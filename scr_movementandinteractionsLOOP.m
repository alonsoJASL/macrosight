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
    
    [~, stt(rowix), xtras(rowix)] = getclumpanglechange(trackinfo, wuc, [ffix lfix]);
    
    fprintf('Done, thetaX = %f \n ', stt.thx);
    
    clearvars -except whichmacro allrowsix rowix xtras T stt
    initscript;
end


%%
%figure
allrowsix = size(T,1);
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
    [~, stt(rowix), xtras] = getclumpanglechange(trackinfo, wuc, [ffix lfix]);
    [prePoints, postPoints] = getpointsforplot(xtras, true);
    figure(1)
    plotsimpledirchange(prePoints, postPoints, true)
    
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
    plotsimpledirchange(prePoints, postPoints, false);
%     
    
%     postxtras.preXY = [posttrinf.X(1:brkidx2) posttrinf.Y(1:brkidx2)];
%     postxtras.postXY = [posttrinf.X(brkidx2:end) posttrinf.Y(brkidx2:end)];
%     [prePoints, postPoints] = getpointsforplot(postxtras, false);
%     plotsimpledirchange(prePoints, postPoints, false);
    
    %pause;
end







