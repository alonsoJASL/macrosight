% MOVEMENT INTERACTION ANALYSIS: Script to display results of changes in
% direction from cell-cell contact.
%
%%

tidy;

%whichmacro = 3; % 1, 2 or 3
initscript;
%
load('angleChanges');
T = readtable('./macros123.xlsx');
TS = readtable('./macros123singles.xlsx');

T(~contains(upper(T.whichdataset), ['MACROS' num2str(whichmacro)]),:) = [];
TS(~contains(upper(TS.whichdataset), ['MACROS' num2str(whichmacro)]),:) = [];

vn = {'macros1', 'macros2', 'macros3'};
markers = {'+','*','o'};
cc = {[0 0.53 0.79], [0.89 0.41 0.12], [.95 .74 .16]};
boxlabels = {'Clump size', 'Angle change'};
dsetID = [angleChangesWithInteraction.datasetID]';

% Global variables to create generalised analysis.
for ix=1:length(experimentInfo.whichmacro)
    a.(vn{ix}) = angleChangesWithInteraction(dsetID==ix);
    noa.(vn{ix}) = angleNoInteraction(dsetID==ix);
    istats.(vn{ix}) = interactionStats(dsetID==ix);
end

Tab = [vertcat(interactionStats.clumpsize) ...
    vertcat(interactionStats.thx) ...
    vertcat(angleNoInteraction.angleChange)];
groups = ones(size(Tab));
groups(:,3) = 1.1;
groups = groups.*repmat(dsetID,1,3);

clumpsizes = vertcat(interactionStats.clumpsize);

%% INTERACTIONS: Fill information

whichA = a.(['macros' num2str(whichmacro)]);
whichNoa = noa.(['macros' num2str(whichmacro)]);

try
    load('MACROSinteractionExperiments.mat');
    indx2start = length(allmacros);
catch e
    fprintf('%s: no angle strcture found, creating a new one.\n', mfilename);
    indx2start = 0;
end

anglechange = vertcat(whichA.angleChange);
preaxis = [-40 40 -40 40];

for ix=1:length(whichA)
    mT = T(ix,:);
    wuc= mT.whichclump;
    clumplab = mT.whichlabel;
    ffix=mT.initialframe;
    lfix=mT.finalframe;

    trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
        clumptracktable(ismember(tablenet.track, clumplab),:)];
    [~, ~, xtras] = getclumpanglechange(trackinfo, wuc, [ffix lfix]);

    [prePoints, postPoints] = getpointsforplot(xtras, true);

    mTS = TS(ix,:);
    pretrinf = trackinfo(ismember(trackinfo.timeframe, ...
        mTS.initialfr_pre:mTS.finalfr_pre),:);
    brkidx1 = round(size(pretrinf,1)/2);

    prextras.preXY = [pretrinf.X(1:brkidx1) pretrinf.Y(1:brkidx1)];
    prextras.postXY = [pretrinf.X(brkidx1:end) pretrinf.Y(brkidx1:end)];

    [preP, postP, thnon(ix)] = getpointsforplot(prextras, true);

    allmacros(ix+indx2start).whichmacro = whichmacro;

    allmacros(ix+indx2start).preinteractionpoints = prePoints;
    allmacros(ix+indx2start).postinteractionpoints = postPoints;

    allmacros(ix+indx2start).precontrolpoints = preP;
    allmacros(ix+indx2start).postcontrolpoints = postP;
end

save('MACROSinteractionExperiments.mat', 'allmacros');


%% BOXPLOTS TIME IN CLUMP VS ANGLE CHANGE
close all;
figure(1)
subplot(131)
boxplot(Tab(:,1), groups(:,1))
title('Clump size');
axis square;

subplot(132)
boxplot(abs([Tab(:,2);Tab(:,3)]), ...
    [groups(:,2);groups(:,3)]);
title('Angle change');
axis square;
%
subplot(133)
hold on
for ix=1:3
    scatter(Tab(dsetID==ix,1), abs(Tab(dsetID==ix,2)),100,markers{ix})
end
legend(vn,'FontSize',20);
xlabel('Clump size');
ylabel('angle change');
title('(c) Scatter')
grid on
axis([0 80 0 200])
axis square;

%% COMPARISON TC=a
figure(3)
clf;

ww = [2 4 6 10];

COLS = reshape(1:length(ww)*3,3,length(ww))';
col1 = COLS(:,1);
col2 = COLS(:,2);
col3 = COLS(:,3);

for ix=1:length(ww)

    subplot(length(ww),3, col1(ix))
    idx = clumpsizes<=ww(ix);
    boxplot(abs([Tab(idx,2);Tab(idx,3)]), [groups(idx,2);groups(idx,3)],...
        'Whisker',50);
    title(sprintf('TC <=%d (n=%d)',ww(ix), sum(idx)));
    axis square
    ylim([0 200])

    subplot(length(ww),3, col2(ix))
    hold on;
    for jx=1:3
        scatter(Tab((idx+(dsetID==jx))==2,1), ...
            Tab((idx+(dsetID==jx))==2,2),72,cc{jx},markers{jx});
    end
    idx = clumpsizes>ww(ix);
    for jx=1:3
        scatter(Tab((idx+(dsetID==jx))==2,1), ...
            Tab((idx+(dsetID==jx))==2,2),72,[.5 .5 .5],markers{jx})
    end
    plotVertLine(ww(ix), [0 200]);
    title(sprintf('TC <=%d | TC > %d',ww(ix), ww(ix)));
    axis square
    axis([0 70 0 200])
    grid on

    subplot(length(ww),3, col3(ix))
    boxplot(abs([Tab(idx,2);Tab(idx,3)]), [groups(idx,2);groups(idx,3)],...
        'Whisker',50);
    title(sprintf('TC >%d (n=%d)',ww(ix), sum(idx)));
    axis square
    ylim([0 200])

