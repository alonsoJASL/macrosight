% LOOP
tidy;
whichmacro = 3;
initscript;
T = readtable('./macros123.xlsx');
T(~contains(upper(T.whichdataset), ds(1:end-1)),:) = [];

TS = readtable('./macros123singles.xlsx');
TS(~contains(upper(TS.whichdataset), ds(1:end-1)),:) = [];
%%
allrowsix = size(T,1);
for rowix=1:allrowsix
    
    mT = T(rowix,:);
    
    wuc= mT.whichclump;
    clumplab = mT.whichlabel;
    
    trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
        clumptracktable(ismember(tablenet.track, clumplab),:)];
    
    ffix=mT.initialframe;
    lfix=mT.finalframe;
    
    [~, interactionStats(rowix), xtras(rowix)] = getclumpanglechange(trackinfo, wuc, [ffix lfix]);
    
    %fprintf('Done, thetaX = %f \n ', interactionStats.thx);
    
    clearvars -except whichmacro allrowsix rowix xtras T stt
    initscript;
end


%%
%figure
allrowsix = size(T,1);

try
    load('angleChanges.mat');
    indx2start = length(angleChangesWithInteraction);
catch e
    fprintf('%s: no angle strcture found, creating a new one.\n', mfilename);
    indx2start = 0;
end

rowix=2;
%for rowix=1:allrowsix

mT = T(rowix,:);
mTS = TS(rowix,:);

wuc= mT.whichclump;
clumplab = mT.whichlabel;

trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
    clumptracktable(ismember(tablenet.track, clumplab),:)];

ffix=mT.initialframe;
lfix=mT.finalframe;
%
[~, interactionStats(indx2start+rowix), xtras] = getclumpanglechange(trackinfo, wuc, [ffix lfix]);
[prePoints, postPoints] = getpointsforplot(xtras, true);

angleChangesWithInteraction(indx2start+rowix).datasetID = whichmacro;
angleChangesWithInteraction(indx2start+rowix).clumpID = wuc;
angleChangesWithInteraction(indx2start+rowix).angleChange = interactionStats(rowix).thx;
angleChangesWithInteraction(indx2start+rowix).previousLine = xtras.preline;
angleChangesWithInteraction(indx2start+rowix).postLine = xtras.postline;
angleChangesWithInteraction(indx2start+rowix).previousTrackPoints = xtras.preXY;
angleChangesWithInteraction(indx2start+rowix).postTrackPoints = xtras.postXY;

figure(1)
%clf
plotsimpledirchange(prePoints, postPoints, true);
rmticklabels;
set(gcf, 'Position', [40 489 1564 459]);
grid on;
axis([-30 25 -15 15]);

strackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
    clumptracktable(ismember(tablenet.track, clumplab),:)];
pretrinf = strackinfo(ismember(strackinfo.timeframe, ...
    (mTS.initialfr_pre):mTS.finalfr_pre),:);
posttrinf = strackinfo(ismember(strackinfo.timeframe, ...
    mTS.initialfr_post:(mTS.finalfr_post)),:);

brkidx1 = round(size(pretrinf,1)/2);
brkidx2 = round(size(posttrinf,1)/2);
%
prextras.preXY = [pretrinf.X(1:brkidx1) pretrinf.Y(1:brkidx1)];
prextras.postXY = [pretrinf.X(brkidx1:end) pretrinf.Y(brkidx1:end)];
[prePoints, postPoints, thnon(rowix)] = getpointsforplot(prextras, true);

angleNoInteraction(indx2start+rowix).datasetID = whichmacro;
angleNoInteraction(indx2start+rowix).beforeClump = wuc;
angleNoInteraction(indx2start+rowix).angleChange = thnon(rowix);
angleNoInteraction(indx2start+rowix).previousLine = xtras.preline;
angleNoInteraction(indx2start+rowix).postLine = xtras.postline;
angleNoInteraction(indx2start+rowix).previousTrackPoints = prextras.preXY;
angleNoInteraction(indx2start+rowix).postTrackPoints = prextras.postXY;

figure(2)
%clf
plotsimpledirchange(prePoints, postPoints, false);
rmticklabels;
set(gcf, 'Position', [57 42 1564 459]);
grid on;
axis([-30 25 -15 15]);
%

%     postxtras.preXY = [posttrinf.X(1:brkidx2) posttrinf.Y(1:brkidx2)];
%     postxtras.postXY = [posttrinf.X(brkidx2:end) posttrinf.Y(brkidx2:end)];
%     [prePoints, postPoints] = getpointsforplot(postxtras, false);
%     plotsimpledirchange(prePoints, postPoints, false);

%pause;
%end

save('angleChanges.mat', 'angleChangesWithInteraction',...
    'angleNoInteraction', 'interactionStats');
fprintf('%s: Structure Saved.\n', mfilename);


%%

%%
%figure
allrowsix = size(T,1);

try
    load('angleChanges.mat');
    indx2start = length(angleChangesWithInteraction);
catch e
    fprintf('%s: no angle strcture found, creating a new one.\n', mfilename);
    indx2start = 0;
end

%rowix=2;
for rowix=1:allrowsix
    
    mT = T(rowix,:);
    mTS = TS(rowix,:);
    
    wuc= mT.whichclump;
    clumplab = mT.whichlabel;
    
    trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
        clumptracktable(ismember(tablenet.track, clumplab),:)];
    
    ffix=mT.initialframe;
    lfix=mT.finalframe;
    %
    [~, interactionStats(indx2start+rowix), xtras] = getclumpanglechange(trackinfo, wuc, [ffix lfix]);
    [prePoints, postPoints] = getpointsforplot(xtras, true);
    
    figure(1)
    %clf
    plotsimpledirchange(prePoints, postPoints, true);
    rmticklabels;
    set(gcf, 'Position', [40 489 1564 459]);
    grid on;
    axis([-30 25 -15 15]);
    
    if rowix==1
        H = gcf;
        f = getframe(H);
        [im,map] = rgb2ind(f.cdata,256,'nodither');
        
        im(1,1,1,allrowsix) = 0;
    else
        f = getframe(gcf);
        im(:,:,1,rowix) = rgb2ind(f.cdata,map,'nodither');
    end
    
    
    strackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
        clumptracktable(ismember(tablenet.track, clumplab),:)];
    pretrinf = strackinfo(ismember(strackinfo.timeframe, ...
        (mTS.initialfr_pre):mTS.finalfr_pre),:);
    posttrinf = strackinfo(ismember(strackinfo.timeframe, ...
        mTS.initialfr_post:(mTS.finalfr_post)),:);
    
    brkidx1 = round(size(pretrinf,1)/2);
    brkidx2 = round(size(posttrinf,1)/2);
    %
    prextras.preXY = [pretrinf.X(1:brkidx1) pretrinf.Y(1:brkidx1)];
    prextras.postXY = [pretrinf.X(brkidx1:end) pretrinf.Y(brkidx1:end)];
    [prePoints, postPoints, thnon(rowix)] = getpointsforplot(prextras, true);
    
    figure(2)
    %clf
    plotsimpledirchange(prePoints, postPoints, false);
    rmticklabels;
    set(gcf, 'Position', [57 42 1564 459]);
    grid on;
    axis([-30 25 -15 15]);
    %
    %pause;
end


