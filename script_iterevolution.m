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

% to track maximium correlations
trackMaxCorr = zeros(size(trackinfo,1),length(clumplab));

%% LOADING THE FIRST (KNOWN) FRAME

ix=1;
t0 = (ix+1):size(trackinfo,1);
jx=1;

framet = trackinfo.timeframe(ix);
frametplusT = trackinfo.timeframe(t0(jx));

fprintf('\n%s: Loading original (known) frame: %s and unknown frame: %s.\n', ...
    mfilename, filenames{framet}, filenames{frametplusT});

[knownfr] = getdatafromhandles(handles, filenames{framet});
[ukfr] = getdatafromhandles(handles, filenames{frametplusT});

knownfr.t=framet;

ukfr.t=frametplusT;
if trackinfo.clumpcode(t0(jx)) == wuc
    ukfr.hasclump = true;
    ukfr.clumpseglabel = trackinfo.clumpseglabel(t0(jx));
    ukfr.thisclump = (oneuk.dataGL==ukfr.clumpseglabel);
else
    ukfr.hasclump = false;
end

%% KNOWN FRAME: track dependent variables:

% initialise some variables
kftr.regs = regionprops(zeros(size(knownfr.dataGR)), ...
    'BoundingBox', 'Centroid', 'EquivDiameter', 'MajorAxisLength', ...
    'MinorAxisLength');
kftr.boundy = cell(length(clumplab),1);
kftr.xy = zeros(length(clumplab),2);
% wtr = W.TR = Which TRack
%wtr = 1;
for wtr=1:length(clumplab)
    
    % K.F.Tf = Known Frames' TRacks
    thisseglabel = trackinfo.seglabel(ix, wtr);
    thiscell = knownfr.clumphandles.nonOverlappingClumps==thisseglabel;
    regs = regionprops(thiscell, 'BoundingBox', 'Centroid', ...
        'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength');
    boundy = bwboundaries(thiscell);
    xinit = trackinfo(trackinfo.timeframe==framet,:).X(wtr);
    yinit = trackinfo(trackinfo.timeframe==framet,:).Y(wtr);
    
    kftr.regs(wtr) = regs;
    kftr.boundy{wtr} = boundy{1};
    kftr.xy(wtr,:) = [xinit yinit];
    
    clear thisseglabel thiscell regs boundy xinit yinit
end


%% UNKNOWN FRAME: track dependent variables (turned to a new.fr = NEW FRame)

newfr.xy = zeros(length(clumplab),2);
newfr.movedboundy = cell(length(clumplab),1);
newfr.movedbb = zeros(length(clumplab),4);
newfr.evomask = zeros(handles.rows, handles.cols, length(clumplab));
newfr.evoshape = cell(length(clumplab),1);

acopt.framesAhead = jx;
acopt.method = 'Chan-Vese';
acopt.iter = 50;
acopt.smoothf = 1.5;
acopt.contractionbias = -0.1;

for wtr=1:length(clumplab)
    
    xinit = trackinfo(trackinfo.timeframe==frametplusT,:).X(wtr);
    yinit = trackinfo(trackinfo.timeframe==frametplusT,:).Y(wtr);
    
    boundy = kftr.boundy{wtr} + repmat([xinit yinit]-kftr.xy(wtr,:),...
        size(kftr.boundy{wtr},1),1);
    bb = kftr.regs(wtr).BoundingBox + ...
        ([yinit xinit 0 0] - [kftr.xy(wtr,2:-1:1) 0 0]);
    
    newfr.movedboundy{wtr} = boundy;
    newfr.movedbb(wtr,:) = bb;
    newfr.xy(wtr,:) = [xinit yinit];
    
    movedmask = imerode(poly2mask(boundy(:,2), boundy(:,1), ...
        handles.rows, handles.cols), ones(5));
    
    evomask = activecontour(ukfr.dataGR, movedmask, acopt.iter, ...
    acopt.method, 'ContractionBias',acopt.contractionbias,...
    'SmoothFactor', acopt.smoothf);
    evoshape = bwboundaries(evomask);

    newfr.evomask(:,:,wtr) = evomask;
    newfr.evoshape{wtr} = evoshape{1};
    
    clear xinit yinit boundy bb
end

%% update tk = t(k-1)+k
