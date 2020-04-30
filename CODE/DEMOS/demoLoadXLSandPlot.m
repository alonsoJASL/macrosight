clc;
mcrsght_info('LOAD CONTACT EVENTS FROM SAVED EXPERIMENT - PLOT RESULTS.');
mcrsght_info('This demo uses the experiment in [./DATA/ctrlvshot3/demo2_*],');
mcrsght_info('and plots the results. ');

basefilename = fullfile(MACROHOME_,'DATA','ctrlvshot3');
dataStructure = load(fullfile(basefilename, 'demo2_angleChanges.mat'));
dataTable = readtable(fullfile(basefilename, 'demo2_angleChanges.xlsx'));

mcrsght_info('Loaded variables:');
disp(dataStructure);
mcrsght_info('Loaded table (first 10 columns):');
disp(dataTable(1:10,:));

controlplot = dataStructure.controlplot;
mutantplot  = dataStructure.mutantplot;

preaxis = [-27 18 -12 13];
figure(2)
clf;
subplot(211)
plotDirectionChangesComparison(controlplot, preaxis, 'r'); 
title(sprintf('Control cases - %d', length(controlplot)), 'FontSize', 20);
set(gca, 'FontSize', 16);

subplot(212)
plotDirectionChangesComparison(mutantplot, preaxis, 'b'); 
title(sprintf('Shot3 cases - %d', length(mutantplot)), 'FontSize', 20);
set(gca, 'FontSize', 16);

set(gcf, 'Position', [680 245 1074 733]);
