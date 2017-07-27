function [BW] = bb2mask(bb, m, n)
% bounding box to binary mask 
% Works like POLY2MASK, but for bounding boxes. 
%

polybox = [bb(1) bb(2); bb(1)+bb(3) bb(2); bb(1)+bb(3) bb(2)+bb(4);
bb(1) bb(2)+bb(4);bb(1) bb(2)];

BW = poly2mask(polybox(:,1), polybox(:,2), m, n);