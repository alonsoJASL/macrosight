% Initialisation script for the Analysis of shapes
%% INITIALISATION

tidy;
fprintf('%s. Initialisation script. Remember to name the data folders as MACROSN\n', mfilename);

%selpath = uigetdir(matlabroot, 'Open directory with data.');
selpath = uigetdir('/Volumes/DATA/MACROPHAGES', 'Open directory with data.');
strsp = strsplit(selpath, '/');
strsp = strsp{contains(strsp, 'MACROS')};
if isempty(str2num(strsp(end)))
    whichmacro = 1;
else
    whichmacro = str2num(strsp(end));
end
fprintf('%s. Dataset detected: whichmacro = %d\n',mfilename, whichmacro);

handlesdir = getMatFolders(selpath);

fprintf('%s: Loading structure with folder names...\n',mfilename);
load(fullfile(handlesdir.pathtodir, handlesdir.dataHa,'handlesdir.mat'));

foldernames = handles;
clear handles;

%if strcmp(chooseplatform, 'mac')
fprintf('%s: Changing folder names to fix OS (%s) \n',...
    mfilename, upper(chooseplatform));

try
    foldernames = fixhandlesdir(foldernames);
catch e
    disp('Something wrong happened. You can make the change manually.');
    disp('Take the [handles] structure and change the names of the dataRe');
    disp('and dataLa paths to the corresponding ones for your OS.');
end

%% LOAD HANDLES
try
    disp('Loading handles structure...');
    
    try
        load(fullfile(handlesdir.pathtodir, handlesdir.dataHa,'handles.mat'));
        foldernames.dataHa = fullfile(handlesdir.pathtodir, handlesdir.dataHa);
        handles.dataRe = fullfile(handlesdir.pathtodir, handlesdir.dataRe);
        handles.dataLa = fullfile(handlesdir.pathtodir, handlesdir.dataLa);
    catch e
        fprintf('%s. %s\n', mfilename, e.message);
        load(fullfile(foldernames.dataHa, 'handles.mat'));
    end
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
switch whichmacro
    case 1
        fprintf('%s: Clearing holes in dataset.\n', mfilename);
        load DATASETHOLES;
        clumptracktable(ismember(tablenet.timeframe, DATASETHOLES),:) = [];
        tablenet(ismember(tablenet.timeframe, DATASETHOLES),:) = [];
    otherwise
        fprintf('\n')
end

