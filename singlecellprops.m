function [cellhandles] = singlecellprops(fr)
%               CELL PROPERTIES 
% 
% Gets cell properties from an binary RGB (b-RGB) image with ground truth
% or segmented by an algorithm. Red channel do not require to hold a single
% cell. The green channel could be either a single cell (binary) or a
% overlapped-prime-labelled one. 
%
% USAGE: 
%           [cellProperties] = cellprops(bRGB)
%
% INPUT: 
%                      bRGB := Binary RGB image of size mxnx3 that holds:
%                               - Red Channel: segmented nuclei of cells.
%                               - Green Channel: segmented single cell or
%                               overlapped cells labelled with prime
%                               numbers.
% 
% OUTPUT:
%           cellProperties := Structure with cell properties:
%                              - numCells: number of cells in bRGB.
%                              - rCentroid: centroid for red cell.
%                              - gCentroid: centroid for green channel.
%                              - direction: direction defined as 
%                                    direction = rCentroid - gCentroid;
%                              - theta: angle from the direction.
% 
if nargin < 2
    originalImage = fr.X;
end

red = (fr.dataL).*(fr.clumphandles.nonOverlappingClumps>0);
green = fr.dataGL.*(fr.clumphandles.nonOverlappingClumps>0);

labs = unique(green);
labs(1) = [];
numCells = length(labs);

rC = zeros(numCells,2);
gC = zeros(numCells,2);

for indx=1:numCells
    
    [thisGreen, thisRed] = singleCellperFrame(green==labs(indx),red>0);
    
    greenRegs = regionprops('table', thisGreen>0, ...
        originalImage(:,:,2),'Centroid');
    redRegs = regionprops('table', thisRed>0, ...
        originalImage(:,:,1),'Centroid');
    
    gC(indx,2:-1:1) = greenRegs.Centroid;
    rC(indx,2:-1:1) = redRegs.Centroid;
    
end 

direction = rC-gC;
theta = -angle(direction(:,1)+direction(:,2).*1i);

cellhandles.numCells = numCells;
cellhandles.rCentroid = rC;
cellhandles.gCentroid = gC;
cellhandles.direction = direction;
cellhandles.theta = theta;

end

function [singleGreen, singleRed] = singleCellperFrame(green, red) 
%
% Gets rid of possible 
%

se = strel('diamond',2);
sG = imopen(green,se);
sR = imopen(bitand(green>0 ,red>0),se);

regsG = regionprops('table', sG, 'Area');
regsR = regionprops('table', sR, 'Area');

singleGreen = bwareafilt(sG, [max([regsG.Area]) Inf]);
singleRed = bwareafilt(sR, [max([regsR.Area]) Inf]);
end