% Log visualisations

%% INIT
initscript;
wuc = 8;
fprintf('%s:Working on clump with ID=%d.\n', mfilename, wuc);

% get labels from the clump
clumplab = getlabelsfromcode(wuc);
trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
    clumptracktable(ismember(tablenet.track, clumplab),:)];
%%

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