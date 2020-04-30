clc;
mcrsght_info('LOAD CONTACT EVENTS FROM SAVED EXPERIMENT - BRIEF ANALYSIS.');
mcrsght_info('This demo uses the experiment in [./DATA/ctrlvshot3/demo2_*],');
mcrsght_info('and performs a simple T-test and boxplots. ');

basefilename = fullfile(MACROHOME_,'DATA','ctrlvshot3');
dataStructure = load(fullfile(basefilename, 'demo2_angleChanges.mat'));
dataTable = readtable(fullfile(basefilename, 'demo2_angleChanges.xlsx'));

mcrsght_info('Loaded variables:');
disp(dataStructure);

controltrackfeatures = dataStructure.controltrackfeatures;
mutanttrackfeatures   = dataStructure.mutanttrackfeatures;
setnames = {dataStructure.generalinfocontrol(1).typeExperiment ...
            dataStructure.generalinfomutant(1).typeExperiment};



[boxdata,boxgroups] = getBoxplotComparisonData(controltrackfeatures, mutanttrackfeatures);

subplot(141)
boxplot(boxdata.clumpsize, boxgroups);
ylabel('clumpsize');
title('Boxplot example - 1');

subplot(142)
boxplot(boxdata.thx, boxgroups);
ylabel('anglechange');
title('Boxplot example - 2');

subplot(143)
boxplot(abs(boxdata.thx), boxgroups);
ylabel('abs(anglechange)');
title('Boxplot example - 3');

subplot(144)
hold on;
for ix=1:2
    scatter(boxdata.clumpsize(boxgroups==ix), abs(boxdata.thx(boxgroups==ix)), 110);
end
legend(setnames);
xlabel('clumpsize');
ylabel('abs(angle change)');
title('Scatterplot example');

set(gcf, 'Position', [560   579   983   369]);

[M, SD, H, P] = compareAngleChanges(controltrackfeatures, mutanttrackfeatures, setnames);
mcrsght_info(sprintf('SET: [%s] MEAN(STDev) = %2.2f(%2.2f) ', ...
                setnames{1}, M.(setnames{1}), SD.(setnames{1})), 'RESULTS');
mcrsght_info(sprintf('SET: [%s] MEAN(STDev) = %2.2f(%2.2f) ', ...
                setnames{2}, M.(setnames{2}), SD.(setnames{2})), 'RESULTS');
mcrsght_info(sprintf('TESTS: T-test p-value = %2.2f ', P.ttest), 'RESULTS');
mcrsght_info(sprintf('TESTS: Wilcoxon p-value = %2.2f ', P.wilcoxon), 'RESULTS');
