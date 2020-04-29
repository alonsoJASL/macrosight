function [prePoints, postPoints, anglepos] = getpointsforplot(positionstruct)
%

preXY = positionstruct.preXY;
postXY = positionstruct.postXY;

x1=preXY(1,:);
y1=postXY(1,:);

c = positionstruct.c;
s = positionstruct.s;

qq = preXY - repmat(x1, size(preXY,1),1);
prePoints = [-s.*qq(:,2)+c.*qq(:,1) c.*qq(:,2)+s.*qq(:,1)];
prePoints = prePoints - repmat(prePoints(end,:), size(prePoints,1),1);

rr = postXY - repmat(y1, size(postXY,1),1);
postPoints = [-s.*rr(:,2)+c.*rr(:,1) c.*rr(:,2)+s.*rr(:,1)];
if nargout >2
    anglepos = positionstruct.th1;
end
