function [contacttrackf, contactpos, benchmrktrackf, benchmrkpos] = getanglechanges(...
    TrInfo, wuc, clumprange, controlrange)
% GET ANGLE CHANGES.
%
% INPUT
%
% OUTPUT
%
% contacttrackf  : clump track position and angle change
% contactpos     : clump track features
% benchmrktrackf : control track positions
% benchmrkpos    : control track features
%

ticlump = TrInfo(ismember(TrInfo.timeframe, clumprange(1):clumprange(2)),:);

[allpaths, wendys] = getpathsperlabel(wuc, ticlump);
wendys(:,2) = wendys(:,2)-1;

% Get rid of all cases where cell exists and re-enters clump
allpaths(wendys(:,1)==wendys(:,2),:)=[];
wendys(wendys(:,1)==wendys(:,2),:)=[];

% CREATE CLUMP PATHS
for ix=1:(size(wendys,1)-1)
    clumpwendys(ix,:) = [wendys(ix,2)+1 wendys(ix+1,1)-1 ix ix+1];
    allclumppaths{ix} = TrInfo(clumpwendys(ix,1):clumpwendys(ix,2),:);
end

% Calculation of angles
wcix = 1; % which clump interaction index.
citab = allclumppaths{wcix};
meanXY = [mean(citab.X,1)' mean(citab.Y,1)']; % [X Y]
stdXY = [std(citab.X,1)' std(citab.Y,1)']; % [X Y]

ctrltrinf = TrInfo(ismember(TrInfo.timeframe, controlrange(1):controlrange(2)),:);
bidx1 = round(size(ctrltrinf,1)/2);
refXY = [ctrltrinf.X(bidx1) ctrltrinf.Y(bidx1)];

% Get the before and after reference comparison
pretab = allpaths{clumpwendys(wcix,3)};
posttab = allpaths{clumpwendys(wcix,4)};

pretab2 = ctrltrinf(1:bidx1,:);
posttab2 = ctrltrinf(bidx1:end,:);

[contacttrackf, contactpos] = gettrackcomparison(pretab, posttab, true);

contacttrackf.bdist2clump = norm([pretab.X(end) pretab.Y(end)]-meanXY(2:-1:1));
contacttrackf.afdist2clump = norm([posttab.X(1) posttab.Y(1)]-meanXY(2:-1:1));
contacttrackf.clumpsize = size(allclumppaths{wcix}, 1);

contactpos.ticlumps = ticlump;
contactpos.meanXY = meanXY;
contactpos.stdXY = stdXY;

[benchmrktrackf, benchmrkpos] = gettrackcomparison(pretab2, posttab2, false);

benchmrktrackf.bdist2ref = norm([pretab2.X(end) pretab2.Y(end)]-refXY(2:-1:1));
benchmrktrackf.afdist2ref = norm([posttab2.X(1) posttab2.Y(1)]-refXY(2:-1:1));

benchmrkpos.ticlumps = ctrltrinf;
benchmrkpos.meanXY = refXY;
benchmrkpos.stdXY = 0;

end