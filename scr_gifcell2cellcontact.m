tidy;

whichmacro = 3; % 1, 2 or 3
initscript_dev;
%
load('angleChanges');
T = readtable('./macros123.xlsx');
TS = readtable('./macros123singles.xlsx');

T(~contains(upper(T.whichdataset), ['MACROS' num2str(whichmacro)]),:) = [];
TS(~contains(upper(TS.whichdataset), ['MACROS' num2str(whichmacro)]),:) = [];

vn = {'macros1', 'macros2', 'macros3'};
markers = {'+','*','o'};
cc = {[0 0.53 0.79], [0.89 0.41 0.12], [.95 .74 .16]};
boxlabels = {'Clump size', 'Angle change'};
dsetID = [angleChangesWithInteraction.datasetID]';

% Global variables to create generalised analysis.
for ix=1:length(experimentInfo.whichmacro)
    a.(vn{ix}) = angleChangesWithInteraction(dsetID==ix);
    noa.(vn{ix}) = angleNoInteraction(dsetID==ix);
    istats.(vn{ix}) = interactionStats(dsetID==ix);
end

Tab = [vertcat(interactionStats.clumpsize) ...
    vertcat(interactionStats.thx) ...
    vertcat(angleNoInteraction.angleChange)];
groups = ones(size(Tab));
groups(:,3) = 1.1;
groups = groups.*repmat(dsetID,1,3);

clumpsizes = vertcat(interactionStats.clumpsize);


%% FIGURON

close all;

whichA = a.(vn{whichmacro});
whichNoa = noa.(vn{whichmacro});

idx=[1 2; 3 4; 5 6; 17 18];
frnum = [161 228 374 210];
clumpsies = [2001 3002 3002 22001];

ix=4;
midclumpframe = frnum(ix);
fr = getdatafromhandles(handles, filenames{midclumpframe});
positionfigure = [323   377   590   555];

switch ix 
    case 1
        preaxis = [60   245   114   235]; % if ix = 1
    case 2
        preaxis = [158   426   141   315]; % if ix = 2
    case 4
        preaxis = [20 291 23 275]; % if ix=4
end

testclump=0;


mT1 = T(idx(ix,1),:);
mT2 = T(idx(ix,2),:);
wuc = clumpsies(ix);
clumplab1 = mT1.whichlabel;
clumplab2 = mT2.whichlabel;

cell1fr = mT1.initialframe:mT1.finalframe;
cell2fr = mT2.initialframe:mT2.finalframe;

trackinfo1 = [tablenet(ismember(tablenet.track, clumplab1),[5 1 2 9 11 13 14]) ...
    clumptracktable(ismember(tablenet.track, clumplab1),:)];
trackinfo2 = [tablenet(ismember(tablenet.track, clumplab2),[5 1 2 9 11 13 14]) ...
    clumptracktable(ismember(tablenet.track, clumplab2),:)];

seglabel1 = trackinfo1.seglabel(ismember(trackinfo1.timeframe,cell1fr));
clumplabel1 = trackinfo1.clumpID(ismember(trackinfo1.timeframe,cell1fr));
seglabel2 = trackinfo2.seglabel(ismember(trackinfo2.timeframe,cell2fr));
clumplabel2 = trackinfo2.clumpID(ismember(trackinfo2.timeframe,cell2fr));

preP1 = whichA(idx(ix,1)).previousTrackPoints;
postP1 = whichA(idx(ix,1)).postTrackPoints;
preP2 = whichA(idx(ix,2)).previousTrackPoints;
postP2 = whichA(idx(ix,2)).postTrackPoints;

XYcl1 = [preP1(end,:); postP1(1,:)];
XYcl2 = [preP2(end,:); postP2(1,:)];

numImages = length(cell1fr);

figure(1000)
for kx=1:numImages
    fr = getdatafromhandles(handles, filenames{cell1fr(kx)});
    
    if sum(kx==find(clumplabel1>0))>0
        boundy = bwboundaries(fr.dataGL==clumplabel1(kx));
        testclump = 1;
    else
        boundy1 =  bwboundaries(fr.dataGL==seglabel1(kx));
        boundy2 =  bwboundaries(fr.dataGL==seglabel2(kx));
        testclump = 0;
    end
    
    if testclump == 1
        disp('testclump=1')
        plotBoundariesAndPoints(rgb2gray(fr.X), [], boundy, 'y-');
        rmticklabels;
    else
        plotBoundariesAndPoints(rgb2gray(fr.X), [], boundy1, 'c-');
        plotBoundariesAndPoints([], [], boundy2, 'm-');
        rmticklabels;
        colormap gray
    end
    
    axis square;
    plotsimpledirchange(preP1, postP1, true);
    plotsimpledirchange(preP2, postP2, true);
    plot(XYcl1(:,2), XYcl1(:,1), 'y', XYcl2(:,2), XYcl2(:,1), 'y', ...
        'LineWidth', 2);
    axis(preaxis);
    
    title(sprintf('%d / %d', kx,numImages))
    
    set(gcf,'position',positionfigure)
    pause(0.5);
    
    if kx==1
        H = gcf;
        f = getframe(H);
        [im,map] = rgb2ind(f.cdata,256,'nodither');
        
        im(1,1,1,numImages) = 0;
        clf;
    else
        f = getframe(gcf);
        im(:,:,1,kx) = rgb2ind(f.cdata,map,'nodither');
        clf;
    end
    
    
    
