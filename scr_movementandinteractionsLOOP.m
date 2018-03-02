tidy;
whichmacro = 2;
initscript;
T = readtable('./macros123.xlsx');
T(~contains(T.whichdataset, ds(1:end-1)),:) = [];
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

clus = unique(T.whichclump);
rowix = 1;
for ix=1:length(clus)
    howmany = size(T(T.whichclump==clus(ix),:),1);
    spaux = reshape(1:howmany*3, 3, howmany)';
    
    for jx=1:howmany
        mT = T(rowix,:);
        midclumppos = fix(mean(mT.clumpinit, mT.clumpfin));
        wuc= mT.whichclump;
        clumplab = mT.whichlabel;
        
        trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
            clumptracktable(ismember(tablenet.track, clumplab),:)];
        
        ffix=mT.initialframe;
        lfix=mT.finalframe;
        
        [~, stt(rowix), xtras(rowix)] = getclumpanglechange(trackinfo, wuc, [ffix lfix]);
        
        fprintf('Done, thetaX = %f \n ', stt.thx);
        
        figure(ix)
        subplot(howmany, 3, spaux(jx, 1))
        thisfr = getdatafromhandles(handles, filenames{midclumppos});
        plotBoundariesAndPoints(thisfr.X, bwboundaries(thisfr.clumphandles.overlappingClumps>0), xtras(rowix).meanXY,'md');
        plot(xtras(rowix).preline(:,2), xtras(rowix).preline(:,1), '-xr');
        plot(xtras(rowix).postline(:,2), xtras(rowix).postline(:,1), '-vg');
        
        subplot(howmany, 3, spaux(jx,2):spaux(jx,3))
        plotdirectionchange(stt(jx), xtras(jx));
        
        rowix = rowix+1;
        %clearvars -except whichmacro allrowsix rowix xtras T stt ix jx howmany spaux clus
        %initscript;
    end
    tightfig;
    fullposition;
    tightfig;
end