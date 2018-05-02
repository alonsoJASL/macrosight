function [prePoints, postPoints, anglepos] = getpointsforplot(anglextras, isclump)
%


if isclump == true
    preXY = anglextras.preXY;
    postXY = anglextras.postXY;
    
    x1=preXY(1,:);
    x2=preXY(end,:);
    y1=postXY(1,:);
    y2=postXY(end,:);
    
    x2prime = x2-x1;
    th1 = rad2deg(angle(x2prime(2)+x2prime(1).*1i));
    
    c=cosd(th1); s=sind(th1);
    
    qq = preXY - repmat(x1, size(preXY,1),1);
    prePoints = [-s.*qq(:,2)+c.*qq(:,1) c.*qq(:,2)+s.*qq(:,1)];
    prePoints = prePoints - repmat(prePoints(end,:), size(prePoints,1),1);
    
    rr = postXY - repmat(y1, size(postXY,1),1);
    postPoints = [-s.*rr(:,2)+c.*rr(:,1) c.*rr(:,2)+s.*rr(:,1)];
    if nargout >2
        anglepos = th1;
    end
    
else
    brkix = length(anglextras.preXY);
    
    XY = [anglextras.preXY;anglextras.postXY];
    x1=XY(1,:);
    x2=XY(end,:);
    
    x2prime = x2-x1;
    th1 = rad2deg(angle(x2prime(2)+x2prime(1).*1i));
    
    c=cosd(th1); s=sind(th1);
    qq = XY - repmat(x1, size(XY,1),1);
    Points = [-s.*qq(:,2)+c.*qq(:,1) c.*qq(:,2)+s.*qq(:,1)];
    
    prePoints = Points(1:brkix,:);
    prePoints = prePoints - repmat(prePoints(end,:), size(prePoints,1),1);
    postPoints = Points((brkix+1):end,:);
    postPoints = postPoints - repmat(postPoints(1,:), size(postPoints,1),1);
    
    if nargout >2
        anglepos = th1;
    end
end



