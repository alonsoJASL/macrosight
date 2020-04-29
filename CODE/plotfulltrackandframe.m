function plotfulltrackandframe(thisfr, trackinfo, indx)
% PLOT A FULL TRACK highlighting the mean speed between clumps. Requires
% the frame structure of the macrosight package.
%

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

[singlepaths, singlewendys] = getpathsperlabel(wuc, trackinfo);
for qx=1:(size(singlewendys,1)-1)
    wendys2(qx,:) = [singlewendys(qx,2)+1 singlewendys(qx+1,1)-1];
end
wendys2(:,1) = wendys2(:,1)-1;

for qx=1:size(XY,1)
    [~, ix] = min(abs(velocity(qx)-auxv));
    plot(XY(qx,1), XY(qx,2), whichmarker, 'Color', cmap(ix(1),:), ...
        'LineWidth', 1.5, 'markersize', 10);
end

if ~isempty(thisfr)
    plotBoundariesAndPoints(thisfr.dataL, [],  ...
        bwboundaries(thisfr.clumphandles.overlappingClumps>0), '-m');
    plotBoundariesAndPoints([], [], ...
        bwboundaries(thisfr.clumphandles.nonOverlappingClumps>0), '-w');
end
end

function [options] = getoptions(s)
options = '';
end