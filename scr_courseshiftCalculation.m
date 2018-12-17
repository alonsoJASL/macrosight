% COURSE SHIFT (ANGLE CHANGE) CALCULATION
% Runs on a specific case, acquiring one direction changes from a specific
% clump. The clumps and data sre obtained in SCR_REVIEWDATASETFORINTERACTIONS. 
% 
%
%% INITIALISATION
tidy;
whichmacro = 1;
initscript_dev;
% initscript; %
T = readtable('./macros123.xlsx');
T(~contains(upper(T.whichdataset), ['MACROS' num2str(whichmacro)]),:) = [];

TS = readtable('./macros123singles.xlsx');
TS(~contains(upper(TS.whichdataset), ['MACROS' num2str(whichmacro)]),:) = [];

%%
%figure

rowix=9;

mT = T(rowix,:);
mTS = TS(rowix,:);

wuc= mT.whichclump;
clumplab = mT.whichlabel;

trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
    clumptracktable(ismember(tablenet.track, clumplab),:)];

ffix=mT.initialframe;
lfix=mT.finalframe;

fbnchix = mTS.initialfr_pre;
lbnchix = mTS.finalfr_pre;

[clumptrackf, clumppos, bnchmktrackf, bnchmkpos] = getanglechanges(...
    trackinfo, wuc, [ffix lfix], [fbnchix lbnchix]);
[clumppreP, clumppostP] = getpointsforplot(clumppos, clumptrackf.isclump);
[bnchmkpreP, bnchmkpostP] = getpointsforplot(bnchmkpos, bnchmktrackf.isclump);

figure(100)
clf

subplot(211)
plotsimpledirchange(clumppreP, clumppostP, clumptrackf.isclump);
rmticklabels;
set(gcf, 'Position', [40 489 1564 459]);
grid on;
axis([-40 40 -40 40]);

subplot(212)
plotsimpledirchange(bnchmkpreP, bnchmkpostP, bnchmktrackf.isclump);
rmticklabels;
set(gcf, 'Position', [40 489 1564 459]);
grid on;
axis([-40 40 -40 40]);


%%
[~, interactionStats, xtras] = getclumpanglechange(trackinfo, wuc, [ffix lfix]);
[prePoints, postPoints] = getpointsforplot(xtras, true);

angleChangesWithInteraction.datasetID = whichmacro;
angleChangesWithInteraction.clumpID = wuc;
angleChangesWithInteraction.angleChange = interactionStats.thx;
angleChangesWithInteraction.previousLine = xtras.preline;
angleChangesWithInteraction.postLine = xtras.postline;
angleChangesWithInteraction.previousTrackPoints = xtras.preXY;
angleChangesWithInteraction.postTrackPoints = xtras.postXY;

figure(1)
%clf
plotsimpledirchange(prePoints, postPoints, true);
rmticklabels;
set(gcf, 'Position', [40 489 1564 459]);
grid on;
axis([-30 25 -15 15]);

strackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
    clumptracktable(ismember(tablenet.track, clumplab),:)];
pretrinf = strackinfo(ismember(strackinfo.timeframe, ...
    (mTS.initialfr_pre):mTS.finalfr_pre),:);
posttrinf = strackinfo(ismember(strackinfo.timeframe, ...
    mTS.initialfr_post:(mTS.finalfr_post)),:);

brkidx1 = round(size(pretrinf,1)/2);
brkidx2 = round(size(posttrinf,1)/2);
%
prextras.preXY = [pretrinf.X(1:brkidx1) pretrinf.Y(1:brkidx1)];
prextras.postXY = [pretrinf.X(brkidx1:end) pretrinf.Y(brkidx1:end)];
[prePoints, postPoints, thnon] = getpointsforplot(prextras, true);

angleNoInteraction.datasetID = whichmacro;
angleNoInteraction.beforeClump = wuc;
angleNoInteraction.angleChange = thnon;
angleNoInteraction.previousLine = xtras.preline;
angleNoInteraction.postLine = xtras.postline;
angleNoInteraction.previousTrackPoints = prextras.preXY;
angleNoInteraction.postTrackPoints = prextras.postXY;

figure(2)
%clf
plotsimpledirchange(prePoints, postPoints, false);
rmticklabels;
set(gcf, 'Position', [57 42 1564 459]);
grid on;
axis([-30 25 -15 15]);
%

%     postxtras.preXY = [posttrinf.X(1:brkidx2) posttrinf.Y(1:brkidx2)];
%     postxtras.postXY = [posttrinf.X(brkidx2:end) posttrinf.Y(brkidx2:end)];
%     [prePoints, postPoints] = getpointsforplot(postxtras, false);
%     plotsimpledirchange(prePoints, postPoints, false);

%end