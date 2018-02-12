% Log visualisations

%% INIT
initscript;
wuc = 8;
fprintf('%s:Working on clump with ID=%d.\n', mfilename, wuc);

% get labels from the clump
clumplab = getlabelsfromcode(wuc);
trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
    clumptracktable(ismember(tablenet.track, clumplab),:)];
%% visualisation-log1
ix=310;
subplot(121)
thisfr = getdatafromhandles(handles, filenames{trackinfo.timeframe(ix)});
plotframeandpoint(thisfr, trackinfo, ix);
title(filenames{trackinfo.timeframe(ix)});
rmticklabels;
ix=411;
subplot(122)
thisfr = getdatafromhandles(handles, filenames{trackinfo.timeframe(ix)});
plotframeandpoint(thisfr, trackinfo, ix);
title(filenames{trackinfo.timeframe(ix)});
rmticklabels;
tightfig

%% visualisation-log2

firstframeidx = 262;
lastframeidx = 340;

%% visualisation-log3

firstframeidx = 300;
lastframeidx = 400;

%%
for ix=firstframeidx:lastframeidx%282:462%282:410%1:size(trackinfo, 1)
    thisfr = getdatafromhandles(handles, filenames{trackinfo.timeframe(ix)});
    if ix==firstframeidx
        plotframeandpoint(thisfr, trackinfo, ix);
    else
        plotframeandpoint([], trackinfo, ix);
    end
    title(filenames{trackinfo.timeframe(ix)});
    pause(0.1);
end
%% Visualisation cell changing direction

jx=pretab.timeframe(1);
tot = length(pretab.timeframe(1):posttab.timeframe(end));

thisfr = getdatafromhandles(handles, filenames{jx});
clf;
plotBoundariesAndPoints(thisfr.X, bwboundaries(thisfr.clumphandles.overlappingClumps>0), meanXY,'md');
plot(preline(:,2), preline(:,1), '-xr');
plot(postline(:,2), postline(:,1), '-vg');
axis([330   546    69   234]);
halfposition;
title([filenames{jx} 32 '(' num2str(1) 32 'out of ' num2str(tot) ')'], ...
    'FontSize', 24);

f = getframe(gcf);
[im,map] = rgb2ind(f.cdata,256,'nodither');
im(1,1,1,tot) = 0;

for jx=pretab.timeframe(2):posttab.timeframe(end)
    %thisfr = getdatafromhandles(handles, filenames{trackinfo.timeframe(jx)});
    thisfr = getdatafromhandles(handles, filenames{jx});
    clf;
    plotBoundariesAndPoints(thisfr.X, bwboundaries(thisfr.clumphandles.overlappingClumps>0), meanXY,'md');
    plot(preline(:,2), preline(:,1), '-xr');
    plot(postline(:,2), postline(:,1), '-vg');
    axis([330   546    69   234]);
    halfposition;
    title([filenames{jx} 32 '(' num2str(jx-pretab.timeframe(1)) 32 'out of ' num2str(tot) ')'],...
        'FontSize', 24);
    
    f = getframe(gcf);
    im(:,:,1,jx-pretab.timeframe(1)) = rgb2ind(f.cdata,map,'nodither');
    
    pause(0.3);
    
end

outputname = './figs/visualisation-dirchange-1.gif';
imwrite(im,map,outputname,'DelayTime',0.25, 'LoopCount',inf);