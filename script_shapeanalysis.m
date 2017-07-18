% SCRIPT FILE: Shape analysis
% 

%% INITIALISATION
initscript;

%% CHOOSE WHICH (uniquely identifiable) CLUMP to work on
% w.u.c = which unique clump!
ix=10; % OR, FOR A RANDOM CODE: randi(length(clumpidcodes));
wuc = clumpidcodes(ix);

fprintf('Working on clump with ID=%d.\n', wuc);

% get labels from the clump
clumplab = getlabelsfromcode(wuc);
timeofclump = unique(tablenet(clumptracktable.clumpcode==wuc,:).timeframe);
clumpnucleirange = (timeofclump(1)-1):(timeofclump(end)+1);

tabletracks = tablenet(ismember(tablenet.timeframe, clumpnucleirange),:);
tableclump = clumptracktable(ismember(tablenet.timeframe, clumpnucleirange),:);

%% For a time t, and it's successor, get sf and cf.
t = 1;
t0 = 1;
framet = clumpnucleirange(t);
frametplusT = clumpnucleirange(t+t0);

fprintf('\n%s: Compare frame: %s and Frame: %s.\n', ...
    mfilename, filenames{framet}, filenames{frametplusT});

[sf] = getdatafromhandles(handles, filenames{framet});
[cf] = getdatafromhandles(handles, filenames{frametplusT});

cf.thisclump = cf.clumphandles.overlappingClumps==10;
cf.regs = regionprops(cf.thisclump);
for jx=1:length(clumplab)
    auxbinmat = sf.clumphandles.nonOverlappingClumps==clumplab(jx);
    sf.regs(jx) = regionprops(auxbinmat, 'BoundingBox', 'Centroid', ...
        'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength');
    sf.boundy(jx) = bwboundaries(auxbinmat);
end
clear auxbinmat jx;

%% Follow independent cells on framet with a xcorr!
% First get the information from framet (i.e sf)
for kx=1:length(clumplab)
    testImage = imfilter(sf.dataGR, imcrop(sf.dataGR, sf.regs(kx).BoundingBox));
    [maxval, mxidx] = max(testImage(:));
    [yinit, xinit] = ind2sub(size(sf.dataGR), mxidx);
    sf.xy(kx,:) = [yinit xinit];
end
clear testImage maxval mxidx yinit xinit;

% Now, get the information from frametplus1 (i.e cf)
for kx=1:length(clumplab)
    testImage = imfilter(cf.dataGR.*cf.thisclump, imcrop(sf.dataGR, sf.regs(kx).BoundingBox));
    [maxval, mxidx] = max(testImage(:));
    [yinit, xinit] = ind2sub(size(sf.dataGR), mxidx);
    cf.xy(kx,:) = [yinit xinit];
end
clear testImage maxval mxidx yinit xinit;

% Move boundaries based on sf.xy and cf.xy 
for kx=1:length(clumplab)
    cf.movedboundy{kx} = sf.boundy{kx} + ...
        repmat(cf.xy(kx,:)-sf.xy(kx,:), size(sf.boundy{kx},1),1);
end