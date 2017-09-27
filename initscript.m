% Initialisation script for the Analysis of shapes
%% INITIALISATION
tidy;

% function not available in package
whichmacro = 1;
[dn,ds] = loadnames('macros', chooseplatform, whichmacro);
handlesdir = getMatFolders(fullfile(dn,ds));

fprintf('%s: Loading structure with folder names...\n',mfilename);
load(fullfile(handlesdir.pathtodir, handlesdir.dataHa,'handlesdir.mat'));

foldernames = handles;
clear handles;

%if strcmp(chooseplatform, 'mac')
fprintf('%s: Changing folder names to fix OS...\n',mfilename);
foldernames = fixhandlesdir(foldernames);
%end

%% LOAD HANDLES
try
    disp('Loading handles structure...');
    load(fullfile(foldernames.dataHa, 'handles.mat'));
    fprintf('%s: Changing folder names in HANDLES to fix OS...\n',mfilename);
    handles = fixhandlesdir(handles);
    [~, filenames] = loadone(foldernames.dataLa, 'all');
    
catch e
    disp('Loading failed... building handles structure from labelled data.');
    handles = neutrophilAnalysis(foldernames.dataLa, 0);
end
%% GET GLOBAL VARIABLES FROM handles STRUCTURE
nodeNet = handles.nodeNetwork;
finalNet = handles.finalNetwork;

% NOW COMPUTE ALL THE VARIABLES FOR TRACKING CLUMPS AND NUCLEI IN THEM
try
    mainidclumps = load(fullfile(foldernames.dataHa,'clumptrackingtables.mat'));
    clumptracktable = mainidclumps.clumptracktable;
    clumpidcodes = mainidclumps.clumpidcodes;
    
    timedfinalnetwork = mainidclumps.timedfinalnetwork;
    tablenet = mainidclumps.tablenet;
    
    disp('Previous results found. Loading...');
catch e
    disp('No record found of clumptrackingtables.mat, you need to regenerate it');
    
    options.savebool = true;
    options.outputpath = '.';
    options.filename = 'fulldataset-nodenet.xlsx';
    
    tablenet = nodenetwork2xls(nodeNet(:,1:31),options);
    timedfinalnetwork = timednetwork(handles);
    
    clumpcode = zeros(size(tablenet,1),1,'uint64');
    clumpID = zeros(size(tablenet,1),1);
    
    clumptracktable = table(clumpcode, clumpID);
    
    for ix=1:handles.numFrames
        whichone = ix;
        thisframetable = tablenet(tablenet.timeframe==whichone,:);
        
        [dataL, dataGL, ~, dataR, dataGR] = getdatafromhandles(...
            handles, filenames{whichone});
        [clumphandles, auxclumpTrack] = ...
            clumptracking(handles, tablenet, whichone);
        clumptracktable(tablenet.timeframe==whichone,:) = auxclumpTrack;
    end
    
    clumpidcodes = unique(clumptracktable.clumpcode(clumptracktable.clumpcode>0));
    clumpidcodes(floor(clumpidcodes/1000)==0) = [];
    
    save(fullfile(foldernames.dataHa,'clumptrackingtables.mat'), ...
        'clumptracktable', 'clumpidcodes', 'timedfinalnetwork', ...
        'tablenet');
end

load DATASETHOLES;
clumptracktable(ismember(tablenet.timeframe, DATASETHOLES),:) = [];
tablenet(ismember(tablenet.timeframe, DATASETHOLES),:) = [];