function plotBoundariesAndPoints(Image, boundaries, points, zoomIn)
% PLOT BOUNDARIES AND POINTS. Plots a set of boundaries and a set of points
% on top of a displayed image. 
% 
% USAGE: 
%       plotBoundariesAndPoints(Image, boundaries);
%       plotBoundariesAndPoints(Image, boundaries, points);
%       plotBoundariesAndPoints(Image, boundaries, points, true)
%       plotBoundariesAndPoints(Image, boundaries, points, '*-')
%       plotBoundariesAndPoints(Image, boundaries, [], true)
% 
%   where the fourth input parameter can be:
%                  - Boolean to zoom in to the bounding box of the
%                    boundaries
%                  - String corresponding to the markers and line type of
%                    the points.
%
% a common usage of this given an Image and a binary image with its 
% segmentation (binImage) would be:
% 
%      plotBoundariesAndPoints(Image, bwboundaries(binImage))
% 

mkr = 15;
liw = 3;

if nargin < 3
    points=[];
    zoomIn = false;
elseif nargin < 4
    zoomIn = false;
end

if ~isempty(Image)
    imagesc(Image);
    if size(Image,3)==1
        colormap bone;
    end
end

hold on;
if ~isempty(boundaries)
    if iscell(boundaries)
        for ix=1:length(boundaries)
            plot(boundaries{ix}(:,2), boundaries{ix}(:,1), 'c--',...
                'LineWidth',2);
            plot(boundaries{ix}(1,2), boundaries{ix}(1,1), 'c+');
        end
    else
        plot(boundaries(:,2), boundaries(:,1), 'c--',...
            boundaries(1,2), boundaries(1,1), 'cd','LineWidth',2);
    end
end

testPoints = (length(zoomIn)==3) + 10*(ischar(zoomIn));

if testPoints == 1
    % colour
    colour = zoomIn;
    if ~isempty(points)
        if iscell(points)
            for jx=1:length(points)
                plot(points{jx}(:,2), points{jx}(:,1), '-', 'Color',colour,...
                    'MarkerFaceColor',colour,...
                    'MarkerEdgeColor',[0 0 0],...
                    'markersize',mkr,...
                    'linewidth', liw);
            end
        else
            plot(points(:,2), points(:,1), 'd', 'Color',colour,...
                    'MarkerFaceColor',colour,...
                    'MarkerEdgeColor',[0 0 0],...
                    'markersize',mkr,...
                    'linewidth', liw);
        end
    end
elseif testPoints == 10
    % string
    pointsStr = zoomIn;
    if ~isempty(points)
        if iscell(points)
            for jx=1:length(points)
                plot(points{jx}(:,2), points{jx}(:,1), pointsStr,...
                    'MarkerFaceColor','none','markersize',mkr,...
                    'linewidth', liw);
            end
        else
            plot(points(:,2), points(:,1), pointsStr,...
                    'MarkerFaceColor','none','markersize',mkr,...
                    'linewidth', liw);
        end
    end
else
    % must be boolean
    if zoomIn == 1
        xmax = max(boundaries(:,2))+1;
        xmin = min(boundaries(:,2))-1;
        ymax = max(boundaries(:,1))+1;
        ymin = min(boundaries(:,1))-1;
        
        axis([xmin xmax ymin ymax]);
    end
    if ~isempty(points)
        if iscell(points)
            for jx=1:length(points)
                plot(points{jx}(:,2), points{jx}(:,1), 'yd',...
                    'MarkerFaceColor','none','markersize',mkr,...
                    'linewidth', liw);
            end
        else
            plot(points(:,2), points(:,1), 'yd',...
                    'MarkerFaceColor','none','markersize',mkr,...
                    'linewidth', liw);
        end
    end
end




