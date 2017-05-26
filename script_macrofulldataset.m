%% initialisation

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
%% Global data
nodeNet = handles.nodeNetwork;
finalNet = handles.finalNetwork;

tfnet = timednetwork(handles);

% tableNetwork(nodeNetwork)
options.savebool = true;
options.outputpath = '.';
options.filename = 'fulldataset-nodenet.xlsx';

tablenet = nodenetwork2xls(nodeNet(:,1:31),options);
tablenet(isnan(tablenet.X), :) = [];

% this has to be done PER FRAME
[boundies] = bwboundaries(clumphandles.overlappingClumps>0);

whosin = inpolygon(tablenet.X, tablenet.Y, boundies{1}(:,1), boundies{1}(:,2));

%% per frame

whichone = 48;
fprintf('Loading file: %s\n', filenames{whichone});
la = load(fullfile(foldernames.dataLa, filenames{whichone}));
re = load(fullfile(foldernames.dataRe, filenames{whichone}));

try
    dataL = la.dataL;
    dataGL = la.dataG;
    dataR = re.dataR;
    dataGR = re.dataG;
    
    clumphandles = la.clumphandles;
catch err
    if strcmp(err.identifier,'MATLAB:nonExistentField')
        disp('The image was not imported properly. Load the next one!');
    else
        disp('Somethign else went wrong!');
        disp(err);
    end
end

% calculations
thisframetable = tablenet(tablenet.timeframe==whichone,:);

greenregs = regionprops('table',(dataGL>0), ...
    'Area', 'Eccentricity', 'Extent', 'MajorAxisLength', ...
    'MinorAxisLength','Orientation', 'Perimeter');

[boundies] = bwboundaries(dataGL>0);
