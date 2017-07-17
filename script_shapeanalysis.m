% Shape analysis
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
%%
figure(1)
clf
plotTracks(handles,2,labelsinclump);
title(sprintf('Nuclei that belong to clump %d, moving through time.', wuc));

%% select one cell from the range
t = 1;
framet = clumpnucleirange(t);
frametplus1 = clumpnucleirange(t+1);

[dataL, dataGL, clumphandles, dataR, dataGR] = ...
    getdatafromhandles(handles, filenames{framet});
sf.dataL = dataL;
sf.dataGL = dataGL;
sf.clumphandles = clumphandles;
sf.dataR = dataR;
sf.dataGR = dataGR;
sf.X = cat(3, dataR, dataGR, zeros(size(dataR)));

[dataL, dataGL, clumphandles, dataR, dataGR] = ...
            getdatafromhandles(handles, filenames{frametplus1});
% cf := clump frame
cf.dataL = dataL;
cf.dataGL = dataGL;
cf.clumphandles = clumphandles;
cf.dataR = dataR;
cf.dataGR = dataGR;
cf.X = cat(3, dataR, dataGR, zeros(size(dataR)));

clear dataL dataGL clumphandles dataR dataGR;

regsclump = regionprops(cf.clumphandles.overlappingClumps==10);
sf.lab = labelsinclump;

regssingle1 = regionprops(sf.clumphandles.nonOverlappingClumps==sf.lab(1));
regssingle2 = regionprops(sf.clumphandles.nonOverlappingClumps==sf.lab(2));

singleboundy = bwboundaries(sf.clumphandles.nonOverlappingClumps==singleidx2);
singlebbox = regssingle1.BoundingBox;

