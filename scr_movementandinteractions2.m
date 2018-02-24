%% Initialisation
tidy;
whichmacro = 2;
initscript;

T = readtable('./macros123.xlsx');
T(~contains(T.whichdataset, ds(1:end-1)),:) = [];

rowix = 1;
mT = T(rowix,:);

wuc= mT.whichclump;
clumplab = mT.whichlabel;

trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
    clumptracktable(ismember(tablenet.track, clumplab),:)];

ffix=mT.initialframe;
lfix=mT.finalframe;

trackinfo(~ismember(trackinfo.timeframe, ffix:lfix),:) = [];

% CLUMPPATHS
% if exist('clumplab') && length(clumplab)>1
%     [trackinfo] = tablecompression(trackinfo, clumplab);
% end
[allpaths, wendys] = getpathsperlabel(wuc, trackinfo);
wendys(:,2) = wendys(:,2)-1;
disp(wendys)
%% Get rid of all cases where cell exists and re-enters clump
allpaths(wendys(:,1)==wendys(:,2),:)=[];
wendys(wendys(:,1)==wendys(:,2),:)=[];

%
for ix=1:(size(wendys,1)-1)
    clumpwendys(ix,:) = [wendys(ix,2)+1 wendys(ix+1,1)-1 ix ix+1];
    allclumppaths{ix} = trackinfo(clumpwendys(ix,1):clumpwendys(ix,2),:);
end

% ANGLES
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

c=cosd(th1); s=sind(th1);
R = [c -s;
    s  c];

y2prime = R'*[y2(2)-y1(2);y2(1)-y1(1)];
y2prime = y2prime(2:-1:1)';

stt(rowix).thx = rad2deg(angle(y2prime(2)+y2prime(1).*1i));
stt(rowix).bL = norm(x2-x1);
stt(rowix).afL = norm(y2-y1);
stt(rowix).bmeanVel = mean(pretab.velocity(1:end-1));
stt(rowix).bstdVel = std(pretab.velocity(1:end-1));
stt(rowix).afmeanVel = mean(posttab.velocity);
stt(rowix).afstdVel = std(posttab.velocity);
stt(rowix).bdist2clump = norm(x2-meanXY(2:-1:1));
stt(rowix).afdist2clump = norm(y1-meanXY(2:-1:1));
stt(rowix).clumpsize = size(allclumppaths{wcix}, 1);

fprintf('Done, thetaX = %f.\n ', stt.thx);

% ANALYSIS WITH ALL THE POINTS IN allpaths{}
preXY = [pretab.X pretab.Y];
postXY = [posttab.X posttab.Y];

qq = preXY - repmat(x1, size(preXY,1),1);
qqq = [-s.*qq(:,2)+c.*qq(:,1) c.*qq(:,2)+s.*qq(:,1)];

rr = postXY - repmat(y1, size(postXY,1),1);
rrr = [-s.*rr(:,2)+c.*rr(:,1) c.*rr(:,2)+s.*rr(:,1)];

%
figure(2)
clf;
hold on; grid on;
plot(qqq(:,2)-qqq(end,2), qqq(:,1)-qqq(end,1), '--d', ...
    qqq([1 end],2)-qqq(end,2), qqq([1 end],1)-qqq(end,1), 'r-o', ...
    'LineWidth', 2, 'MarkerSize', 7)
plot(rrr(:,2), rrr(:,1), ':*', rrr([1 end], 2), rrr([1 end],1), 'x-g', ...
    'LineWidth', 2, 'MarkerSize', 7)
THX = stt(rowix).thx;
ra = 0.25.*min(stt(rowix).bL, stt(rowix).afL);
if THX>0
    t=0:0.5:THX;
    plot(ra.*cosd(t), ra.*sind(t), 'm', ...
        ra.*cosd(t(end-5)), ra.*sind(t(end-5)),'vm', ...
        'LineWidth', 2, 'MarkerSize', 7)
else
    t=THX:0.5:0;
    plot(ra.*cosd(t), ra.*sind(t), 'm', ...
        ra.*cosd(t(5)), ra.*sind(t(5)),'^m', ...
        'LineWidth', 2, 'MarkerSize', 7)
end

legend('Pre-clump','Pre-line', 'Post-clump',  'Post-line',...
    'Change of dir (\theta)', ...
    'Location','southoutside','Orientation','horizontal')
set(gcf, 'Position',[2   562   958   434]);


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