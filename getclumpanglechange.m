function [anglechange, anglestats, xtras] = getclumpanglechange(...
    TrInfo, wuc, clumprange, prepostranges)
% GET ANGLE CHANGE AFTER CLUMP.
% USAGE:
%     [anglechange, anglestats, xtras] = getclumpanglechange(trackinfo, wuc, clumprange)
%
%                   - anglechange: \in (-180, 180).
%                   - anglestats: structure with some measurements.
%

if nargin < 4
    prepostranges = [];
end

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

anglechange = rad2deg(angle(y2prime(2)+y2prime(1).*1i));

if nargout > 1
    anglestats.thx = anglechange;
    anglestats.bL = norm(x2-x1);
    anglestats.afL = norm(y2-y1);
    anglestats.bmeanVel = mean(pretab.velocity(1:end-1));
    anglestats.bstdVel = std(pretab.velocity(1:end-1));
    anglestats.afmeanVel = mean(posttab.velocity);
    anglestats.afstdVel = std(posttab.velocity);
    anglestats.bdist2clump = norm(x2-meanXY(2:-1:1));
    anglestats.afdist2clump = norm(y1-meanXY(2:-1:1));
    anglestats.clumpsize = size(allclumppaths{wcix}, 1);
    if nargout > 2
        xtras.ticlumps = ticlump;
        xtras.meanXY = meanXY;
        xtras.preline = preline;
        xtras.postline = postline;
        xtras.preXY = [pretab.X pretab.Y];
        xtras.postXY = [posttab.X posttab.Y];
        xtras.R = R;
        xtras.c = c;
        xtras.s = s;
        xtras.th1 = th1;
        if ~isempty(prepostranges)
            preXY = [TrInfo(prepostranges(1,1):prepostranges(1,2),:).X ...
                TrInfo(prepostranges(1,1):prepostranges(1,2),:).Y];
            postXY = [TrInfo(prepostranges(2,1):prepostranges(2,2),:).X ...
                TrInfo(prepostranges(2,1):prepostranges(2,2),:).Y];
            
            xtras.preclumpXY = preXY;
            xtras.postclumpXY = postXY;
            
            preXY = preXY - repmat(preXY(1,:), size(preXY,1), 1);           
            thet = rad2deg(angle((preXY(end,2)) + (preXY(end,1)).*1i));
            c2=cosd(thet); s2=sind(thet);
            preXY = [-s.*preXY(:,2)+c.*preXY(:,1) c.*preXY(:,2)+s.*preXY(:,1)];
            preXY = preXY - repmat(preXY(fix(size(preXY,1)/2),:), size(preXY,1), 1);
            
            postXY = postXY - repmat(postXY(1,:), size(postXY,1), 1);
            thet = rad2deg(angle((postXY(end,2)) + (postXY(end,1)).*1i));
            c2=cosd(thet); s2=sind(thet);
            postXY = [-s.*postXY(:,2)+c.*postXY(:,1) c.*postXY(:,2)+s.*postXY(:,1)];
            postXY = postXY - repmat(postXY(fix(size(postXY,1)/2),:), size(postXY,1), 1);
            
            xtras.preclumpXYmod = preXY;
            xtras.postclumpXYmod = postclump;
        end
    end
end
end
