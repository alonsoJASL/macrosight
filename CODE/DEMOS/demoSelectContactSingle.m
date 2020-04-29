clc;
mcrsght_info('SELECT CONTACT EVENTS ON SINGLE DATASET.');
mcrsght_info('This demo uses the experiment in [./DATA/ctrlvshot3/CONTROL01],');
mcrsght_info('and lets you select the correct contact events manually. ');

basefilename = fullfile(MACROHOME_,'DATA','ctrlvshot3');
whichDs = 'CONTROL01';
S=5; % starting point before/after contact

mcrsght_info(sprintf('Base folder: [%s]', basefilename));
mcrsght_info(sprintf('Experiment folder: [%s]', whichDs));
mcrsght_info(sprintf('Frames before/after contact (clumps): [%d]', S));

% load or create basic structures
[tablenet, clumptracktable, clumpidcodes, ~] = setupInitialStructures(basefilename, whichDs);
fulltablenet = [tablenet clumptracktable];

% create table with contact events
[T] = selectContactEvents(fulltablenet, clumpidcodes, S, whichDs);

% Calculate angle changes after contact events
[generalinfo, trackfeatures, anglechanges, plotpoints] = calculateAngleChanges(tablenet, clumptracktable, T);

writetable(T, fullfile(basefilename, 'demo1_selectContactSingle.xlsx'));
save( fullfile(basefilename, 'demo1_selectContactSingle_structures.mat'),...
    'generalinfo', 'trackfeatures', 'anglechanges', 'plotpoints');

%% display results
clc;
mcrsght_info('SELECT CONTACT EVENTS ON SINGLE DATASET.');
mcrsght_info('This demo uses the experiment in [./DATA/ctrlvshot3/CONTROL01],');
mcrsght_info('and lets you select the correct contact events manually. ');
mcrsght_info(sprintf('Base folder: [%s]', basefilename));
mcrsght_info(sprintf('Experiment folder: [%s]', whichDs));
mcrsght_info(sprintf('Frames before/after contact (clumps): [%d]', S));


mcrsght_info('The contact events found in this dataset:');
disp(T);
mcrsght_info(sprintf('Table saved in file: [%s]', fullfile(basefilename, 'demo_selectContactSingle.xlsx')));


