% script: single shape analysis (SINGLE UNKNOWN FRAME)
%
%% INITIALISATION
initscript;
load DATASETHOLES
%% CHOOSE TRACKS
% w.u.c = which unique clump!
wuc = 8002; % 8002, 8007, 11010, 8007005, 60010, 60010002, 15014013
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
legend(auxstr1,'',auxstr2,'', 'Location','northwest');
axis([209  502 115 383]);

f = getframe(gcf);
[im, map] = rgb2ind(f.cdata, 256, 'nodither');
im(1,1,1,size(trackinfo,1)-1) = 0;

%% 3. start 'loop'
% 3.1 Load the unknown frame
tkp1 = tk+1;
frametplusT = trackinfo.timeframe(tkp1);
[ukfr] = getCommonVariablesPerFrame(handles, trackinfo, wuc, ...
    filenames{frametplusT}, frametplusT);

% 3.2 Evolve
acopt.method = 'Chan-Vese';
acopt.iter = 50;
acopt.smoothf = 2;
acopt.contractionbias = -0.1;
[newfr] = nextframeevolution(ukfr, kftr, trackinfo, clumplab, acopt);

% 3.3 Preliminary result showing: 
figure(1)
clf;
plotBoundariesAndPoints(ukfr.X, newfr.movedboundy, newfr.evoshape, 'm-');
title(sprintf('Frame %d', frametplusT));
auxstr1 = sprintf('Original boundary t=%d',framet);
auxstr2 = sprintf('Original boundary t=%d',framet);
auxstr3 = sprintf('Evolved boundary t+1=%d',frametplusT);
auxstr4 = sprintf('Evolved boundary t+1=%d',frametplusT);
if ukfr.hasclump == true
    plotBoundariesAndPoints([],[],bwboundaries(ukfr.thisclump), ':y');
    legend(auxstr1,'', auxstr2, '', auxstr3, auxstr4, 'clump detected', ...
        'Location','northwest');    
else
    legend(auxstr1,'', auxstr2, '', auxstr3, auxstr4, 'Location','northwest');
end
axis([209  502 115 383]);

if tk<=size(trackinfo,1)
    disp('yeees')
    f = getframe(gcf);
    im(:,:,1,tk) = rgb2ind(f.cdata, map, 'nodither');
end

% 3.4 Update
% 3.4.1 Update knownfr
knownfr = ukfr;
if knownfr.hasclump == true
    knwonfr.hasclump = false;
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
%% LOADING THE FIRST FRAME and FRAME t0+1 (unknown)

tk=1;
framet = trackinfo.timeframe(tk);

tkp1 = tk+1;
frametplusT = trackinfo.timeframe(tkp1);

fprintf('\n%s: Loading original (known) frame: %s and unknown frame: %s.\n', ...
    mfilename, filenames{framet}, filenames{frametplusT});

[knownfr] = getdatafromhandles(handles, filenames{framet});
knownfr.t=framet;
knownfr.hasclump = false;
knownfr.clumpseglabel = [];
knownfr.thisclump = [];

[ukfr] = getdatafromhandles(handles, filenames{frametplusT});

ukfr.t=frametplusT;
if trackinfo.clumpcode(tkp1) == wuc
    ukfr.hasclump = true;
    ukfr.clumpseglabel = trackinfo.clumpseglabel(tkp1);
    ukfr.thisclump = (ukfr.dataGL==ukfr.clumpseglabel);
else
    ukfr.hasclump = false;
    ukfr.clumpseglabel = [];
    ukfr.thisclump = [];
end

%% KNOWN FRAME: track dependent variables:
% initialise variables
kftr.regs = regionprops(zeros(size(knownfr.dataGR)), ...
    'BoundingBox', 'Centroid', 'EquivDiameter', 'MajorAxisLength', ...
    'MinorAxisLength');
kftr.boundy = cell(length(clumplab),1);
kftr.xy = zeros(length(clumplab),2);

% wtr = W.TR = Which TRack
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

%% UNKNOWN FRAME: track dependent variables (turned to a new.fr = NEW FRame)
[newfr] = nextframeevolution(ukfr, kftr, trackinfo, clumplab);
%% update tk = t(k-1)+k
% LOADING THE FIRST FRAME and FRAME t0+1 (unknown)
tk=tk+1;
tkp1 = tk+1;

framet = frametplusT;
frametplusT = trackinfo.timeframe(tkp1);

fprintf('\n%s: Loading original (known) frame: %s and unknown frame: %s.\n', ...
    mfilename, filenames{framet}, filenames{frametplusT});

% check if hasclump needs to be addressed and update knownfr
knownfr = ukfr;
% then update ukfr
[ukfr] = getdatafromhandles(handles, filenames{frametplusT});

ukfr.t=frametplusT;
if trackinfo.clumpcode(tkp1) == wuc
    ukfr.hasclump = true;
    ukfr.clumpseglabel = trackinfo.clumpseglabel(tkp1);
    ukfr.thisclump = (oneuk.dataGL==ukfr.clumpseglabel);
else
    ukfr.hasclump = false;
end

%% update tk = t(k-1)+k
% updating the track-dependent variables kftr

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

clear auxfr;

%% DEVELOPMENT OF NEXTFRAMEEVOLUTION ROUTINE
% UNKNOWN FRAME: track dependent variables (turned to a new.fr = NEW FRame)

if false % to debug, erase this or change to true
fprintf('%s: Evolving shape to frame t%d = t%d+1.\n', ...
    mfilename, tkp1, tk);

newfr.xy = zeros(length(clumplab),2);
newfr.movedboundy = cell(length(clumplab),1);
newfr.movedbb = zeros(length(clumplab),4);
newfr.evomask = zeros(handles.rows, handles.cols, length(clumplab));
newfr.evoshape = cell(length(clumplab),1);

acopt.framesAhead = 1;
acopt.method = 'Chan-Vese';
acopt.iter = 50;
acopt.smoothf = 2;
acopt.contractionbias = -0.1;

for wtr=1:length(clumplab)
    
    xin = trackinfo(trackinfo.timeframe==frametplusT,:).X(wtr);
    yin = trackinfo(trackinfo.timeframe==frametplusT,:).Y(wtr);
    
    boundy = kftr.boundy{wtr} + repmat([xin yin]-kftr.xy(wtr,:),...
        size(kftr.boundy{wtr},1),1);
    bb = kftr.regs(wtr).BoundingBox + ...
        ([yin xin 0 0] - [kftr.xy(wtr,2:-1:1) 0 0]);
    
    newfr.movedboundy{wtr} = boundy;
    newfr.movedbb(wtr,:) = bb;
    newfr.xy(wtr,:) = [xin yin];
    
    movedmask = imerode(poly2mask(boundy(:,2), boundy(:,1), ...
        handles.rows, handles.cols), ones(5));
    
    evomask = activecontour(ukfr.dataGR, movedmask, acopt.iter, ...
        acopt.method, 'ContractionBias',acopt.contractionbias,...
        'SmoothFactor', acopt.smoothf);
    evoshape = bwboundaries(evomask);
    
    newfr.evomask(:,:,wtr) = evomask.*trackinfo.seglabel(tk+1, wtr);
    newfr.evoshape{wtr} = evoshape{1};
    
    clear xin yin boundy bb movedmask evomask
end
end
