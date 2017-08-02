% script: single shape analysis (SINGLE UNKNOWN FRAME)
%
%% INITIALISATION
initscript;
load DATASETHOLES
%% CHOOSE TRACKS
% w.u.c = which unique clump!
wuc = 11010; % 8002, 11010, 60010, 60010002
fprintf('%s:Working on clump with ID=%d.\n', mfilename, wuc);

% get labels from the clump
clumplab = getlabelsfromcode(wuc);

trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 11 13 14]) ...
    clumptracktable(ismember(tablenet.track, clumplab),:)];

% remove holes from analysis
trackinfo(ismember(trackinfo.timeframe,DATASETHOLES),:) = [];

%% Extract frames wheree the clump exists

% for clump 8002
% trackinfo(trackinfo.timeframe<417,:) = [];
% for clump 11010
% trackinfo(trackinfo.timeframe>=144,:)=[];

% Select range for clump automatically feature will be added later.

aa = table2struct(trackinfo(1:2:end,:));
jx=1:2:size(trackinfo,1);
for ix=1:length(jx)
    aa(ix).seglabel = [trackinfo(jx(ix),:).seglabel trackinfo(jx(ix)+1,:).seglabel];
    aa(ix).track = [trackinfo(jx(ix),:).track trackinfo(jx(ix)+1,:).track];
    aa(ix).finalLabel = [trackinfo(jx(ix),:).finalLabel trackinfo(jx(ix)+1,:).finalLabel];
    aa(ix).clumpseglabel = aa(ix).seglabel(1);
end
trackinfo = struct2table(aa);
clear ix jx;

% to track maximium correlations
trackMaxCorr = zeros(size(trackinfo,1),length(clumplab));

%% LOADING THE FIRST (KNOWN) FRAME
whichtrack = 1;
outname = sprintf('clump%d-tr%d.mat',wuc,clumplab(whichtrack));
fprintf('\n%sGenerating data for %s.\n', mfilename, upper(outname));

ix = 1;
framet = trackinfo.timeframe(ix);
thisseglabel = trackinfo.seglabel(ix, whichtrack);

fprintf('\n%s: Loading original (known) frame: %s.\n', ...
    mfilename, filenames{framet});

[auxknown] = getdatafromhandles(handles, filenames{framet});

auxbinmat = auxknown.clumphandles.nonOverlappingClumps==thisseglabel;
auxknown.regs = regionprops(auxbinmat, 'BoundingBox', 'Centroid', ...
    'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength');
auxknown.boundy = bwboundaries(auxbinmat);
clear auxbinmat

testImage = imfilter(auxknown.dataGR,imcrop(auxknown.dataGR,...
    auxknown.regs.BoundingBox));
[trackMaxCorr(ix, whichtrack), mxidx] = max(testImage(:));
[yinit, xinit] = ind2sub(size(auxknown.dataGR), mxidx);
auxknown.xy = [yinit xinit];

auxknown.test = testImage;
knownfr(whichtrack) = auxknown;
clear testImage mxidx yinit xinit;

%% PICK A SINGLE UNKNOWN FRAME
%

% This section in the script is to check one particular case.
% If it needs to be used, then change the value of debugvar to true.
t0 = (ix+1):size(trackinfo,1);
jx=10;

frametplusT = trackinfo.timeframe(t0(jx));
[auxstruct] = getdatafromhandles(handles, filenames{frametplusT});

if trackinfo.clumpcode(t0(jx)) == wuc
    % Dealing with a clump
    testImage = imfilter(auxstruct.dataGR.*...
        (auxstruct.dataGL==trackinfo.clumpseglabel(t0(jx))), ...
        imcrop(knownfr(whichtrack).dataGR, knownfr(whichtrack).regs.BoundingBox));
else
    % Dealing with a normal cell
    testImage = imfilter(auxstruct.dataGR, ...
        imcrop(knownfr(whichtrack).dataGR, knownfr(whichtrack).regs.BoundingBox));
end

[trackMaxCorr(jx, whichtrack), mxidx] = max(testImage(:));
[yinit, xinit] = ind2sub(size(knownfr(whichtrack).dataGR), mxidx);

auxstruct.xy = [yinit xinit];
auxstruct.test = testImage;

auxstruct.movedboundy = knownfr(whichtrack).boundy{1} + ...
    repmat(auxstruct.xy-knownfr(whichtrack).xy, size(knownfr(whichtrack).boundy{1},1),1);
auxstruct.movedbb = knownfr(whichtrack).regs.BoundingBox + ...
    [auxstruct.xy(2:-1:1) 0 0]-[knownfr(whichtrack).xy(2:-1:1) 0 0];

% ukfr = u.k.fr = UnKnown FRame
ukfr(jx,whichtrack) = auxstruct;

clear testImage mxidx yinit xinit auxstruct;

% Now, evolve the shape from: knownfr(whichtrack).movedboundy to ukfr(jx).dataGR
oneuk = ukfr(jx, whichtrack);

oneuk.movedmask = imerode(poly2mask(...
    oneuk.movedboundy(:,2), oneuk.movedboundy(:,1),...
    handles.rows, handles.cols), ...
    ones(7));

acopt.framesAhead = jx;
acopt.method = 'Chan-Vese';
acopt.iter = 100;
acopt.smoothf = 2;
acopt.contractionbias = -0.1;

BW1 = activecontour(oneuk.dataGR, oneuk.movedmask, acopt.iter, ...
    acopt.method, 'ContractionBias',acopt.contractionbias,...
    'SmoothFactor', acopt.smoothf);

%% 
figure(1)
plot(trackinfo.timeframe, trackMaxCorr);
title('Maximum correlations ');
legend(sprintf('TRACK-%d',clumplab(1)), sprintf('TRACK-%d',clumplab(2)))

figure(2)
subplot(121)
plotBoundariesAndPoints(oneuk.X, oneuk.movedboundy, bwboundaries(BW1), 'm-')
legend('Known frame moved bound', '... starting point', 'Evolved shape')
axis([274.4489  537.1758  220.9766  377.7428])
subplot(122)
plotBoundariesAndPoints(oneuk.dataGL, oneuk.movedboundy, bwboundaries(BW1), 'm-')
legend('Known frame moved bound', '... starting point', 'Evolved shape')
axis([274.4489  537.1758  220.9766  377.7428])
%tightfig

%%
figure(111)
set(gcf, 'Position', get(0,'ScreenSize'));
clf;
subplot(2,3,[1 2 4 5])
plotBoundariesAndPoints(ukfr(jx).dataGL, knownfr(whichtrack).boundy, ...
    ukfr(jx).movedboundy, 'm-');
title(sprintf('Frame %s: original boundary vs moved boundary',...
    filenames{frametplusT} ));
subplot(233)
plotBoundariesAndPoints(ukfr(jx).dataGL==trackinfo.clumpseglabel(t0(jx)),...
    knownfr(whichtrack).boundy);
title('(not that it matters right now, but) check labels on jumpf');
subplot(236)
plotBoundariesAndPoints(ukfr(jx).test,...
    knownfr(whichtrack).boundy, ukfr(jx).movedboundy, 'm-');
colormap parula;