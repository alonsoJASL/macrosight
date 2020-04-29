function [tablenet, clumptracktable, clumpidcodes, handles] = setupInitialStructures(basefilename, whichExperiment)
% SETUP INITIAL STRUCTURES. Loads handles stucture from phagosight and
% creates the tables from handles.nodeNetwork, the clump tracking table,
% and creates the clump id vector.
%
% USAGE:
%   [tablenet, clumptracktable, clumpidcodes, handles] = setupInitialStructures(basefilename, whichExperiment)
%

switch nargin
    case 0
        mcrsght_info('Choose base directory with data and structures.');
        pause(1.5);
        basefilename = uigetdir(fullfile('.', 'DATA'), ...
            'Choose base directory with data and structures.');
        whichExperiment = chooseExperiment(basefilename);
        fullExperimentPath = fullfile(basefilename, whichExperiment);
    case 1
        whichExperiment = chooseExperiment(basefilename);
        fullExperimentPath = fullfile(basefilename, whichExperiment);
    case 2
        fullExperimentPath = fullfile(basefilename, whichExperiment);
        if contains(whichExperiment, basefilename) == true
            fullExperimentPath = whichExperiment;
        elseif ~isfolder(fullExperimentPath)
            mcrsght_info(sprintf('(%s) not a folder.', fullExperimentPath),...
                mfilename);
            str = input(sprintf('Is (%s) in a different location to (%s)? Y/N [N]', ...
                whichExperiment, basefilename));
            if isempty(str)
                str = 'N';
            end
            if strcmpi(str, 'N')
                whichExperiment = chooseExperiment(basefilename);
                fullExperimentPath = fullfile(basefilename, whichExperiment);
            else
                fullExperimentPath = whichExperiment;
            end
        end
end


mcrsght_info(sprintf('Loading structure with folder names from (%s).', fullExperimentPath));
foldernames = getMatFolders(fullExperimentPath);

try
    mcrsght_info('Loading handles structure and changing folder names in HANDLES.');
    currdata = load(fullfile(foldernames.pathtodir, foldernames.dataHa,'handles.mat'));
    handles = currdata.handles;
    handles.dataRe = fullfile(foldernames.pathtodir, foldernames.dataRe);
    handles.dataLa = fullfile(foldernames.pathtodir, foldernames.dataLa);
    handles.dataHa = fullfile(foldernames.pathtodir, foldernames.dataHa);
    
catch
    mcrsght_info('Loading failed... building handles structure from labelled data.', 'ERROR');
    handles = neutrophilAnalysis(fullfile(foldernames.pathtodir, foldernames.dataLa), 0);
end


try
    mainidclumps = load(fullfile(handles.dataHa,'clumptrackingtables.mat'));
    clumptracktable = mainidclumps.clumptracktable;
    clumpidcodes = mainidclumps.clumpidcodes;
    
    tablenet = mainidclumps.tablenet;
    
    mcrsght_info('Previous results found. Loading...');
catch e
    mcrsght_info('No record found of clumptrackingtables.mat, generating...');
    
    nodeNet = handles.nodeNetwork;
    
    options.savebool = false;
    options.outputpath = handles.dataHa;
    options.filename = fullfile(basefilename, 'fulldataset-nodenet.xlsx');
    
    tablenet = nodenetwork2xls(nodeNet(:,1:31),options);
    
    clumpcode = zeros(size(tablenet,1),1,'uint64');
    clumpID = zeros(size(tablenet,1),1);
    
    clumptracktable = table(clumpcode, clumpID);
    
    for ix=1:handles.numFrames
        whichone = ix;
        [~, auxclumpTrack] = clumptracking(handles, tablenet, whichone);
        clumptracktable(tablenet.timeframe==whichone,:) = auxclumpTrack;
    end
    
    clumpidcodes = unique(clumptracktable.clumpcode(clumptracktable.clumpcode>0));
    clumpidcodes(floor(clumpidcodes/1000)==0) = [];
    
    save(fullfile(handles.dataHa,'clumptrackingtables.mat'), ...
        'clumptracktable', 'clumpidcodes', 'tablenet');
end