function plotframeandpoint(thisfr, trackinfo, indx, options)
% PLOT FRAME AND POINT.
%

if nargin < 4
    labeltext = false;
else
    [labeltext] = getoptions(options);
end

if ~isempty(thisfr)
    plotBoundariesAndPoints(thisfr.X, [],  ...
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
if labeltext == false
    for qx=1:size(XY,1)
        [~, ix] = min(abs(velocity(qx)-auxv));
        plot(XY(qx,1), XY(qx,2), whichmarker, 'Color', cmap(ix(1),:), ...
            'LineWidth', 1.5, 'markersize', 10);
    end
else
    for qx=1:size(XY,1)
        [~, ix] = min(abs(velocity(qx)-auxv));
        plot(XY(qx,1), XY(qx,2), whichmarker, 'Color', cmap(ix(1),:), ...
            'LineWidth', 1.5, 'markersize', 10);
        text(XY(qx,1),XY(qx,2),...
            ['\leftarrow' num2str(trackinfo.finalLabel(indx))],...
            'Color',cmap(ix(1),:),'FontSize',15);
    end
end
end



function [labeltext] = getoptions(s)
labeltext = false;
if islogical(s)
    labeltext = s;
else
    fname = fieldnames(s);
    for ix=1:length(fname)
        switch fname{ix}
            case 'labeltext'
                labeltext = s.(fname{ix});
            otherwise
                fprintf('%s: Error, option %s not recognised.\n', ...
                    mfilename, upper(fname{ix}));
        end
    end
end
end