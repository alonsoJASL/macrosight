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
%% LOADING THE FIRST FRAME
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

%% ALL THE REMAINING UNKNOWN FRAMES

t0 = (ix+1):size(trackinfo,1);
incr = 1;

% set to false if you do not want images to be shown.
debugvar = false;
%jx=1;

if debugvar==true
    figure(111)
    set(gcf, 'Position', get(0,'ScreenSize'));
end
for jx=1:incr:length(t0)
    frametplusT = trackinfo.timeframe(t0(jx));
    [auxstruct] = getdatafromhandles(handles, filenames{frametplusT});
    auxstruct.seglabel = trackinfo.seglabel(t0(jx));
    
    testImage = imfilter(auxstruct.dataGR, ...
        imcrop(knownfr.dataGR, knownfr.regs.BoundingBox));
    
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
    
    if debugvar == true
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
        pause;
    end
end
clear testImage mxidx yinit xinit auxstruct;

dist2known = distset2vect(vertcat(ukfr.xy),knownfr.xy,true);
figure(1)
clf
plot(trackinfo.timeframe, trackMaxCorr, ...
    trackinfo.timeframe, dist2known);
hold on;
plotHorzLine(trackinfo.timeframe, multithresh(dist2known,1));
title('Cross correlation maximum value per unknown frame');
xlabel(sprintf('Time frames: known (%s), unknown (%d and beyond)', ...
    filenames{framet}, trackinfo.timeframe(t0(1))));
legend('Cross correlation maximum value', ...
    'Distance from the original position', ...
    'Otsu of distances');
grid on;
xlim([trackinfo.timeframe(1) trackinfo.timeframe(end)]);

figure(2)
plotBoundariesAndPoints(knownfr.X, knownfr.boundy, vertcat(ukfr.xy), 'm*');

%% PICK A SINGLE UNKNOWN FRAME

t0 = (ix+1):size(trackinfo,1);
jx=10;

% set to false if you do not want images to be shown.
debugvar = true;

if debugvar==true
    figure(111)
    set(gcf, 'Position', get(0,'ScreenSize'));
end

frametplusT = trackinfo.timeframe(t0(jx));
[auxstruct] = getdatafromhandles(handles, filenames{frametplusT});
auxstruct.seglabel = trackinfo.seglabel(t0(jx));

testImage = imfilter(auxstruct.dataGR, ...
    imcrop(knownfr.dataGR, knownfr.regs.BoundingBox));

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

if debugvar == true
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
end

clear testImage mxidx yinit xinit auxstruct;

figure(1)
plot(trackinfo.timeframe, trackMaxCorr);
title('Maximum correlations ');

figure(2)
plotBoundariesAndPoints(knownfr.X, knownfr.boundy, vertcat(ukfr.xy), 'm*');