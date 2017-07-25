% script: single shape analysis
%
%% INITIALISATION
initscript;

%% CHOOSE TRACKS
% w.u.c = which unique clump!
ix=8; % OR, FOR A RANDOM CODE: randi(length(clumpidcodes)); 10
wuc = clumpidcodes(ix);
fprintf('Working on clump with ID=%d.\n', wuc);

% get labels from the clump
clumplab = getlabelsfromcode(wuc);
%% CHOOSE ONE TRACK AND ISOLATE THE GREEN CHANNEL SEGMENTATION FOR IT.
thistrack = clumplab(1);
trackinfo = tablenet(tablenet.track==2,[5 11 13 14]);

% delete frames from the analysis.
trackinfo(1:417,:)=[];
trackMaxCorr = zeros(size(trackinfo,1),1);
%% LOADING A SINGLE FRAME
ix = 1;
framet = trackinfo.timeframe(ix);

thisseglabel = trackinfo.seglabel(ix);

fprintf('\n%s: Loading original frame: %s.\n', ...
    mfilename, filenames{framet});

[thisf] = getdatafromhandles(handles, filenames{framet});

auxbinmat = thisf.clumphandles.nonOverlappingClumps==thisseglabel;
thisf.regs = regionprops(auxbinmat, 'BoundingBox', 'Centroid', ...
    'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength');
thisf.boundy = bwboundaries(auxbinmat);
clear auxbinmat

testImage = imfilter(thisf.dataGR, ...
    imcrop(thisf.dataGR, thisf.regs.BoundingBox));
[trackMaxCorr(ix), mxidx] = max(testImage(:));
[yinit, xinit] = ind2sub(size(thisf.dataGR), mxidx);
thisf.xy = [yinit xinit];

thisf.test = testImage;
clear testImage mxidx yinit xinit;

%% ONTO the following frames
t0 = 5;
frametplusT = framet + t0;
[jumpf] = getdatafromhandles(handles, filenames{frametplusT});

fprintf('\n%s: Compare frame: %s and Frame: %s.\n', ...
    mfilename, filenames{framet}, filenames{frametplusT});

%% 

t0 = (ix+1):size(trackinfo,1);
incr = 1;

%jx=1;
for jx=1:incr:length(t0)
    frametplusT = trackinfo.timeframe(t0(jx));
    [auxstruct] = getdatafromhandles(handles, filenames{frametplusT});
    
    testImage = imfilter(auxstruct.dataGR, ...
        imcrop(thisf.dataGR, thisf.regs.BoundingBox));
    
    [trackMaxCorr(jx), mxidx] = max(testImage(:));
    [yinit, xinit] = ind2sub(size(thisf.dataGR), mxidx);
    
    auxstruct.xy = [yinit xinit];
    auxstruct.test = testImage; 
    
    jumpf(jx) = auxstruct;
end
clear testImage mxidx yinit xinit;

figure(1)
plot(trackinfo.timeframe, trackMaxCorr);
title('xcorr ');

figure(2)
plotBoundariesAndPoints(thisf.X, thisf.boundy, vertcat(jumpf.xy), 'm*');
