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

trackinfo(~ismember(trackinfo.timeframe, 418:495),:)=[];
trackinfo = tablecompression(trackinfo, clumplab);
%% FULL WORKFLOW (as in log)

% 1. Load known frame
tk=1;
framet = trackinfo.timeframe(tk);
[knownfr] = getCommonVariablesPerFrame(handles, trackinfo, wuc, ...
    filenames{framet}, framet);

% 2. Compute the tracks' variables in the known frame
[kftr] = getKnownTracksVariables(knownfr, trackinfo, clumplab, tk);
% 2.1 Initialise a table with regionprops
ttab = struct2table(kftr.regs(1));

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

% 3.3 Show preliminary results
% LOOK AT LOGS

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
    
    % update clumptracktable
    test1 = clumptracktable(tablenet.timeframe==knownfr.t,:);
    test2 = find(tablenet.timeframe==knownfr.t);
    indx = test2(test1.clumpcode==wuc);
    
    clumptracktable(indx,:).Variables = ...
        zeros(size(clumptracktable(indx,:).Variables));
    
    if isempty(find(clumptracktable.clumpcode==wuc, 1))
        % removing the clump code if the clump is completely removed
        fprintf('%s: Clump removed from dataset.\n', mfilename);
        clumpidcodes(clumpidcodes==wuc) = [];
    end
    
    
    ButtonName = questdlg('Do you want to save the updated variables?', ...
        'Update variables to HDD?','Yes', 'No','No');
    switch ButtonName
        case 'Yes'
            save(fullfile(filenames{knownfr.t}), ...
                'dataG','dataL','clumphandles','statsData','numNeutrop');
            save(fullfile('clumptrackingtables.mat'), ...
                'clumptracktable', 'clumpidcodes', 'timedfinalnetwork', ...
                'tablenet');
            
            fprintf('%s: variables have been updated to HDD.\n',...
                mfilename);
        case 'No'
            fprintf('%s: Nothing got saved to the hard drive.\n',...
                mfilename);
    end
    clear ButtonName;
    
    knownfr.hasclump = false;
    knownfr.clumpseglabel = [];
    knownfr.thisclump = [];
end
framet = frametplusT;

% 3.4.2 Update kftr
auxfr.regs = regionprops(zeros(size(knownfr.dataGR)), ...
    'BoundingBox', 'Perimeter', 'Area','EquivDiameter', 'MajorAxisLength', ...
    'MinorAxisLength');
auxfr.boundy = newfr.evoshape;
auxfr.xy = newfr.xy;

tk = tk+1;
for wtr=1:length(clumplab)
    thiscell = newfr.evomask(:,:,wtr)>0;
    regs = regionprops(thiscell, 'BoundingBox', 'Perimeter', 'Area', ...
        'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength');
    
    midx = find([regs.Area]==max([regs.Area]));
    auxfr.regs(wtr) = regs(midx);
    
    cellregs(tk,:,wtr) = [regs(midx).Area ...
        regs(midx).MinorAxisLength/regs(midx).MajorAxisLength ...
        regs(midx).EquivDiameter ...
        regs(midx).Perimeter/regs(midx).Area];
end

kftr = auxfr;
ttab = struct2table(kftr.regs(1));

clear auxfr acopt midx;
