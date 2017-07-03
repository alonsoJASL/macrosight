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

[~,laname1] = loadone(handles.dataLa,clumpnucleirange(1));
[~,laname2] = loadone(handles.dataLa,clumpnucleirange(2));
[dataL1, dataGL1, clumphandles1, dataR1, dataGR1] = ...
    getdatafromhandles(handles, laname1);
[dataL2, dataGL2, clumphandles2, dataR2, dataGR2] = ...
    getdatafromhandles(handles, laname2);

X1 = cat(3, dataR1, dataGR1, zeros(size(dataR1)));
X2 = cat(3, dataR2, dataGR2, zeros(size(dataR2)));

regsclump = regionprops(clumphandles2.overlappingClumps==10);

singleidx = 10;
regssingle = regionprops(clumphandles1.nonOverlappingClumps==singleidx);
singleboundy = bwboundaries(clumphandles1.nonOverlappingClumps==singleidx);

figure(21)
clf;
subplot(121);
imagesc(dataGL1);
title(sprintf('Green channel at frame = %s', laname1));
rectangle('Position', regsclump.BoundingBox, 'EdgeColor', 'r');
rectangle('Position', regssingle.BoundingBox, 'EdgeColor', 'c');

subplot(122);
imagesc(dataGL2);
title(sprintf('Green channel at frame = %s', laname2));
rectangle('Position', regsclump.BoundingBox, 'EdgeColor', 'r');
rectangle('Position', regssingle.BoundingBox, 'EdgeColor', 'c');

tightfig;

figure(2)
clf;
imshowpair(X1,X2);
title(sprintf('Showing frames %s and %s', laname1, laname2));
rectangle('Position', regsclump.BoundingBox, 'EdgeColor', 'r');
rectangle('Position', regssingle.BoundingBox, 'EdgeColor', 'c');

%% SOM test 

% Get two grids in bounding boxes
netsize = [7 7];
nettype = 'supergrid';
bbox1 = regssingle.BoundingBox./2;
%bbox2 = regsclump.BoundingBox;

pos1 = somGetNetworkPositions(nettype, netsize, bbox1);
%pos2 = somGetNetworkPositions(nettype, netsize, bbox2);

G1 = somBasicNetworks(nettype, netsize, pos1);

% parameters of the self-organising method
thisalpha = 0.5;
thisalphadecay = 'none';
thisneighboursize = 8;
thisneighbourdecay = 'linear';
thissteptype = 'intensity';

options.maxiter = 2500;
options.alphazero = thisalpha;
options.alphadtype = thisalphadecay;
options.N0 = thisneighboursize;
options.ndtype = thisneighbourdecay;
options.staticfrontier = false;
options.steptype = thissteptype;
options.debugvar = false;
options.gifolder = strcat('.',filesep);
options.gifname = [];

[inputData, sizeinput] = somGetInputData(...
   clumphandles1.nonOverlappingClumps==singleidx,X1);
%% Training at time t
tic;
[G, nethandles] = somTrainingPlus(inputData, G1, options);
nethandles.time = toc;

% Training at time t+1

% parameters of the self-organising method
thisalpha = 0.25;
thisalphadecay = 'linear';
thisneighboursize = 4;
thisneighbourdecay = 'exp';
thissteptype = 'intensity';

options.maxiter = 100;
options.alphazero = thisalpha;
options.alphadtype = thisalphadecay;
options.N0 = thisneighboursize;
options.ndtype = thisneighbourdecay;
options.staticfrontier = false;
options.steptype = thissteptype;
options.debugvar = false;
options.gifolder = strcat('.',filesep);
options.gifname = [];

[inputData, sizeinput] = somGetInputData(...
   dataGR2.*(clumphandles2.overlappingClumps==10),X2);

tic;
[fG, nethandles] = somTrainingPlus(inputData, G, options);
nethandles.time = toc;

figure(5)
subplot(121)
plotGraphonImage(dataGR1, G);
title(sprintf('Network input at frame = %s', laname1));

subplot(122)
plotGraphonImage(dataGR2, fG);
title(sprintf('Network output at frame = %s', laname2));
