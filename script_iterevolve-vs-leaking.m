% script: single shape analysis (SINGLE UNKNOWN FRAME)
%
%% INITIALISATION
initscript;
load DATASETHOLES
%% CHOOSE TRACKS
% w.u.c = which unique clump!
wuc = 8007; % 8002, 8007, 11010, 8007005, 60010, 60010002, 15014013
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
[knownfr, kftr] = updateKnownFrame(ukfr, newfr, clumplab);
if ukfr.hasclump == true && false % change to true for updating info to disk
    update2disk(handles, knownfr, newfr, wuc);
end
framet = frametplusT;

ttab = [ttab;struct2table(kftr.regs(1))];

tk = tk+1;