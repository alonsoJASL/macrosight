% script: single shape analysis (SINGLE UNKNOWN FRAME)
%
%% INITIALISATION
initscript;

%% CHOOSE TRACKS
% w.u.c = which unique clump!
wuc = 11010;
fprintf('%s:Working on clump with ID=%d.\n', mfilename, wuc);

% get labels from the clump
clumplab = getlabelsfromcode(wuc);
% CHOOSE ONE TRACK AND ISOLATE THE GREEN CHANNEL SEGMENTATION FOR IT.
thistrack = clumplab(1);
fprintf('%s:\t...on track with finalLabel=%d.\n', mfilename, thistrack);

trackinfo = [tablenet(tablenet.track==thistrack,[5 11 13 14]) ...
    clumptracktable(tablenet.track==thistrack,1)];

%% Extract frames wheree the clump exists

% for clump 8002
trackinfo(1:417,:)=[];
%
% for clump 11010
trackinfo(144:end,:)=[];
trackinfo([75 119],:)=[];

% to track maximium correlations
trackMaxCorr = zeros(size(trackinfo,1),1);
%% LOADING THE FIRST (KNOWN) FRAME
outname = sprintf('clump%d-tr%d.mat',wuc,thistrack);
fprintf('\n%sGenerating data for %s.\n', mfilename, upper(outname));

ix = 1;
framet = trackinfo.timeframe(ix);
thisseglabel = trackinfo.seglabel(ix);

fprintf('\n%s: Loading original (known) frame: %s.\n', ...
    mfilename, filenames{framet});

[knownfr] = getdatafromhandles(handles, filenames{framet});

auxbinmat = knownfr.clumphandles.nonOverlappingClumps==thisseglabel;
knownfr.regs = regionprops(auxbinmat, 'BoundingBox', 'Centroid', ...
    'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength');
knownfr.boundy = bwboundaries(auxbinmat);
clear auxbinmat

testImage = imfilter(knownfr.dataGR,imcrop(knownfr.dataGR,...
    knownfr.regs.BoundingBox));
[trackMaxCorr(ix), mxidx] = max(testImage(:));
[yinit, xinit] = ind2sub(size(knownfr.dataGR), mxidx);
knownfr.xy = [yinit xinit];

knownfr.test = testImage;
clear testImage mxidx yinit xinit;

%% PICK A SINGLE UNKNOWN FRAME
%

% This section in the script is to check one particular case.
% If it needs to be used, then change the value of debugvar to true.
t0 = (ix+1):size(trackinfo,1);
jx=15;

frametplusT = trackinfo.timeframe(t0(jx));
[auxstruct] = getdatafromhandles(handles, filenames{frametplusT});
auxstruct.seglabel = trackinfo.seglabel(t0(jx)); 

if trackinfo.clumpcode(jx) == wuc
    % Dealing with a clump
    testImage = imfilter((auxstruct.dataGL==auxstruct.seglabel).*auxstruct.dataGR, ...
        imcrop(knownfr.dataGR, knownfr.regs.BoundingBox));
else
    % Dealing with a normal cell
    testImage = imfilter(auxstruct.dataGR, ...
        imcrop(knownfr.dataGR, knownfr.regs.BoundingBox));
end

[trackMaxCorr(jx), mxidx] = max(testImage(:));
[yinit, xinit] = ind2sub(size(knownfr.dataGR), mxidx);

auxstruct.xy = [yinit xinit];
auxstruct.test = testImage;

auxstruct.movedboundy = knownfr.boundy{1} + ...
    repmat(auxstruct.xy-knownfr.xy, size(knownfr.boundy{1},1),1);
auxstruct.movedbb = knownfr.regs.BoundingBox + ...
    [auxstruct.xy(2:-1:1) 0 0]-[knownfr.xy(2:-1:1) 0 0];

% ukfr = u.k.fr = UnKnown FRame
ukfr(jx) = auxstruct;

clear testImage mxidx yinit xinit auxstruct;

% Now, evolve the shape from: knownfr.movedboundy to ukfr(jx).dataGR
oneuk = ukfr(jx);

oneuk.movedmask = poly2mask(...
    oneuk.movedboundy(:,2), oneuk.movedboundy(:,1),...
    handles.rows, handles.cols);

acopt.framesAhead = jx;
acopt.method = 'Chan-Vese';
acopt.iter = 100;
acopt.smoothf = 2;
acopt.contractionbias = -0.01;

BW1 = activecontour(oneuk.dataGR, oneuk.movedmask, acopt.iter, ...
    acopt.method, 'ContractionBias',acopt.contractionbias,...
    'SmoothFactor', acopt.smoothf);

figure(2)
subplot(121)
plotBoundariesAndPoints(oneuk.X, oneuk.movedboundy, bwboundaries(BW1), 'm-')
legend('Known frame moved bound', '... starting point', 'Evolved shape')
axis([274.4489  537.1758  220.9766  377.7428])
subplot(122)
plotBoundariesAndPoints(oneuk.dataGL, oneuk.movedboundy, bwboundaries(BW1), 'm-')
legend('Known frame moved bound', '... starting point', 'Evolved shape')
axis([274.4489  537.1758  220.9766  377.7428])
tightfig

%% 
figure(1)
plot(trackinfo.timeframe, trackMaxCorr);
title('Maximum correlations ');

figure(111)
set(gcf, 'Position', get(0,'ScreenSize'));
clf;
subplot(2,3,[1 2 4 5])
plotBoundariesAndPoints(ukfr(jx).dataGL, knownfr.boundy, ...
    ukfr(jx).movedboundy, 'm-');
title(sprintf('Frame %s: original boundary vs moved boundary',...
    filenames{frametplusT} ));
subplot(233)
plotBoundariesAndPoints(ukfr(jx).dataGL==ukfr(jx).seglabel,...
    knownfr.boundy);
title('(not that it matters right now, but) check labels on jumpf');
subplot(236)
plotBoundariesAndPoints(ukfr(jx).test,...
    knownfr.boundy, ukfr(jx).movedboundy, 'm-');
colormap parula;