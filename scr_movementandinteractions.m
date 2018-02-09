% script file: Movement and interactions
% Log file: ./md-logs/scr-movementinteractions-0.md
% scr_movementandinteractions.m
%
%% Initialisation
whichmacro = 2;
initscript;

%% Create trackinfo from clump frames
% Choose the entries in `tablenet` that contain the tracks in
% `whichclump`. Get them into variable `trackinfo`.
wuc = 8007;
fprintf('%s:Working on clump with ID=%d.\n', mfilename, wuc);

% get labels from the clump
clumplab = getlabelsfromcode(wuc);
trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
    clumptracktable(ismember(tablenet.track, clumplab),:)];

ffix = 6;%min(trackinfo.timeframe);
lfix = 72;%max(trackinfo.timeframe);

trackinfo(~ismember(trackinfo.timeframe, ffix:lfix),:) = [];

%%
if length(clumplab)>1
    [trackinfo] = tablecompression(trackinfo, clumplab);
end
[allpaths, wendys] = getpathsperlabel(8007, trackinfo);
wendys(:,2) = wendys(:,2)-1;

for ix=1:(size(wendys,1)-1)
    clumpwendys(ix,:) = [wendys(ix,2)+1 wendys(ix+1,1)-1 ix ix+1];
    allclumppaths{ix} = trackinfo(clumpwendys(ix,1):clumpwendys(ix,2),:);
end

%%

wcix = 3; % which clump interaction index.
citab = allclumppaths{wcix};
meanXY = [mean(allclumppaths{wcix}.X,1)' mean(allclumppaths{wcix}.Y,1)']; % [X Y]

pretab = allpaths{clumpwendys(wcix,3)};
posttab = allpaths{clumpwendys(wcix,4)};

preline = [pretab([1 end],:).X pretab([1 end],:).Y];
postline = [posttab([1 end],:).X posttab([1 end],:).Y];


for jx=pretab.timeframe(1):posttab.timeframe(end)
    %thisfr = getdatafromhandles(handles, filenames{trackinfo.timeframe(jx)});
    thisfr = getdatafromhandles(handles, filenames{jx});
    clf;
    plotBoundariesAndPoints(thisfr.X, bwboundaries(thisfr.clumphandles.overlappingClumps>0), meanXY,'cm');
    plot(preline(:,2), preline(:,1), '-xr');
    plot(postline(:,2), postline(:,1), '-vg');
    pause;
end
%% plot all the tracks by frames

debugvar = true;

ffix = 5;%min(trackinfo.timeframe);
lfix = 72;%max(trackinfo.timeframe);

firstframeidx = find(trackinfo.timeframe==ffix);
lastframeidx = find(trackinfo.timeframe==lfix);

for ix=ffix:lfix%282:462%282:410%1:size(trackinfo, 1)
    thisfr = getdatafromhandles(handles, filenames{ix});
    clf
    plotalltracksperframe(thisfr, trackinfo, ix)
    title(['Frame' 32 num2str(ix)], 'fontsize', 24);
    rmticklabels;
    halfposition;
    removeBorders;
    if debugvar
        if ix==ffix
            f = getframe(gcf);
            [im, map] = rgb2ind(f.cdata, 256, 'nodither');
            im(1,1,1,length(ffix:lfix)) = 0;
        else
            f = getframe(gcf);
            im(:,:,1,ix) = rgb2ind(f.cdata, map, 'nodither');
        end
    end
    pause(0.1);
end
if debugvar
    imwrite(im,map,['./figs/visualisation-macros' num2str(whichmacro) ...
        '-clump' num2str(wuc)  '.gif'],...
        'DelayTime', 0.1, 'LoopCount',inf);
end

%% plot each frame with the track
ffix = min(trackinfo.timeframe);
lfix = max(trackinfo.timeframe);

firstframeidx = find(trackinfo.timeframe==ffix);
lastframeidx = find(trackinfo.timeframe==lfix);

for ix=firstframeidx:lastframeidx%282:462%282:410%1:size(trackinfo, 1)
    thisfr = getdatafromhandles(handles, filenames{trackinfo.timeframe(ix)});
    clf
    plotframeandpoint(thisfr, trackinfo, ix, true);
    title(['Frame' 32 num2str(trackinfo.timeframe(ix))], 'fontsize', 24);
    rmticklabels;
    halfposition;
    pause;
end
%% Plot one frame and then follow the track
ffix = 1;
lfix = 541;

firstframeidx = find(trackinfo.timeframe==ffix);
lastframeidx = find(trackinfo.timeframe==lfix);

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
% Evaluate the tracks and choose an appropriate segment of the
% dataset that shows the cells before and after the clump.
ffix = 1;
lfix = 541;

firstframeidx = find(trackinfo.timeframe==ffix);
lastframeidx = find(trackinfo.timeframe==lfix);

for ix=firstframeidx:lastframeidx%282:462%282:410%1:size(trackinfo, 1)
    thisfr = getdatafromhandles(handles, filenames{trackinfo.timeframe(ix)});
    %if ix==firstframeidx
    %   plotframeandpoint(thisfr, trackinfo, ix);
    %else
    plotframeandpoint([], trackinfo, ix);
    %end
    title(filenames{trackinfo.timeframe(ix)});
    pause(0.1);
end
%%
% Analyse the mean velocity before and after a certain amount of
% frames (10?, 100?, ...)

for ix=firstframeidx:lastframeidx%282:462%282:410%1:size(trackinfo, 1)
    thisfr = getdatafromhandles(handles, filenames{trackinfo.timeframe(ix)});
    plotclumpsandsingles(thisfr)
    title(filenames{trackinfo.timeframe(ix)});
    pause(0.1);
end

