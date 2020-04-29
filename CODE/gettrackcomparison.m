function [trackfeatures, positionstruct] = gettrackcomparison(pretab, posttab, isclump)
% GET TRACK COMPARISONS. Calculate angle changes from the two sections of
% the track table: PRETAB and POSTTAB. 
% 
% USAGE:
%    [trackfeatures, posandrots] = gettrackcomparison(pretab, posttab, isclump)
%
% Each INPUT table must contain at least the following columns: 
%            - X,Y : positions
%            - velocity 
%
% OUTPUT: 
%    trackfeatures := contains information about the tracks before and
%    after the comparison point. Most importantly it contains the angle
%    change from the comparison point.
% 
%      posandrots := contains positions to plot and present the results as
%      well as the rotation angles necessary.
% 
preline = [pretab([1 end],:).X pretab([1 end],:).Y];
postline = [posttab([1 end],:).X posttab([1 end],:).Y];

x1=preline(1,:);
x2=preline(2,:);
y1=postline(1,:);
y2=postline(2,:);

% aligning tracks through angle rotth
x2prime = x2-x1;
rotth = rad2deg(angle(x2prime(2)+x2prime(1).*1i));

c=cosd(rotth); s=sind(rotth);
R = [c -s;
    s  c];

y2prime = R'*[y2(2)-y1(2);y2(1)-y1(1)];
y2prime = y2prime(2:-1:1)';

anglechange = rad2deg(angle(y2prime(2)+y2prime(1).*1i));

trackfeatures.thx = anglechange;
trackfeatures.bL = norm(x2-x1);
trackfeatures.afL = norm(y2-y1);
trackfeatures.bmeanVel = mean(pretab.velocity(1:end-1));
trackfeatures.bstdVel = std(pretab.velocity(1:end-1));
trackfeatures.afmeanVel = mean(posttab.velocity);
trackfeatures.afstdVel = std(posttab.velocity);
trackfeatures.isclump = isclump;

positionstruct.preline = preline;
positionstruct.postline = postline;
positionstruct.preXY = [pretab.X pretab.Y];
positionstruct.postXY = [posttab.X posttab.Y];
positionstruct.R = R;
positionstruct.c = c;
positionstruct.s = s;
positionstruct.th1 = rotth;
end
