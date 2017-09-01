% script: single shape analysis (SINGLE UNKNOWN FRAME)
%
%% INITIALISATION
initscript;
load DATASETHOLES
%% CHOOSE TRACKS
% w.u.c = which unique clump!
wuc = 11010; % 8002, 8007, 11010, 14013, 8007005, 60010, 60010002, 15014013
fprintf('%s:Working on clump with ID=%d.\n', mfilename, wuc);

% get labels from the clump
clumplab = getlabelsfromcode(wuc);
trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 11 13 14]) ...
    clumptracktable(ismember(tablenet.track, clumplab),:)];

% remove holes from analysis
trackinfo(ismember(trackinfo.timeframe,DATASETHOLES),:) = [];

%% Extract frames where the clump exists
%trackinfo(~ismember(trackinfo.timeframe, 418:478),:)=[];
trackinfo(~ismember(trackinfo.timeframe, 1:70),:)=[];
trackinfo = tablecompression(trackinfo, clumplab);
%% FULL WORKFLOW (as in log)
% 1. Load known frame
tk=1;
framet = trackinfo.timeframe(tk);
[knownfr] = getCommonVariablesPerFrame(handles, trackinfo, wuc, ...
    filenames{framet}, framet);

% 2. Compute the tracks' variables in the known frame
[kftr] = getKnownTracksVariables(knownfr, trackinfo, clumplab, tk);

