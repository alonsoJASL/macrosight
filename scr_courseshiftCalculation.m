% COURSE SHIFT (ANGLE CHANGE) CALCULATION
% Runs on a specific case, acquiring one direction changes from a specific
% clump. The clumps and data sre obtained in SCR_REVIEWDATASETFORINTERACTIONS. 
% 
%
%% INITIALISATION
tidy;
whichmacro = 3;
initscript_dev;
% initscript; %
T = readtable('./macros123.xlsx');
T(~contains(upper(T.whichdataset), ['MACROS' num2str(whichmacro)]),:) = [];

TS = readtable('./macros123singles.xlsx');
TS(~contains(upper(TS.whichdataset), ['MACROS' num2str(whichmacro)]),:) = [];

%%
%figure

rowix=7;

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
[clumppreP, clumppostP] = getpointsforplot(clumppos);
[bnchmkpreP, bnchmkpostP] = getpointsforplot(bnchmkpos);

%
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


