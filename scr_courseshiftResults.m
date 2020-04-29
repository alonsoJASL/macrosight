% MOVEMENT INTERACTION ANALYSIS: Script to display results of changes in
% direction from cell-cell contact.
%
%%

tidy;

%whichmacro = 3; % 1, 2 or 3
%initscript_dev;
%
load('DATA/angleChanges');

vn = {'macros1', 'macros2', 'macros3'};
markers = {'+','*','o'};
cc = {[0 0.53 0.79], [0.89 0.41 0.12], [.95 .74 .16]};
boxlabels = {'Clump size', 'Angle change'};
dsetID = [generalinfo.datasetID]';

% Global variables to create generalised analysis.
for ix=1:length(experimentInfo.whichmacro)
    a.(vn{ix}) = clumpanglechanges(dsetID==ix);
    noa.(vn{ix}) = bnchmkanglechanges(dsetID==ix);
    atrfeat.(vn{ix}) = clumptrackfeatures(dsetID==ix);
    noatrfeat.(vn{ix}) = bnchmktrackfeatures(dsetID==ix);
end

Tab = [vertcat(clumptrackfeatures.clumpsize) ...
    vertcat(clumptrackfeatures.thx) ...
    vertcat(bnchmktrackfeatures.thx)];
groups = ones(size(Tab));
groups(:,3) = 1.1;
groups = groups.*repmat(dsetID,1,3);

clumpsizes = vertcat(clumptrackfeatures.clumpsize);

abstab = abs(Tab);

%% Fig 4. BOXPLOTS TIME IN CLUMP VS ANGLE CHANGE

figure(41)
subplot(221)
boxplot(Tab(:,1), groups(:,1))
title('Clump size');
axis square;

subplot(222)
boxplot([Tab(:,2);Tab(:,3)], ...
    [groups(:,2);groups(:,3)]);
title('Angle change');
axis square;
%
subplot(223)
hold on
for ix=1:3
    scatter(Tab(dsetID==ix,1), Tab(dsetID==ix,2),110,markers{ix})
end
legend(vn,'FontSize',20);
xlabel('Clump size');
ylabel('angle change');
title('(c) Scatter')
grid on
%axis([0 80 0 200])
xlim([0 80]);
axis square;

subplot(224)
hold on
for ix=1:3
    scatter(Tab(dsetID==ix,1), Tab(dsetID==ix,2),110,markers{ix})
end
legend(vn,'FontSize',20);
xlabel('Clump size');
ylabel('angle change');
title('(d) Scatter (zoom)')
grid on
%axis([0 80 0 200])
xlim([0 20]);
axis square;


%% figures with abs(angle)
figure(42)
subplot(131)
boxplot(Tab(:,1), groups(:,1))
title('Clump size');
axis square;

subplot(132)
boxplot([abstab(:,2);abstab(:,3)], ...
    [groups(:,2);groups(:,3)]);
title('Angle change');
axis square;
%
subplot(133)
hold on
for ix=1:3
    scatter(Tab(dsetID==ix,1), abstab(dsetID==ix,2),110,markers{ix})
end
legend(vn,'FontSize',20);
xlabel('Clump size');
ylabel('angle change');
title('(c) Scatter')
grid on
%axis([0 80 0 200])
xlim([0 80]);
axis square;

%% Fig 3. COMPARISON TC=a
figure(3)
clf;

ww = [2 6 10];

COLS = reshape(1:length(ww)*3,3,length(ww))';
col1 = COLS(:,1);
col2 = COLS(:,2);
col3 = COLS(:,3);

for ix=1:length(ww)
    
    subplot(length(ww),3, col1(ix))
    idx = clumpsizes<=ww(ix);
    boxplot([Tab(idx,2);Tab(idx,3)], [groups(idx,2);groups(idx,3)],...
        'Whisker',50);
    title(sprintf('TC <=%d (n=%d)',ww(ix), sum(idx)));
    axis square
    xlim([0.5 6.5])
    ylim([-180 180])
    
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
    plotVertLine(ww(ix), [-180 180]);
    title(sprintf('TC <=%d & TC > %d',ww(ix), ww(ix)));
    axis square
    axis([0 20 -180 180])
    grid on
    
    subplot(length(ww),3, col3(ix))
    boxplot([Tab(idx,2);Tab(idx,3)], [groups(idx,2);groups(idx,3)],...
        'Whisker',50);
    title(sprintf('TC >%d (n=%d)',ww(ix), sum(idx)));
    axis square
    xlim([0.5 6.5])
    ylim([-180 180])
    
end
%% Figs 1,2 ALL INTERACTION PLOTS

preaxis = [-30 40 -20 35];

