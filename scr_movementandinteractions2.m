%% Initialisation
tidy;
whichmacro = 2;
initscript;

%% 
rowix = 8;

T = readtable('./macros123.xlsx');
T(~contains(upper(T.whichdataset), ds(1:end-1)),:) = [];
mT = T(rowix,:);

TS = readtable('./macros123singles.xlsx');
TS(~contains(upper(TS.whichdataset), ds(1:end-1)),:) = [];
mTS = TS(rowix,:);

wuc= mT.whichclump;
clumplab = mT.whichlabel;

trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
    clumptracktable(ismember(tablenet.track, clumplab),:)];

ffix=mT.initialframe;
lfix=mT.finalframe;

[~, stt, xtras] = getclumpanglechange(trackinfo, wuc, [ffix lfix]);

subplot(212)
plotdirectionchange(stt, xtras, true);

fprintf('Done, thetaX = %f \n ', stt.thx);

%% plotdirectionchange(stt, xtras);
strackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
    clumptracktable(ismember(tablenet.track, clumplab),:)];
pretrinf = strackinfo(ismember(strackinfo.timeframe, ...
    (mTS.initialfr_pre):mTS.finalfr_pre),:);
posttrinf = strackinfo(ismember(strackinfo.timeframe, ...
    mTS.initialfr_post:(mTS.finalfr_post)),:);

preXY = [pretrinf.X pretrinf.Y];
postXY = [posttrinf.X posttrinf.Y];
s=xtras.s; c=xtras.c;
x1 = preXY(1,:);
y1 = postXY(1,:);
qq = preXY - repmat(x1, size(preXY,1),1);
qqq = [-s.*qq(:,2)+c.*qq(:,1) c.*qq(:,2)+s.*qq(:,1)];
posty2prime = postXY(end,:)-postXY(1,:);
th2 = rad2deg(angle(posty2prime(2)+posty2prime(1).*1i));
c2=cosd(th2); s2=sind(th2);
rr = postXY - repmat(y1, size(postXY,1),1);
rrr = [-s2.*rr(:,2)+c2.*rr(:,1) c2.*rr(:,2)+s2.*rr(:,1)];

plotdirectionchange(stt, xtras);
plot(qqq(:,2)-qqq(end,2), qqq(:,1)-qqq(end,1)-2, '--db', ...
    'LineWidth', 2, 'MarkerSize', 7)
plot(rrr(:,2)-rrr(end,2), rrr(:,1)-rrr(end,1)-4, '--d', ...
    'LineWidth', 2, 'MarkerSize', 7)
%%
figure(1)
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
figure(2)
%jx=randi([ffix lfix]);
jx=round(mean([mT.clumpinit mT.clumpfin]));
thisfr = getdatafromhandles(handles, filenames{jx});
clf;
plotBoundariesAndPoints(rgb2gray(thisfr.X), [], xtras.meanXY, 'md');
%plotBoundariesAndPoints([], [], xtras.meanXY, 'md');
pos = [xtras.meanXY-xtras.stdXY 2.*xtras.stdXY];
rectangle('Position', [pos(2) pos(1) pos(4) pos(3)] ,'Curvature',[1 1], 'EdgeColor', 'm',...
    'LineWidth',4,'LineStyle', ':')
plot(xtras.preline(:,2), xtras.preline(:,1), '-r', ...
    xtras.preline(2,2),xtras.preline(2,1),'xr',...
    'MarkerSize', 20, 'LineWidth', 6);
plot(xtras.postline(:,2), xtras.postline(:,1), '-g',...
    xtras.postline(1,2),xtras.postline(1,1),'^g',...
    'MarkerSize', 20, 'LineWidth', 6);
axis([481   630   389   513])
title(['Angle =' 32 num2str(stt.thx)],'FontSize', 30);
legend({'Mean position (clump)', 'Direction pre-clump', 'Clump entry', ...
    'Direction post-clump', 'Clump exit'}, 'FontSize', 24)

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