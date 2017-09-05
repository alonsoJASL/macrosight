% script: single shape analysis (SINGLE UNKNOWN FRAME)
%
%% INITIALISATION
initscript;
load DATASETHOLES
%% CHOOSE TRACKS
% w.u.c = which unique clump!
wuc = 11010; % 8002, 8007, 11010, 14013, 8007005, 60010, 60010002, 15014013

fprintf('%s:Working on clump with ID=%d.\n', mfilename, wuc);

% get labels from the clump
clumplab = getlabelsfromcode(wuc);
trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 11 13 14]) ...
    clumptracktable(ismember(tablenet.track, clumplab),:)];

% remove holes from analysis
trackinfo(ismember(trackinfo.timeframe,DATASETHOLES),:) = [];

%% Extract frames where the clump exists
trackinfo(~ismember(trackinfo.timeframe, 1:20),:)=[];
trackinfo = tablecompression(trackinfo, clumplab);
%% FULL WORKFLOW (as in log)
% 1. Load known frame
tk=1;
framet = trackinfo.timeframe(tk);
[knownfr] = getCommonVariablesPerFrame(handles, trackinfo, wuc, ...
    filenames{framet}, framet);

% 2. Compute the tracks' variables in the known frame
[kftr] = getKnownTracksVariables(knownfr, trackinfo, clumplab, tk);

% initialisation of parameters
acopt.method = 'Chan-Vese';
acopt.iter = 25;
acopt.smoothf = 1.5;
acopt.contractionbias = -0.1;
acopt.erodenum = 5;
%% 3. start 'loop'
% 3.1 Load the unknown frame
debugvar = true;

%for tk=1:(length(trackinfo.timeframe)-1)
tkp1 = tk+1;
frametplusT = trackinfo.timeframe(tkp1);
[ukfr] = getCommonVariablesPerFrame(handles, trackinfo, wuc, ...
    filenames{frametplusT}, frametplusT);

% 3.2 Evolve
acopt.whichfn = 'inversegrad';
[newfr] = nextframeevolution(ukfr, kftr, trackinfo, clumplab, acopt);

%  3.4 Update
% 3.4.1 Update knownfr
[knownfr, kftr] = updateKnownFrame(ukfr, newfr, clumplab);
if ukfr.hasclump == true && false % change to true for updating info to disk
    update2disk(handles, knownfr, newfr, wuc);
end
framet = frametplusT;

% 3.3 Show preliminary results
% LOOK AT LOGS
if debugvar == true
    f11=figure(11);
    plotBoundariesAndPoints(ukfr.X, newfr.movedboundy, newfr.evoshape, 'm-');
    title(sprintf('Frame %d', frametplusT));
    if ukfr.hasclump == true
        plotBoundariesAndPoints([],[],bwboundaries(ukfr.thisclump), ':y');
    end
end

%end
tk = tk+1;
%% Shape measurements
whichlab = 2;
propt = ttab{whichlab};
agtab = hag(whichlab);

aspectRatio = propt.MinorAxisLength./propt.MajorAxisLength;
circularity = (4*pi).*(propt.Area./(propt.Perimeter.^2));

propertiesTable = [propt(:,1) table(aspectRatio, circularity) propt(:,5:end)];
agramTable = struct2table(agtab);
%
ffns = fieldnames(propertiesTable);
ffns2 = fieldnames(agramTable);

ffns2(end-2:end) = [];
ffns(end-2:end) = [];

figure(clumplab(whichlab))
for ix=1:length(ffns)
    subplot(4,3,ix)
    whichY = propertiesTable.(ffns{ix});
    plotVarandDiff(trackinfo.timeframe, whichY, ffns{ix});
    title(ffns{ix});
    grid on
    
    subplot(4,3,6+ix)
    whichY = agramTable.(ffns2{ix});
    plotVarandDiff(trackinfo.timeframe, whichY, ffns2{ix});
    title(ffns2{ix});
    grid on
end