figure(1)
clf
for ix=1:3
    whichidx = find([generalinfo.datasetID]==ix);
    for jx=1:length(whichidx)
        subplot(3,6,(6*(ix-1) + (1:3)))
        plotsimpledirchange(clumpplot(whichidx(jx)).plotprepoints, ...
            clumpplot(whichidx(jx)).plotpostpoints, true);
        %yticklabels([]);
        axis(preaxis)
        grid on;
        %hold on;
        subplot(3,6,(6*(ix-1) + (4:6)))
        plotsimpledirchange(bnchmkplot(whichidx(jx)).plotprepoints,...
            bnchmkplot(whichidx(jx)).plotpostpoints, false);
        axis(preaxis)
        %yticklabels([]);
        grid on;
        %hold on;
    end
end

%%
figure(2)
for jx=1:length(clumpplot)
    subplot(211)
    plotsimpledirchange(clumpplot(jx).plotprepoints, ...
        clumpplot(jx).plotpostpoints, true);
    axis(preaxis)
    hold on;
    subplot(212)
    plotsimpledirchange(bnchmkplot(jx).plotprepoints,...
        bnchmkplot(jx).plotpostpoints, false);
    axis(preaxis)
    grid on;
    hold on;
end

%% COMPARISON OF ANGLES with statistical tests

absbool = true;
if absbool
    disp('ABS(Angle)');
else
    disp('Angles unchanged');
end
for ix=1:4
    if ix==4
        angleContact = vertcat(clumptrackfeatures.thx);
        angleNoContact = vertcat(bnchmktrackfeatures.thx);
        
        SS = sprintf('ALL\t   ');
    else
        angleContact = vertcat(atrfeat.(['macros' num2str(ix)]).thx);
        angleNoContact = vertcat(noatrfeat.(['macros' num2str(ix)]).thx);
        SS = ['MACROS' num2str(ix)];
    end
    if absbool
        angleContact = abs(angleContact);
        angleNoContact = abs(angleNoContact);
    end
    
    m = mean(([angleContact angleNoContact]));
    sd = std([angleContact angleNoContact]);
    [pwill, hwill] = signrank(angleContact, angleNoContact);
    [httest, pttest] = ttest2(angleContact, angleNoContact);
    
    if hwill==1
        rejwill = 'reject';
    else
        rejwill = sprintf('nope\t');
    end
    if httest==1
        rejttest = 'reject';
    else
        rejttest = sprintf('nope\t');
    end
    if ix==1
        fprintf('\t   & With cell-cell  &  NO contact  &     WILLCOXON         &     T-TEST           &\n');
        fprintf('DATASET&   mean (std)    &  mean (std)  & p-value & Can reject? & p-value & Can reject? &\n');
    end
    fprintf('%s& %3.2f (%2.2f)  & %3.2f (%2.2f)  &  %2.2f   & %s  &   %2.2f  & %s  &\n', ...
        SS, m(1), sd(1), m(2), sd(2), pwill, rejwill, pttest, rejttest);
end

disp('REJECT = there is statistical difference, NOPE = no statistical difference in the angles');

%% COMPARISON OF ANGLES and TC with statistical tests

absbool = false;
if absbool
    disp('ABS(Angle)');
else
    disp('Angles unchanged');
end

for ix=1:4
    if ix==4
        angleContact = vertcat(clumptrackfeatures.thx);
        angleNoContact = vertcat(bnchmktrackfeatures.thx);
        
        SS = sprintf('ALL\t   ');
    else
        angleContact = vertcat(atrfeat.(['macros' num2str(ix)]).thx);
        angleNoContact = vertcat(noatrfeat.(['macros' num2str(ix)]).thx);
        SS = ['MACROS' num2str(ix)];
    end
    if absbool
        angleContact = abs(angleContact);
        angleNoContact = abs(angleNoContact);
    end
    
    m = mean(([angleContact angleNoContact]));
    sd = std([angleContact angleNoContact]);
    [pwill, hwill] = signrank(angleContact, angleNoContact);
    [httest, pttest] = ttest2(angleContact, angleNoContact);
    
    if hwill==1
        rejwill = 'reject';
    else
        rejwill = sprintf('nope\t');
    end
    if httest==1
        rejttest = 'reject';
    else
        rejttest = sprintf('nope\t');
    end
    if ix==1
        fprintf('\t   & With cell-cell  &  NO contact  &     WILLCOXON         &     T-TEST         \\\\\n');
        fprintf('DATASET&   mean (std)    &  mean (std)  & p-value & p-value  \\\\\n');
    end
    fprintf('%s& %3.2f (%2.2f)  & %3.2f (%2.2f)  &  %2.2f  &   %2.2f   \\\\\n', ...
        SS, m(1), sd(1), m(2), sd(2), pwill, pttest);
end

disp('REJECT = there is statistical difference, NOPE = no statistical difference in the angles');

