function [simpleRed, simpleGreen] = simpleClumpsSegmentation(X)
%           SIMPLE CLUMPS SEGMENTATION
% A simple hysteresis thresholding method based on Otsu's threshold. 
% If size(X,3)=3, the program returns a segmentation of X(:,:,1) as well as
% X(:,:,2). If size(X,3)=1, then the program returns the segmentation of X. 
% On both cases, it filters the imagesc with a Gaussian filter of size 5.
% It also performs a morphological filling of any holes, followed by an
% open operation.
% 
% USAGE: [simpleRed, simpleGreen] = simpleClumpsSegmentation(X)
%                    [simpleSegm] = simpleClumpsSegmentation(X)
% 
% INPUT:
%                       X := matrix of size(X)=[M,N,3] or [M,N]
% OUTPUT:
%               simpleRed := segmentation of X(:,:,1)
%             simpleGreen := segmentation of X(:,:,2)
% 
%              simpleSegm := segmentation of X, when X is grey-scale.
% 
% 
% 

if size(X,3) == 1
    green = X;
    
    f = fspecial('gaussian',[5 5],1);
    
    filtGreen = imfilter(green,f); 
    levGreen = multithresh(filtGreen,2);
    
    simpleGreen = binaryFromLevels(filtGreen, levGreen);
    
    % Postprocessing of binary levels
    simpleGreen = imfill(simpleGreen,'holes');
    seG = strel('sphere',3);
    simpleGreen = imopen(simpleGreen,seG);
    simpleRed = [];
    
    if nargout < 2
        simpleRed = simpleGreen;
    end
else
    
    red = X(:,:,1);
    green = X(:,:,2);
    
    f = fspecial('gaussian',[7 7],1);
    f2 = fspecial('disk', 3);
    %f = ones(5)./5;
    
    filtRed = imfilter(red,f2);
    filtGreen = imfilter(green,f);
    
    levRed = multithresh(filtRed,2);
    levGreen = multithresh(filtGreen,2);
    
    simpleRed = binaryFromLevels(filtRed, levRed);
    simpleGreen = binaryFromLevels(filtGreen, levGreen);
    
    % Postprocessing of binary levels
    simpleGreen = imfill(simpleGreen,'holes');
    seR = strel('disk',4);
    seG = strel('sphere',3);
    simpleRed = imopen(simpleRed,seR);
    simpleGreen = imopen(simpleGreen,seG);
end
end

function [binaryImage, dataL] = binaryFromLevels(X, levels)
numLevels = length(levels);
switch numLevels
    case 1
        binaryImage = X > levels;
        dataL = bwlabeln(binaryImage);
        
    case 2
        LowT = bwlabeln(X>levels(1));
        ToKeep = unique(LowT.*(X>levels(2)));
        [dataL,~] = bwlabeln(ismember(LowT,ToKeep(2:end)));
        binaryImage = dataL > 0;
        
    otherwise
        binaryImage = [];
        dataL = [];
        help binaryFromLevels;
        return;
end
end