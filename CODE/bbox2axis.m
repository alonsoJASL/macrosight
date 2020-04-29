function [aX] = bbox2axis(bbox, offpxls)
% BOUNDING BOX TO AXIS FORMAT. This function allows to convert bounding box
% matrices into axis, for easier plotting
%

if nargin < 2
    offpxls = 3;
end

aX = [bbox(:,1) bbox(:,1)+bbox(:,3) bbox(:,2) bbox(:,2)+bbox(:,4)];
aX = aX + repmat([-offpxls offpxls -offpxls offpxls], size(aX,1),1);