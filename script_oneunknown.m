% script: single shape analysis (SINGLE UNKNOWN FRAME)
%
%% INITIALISATION
initscript;
load DATASETHOLES
%% CHOOSE TRACKS
% w.u.c = which unique clump!
wuc = 8007005; % 8002, 8007, 11010, 8007005, 60010, 60010002
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
% for clump 8007005
% trackinfo(~ismember(trackinfo.timeframe, 15:18),:)=[];

% Select range for clump automatically feature will be added later.

aa = table2struct(trackinfo(1:length(clumplab):end,:));
jx=1:length(clumplab):size(trackinfo,1);
fields = {'seglabel','track','finalLabel'};
for ix=1:length(jx)
    for kx=1:length(fields)
        auxvect = zeros(1,length(clumplab));
        for qx=1:length(clumplab)
            auxvect(qx) =  trackinfo(jx(ix)+(qx-1),:).(fields{kx});
        end
        aa(ix).(fields{kx}) = auxvect;
    end
    aa(ix).clumpseglabel = aa(ix).seglabel(1)*(aa(ix).clumpcode>0);
end

trackinfo = struct2table(aa);
clear ix jx;

% to track maximium correlations
trackMaxCorr = zeros(size(trackinfo,1),length(clumplab));

%% LOADING THE FIRST (KNOWN) FRAME
% wtr = W.TR = Which TRack
wtr = 3;
outname = sprintf('clump%d-tr%d.mat',wuc,clumplab(wtr));
fprintf('\n%sGenerating data for %s.\n', mfilename, upper(outname));

ix = 3;
framet = trackinfo.timeframe(ix);
thisseglabel = trackinfo.seglabel(ix, wtr);

fprintf('\n%s: Loading original (known) frame: %s.\n', ...
    mfilename, filenames{framet});

[auxknown] = getdatafromhandles(handles, filenames{framet});

auxbinmat = auxknown.clumphandles.nonOverlappingClumps==thisseglabel;
auxknown.regs = regionprops(auxbinmat, 'BoundingBox', 'Centroid', ...
    'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength');
auxknown.boundy = bwboundaries(auxbinmat);
clear auxbinmat

testImage = imfilter((auxknown.dataGL==thisseglabel).*auxknown.dataGR,...
    imcrop(auxknown.dataGR,...
    auxknown.regs.BoundingBox));
[trackMaxCorr(ix, wtr), mxidx] = max(testImage(:));
[yinit, xinit] = ind2sub(size(auxknown.dataGR), mxidx);
auxknown.xy = [yinit xinit];

auxknown.test = testImage;
knownfr(wtr) = auxknown;
clear testImage mxidx yinit xinit;

%% PICK A SINGLE UNKNOWN FRAME
%

% This section in the script is to check one particular case.
% If it needs to be used, then change the value of debugvar to true.
t0 = (ix+1):size(trackinfo,1);
jx=1;

frametplusT = trackinfo.timeframe(t0(jx));
[oneuk] = getdatafromhandles(handles, filenames{frametplusT});

if trackinfo.clumpcode(t0(jx)) == wuc
    % Dealing with a clump
    testImage = imfilter(oneuk.dataGR.*...
        (oneuk.dataGL==trackinfo.clumpseglabel(t0(jx))), ...
        imcrop(knownfr(wtr).dataGR, knownfr(wtr).regs.BoundingBox));
else
    % Dealing with a normal cell
    testImage = imfilter(oneuk.dataGR, ...
        imcrop(knownfr(wtr).dataGR, knownfr(wtr).regs.BoundingBox));
end

[trackMaxCorr(jx, wtr), mxidx] = max(testImage(:));
[yinit, xinit] = ind2sub(size(knownfr(wtr).dataGR), mxidx);

oneuk.xy = [yinit xinit];
oneuk.test = testImage;

oneuk.movedboundy = knownfr(wtr).boundy{1} + ...
    repmat(oneuk.xy-knownfr(wtr).xy, size(knownfr(wtr).boundy{1},1),1);
oneuk.movedbb = knownfr(wtr).regs.BoundingBox + ...
    [oneuk.xy(2:-1:1) 0 0]-[knownfr(wtr).xy(2:-1:1) 0 0];

clear testImage mxidx yinit xinit auxstruct;

% Now, evolve the shape from: knownfr(whichtrack).movedboundy to ukfr(jx).dataGR
oneuk.movedmask = imerode(poly2mask(...
    oneuk.movedboundy(:,2), oneuk.movedboundy(:,1),...
    handles.rows, handles.cols), ...
    ones(5));

acopt.framesAhead = jx;
acopt.method = 'Chan-Vese';
acopt.iter = 75;
acopt.smoothf = 1.5;
acopt.contractionbias = -0.1;

BW1 = activecontour(oneuk.dataGR, ...
    oneuk.movedmask, acopt.iter, ...
    acopt.method, 'ContractionBias',acopt.contractionbias,...
    'SmoothFactor', acopt.smoothf);

oneuk.unclumped = BW1;

% ukfr = u.k.fr = UnKnown FRame
ukfr(jx,wtr) = oneuk;

%
figure(1)
plot(trackinfo.timeframe, trackMaxCorr);
title('Maximum correlations ');
legend(sprintf('TRACK-%d',clumplab(1)), sprintf('TRACK-%d',clumplab(2)))

figure(2)
subplot(121)
plotBoundariesAndPoints(oneuk.X, oneuk.movedboundy, bwboundaries(BW1), 'm-')
legend('Known frame moved bound', '... starting point', 'Evolved shape')
%axis([274.4489  537.1758  220.9766  377.7428])
subplot(122)
plotBoundariesAndPoints(oneuk.dataGL, oneuk.movedboundy, bwboundaries(BW1), 'm-')
legend('Known frame moved bound', '... starting point', 'Evolved shape')
%axis([274.4489  537.1758  220.9766  377.7428])
tightfig

%%
figure(111)
set(gcf, 'Position', get(0,'ScreenSize'));
clf;
subplot(2,3,[1 2 4 5])
plotBoundariesAndPoints(ukfr(jx, wtr).dataGL, knownfr(wtr).boundy, ...
    ukfr(jx).movedboundy, 'm-');
title(sprintf('Frame %s: original boundary vs moved boundary',...
    filenames{frametplusT} ));
subplot(233)
plotBoundariesAndPoints(ukfr(jx,wtr).dataGL==trackinfo.clumpseglabel(t0(jx)),...
    knownfr(wtr).boundy);
title('(not that it matters right now, but) check labels on jumpf');
subplot(236)
plotBoundariesAndPoints(ukfr(jx, wtr).test,...
    knownfr(wtr).boundy, ukfr(jx, wtr).movedboundy, 'm-');
colormap parula;