function update2disk(handles, frame2update, newfr, wuc)
%   UPDATE FRAMES INFORMATION TO DISK. Updates a segmentation based on a
%   frame in which some of its cells have been changed. Only to be used
%   when disambiguating a clump.
%

filenames = dir(fullfile(handles.dataLa, '*.mat'));
filenames = {filenames.name};

% Change variables and save them back to the HDD
fprintf('%s: a clump has been disambiguated!\n', mfilename);
load(fullfile(handles.dataLa, filenames{frame2update.t}));
try
    fprintf('%s: Attempting to load tableNet...\n', mfilename);
    matfolders = getMatFolders(handles.dataLa);
    preresultsdata = load(fullfile(matfolders.dataHa,...
        'clumptrackingtables.mat'));
    tablenet = preresultsdata.tablenet;
    clumptracktable = preresultsdata.clumptracktable;
    clumpidcodes = preresultsdata.clumpidcodes;
    
    fprintf('%s: Load successful...\n', mfilename);
catch e
    fprintf('%s: ERROR. Load unsuccessful, check your preliminary results.\n',...
        mfilename);
    return;
end

dataL = frame2update.dataL;
dataG = frame2update.dataGL;
clumphandles = frame2update.clumphandles;

idx = find(dataG==ukfr.clumpseglabel);
dataG(idx) = 0;
clumphandles.overlappingClumps(idx)=0;

for kx=1:length(clumplab)
    dataG = dataG + newfr.evomask(:,:,kx);
    clumphandles.nonOverlappingClumps = ...
        clumphandles.nonOverlappingClumps + newfr.evomask(:,:,kx);
end

% update clumptracktable
test1 = clumptracktable(tablenet.timeframe==frame2update.t,:);
test2 = find(tablenet.timeframe==frame2update.t);
indx = test2(test1.clumpcode==wuc);

clumptracktable(indx,:).Variables = ...
    zeros(size(clumptracktable(indx,:).Variables));

if isempty(find(clumptracktable.clumpcode==wuc, 1))
    % removing the clump code if the clump is completely removed
    fprintf('%s: Clump removed from dataset.\n', mfilename);
    clumpidcodes(clumpidcodes==wuc) = [];
end


ButtonName = questdlg('Do you want to save the updated variables?', ...
    'Update variables to HDD?','Yes', 'Yes, save to workspace',  'No','No');
switch ButtonName
    case 'Yes'
        save(fullfile(filenames{frame2update.t}), ...
            'dataG','dataL','clumphandles','statsData','numNeutrop');
        save(fullfile('clumptrackingtables.mat'), ...
            'clumptracktable', 'clumpidcodes', 'timedfinalnetwork', ...
            'tablenet');
        
        fprintf('%s: variables have been updated to HDD.\n',...
            mfilename);
    case 'Yes, save to workspace'
        save(fullfile(filenames{frame2update.t}), ...
            'dataG','dataL','clumphandles','statsData','numNeutrop');
        save(fullfile('clumptrackingtables.mat'), ...
            'clumptracktable', 'clumpidcodes', 'timedfinalnetwork', ...
            'tablenet');
        
        fprintf('%s: variables have been updated to HDD.\n',...
            mfilename);
    case 'No'
        fprintf('%s: Nothing got saved to the hard drive.\n',...
            mfilename);
end