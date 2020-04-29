function [currData, filename] = loadSomeFile(basefilename, whichone)
%
%

allFiles = dir(fullfile(basefilename, '*.mat'));
if isempty(allFiles)
    mcrsght_info(sprintf('No mat files found on folder: %s\n', ...
        basefilename), 'ERROR');
    currData = [];
    return;   
end
    
if nargin < 2
    whichone = 'random';
elseif ischar(whichone) 
    whichone = lower(whichone);
else
    % it's an index!
    indx = whichone;
    whichone = 'index';
end

switch whichone
    case 'all'
        imNames = {allFiles.name};
    case 'random'
        index = randi(length(allFiles));
        imNames = allFiles(index).name;
    case 'one'
        imNames = allFiles(1).name;
    case 'index'
        imNames = allFiles(indx).name;
    otherwise 
        mcrsght_info('Wrong option. Use: all, random, one, or specify the index.', 'WARINING');
        mcrsght_info('Returning all');
        imNames = {allFiles.name};
end

if strcmp(whichone, 'all')
    mcrsght_info(sprintf('Loading all %d names of images and image %s as an example.',...
        length(imNames), imNames{1}),mfilename);
    currData = load(fullfile(basefilename, imNames{1}));
else
    currData = load(fullfile(basefilename, imNames));
end
if nargout>1
    filename = imNames;
elseif  strcmp(whichone, 'all')
    mcrsght_info(sprintf('Use the command: %s to load all the names.',  ...
        upper('[currData, filename] = loadSomeFile(...)')));
end