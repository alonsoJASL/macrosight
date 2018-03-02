%% Initialisation
tidy;
whichmacro = 2;
initscript;
rowix = 11;

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

fprintf('Done, thetaX = %f \n ', stt.thx);

plotdirectionchange(stt, xtras);
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
jx=randi([pretab.timeframe(1) posttab.timeframe(end)]);
thisfr = getdatafromhandles(handles, filenames{jx});
clf;
plotBoundariesAndPoints(thisfr.X, bwboundaries(thisfr.clumphandles.overlappingClumps>0), meanXY,'md');
plot(preline(:,2), preline(:,1), '-xr');
plot(postline(:,2), postline(:,1), '-vg');
axis xy;
title(['Angle =' 32 num2str(stt(rowix).thx)]);

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