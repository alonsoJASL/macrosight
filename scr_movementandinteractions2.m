%% Initialisation
tidy;
whichmacro = 3;
initscript;

T = readtable('/Users/jsolisl/Desktop/macros123.xlsx');
T(~contains(T.whichdataset, ds(1:end-1)),:) = [];

rowix = 5;
mT = T(rowix,:);

wuc= mT.whichclump;
clumplab = mT.whichlabel;

trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
    clumptracktable(ismember(tablenet.track, clumplab),:)];

ffix=mT.initialframe;
lfix=mT.finalframe;

trackinfo(~ismember(trackinfo.timeframe, ffix:lfix),:) = [];

%%
% if exist('clumplab') && length(clumplab)>1
%     [trackinfo] = tablecompression(trackinfo, clumplab);
% end
[allpaths, wendys] = getpathsperlabel(wuc, trackinfo);
wendys(:,2) = wendys(:,2)-1;

for ix=1:(size(wendys,1)-1)
    clumpwendys(ix,:) = [wendys(ix,2)+1 wendys(ix+1,1)-1 ix ix+1];
    allclumppaths{ix} = trackinfo(clumpwendys(ix,1):clumpwendys(ix,2),:);
end

%%

wcix = 1; % which clump interaction index.
citab = allclumppaths{wcix};
meanXY = [mean(allclumppaths{wcix}.X,1)' mean(allclumppaths{wcix}.Y,1)']; % [X Y]

pretab = allpaths{clumpwendys(wcix,3)};
posttab = allpaths{clumpwendys(wcix,4)};

preline = [pretab([1 end],:).X pretab([1 end],:).Y];
postline = [posttab([1 end],:).X posttab([1 end],:).Y];

x1=preline(1,:);
x2=preline(2,:);
y1=postline(1,:);
y2=postline(2,:);
x2prime = x2-x1;
th1 = rad2deg(angle(x2prime(2)+x2prime(1).*1i));
R = [cosd(-th1) -sind(-th1); sind(-th1) cosd(-th1)];
y2prime = (y2-y1)*R(:,2:-1:1)';
thx = rad2deg(angle(y2prime(2)+y2prime(1).*1i));


%% Check one
jx=randi([pretab.timeframe(1) posttab.timeframe(end)]);
thisfr = getdatafromhandles(handles, filenames{jx});
clf;
plotBoundariesAndPoints(thisfr.X, bwboundaries(thisfr.clumphandles.overlappingClumps>0), meanXY,'md');
plot(preline(:,2), preline(:,1), '-xr');
plot(postline(:,2), postline(:,1), '-vg');
axis xy;
title(['Angle =' 32 num2str(thx)]);

%% check all
for jx=pretab.timeframe(1):posttab.timeframe(end)
    %thisfr = getdatafromhandles(handles, filenames{trackinfo.timeframe(jx)});
    thisfr = getdatafromhandles(handles, filenames{jx});
    clf;
    plotBoundariesAndPoints(thisfr.X, bwboundaries(thisfr.clumphandles.overlappingClumps>0), meanXY,'md');
    plot(preline(:,2), preline(:,1), '-xr');
    plot(postline(:,2), postline(:,1), '-vg');
    pause;
end