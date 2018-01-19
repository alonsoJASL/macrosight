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
%% 