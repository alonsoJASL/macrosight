function [experimentFolder] = chooseExperiment(basefilename, returnAll)

if nargin < 2
    returnAll = false;
end

folderoptions = dir(basefilename);
folderoptions(~[folderoptions.isdir]) = [];
folderoptions = {folderoptions.name}';
folderoptions(contains(folderoptions,'.')) = [];
folderoptions(contains(folderoptions, '_mat_')) = [];

if ~returnAll
    mcrsght_info('Choose subdirectory with experiment from the list below:.');
    
    for ix=1:length(folderoptions)
        mcrsght_info(folderoptions{ix}, num2str(ix));
    end
    STR = input('your choice (default: 1) :_ ','s');
    if isempty(STR)
        experimentFolder = folderoptions{1};
    else
        experimentFolder = folderoptions{str2num(STR)};
    end
    
else
    experimentFolder = folderoptions;
end