end

imwrite(im,map,['clump' num2str(clumpsies(ix)) '.gif'],...
    'DelayTime',0.5, 'LoopCount',inf);


%% FIGURON

close all;

whichA = a.(vn{whichmacro});
whichNoa = noa.(vn{whichmacro});

idx=[1 2; 3 4; 5 6; 17 18];
frnum = [161 228 374 210];
clumpsies = [2001 3002 3002 22001];

ix=1;
midclumpframe = frnum(ix);
fr = getdatafromhandles(handles, filenames{midclumpframe});
positionfigure = [114   340   780   588];

preaxis = [60   245   114   235]; % if ix = 1
%preaxis = [158   426   141   315]; % if ix = 2
%preaxis = [20 291 23 275]; % if ix=4

for jx=1:2
    mT = T(idx(ix,jx),:);
    wuc = clumpsies(ix);
    clumplab = mT.whichlabel;
    
    
    preP = whichA(idx(ix,jx)).previousTrackPoints;
    postP = whichA(idx(ix,jx)).postTrackPoints;
    
    
    trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
        clumptracktable(ismember(tablenet.track, clumplab),:)];
    
    pre = round(linspace(mT.initialframe, mT.clumpinit, min(5, mT.clumpinit-mT.initialframe)));
    during = round(linspace(mT.clumpinit+1, mT.clumpfin, min(5, mT.clumpfin-mT.clumpinit)));
    post = (mT.clumpfin+1):mT.finalframe;
    
    preseglabel = trackinfo.seglabel(ismember(trackinfo.timeframe,pre));
    preclumplabel = trackinfo.clumpID(ismember(trackinfo.timeframe,pre));
    durseglabel = trackinfo.seglabel(ismember(trackinfo.timeframe,during));
    durclumplabel = trackinfo.clumpID(ismember(trackinfo.timeframe,during));
    postseglabel = trackinfo.seglabel(ismember(trackinfo.timeframe,post));
    postclumplabel = trackinfo.clumpID(ismember(trackinfo.timeframe,post));
    
    figure(1)
    for kx=1:length(pre)
        subplot(1,length(pre), kx)
        fr = getdatafromhandles(handles, filenames{pre(kx)});
        if kx==find(preclumplabel>0)
            regs = regionprops(fr.dataGL==preclumplabel(kx), 'BoundingBox');
            boundy = bwboundaries(fr.dataGL==preclumplabel(kx));
        else
            regs = regionprops(fr.dataGL==preseglabel(kx), 'BoundingBox');
            boundy =  bwboundaries(fr.dataGL==preseglabel(kx));
        end
        
        if jx==1
            plotBoundariesAndPoints(rgb2gray(fr.X), [], boundy, 'c-');
            rmticklabels;
            colormap gray
        else
            plotBoundariesAndPoints([], [], boundy, 'm-');
        end
        axis square;
        
        plotsimpledirchange(preP, postP, true);
        ffix=mT.initialframe;
        lfix=mT.finalframe;
        axis(preaxis);
    end
    set(gcf,'position',positionfigure)
    
    figure(2)
    for kx=1:length(during)
        subplot(1,length(during), kx)
        fr = getdatafromhandles(handles, filenames{during(kx)});
        if kx==find(durclumplabel>0)
            regs = regionprops(fr.dataGL==durclumplabel(kx), 'BoundingBox');
            boundy = bwboundaries(fr.dataGL==durclumplabel(kx));
        else
            regs = regionprops(fr.dataGL==durseglabel(kx), 'BoundingBox');
            boundy =  bwboundaries(fr.dataGL==durseglabel(kx));
        end
        
        if jx==1
            plotBoundariesAndPoints(rgb2gray(fr.X), [], boundy, 'c-');
            rmticklabels;
            colormap gray
        else
            plotBoundariesAndPoints([], [], boundy, 'y-');
        end
        axis square;
        
        plotsimpledirchange(preP, postP, true);
        ffix=mT.initialframe;
        lfix=mT.finalframe;
        axis(preaxis);
    end
    set(gcf,'position',positionfigure)
    
    figure(3)
    for kx=1:length(post)
        subplot(1,length(post), kx)
        fr = getdatafromhandles(handles, filenames{post(kx)});
        if kx==find(postclumplabel>0)
            regs = regionprops(fr.dataGL==postclumplabel(kx), 'BoundingBox');
            boundy = bwboundaries(fr.dataGL==postclumplabel(kx));
        else
            regs = regionprops(fr.dataGL==postseglabel(kx), 'BoundingBox');
            boundy =  bwboundaries(fr.dataGL==postseglabel(kx));
        end
        
        if jx==1
            plotBoundariesAndPoints(rgb2gray(fr.X), [], boundy, 'c-');
            rmticklabels;
            colormap gray
        else
            plotBoundariesAndPoints([], [], boundy, 'm-');
        end
        axis square;
        
        plotsimpledirchange(preP, postP, true);
        ffix=mT.initialframe;
        lfix=mT.finalframe;
        axis(preaxis);
    end
    set(gcf,'position',positionfigure)
end