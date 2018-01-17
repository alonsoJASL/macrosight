function plotframeandpoint(thisfr, trackinfo, indx)
% PLOT FRAME AND POINT.
% 

plotBoundariesAndPoints(thisfr.X, [],  ...
    bwboundaries(thisfr.clumphandles.overlappingClumps>0), '-m');
plotBoundariesAndPoints([], [], ...
    bwboundaries(thisfr.clumphandles.nonOverlappingClumps>0), '-w');

XY = trackinfo(indx, [3 2]).Variables;
velocity = trackinfo(indx,:).velocity;

cmap = parula;
auxv = linspace(-2.7701, 6.5582, 64);
[~, ix] = min(abs(velocity-auxv));

plot(XY(:,1), XY(:,2), '+', 'Color', cmap(ix(1),:));
