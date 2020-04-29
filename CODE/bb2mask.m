function [BW] = bb2mask(bb, m, n)
% BOUNDING BOX TO BINARY MASK 
% Works like POLY2MASK, but for bounding boxes. 
% [m,n] = size of image
%
% USAGE: 
%      [BW] = bb2mask(bb, m, n)
% BW is a mXn image with ones in the place of the boundary box bb.
% 

polybox = [bb(1) bb(2); bb(1)+bb(3) bb(2); bb(1)+bb(3) bb(2)+bb(4);
bb(1) bb(2)+bb(4);bb(1) bb(2)];

BW = poly2mask(polybox(:,1), polybox(:,2), m, n);