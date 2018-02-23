tidy;
whichmacro = 2;
initscript;
T = readtable('./macros123.xlsx');
T(~contains(T.whichdataset, ds(1:end-1)),:) = [];

allrowsix = size(T,1);
for rowix=1:allrowsix
    
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
    R = [cosd(th1) -sind(th1); sind(th1) cosd(th1)];
    
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
    
    clearvars -except whichmacro allrowsix rowix T stt
    initscript;
end
