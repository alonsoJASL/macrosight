% script: single shape analysis (SINGLE UNKNOWN FRAME)
%
%% INITIALISATION
initscript;
load DATASETHOLES
%% CHOOSE TRACKS
% w.u.c = which unique clump!
wuc = 8007005; % 8002, 8007, 11010, 8007005, 60010, 60010002, 15014013
fprintf('%s:Working on clump with ID=%d.\n', mfilename, wuc);

% get labels from the clump
clumplab = getlabelsfromcode(wuc);
trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 11 13 14]) ...
    clumptracktable(ismember(tablenet.track, clumplab),:)];

% remove holes from analysis
trackinfo(ismember(trackinfo.timeframe,DATASETHOLES),:) = [];

%% Extract frames where the clump exists

% for clump 8002
% trackinfo(trackinfo.timeframe<418,:) = [];
% for clump 11010
% trackinfo(trackinfo.timeframe>=144,:)=[];
% for clump 8007005
% trackinfo(~ismember(trackinfo.timeframe, 15:18),:)=[];

% Select range for clump automatically feature will be added later.

aa = table2struct(trackinfo(1:length(clumplab):end,:));
jx=1:length(clumplab):size(trackinfo,1);
fields = {'X','Y','seglabel','track','finalLabel'};
for ix=1:length(jx)
    for kx=1:length(fields)
        auxvect = zeros(1,length(clumplab));
        for qx=1:length(clumplab)
            auxvect(qx) =  trackinfo(jx(ix)+(qx-1),:).(fields{kx});
        end
        aa(ix).(fields{kx}) = auxvect;
    end
    aa(ix).clumpseglabel = aa(ix).seglabel(1)*(aa(ix).clumpcode>0);
end

trackinfo = struct2table(aa);
clear ix jx;

%% FULL WORKFLOW (as in log)

% 1. Load known frame
tk=1;
framet = trackinfo.timeframe(tk);
[knownfr] = getCommonVariablesPerFrame(handles, trackinfo, wuc, ...
    filenames{framet}, framet);

% 2. Compute the tracks' variables in the known frame
kftr.regs = regionprops(zeros(size(knownfr.dataGR)), ...
    'BoundingBox', 'Centroid', 'EquivDiameter', 'MajorAxisLength', ...
    'MinorAxisLength');
kftr.boundy = cell(length(clumplab),1);
kftr.xy = zeros(length(clumplab),2);

for wtr=1:length(clumplab)
    % K.F.Tf = Known Frames' TRacks
    thisseglabel = trackinfo.seglabel(tk, wtr);
    thiscell = knownfr.clumphandles.nonOverlappingClumps==thisseglabel;
    regs = regionprops(thiscell, 'BoundingBox', 'Centroid', ...
        'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength');
    boundy = bwboundaries(thiscell);
    xin = trackinfo(trackinfo.timeframe==framet,:).X(wtr);
    yin = trackinfo(trackinfo.timeframe==framet,:).Y(wtr);

    kftr.regs(wtr) = regs;
    kftr.boundy{wtr} = boundy{1};
    kftr.xy(wtr,:) = [xin yin];

    clear thisseglabel thiscell regs boundy xin yin
end

figure(1)
clf;
plotBoundariesAndPoints(knownfr.X, kftr.boundy);
title(sprintf('Frame %d', framet));
auxstr1 = sprintf('Original boundary t=%d',framet);
auxstr2 = sprintf('Original boundary t=%d',framet);
legend(auxstr1,'',auxstr2,'', 'Location','northeast');
%axis([209  502 115 383]); % wuc=8002
%axis([300 567 183 391]); % wuc=11010
axis([105 398 50 258]); % wuc=8007005


%% 3. start 'loop'
% 3.1 Load the unknown frame
tkp1 = tk+1;
frametplusT = trackinfo.timeframe(tkp1);
[ukfr] = getCommonVariablesPerFrame(handles, trackinfo, wuc, ...
    filenames{frametplusT}, frametplusT);

% 3.2 Evolve
acopt.method = 'Chan-Vese';
acopt.iter = 50;
acopt.smoothf = 1.5;
acopt.contractionbias = -0.1;
acopt.erodenum = 5;
[newfr] = nextframeevolution(ukfr, kftr, trackinfo, clumplab, acopt);

% 3.3 Preliminary result showing: 
figure(1)
clf;
plotBoundariesAndPoints(ukfr.X, newfr.movedboundy, newfr.evoshape, 'm-');
title(sprintf('Frame %d', frametplusT));
if ukfr.hasclump == true
    plotBoundariesAndPoints([],[],bwboundaries(ukfr.thisclump), ':y');
end
%axis([209  502 115 383]); % wuc=8002
%axis([300 567 183 391]); % wuc=11010
axis([105 398 50 258]); % wuc=8007005

% 3.4 Update
% 3.4.1 Update knownfr
knownfr = ukfr;
if knownfr.hasclump == true
    % 3.4.1.1 Change variables and save them back to the HDD
    fprintf('%s: a clump has been disambiguated!\n', mfilename);
    load(fullfile(handles.dataLa, filenames{knownfr.t}));
    
    dataL = knownfr.dataL;
    dataG = knownfr.dataGL;
    clumphandles = knownfr.clumphandles;
    
    idx = find(dataG==ukfr.clumpseglabel);
    dataG(idx) = 0;
    clumphandles.overlappingClumps(idx)=0;

    for kx=1:length(clumplab)
        dataG = dataG + newfr.evomask(:,:,kx);
        clumphandles.nonOverlappingClumps = ...
            clumphandles.nonOverlappingClumps + newfr.evomask(:,:,kx);
    end
    save(filenames{knownfr.t}, 'dataG','dataL','clumphandles','statsData',...
        'numNeutrop');
    fprintf('%s: variables DATAGL and CLUMPHANDLES have been updated.\n',...
        mfilename);
    
    
    
    knownfr.hasclump = false;
    knownfr.clumpseglabel = [];
    knownfr.thisclump = [];
end
framet = frametplusT;

% 3.4.2 Update kftr
auxfr.regs = regionprops(zeros(size(knownfr.dataGR)), ...
    'BoundingBox', 'Centroid', 'EquivDiameter', 'MajorAxisLength', ...
    'MinorAxisLength');
auxfr.boundy = newfr.evoshape;
auxfr.xy = newfr.xy;

for wtr=1:length(clumplab)
    thiscell = newfr.evomask(:,:,wtr)>0;
    regs = regionprops(thiscell, 'BoundingBox', 'Centroid', ...
        'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength');

    auxfr.regs(wtr) = regs;
end

kftr = auxfr;
clear auxfr acopt;
 
tk = tk+1;
