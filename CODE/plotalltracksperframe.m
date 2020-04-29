function plotalltracksperframe(thisfr, trackinfo, indx)

fr = find(trackinfo.timeframe==indx);

alllabels = trackinfo.finalLabel(fr);
XY = trackinfo(fr, [3 2]).Variables;
velocity = trackinfo.velocity(fr);
clumpid = trackinfo.clumpID(fr);

cmap = parula;
auxv = linspace(-2.7701, 6.5582, 64);

if ~isempty(thisfr)
    plotBoundariesAndPoints(thisfr.X, [],  ...
        bwboundaries(thisfr.clumphandles.overlappingClumps>0), '-m');
    plotBoundariesAndPoints([], [], ...
        bwboundaries(thisfr.clumphandles.nonOverlappingClumps>0), '-w');
end

hold on;

for qx=1:size(XY,1)
    if  clumpid(qx) > 0
        whichmarker = 'd';
    else
        whichmarker = '.';
    end
    [~, ix] = min(abs(velocity(qx)-auxv));
    plot(XY(qx,1), XY(qx,2), whichmarker, 'Color', cmap(ix(1),:), ...
        'LineWidth', 1.5, 'markersize', 10);
    text(XY(qx,1),XY(qx,2),...
        ['\leftarrow' num2str(alllabels(qx))],...
        'Color',cmap(ix(1),:),'FontSize',15);
end