for ix=1:length(clumplab)
    % 2.1 Initialise a table with regionprops
    ttab{ix} = struct2table(kftr.regs(1));
    % 2.2 Unse anglegram measurements for LOLZ
    [ag] = computeMultiAnglegram(kftr.boundy(1));
    
    agopt.mainthresh = 150;
    agopt.offsetVar = 7;
    agopt.statsfname = 'max';
    [candies, candyh] = computeCandidatePoints(ag, kftr.boundy{ix}, agopt);
    
    hag(ix).meanAg = candyh.meanAM;
    hag(ix).stdAg = candyh.stdAM;
    hag(ix).frobNorm = norm(ag,'fro');
    %hag(ix).spectralRadius = max(abs(eig(ag'*ag)));
    hag(ix).maxsvd = max(svd(ag));
    hag(ix).rankAG = rank(ag);
    hag(ix).rankRatio = (rank(ag)/size(ag,2));
end


%% 3. start 'loop'
% 3.1 Load the unknown frame
debugvar = true;

for tk=1:(length(trackinfo.timeframe)-1)
    tkp1 = tk+1;
    frametplusT = trackinfo.timeframe(tkp1);
    [ukfr] = getCommonVariablesPerFrame(handles, trackinfo, wuc, ...
        filenames{frametplusT}, frametplusT);
    
    % 3.2 Evolve
    acopt.method = 'Chan-Vese';
    acopt.iter = 50;
    acopt.smoothf = 1.5;
    acopt.contractionbias = -0.1;
    acopt.erodenum = 5;
    [newfr] = nextframeevolution(ukfr, kftr, trackinfo, clumplab, acopt);
    
    % 3.4 Update
    % 3.4.1 Update knownfr
    [knownfr, kftr] = updateKnownFrame(ukfr, newfr, clumplab);
    if ukfr.hasclump == true && false % change to true for updating info to disk
        update2disk(handles, knownfr, newfr, wuc);
    end
    framet = frametplusT;
    
    anglegrams = cell(length(clumplab),1);
    for ix=1:length(clumplab)
        % 2.1 Initialise a table with regionprops
        ttab{ix} = [ttab{ix};struct2table(kftr.regs(ix))];
        % 2.2 Unse anglegram measurements for LOLZ
        [ag] = computeMultiAnglegram(kftr.boundy(ix));
        anglegrams{ix} = ag;
        
        agopt.mainthresh = 150;
        agopt.offsetVar = 7;
        agopt.statsfname = 'max';
        [candies, candyh] = computeCandidatePoints(ag, kftr.boundy{ix}, agopt);
        
        hag(ix).meanAg = [hag(ix).meanAg; candyh.meanAM];
        hag(ix).stdAg = [hag(ix).stdAg; candyh.stdAM];
        hag(ix).frobNorm = [hag(ix).frobNorm; norm(ag,'fro')];
        %hag(ix).spectralRadius = [hag(ix).spectralRadius; max(abs(eig(ag'*ag)))];
        hag(ix).maxsvd = [hag(ix).maxsvd; max(svd(ag))];
        hag(ix).rankAG = [hag(ix).rankAG; rank(ag)];
        hag(ix).rankRatio =[hag(ix).rankRatio; (rank(ag)/size(ag,2))];
    end
    
    % 3.3 Show preliminary results
    % LOOK AT LOGS
    if debugvar == true
        f11=figure(11);
        plotBoundariesAndPoints(ukfr.X, newfr.movedboundy, newfr.evoshape, 'm-');
        title(sprintf('Frame %d', frametplusT));
        if ukfr.hasclump == true
            plotBoundariesAndPoints([],[],bwboundaries(ukfr.thisclump), ':y');
        end
        
        f12=figure(12);
        for qx=1:length(clumplab)
            subplot(1,length(clumplab),qx)
            anglegrams{qx}(end,end) = 340;
            imagesc(anglegrams{qx});
            colorbar;
            set(f12, 'Position', ceil(get(0,'ScreenSize')./2));
            anglegrams{qx}(end,end) = 0;
        end
        
        if tk==1
            f1 = getframe(f11);
            [im, map] = rgb2ind(f1.cdata, 256, 'nodither');
            im(1,1,1,(length(trackinfo.timeframe)-1)) = 0;
            
            f2 = getframe(f12);
            [im2, map2] = rgb2ind(f2.cdata, 256, 'nodither');
            im2(1,1,1,(length(trackinfo.timeframe)-1)) = 0;
        else
            f1 = getframe(f11);
            f2 = getframe(f12);
            %[im2, map2] = rgb2ind(f2.cdata, 256, 'nodither');
        end
        im(:,:,1,tk) = rgb2ind(f1.cdata, map, 'nodither');
        im2(:,:,1,tk) = rgb2ind(f2.cdata, map2, 'nodither');
        pause(0.3);
    end
    
end
%tk = tk+1;
if debugvar == true
    gifname = sprintf('clump%d-frames%dto%d.gif', ...
        wuc, trackinfo.timeframe(1), trackinfo.timeframe(end));
    imwrite(im,map,gifname ,'DelayTime', 0.75, 'LoopCount',inf);
    imwrite(im2,map2,strcat('anglegrams-',gifname),...
        'DelayTime', 0.75, 'LoopCount',inf);
    clear gifname;
end
%% Shape measurements
whichlab = 2;
propt = ttab{whichlab};
agtab = hag(whichlab);

aspectRatio = propt.MinorAxisLength./propt.MajorAxisLength;
circularity = (4*pi).*(propt.Area./(propt.Perimeter.^2));

propertiesTable = [propt(:,1) table(aspectRatio, circularity) propt(:,5:end)];
agramTable = struct2table(agtab);
%
ffns = fieldnames(propertiesTable);
ffns2 = fieldnames(agramTable);

ffns2(end-2:end) = [];
ffns(end-2:end) = [];

figure(clumplab(whichlab))
for ix=1:length(ffns)
    subplot(4,3,ix)
    whichY = propertiesTable.(ffns{ix});
    plotVarandDiff(trackinfo.timeframe, whichY, ffns{ix});
    title(ffns{ix});
    grid on
    
    subplot(4,3,6+ix)
    whichY = agramTable.(ffns2{ix});
    plotVarandDiff(trackinfo.timeframe, whichY, ffns2{ix});
    title(ffns2{ix});
    grid on
end


