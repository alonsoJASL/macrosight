function [handles] = rgbdataprocessing(datainname, options)
% greylevelsegmentation segments an image, set of images that were stored
% on a folder.
%

switch nargin
    case 0
        options.methodUsed = 'clump';
        options.parameters = [];
        options.foldername = 'La';
        
        [~, handles] = readDatasetDetails();
        handles = handles(1);
        fnames = fieldnames(handles);
        indx = find(contains(fnames, 'data'));
        
        if ~isempty(indx)
            [handles] = rgbdataprocessing(fullfile(handles.pathtodir, ...
                handles.(fnames{indx(1)})), options);
        else
            [handles] = rgbdataprocessing(handles.fileName, options);
        end
    case 1
        if isdir(datainname)
            options.methodUsed = 'clump';
            options.parameters = [];
            options.foldername = 'La';
            
            [handles] = rgbdataprocessing(datainname, options);
        else
            fprintf('%s: ERROR, wrong folder name.', mfilename);
            handles = [];
            return;
        end
    case 2
        [methodUsed, parameters, foldername] = getoptions(options);
        if isdir(datainname)
            if strcmp(datainname(end), filesep)
                datainname(end)=[];
            end
            if contains(datainname, '_mat_')
                matidx = strfind(datainname,'_mat_');
                outdir = strcat(datainname(1:matidx), 'mat_', foldername);
            else
                outdir = strcat(datainname, '_mat_', foldername);
                if contains(datainname,'_mat_')
                    if contains(datainname, 'Re')
                        handles.dataRe = datainname;
                    elseif contains(datainname, 'Or')
                        handles.dataOr = datainname;
                    end
                end
            end
            
            if ~isdir(outdir)
                mkdir(outdir);
            end
            
            filenames = dir(fullfile(datainname));
            filenames(1:2) = [];
            filenames = {filenames.name};
            
            for ix=1:length(filenames)
                [X, xatt] = readParseInput(fullfile(datainname, filenames{ix}));
                [dataL2] = processing(X, methodUsed, parameters);
                
                dataG = dataL2(:,:,2);
                dataL = dataL2(:,:,1);
                                
                dotidx = strfind(filenames{ix},'.');
                matname = strcat(filenames{ix}(1:dotidx), 'mat');
                
                if strcmp(foldername, 'La')
                    [~, clumphandles] = getOverlappingClumpsBoundaries(...
                        dataG>0, dataL>0);
                    statsData = regionprops(dataL>0);
                    numNeutrop = length(statsData);
                    save(fullfile(outdir, matname),...
                        'dataL', 'dataG', 'statsData', ...
                        'numNeutrop','clumphandles');
                else
                    dataR = dataL;
                    dataRG = dataG;
                    save(fullfile(outdir, matname),...
                        'dataR', 'dataRG');
                end
                
            end
            handles.numFrames = length(filenames);
            handles.rows = xatt(1).Height;
            handles.cols = xatt(1).Width;
            handles.levs = xatt(1).Depth;
            if strcmp(foldername, 'La')
                handles.dataLa = outdir;
            else
                handles.dataRe = outdir;
            end
            
        else
            fprintf('%s: ERROR, wrong folder name.', mfilename);
            handles = [];
            return;
        end
end

end

function [dataOut] = processing(X, methodused, parameters)
% Segment one image (X) with method methodused' such that:
% dataL = methodused(X;parameters)
switch lower(methodused)
    case {'clump', 'clumps'}
        [dataRed, dataG] = simpleClumpsSegmentation(X);
        
        dataRed = bwlabeln(dataRed);
        dataG = bwlabeln(dataG);
        
        dataOut = cat(3, dataRed, dataG, zeros(size(dataG,1), size(dataG,2)));
    case {'binarize', 'binarise'}
        if strcmpi(parameters, 'global') || ...
                strcmpi(parameters, 'adaptive')
            parameters = lower(parameters);
        else
            fprintf('%s: Error in PARAMETERS variable: %s.\n Using global.',...
                mfilename, parameters);
            parameters = 'global';
        end
        
        switch size(X,3)
            case 1
                dataOut = bwlabeln(imfill(imbinarize(X, ...
                    parameters), 'holes'));
            case 3
                dataRed = bwlabeln(imfill(imbinarize(X(:,:,1), ...
                    parameters),'holes'));
                dataG = bwlabeln(imfill(imbinarize(X(:,:,2), ...
                    parameters), 'holes'));
                
                dataOut = cat(3, dataRed, dataG, zeros(size(dataG), size(dataG)));
                
            otherwise
                levs = multithresh(X,1);
                bw = imfill(imquantize(X, levs)==2, 'holes');
                dataOut = bwlabeln(bw);
        end
        
    case {'reduce'}
        dataOut = reduceu(X, parameters);
        
end
end

function [methodUsed, parameters, foldername] = getoptions(s)
% get options for function greylevelsegmentation
methodUsed = 'clump';
parameters = [];
foldername = 'La';

fnames = fieldnames(s);
for ix=1:length(fnames)
    switch fnames{ix}
        case 'methodUsed'
            methodUsed = s.(fnames{ix});
        case 'parameters'
            parameters = s.(fnames{ix});
        case 'foldername'
            foldername = s.(fnames{ix});
        otherwise
            fprintf('%s: specified wrong option %s.\n', ...
                mfilename, upper(fnames{ix}));
    end
end
end
