% script file: Movement and interactions
% Log file: ./md-logs/scr-movementinteractions-0.md
% scr_movementandinteractions.m
%
%% Initialisation

initscript;

%% Create trackinfo from clump frames
% Choose the entries in `tablenet` that contain the tracks in
% `whichclump`. Get them into variable `trackinfo`.
wuc = 8;
fprintf('%s:Working on clump with ID=%d.\n', mfilename, wuc);

% get labels from the clump
clumplab = getlabelsfromcode(wuc);
trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
    clumptracktable(ismember(tablenet.track, clumplab),:)];

disp(trackinfo);

%% check 10 and 11 after frame 135 (they seem to speed up like hell!
for ix=282:462%282:410%1:size(trackinfo, 1)
    thisfr = getdatafromhandles(handles, filenames{trackinfo.timeframe(ix)});
    clf
    plotframeandpoint(thisfr, trackinfo, ix);
    title(filenames{trackinfo.timeframe(ix)}, 'fontsize', 24);
    rmticklabels;
    halfposition;
    pause(0.1);
end
%%
for ix=262:374%282:462%282:410%1:size(trackinfo, 1)
    thisfr = getdatafromhandles(handles, filenames{trackinfo.timeframe(ix)});
    if ix==262
        plotframeandpoint(thisfr, trackinfo, ix);
    else
        plotframeandpoint([], trackinfo, ix);
    end
    title(filenames{trackinfo.timeframe(ix)});
    pause;
end
%%
% Evaluate the tracks and choose an appropriate segment of the
% dataset that shows the cells before and after the clump.

%%
% Analyse the mean velocity before and after a certain amount of
% frames (10?, 100?, ...)
