function [newhandles] = separateDataset(handles)
% SEPARATE DATASET. Separates the data processed by RGBPROCESING funciton 
% and saves it saves it in a was PhagoSight can read use it. 
%
% USAGE: [newhandles] = separateDataset(handles)
% 
if nargin < 1
    fprintf('%s: ERROR, handles structure not specified.', mfilename);
    fprintf('\n\tUsage:[newhandles] = separateDataset(handles)\n');
    newhandles = [];
    return;
end

hnames = fieldnames(handles);
testvar = sum(contains(hnames, 'dataLa'));
if testvar == 0 
    % no dataLa, ask for dataRe
    testvar = sum(contains(hnames, 'dataRe'));
    if testvar == 1
        fprintf('%s: Only dataRe folder found, creating labelled data first.\n',...
            mfilename);
        reidx = contains(hnames, 'dataRe');
        
        [auxhandles] = rgbdataprocessing(handles.(hnames{reidx}), options);
        handles.dataLa = auxhandles.dataLa;
        
        [newhandles] = separateDataset(handles, options);
    else
        fprintf('%s: ERROR, handles structure does not contain path to dataRe or dataLa folder.\n',...
            mfilename);
        newhandles = [];
        return;
    end
else 
    % dataLa found!
    fprintf('%s: dataLa folder found in handles structure.\n', mfilename)
    newhandles = handles;
    matidx = strfind(handles.dataLa, '_mat');
    
    overlapdir = strcat(handles.dataLa(1:matidx), 'overlap_', ...
        handles.dataLa(matidx+1:end));
    noverlapdir = strcat(handles.dataLa(1:matidx), 'nonoverlap_', ...
        handles.dataLa(matidx+1:end));
    if ~isdir(overlapdir); mkdir(overlapdir); end
    if ~isdir(noverlapdir); mkdir(noverlapdir); end
    
    fnames = dir(handles.dataLa);
    fnames(1:2) = [];
    
    fnames = {fnames.name};
    
    for ix=1:length(fnames)
        load(fullfile(handles.dataLa, fnames{ix}));
        %  dataL, dataG, statsData, numNeutrop, clumphandles
        og.dataL = dataL; 
        og.dataG = dataG;
        og.statsData = statsData;
        og.numNeutrop = numNeutrop;
        
        dataL = og.dataL.*(clumphandles.overlappingClumps>0);
        dataG = clumphandles.overlappingClumps;
        statsData = regionprops(dataL>0);
        numNeutrop = length(statsData);
        
        save(fullfile(overlapdir,fnames{ix}), 'dataL','dataG', 'statsData', ...
                        'numNeutrop','clumphandles');
        
        dataL = og.dataL.*(clumphandles.nonOverlappingClumps>0);
        dataG = clumphandles.nonOverlappingClumps;
        statsData = regionprops(dataL>0);
        numNeutrop = length(statsData);
        
        save(fullfile(noverlapdir,fnames{ix}), 'dataL','dataG', 'statsData', ...
                        'numNeutrop','clumphandles');
        
    end
    
    newhandles.dataOvlp = overlapdir;
    newhandles.dataNovlp = noverlapdir;
    
end        
end

function [typeseparation] = getoptions(s)
% get options for function greylevelsegmentation
typeseparation = 'both';

fnames = fieldnames(s);
for ix=1:length(fnames)
    switch fnames{ix}
        case 'typeseparation'
            typeseparation = s.(fnames{ix});
        otherwise
            fprintf('%s: specified wrong option %s.\n', ...
                mfilename, upper(fnames{ix}));
    end
end
end
