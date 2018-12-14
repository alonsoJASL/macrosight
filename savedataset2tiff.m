function [outputpath] = savedataset2tiff(dset, rawpath, outpath)
% SAVE DATASET TO INDIVIDUAL TIFF FILES.
%
% Usage:
% .     [outputpath] = savedataset2tiff(dsetname, datapath, outputpath)
%

% FIRST: find the directory where everything is and set the directory of
% the output.
switch nargin
    case 0 % no information: need everything:
        fprintf('[%s]: Please select the folder you are looking for...\n',...
            mfilename);
        pause(0.3);
        
        [dset, rawpath, ~] = uigetfile('*.tif', ...
            'Find the experiment you are looking for!');
        dsetname = fixdatasetname(dset);
        
        qx = sprintf('Which name do you want to give the dataset? \n %s:[%s]\n',...
            'Default', dsetname);
        reply = input(qx,'s');
        if isempty(reply)
            reply = dsetname;
        end
        fprintf('[%s]: Now, select the folder for the parsed data\n.', mfilename);
        pause(0.3);
        [outpath] = uigetdir(rawpath,'Where do you want the parsed data?');
        
    case 1
        fprintf('[%s]: Please select the folder you are looking for...\n',...
            mfilename);
        pause(0.3);
        
        [~, rawpath, ~] = uigetfile('*.tif', ...
            'Find the experiment you are looking for!');
        dsetname = fixdatasetname(dset);
        
        fprintf('[%s]: Now, select the folder for the parsed data\n.', mfilename);
        pause(0.3);
        [outpath] = uigetdir(rawpath,'Where do you want the parsed data?');
    case 2
        if ~isdir(rawpath)
            fprintf('[%s]. ERROR: Wrong input folder name: %s \n',...
                mfilename, rawpath);
            [outputpath] = savedataset2tiff(dsetname);
        end
    case 3
        if ~isdir(rawpath)
            fprintf('[%s]. ERROR: Wrong input folder name: %s \n',...
                mfilename, rawpath);
            fprintf('[%s]: Please select the folder you are looking for...\n',...
                mfilename);
            pause(0.3);
            
            [~, rawpath, ~] = uigetfile('*.tif', ...
                'Find the experiment you are looking for!');
            [outputpath] = savedataset2tiff(dsetname, rawpath, outpath);
        end
        dsetname = fixdatasetname(dset);
        
        if ~isdir(outpath)
            fprintf('[%s]: Now, select the folder for the parsed data\n', mfilename);
            pause(0.3);
            [outpath] = uigetdir(rawpath,'Where do you want the parsed data?');
        end
        
    otherwise
        ss = '[outputpath] = savedataset2tiff(dsetname, datapath, outputpath)';
        fprintf('[%s]. ERROR: \n\tUSAGE: %s\n', mfilename, ss);
        outputpath = [];
end

ix=2;
jx=-1;
subplot(121)
imagesc(imread(fullfile(rawpath, dset), ix));
title('is this the red [R] channel?');
subplot(122)
imagesc(imread(fullfile(rawpath, dset), ix+jx));
title('is this green [G] channel?');

qx = sprintf('[%s]. Is the order of the channels correct? Y/N [Default:Y],\n',...
    mfilename);
reply = input(qx, 's');
if isempty(reply)
    reply = 'Y';
end
if strcmpi(reply,'N') || strcmpi(reply,'NO')
    ix = 1;
    jx=+1;
end
close;

infoim = imfinfo(fullfile(rawpath, dset));
numIm = length(infoim);
N = numIm/2;
A = zeros(infoim(1).Height,infoim(1).Width, 3);

rx = 1;
outputpath = fullfile(outpath, dsetname);
if ~isdir(outputpath)
    mkdir(outputpath);
end
filenameshort = 'T';
for kx=ix:2:numIm
    A(:,:,1) = imread(fullfile(rawpath, dset), kx);
    A(:,:,2) = imread(fullfile(rawpath, dset), kx+jx);
    
    A(:,:,1) = double(A(:,:,1))./double(max(max(A(:,:,1))));
    A(:,:,2) = double(A(:,:,2))./double(max(max(A(:,:,2))));
    
    if rx<10
        filename = strcat(filenameshort, '000', num2str(rx));
    elseif rx<100
        filename = strcat(filenameshort, '00',num2str(rx));
    elseif rx<1000
        filename = strcat(filenameshort, '0',num2str(rx));
    else
        filename = strcat(filenameshort,num2str(rx));
    end
    filename = [filename '.tif'];
    
    rx = rx+1;
    if false % change to true for debugging code
        imagesc(A);
        pause(0.25);
    end
    
    imwrite(A,fullfile(outputpath, filename));
    
end

outputpath = fullfile(outpath, dsetname);

end

function [dsetname] = fixdatasetname(dset)
ix = strfind(dset,'.tif')-1;
dsetname = upper(dset(~isspace(dset)));
dsetname = dsetname(1:ix);
badchar = {'-', '.', '*'};

for jx=1:length(badchar)
    dsetname(strfind(dsetname,badchar{jx})) = '_';
end
end