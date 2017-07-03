% SOM Shape analysis
%
%% INITIALISATION

initscript;

%% CHOOSE WHICH (uniquely identifiable) CLUMP to work on

% w.u.c = which unique clump!
ix=10; % OR, FOR A RANDOM CODE: randi(length(clumpidcodes));
wuc = clumpidcodes(ix);

fprintf('Working on clump with ID=%d.\n', wuc);

% get labels from the clump
labelsinclump = getlabelsfromcode(wuc);
timeofclump = unique(tablenet(clumptracktable.clumpcode==wuc,:).timeframe);
clumpnucleirange = (timeofclump(1)-1):(timeofclump(end)+1);

tabletracks = tablenet(ismember(tablenet.timeframe, clumpnucleirange),:);
tableclump = clumptracktable(ismember(tablenet.timeframe, clumpnucleirange),:);

figure(1)
clf
plotTracks(handles,2,labelsinclump);
title(sprintf('Nuclei that belong to clump %d, moving through time.', wuc));

%% select one cell from the range
whichone = clumpnucleirange(1);

laname1 = filenames{clumpnucleirange(1)};
laname2 = filenames{clumpnucleirange(2)};

[dataL1, dataGL1, clumphandles1, dataR1, dataGR1] = ...
    getdatafromhandles(handles, laname1);
[dataL2, dataGL2, clumphandles2, dataR2, dataGR2] = ...
    getdatafromhandles(handles, laname2);

Xthis = cat(3, dataR1, dataGR1, zeros(size(dataR1)));
Xnext = cat(3, dataR2, dataGR2, zeros(size(dataR2)));

regsclump = regionprops(clumphandles2.overlappingClumps==10);

singleidx1 = 10;
singleidx2 = 11;
regssingle1 = regionprops(clumphandles1.nonOverlappingClumps==singleidx1);
regssingle2 = regionprops(clumphandles1.nonOverlappingClumps==singleidx2);

singleboundy = bwboundaries(clumphandles1.nonOverlappingClumps==singleidx2);

figure(21)
clf;
subplot(121);
imagesc(dataGL1);
title(sprintf('Green channel at frame = %s', laname1));
rectangle('Position', regsclump.BoundingBox, 'EdgeColor', 'r');
rectangle('Position', regssingle2.BoundingBox, 'EdgeColor', 'c');

subplot(122);
imagesc(dataGL2);
title(sprintf('Green channel at frame = %s', laname2));
rectangle('Position', regsclump.BoundingBox, 'EdgeColor', 'r');
rectangle('Position', regssingle2.BoundingBox, 'EdgeColor', 'c');

tightfig;

figure(2)
clf;
imshowpair(Xthis,Xnext);
title(sprintf('Showing frames %s and %s', laname1, laname2));
rectangle('Position', regsclump.BoundingBox, 'EdgeColor', 'r');
rectangle('Position', regssingle2.BoundingBox, 'EdgeColor', 'c');

%% SURF test 1: detectSURF -> extractFeatures -> matchFeatures

% SURF detection options:
metthresh = 1000; % default=1000
numoct = 3; % default=3
numscale = 4; % default=4

roisingle2 = regssingle2.BoundingBox; %default=[1 1 size(dataGR1,2) size(dataGR1,1)];
roi2 = [1 1 size(dataGR2,2) size(dataGR2,1)];% regsclump.BoundingBox; %

framecell2 = edge(dataGR1,'canny'); % dataGR1; % rgb2gray(X1);
tplusone = edge(dataGR2,'canny'); % dataGR2; % rgb2gray(X2);

pointscell2 = detectSURFFeatures(framecell2, ...
    'MetricThreshold', metthresh, 'NumOctaves', numoct,...
    'NumScaleLevels', numscale, 'ROI', roisingle2);
pointstplus1 = detectSURFFeatures(tplusone, ...
    'MetricThreshold', metthresh, 'NumOctaves', numoct,...
    'NumScaleLevels', numscale, 'ROI', roi2);

[fcell2,vptscell2] = extractFeatures(framecell2,pointscell2);
[ftplus1,vptstplus1] = extractFeatures(tplusone,pointstplus1);

indexPairs = matchFeatures(fcell2,ftplus1);
matchedPoints1 = vptscell2(indexPairs(:,1));
matchedPoints2 = vptstplus1(indexPairs(:,2));

[tform, inlierDistorted, inlierOriginal] = estimateGeometricTransform(...
    matchedPoints2, matchedPoints1, 'projective');

figure(3);
clf;
showMatchedFeatures(framecell2,tplusone,matchedPoints1,matchedPoints2, 'montage');
legend('matched points 1','matched points 2');
title('Matched points from both ')

figure(4);
clf;
showMatchedFeatures(dataGR1,dataGR2,inlierOriginal,inlierDistorted);
hold on;
plotBoundariesAndPoints([], singleboundy, ...
    transformPointsInverse(tform, singleboundy{1}), 'm-');

%% SURF test 2: imcrop detectSURF -> extractFeatures -> matchFeatures

close all;

roisingle1 = regssingle1.BoundingBox;
roisingle2 = regssingle2.BoundingBox;

framecell1 = imcrop(edge(dataGR1,'canny'), roisingle1);
framecell2 = imcrop(edge(dataGR1,'canny'), roisingle2);

tplusone = edge(dataGR2,'canny');

% FOR DEBUGGING
if true
    figure(3)
    subplot(131)
    imshow(tplusone); title('next frame');
    subplot(132)
    imshow(framecell1)
    subplot(133)
    imshow(framecell2)
    tightfig 
    
    colormap bone
end
%%
pointscell1 = detectSURFFeatures(framecell1);
pointscell2 = detectSURFFeatures(framecell2);

pointstplus1 = detectSURFFeatures(tplusone);

[fcell1,vptscell1] = extractFeatures(framecell1,pointscell1);
[fcell2,vptscell2] = extractFeatures(framecell2,pointscell2);

[ftplus1,vptstplus1] = extractFeatures(tplusone,pointstplus1);
%%
indexPairs = matchFeatures(fcell2,ftplus1);

matchedPoints1 = vptscell2(indexPairs(:,1));
matchedPoints2 = vptstplus1(indexPairs(:,2));

figure(31);
clf;
showMatchedFeatures(framecell2,tplusone,matchedPoints1,matchedPoints2, 'montage');
legend('matched points 1','matched points 2');
title('Matched points from both ')

% indexPairs = matchFeatures(fcell2,ftplus1);
% matchedPoints1 = vptscell2(indexPairs(:,1));
% matchedPoints2 = vptstplus1(indexPairs(:,2));
% figure(32);
% clf;
% showMatchedFeatures(framecell2,tplusone,matchedPoints1,matchedPoints2, 'montage');
% legend('matched points 1','matched points 2');
% title('Matched points from both ')

%%

[tform, inlierDistorted, inlierOriginal] = estimateGeometricTransform(...
    matchedPoints2, matchedPoints1, 'projective');

figure(4);
clf;
showMatchedFeatures(dataGR1,dataGR2,inlierOriginal,inlierDistorted);
hold on;
plotBoundariesAndPoints([], singleboundy, ...
    transformPointsInverse(tform, singleboundy{1}), 'm-');
