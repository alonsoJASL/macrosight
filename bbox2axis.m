function [aX] = bbox2axis(bbox, offpxls)
% BOUNDING BOX TO AXIS FORMAT.
%

if nargin < 2
    offpxls = 3;
end

aX = [bbox(1) bbox(1)+bbox(3) bbox(2) bbox(2)+bbox(4)];
aX = aX + [-offpxls offpxls -offpxls offpxls];