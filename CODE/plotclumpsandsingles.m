function plotclumpsandsingles(thisfr)
% PLOT FRAME AND POINT.
%

hold on;
if ~isempty(thisfr)
    plotBoundariesAndPoints([], [],  ...
        bwboundaries(thisfr.clumphandles.overlappingClumps>0), '-m');
    plotBoundariesAndPoints([], [], ...
        bwboundaries(thisfr.clumphandles.nonOverlappingClumps>0), '-w');
end
