function plotframeandpoint(thisfr, trackinfo, indx)
% PLOT FRAME AND POINT.
%

if ~isempty(thisfr)
    plotBoundariesAndPoints(thisfr.dataL, [],  ...
        bwboundaries(thisfr.clumphandles.overlappingClumps>0), '-m');
    plotBoundariesAndPoints([], [], ...
        bwboundaries(thisfr.clumphandles.nonOverlappingClumps>0), '-w');
end

hold on;

XY = trackinfo(indx, [3 2]).Variables;
velocity = trackinfo(indx,:).velocity;

cmap = parula;
auxv = linspace(-2.7701, 6.5582, 64);

if trackinfo.clumpID(indx) > 0
    whichmarker = 'd';
else
    whichmarker = '.';
end

for qx=1:size(XY,1)
    [~, ix] = min(abs(velocity(qx)-auxv));
    plot(XY(qx,1), XY(qx,2), whichmarker, 'Color', cmap(ix(1),:), ...
        'LineWidth', 1.5, 'markersize', 10);
end
end



function [options] = getoptions(s)
options = '';
end