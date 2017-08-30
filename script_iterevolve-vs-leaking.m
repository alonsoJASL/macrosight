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

trackinfo(~ismember(trackinfo.timeframe, 418:478),:)=[];
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
% 2.2 Unse anglegram measurements for LOLZ
[ag] = computeMultiAnglegram(kftr.boundy(1));

agopt.mainthresh = 150;
agopt.offsetVar = 7;
agopt.statsfname = 'max';
[candies, candyh] = computeCandidatePoints(ag, kftr.boundy{1}, agopt);

hag.nCandy = size(candies(candyh.intensityPeaks>180,:),1);
hag.meanAg = candyh.meanAM;
hag.stdAg = candyh.stdAM;
hag.frobNorm = norm(ag,'fro');
hag.spectralRadius = max(abs(eig(ag'*ag)));
hag.maxsvd = max(svd(ag));
hag.rankAG = rank(ag);
hag.rankRatio = hag.rankAG/size(ag,2);

%% 3. start 'loop'
% 3.1 Load the unknown frame
for tk=1:(length(trackinfo.timeframe)-1)
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
if false
figure(1)
plotBoundariesAndPoints(ukfr.X, newfr.movedboundy, newfr.evoshape, 'm-');
title(sprintf('Frame %d', frametplusT));
if ukfr.hasclump == true
    plotBoundariesAndPoints([],[],bwboundaries(ukfr.thisclump), ':y');
end
pause(0.3);
end

% 3.4 Update
% 3.4.1 Update knownfr
[knownfr, kftr] = updateKnownFrame(ukfr, newfr, clumplab);
if ukfr.hasclump == true && false % change to true for updating info to disk
    update2disk(handles, knownfr, newfr, wuc);
end
framet = frametplusT;

ttab = [ttab;struct2table(kftr.regs(1))];
% 2.2 Unse anglegram measurements for LOLZ
[ag] = computeMultiAnglegram(kftr.boundy(1));
[candies, candyh] = computeCandidatePoints(ag, kftr.boundy{1}, agopt);

hag.nCandy = [hag.nCandy;size(candies(candyh.intensityPeaks>180,:),1)];
hag.meanAg = [hag.meanAg; candyh.meanAM];
hag.stdAg = [hag.stdAg; candyh.stdAM];
hag.frobNorm = [hag.frobNorm; norm(ag,'fro')];
hag.spectralRadius = [ hag.spectralRadius; max(abs(eig(ag'*ag)))];
hag.maxsvd = [hag.maxsvd; max(svd(ag))];
hag.rankAG = [hag.rankAG; rank(ag)];
hag.rankRatio =[hag.rankRatio; (rank(ag)/size(ag,2))];
end
%tk = tk+1;

%% Shape measurements

aspectRatio = ttab.MinorAxisLength./ttab.MajorAxisLength;
circularity = (4*pi).*(ttab.Area./(ttab.Perimeter.^2));

propertiesTable = [ttab(:,1) table(aspectRatio, circularity) ttab(:,5:end)];
agramTable = struct2table(hag);
agramTable(:,1) = [];
%% 
ffns = fieldnames(propertiesTable);
ffns(end-2:end) = [];

figure(1)
for ix=1:length(ffns)
    subplot(2,3,ix)
    whichY = propertiesTable.(ffns{ix});
    plotVarandDiff(trackinfo.timeframe, whichY, ffns{ix});
    title(ffns{ix});
    grid on
end


ffns = fieldnames(agramTable);
ffns(end-2:end) = [];

figure(2)
for ix=1:length(ffns)
    subplot(2,4,ix)
    whichY = agramTable.(ffns{ix});
    plotVarandDiff(trackinfo.timeframe, whichY, ffns{ix});
    title(ffns{ix});
    grid on
end



