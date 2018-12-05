% Script file: MACROSIGHT FULL DATASET ANALYISIS
% This file analyses the data in its entirety. It perfoms: 
% - Segmentation of both channels
% - Tracking of red nuclei 
% - 
%
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

if strcmp(chooseplatform, 'mac')
    fprintf('%s: Changing folder names to fix OS...\n',mfilename);
    foldernames = fixhandlesdir(foldernames);
end

%% LOAD HANDLES
try
    disp('Loading handles structure...');
    load(fullfile(foldernames.dataHa, 'handles.mat'));
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


%% DEBUG SEGMENTATION
wrongImages = zeros(handles.numFrames, 1);
deepErrors = zeros(handles.numFrames, 1);
%
%ix = 217;

nodeNet = handles.nodeNetwork;
finalNet = handles.finalNetwork;

options.savebool = false;
options.outputpath = '.';
options.filename = 'fulldataset-nodenet.xlsx';
tablenet = nodenetwork2xls(nodeNet(:,1:31),options);

for ix=1:handles.numFrames
whichone = ix;
fprintf('Loading file: %s\n', filenames{whichone});
la = load(fullfile(foldernames.dataLa, filenames{whichone}));
re = load(fullfile(foldernames.dataRe, filenames{whichone}));

try
    dataL = la.dataL;
    dataGL = cleanupgreen(dataL, la.dataG);
    dataR = re.dataR;
    dataGR = re.dataG;
    
    X = cat(3, dataR, dataGR, zeros(size(dataL)));
    clumphandles = la.clumphandles;
    clumphandles.nonOverlappingClumps = ...
        (clumphandles.nonOverlappingClumps>0).*dataGL;
    clumphandles.overlappingClumps = ...
        (clumphandles.overlappingClumps>0).*dataGL;
    
    % this has to be done PER FRAME
    [overboundies] = bwboundaries(clumphandles.overlappingClumps>0);
    [noverboundies] = bwboundaries(clumphandles.nonOverlappingClumps>0);
    
    if ~isempty(overboundies)
        whosin = inpolygon(tablenet.X, tablenet.Y, ...
            overboundies{1}(:,1), overboundies{1}(:,2));
    end
    
    figure(1)
    clf
    plotBoundariesAndPoints(dataGL, [], overboundies, 'm-');
    colormap pink;
    title(filenames{whichone});
    
    pause(0.02);
    
catch err
    if strcmp(err.identifier,'MATLAB:nonExistentField')
        disp('The image was not segmented properly. Load the next one!');
        
        wrongImages(ix) =1;
        
        [dataL, dataG] = simpleClumpsSegmentation(cat(3, re.dataR, re.dataG, ...
            zeros(size(re.dataR))));
        [~, clumphandles] = getOverlappingClumpsBoundaries(dataG>0, dataL>0);
        statsData = regionprops(dataL>0);
        numNeutrop = length(statsData);
        save(fullfile(foldernames.dataLa, filenames{whichone}), ...
            'dataL', 'dataG', 'statsData', 'numNeutrop', 'clumphandles');
        %pause;
    else
        disp('Somethign else went wrong!');
        disp(err);
        deepErrors(ix) = 1;
    end
end
end