end
%% ALL INTERACTION PLOTS
close all;
load('MACROSinteractionExperiments.mat');
preaxis = [-40 40 -40 40];

figure(1)
for ix=1:3
    whichmac = allmacros([allmacros.whichmacro]==ix);
    for jx=1:length(whichmac)
        prePoints = whichmac(jx).preinteractionpoints;
        postPoints = whichmac(jx).postinteractionpoints;

        preP = whichmac(jx).precontrolpoints;
        postP = whichmac(jx).postcontrolpoints;

        subplot(3,6,(6*(ix-1) + (1:3)))
        plotsimpledirchange(prePoints, postPoints, true);
        axis(preaxis)
        yticklabels([]);
        grid on;
        hold on;
        subplot(3,6,(6*(ix-1) + (4:6)))
        plotsimpledirchange(preP, postP, false);
        axis(preaxis)
        yticklabels([]);
        grid on;
        hold on;
    end
end

figure(2)
for jx=1:length(allmacros)
    prePoints = allmacros(jx).preinteractionpoints;
    postPoints = allmacros(jx).postinteractionpoints;

    preP = allmacros(jx).precontrolpoints;
    postP = allmacros(jx).postcontrolpoints;

    subplot(211)
    plotsimpledirchange(prePoints, postPoints, true);
    axis(preaxis)
    hold on;
    subplot(212)
    plotsimpledirchange(preP, postP, false);
    grid on;
    hold on;
end


%% INTERACTIONS

whichA = a.(['macros' num2str(whichmacro)]);
whichNoa = noa.(['macros' num2str(whichmacro)]);

anglechange = vertcat(whichA.angleChange);
preaxis = [-40 40 -40 40];
figure(whichmacro)
for ix=1:length(whichA)
    mT = T(ix,:);
    wuc= mT.whichclump;
    clumplab = mT.whichlabel;
    ffix=mT.initialframe;
    lfix=mT.finalframe;

    trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
        clumptracktable(ismember(tablenet.track, clumplab),:)];
    [~, ~, xtras] = getclumpanglechange(trackinfo, wuc, [ffix lfix]);

    [prePoints, postPoints] = getpointsforplot(xtras, true);

    subplot(211)
    plotsimpledirchange(prePoints, postPoints, false);
    axis(preaxis)
    hold on;

    mTS = TS(ix,:);
    pretrinf = trackinfo(ismember(trackinfo.timeframe, ...
        mTS.initialfr_pre:mTS.finalfr_pre),:);
    brkidx1 = round(size(pretrinf,1)/2);

    prextras.preXY = [pretrinf.X(1:brkidx1) pretrinf.Y(1:brkidx1)];
    prextras.postXY = [pretrinf.X(brkidx1:end) pretrinf.Y(brkidx1:end)];

    [preP, postP, thnon(ix)] = getpointsforplot(prextras, true);

    subplot(212)
    plotsimpledirchange(preP, postP, false);
    axis(preaxis)
    hold on;
    %pause;
end
%set(gcf, 'Position', [  40         319        1564         629]);
set(gcf, 'Position', [146 62 1336 894]);
grid on;

%% COMPARISON OF ANGLES with statistical tests

%disp('Angles unchanged');
%disp('ABS(Angle)');
for ix=1:4
    if ix==4
        angleContact = vertcat(angleChangesWithInteraction.angleChange);
        angleNoContact = vertcat(angleNoInteraction.angleChange);

        SS = 'ALL';
    else
        angleContact = vertcat(a.(['macros' num2str(ix)]).angleChange);
        angleNoContact = vertcat(noa.(['macros' num2str(ix)]).angleChange);
        SS = ['MACROS' num2str(ix)];
    end
    m = mean(([angleContact angleNoContact]));
    sd = std([angleContact angleNoContact]);
    [pwill, hwill] = signrank(angleContact, angleNoContact);
    [httest, pttest] = ttest2(angleContact, angleNoContact);

    if hwill==1
        rejwill = 'reject';
    else
        rejwill = 'nope';
    end
    if httest==1
        rejttest = 'reject';
    else
        rejttest = 'nope';
    end
    if ix==1
        fprintf('| With cell-cell  |  NO contact  |     WILLCOXON         |     T-TEST           |\n');
        fprintf('DATASET|   mean (std)    |  mean (std)  | p-value | Can reject? | p-value | Can reject? |\n');
    end
    fprintf('%s| %3.2f (%2.2f) | %3.2f (%2.2f) |  %2.2f  | %s  |   %2.2f  | %s  |\n', ...
        SS, m(1), sd(1), m(2), sd(2), pwill, rejwill, pttest, rejttest);
end

%%
