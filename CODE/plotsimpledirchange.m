function plotsimpledirchange(prePoint, postPoint, clumpbool)
% PLOT SIMPLE DIRECTION CHANGE. Takes two vectors prePoint and postPoint
% and plots them.

if ischar(clumpbool)
    lc = clumpbool;
elseif clumpbool==true
    lc = 'r'; % normal
    %lc = 'g';
else
    lc = 'k';
end

hold on;
plot(prePoint(:,2), prePoint(:,1), '-d', 'Color', [0.5 0.5 0.5], ...
    'LineWidth', 2, 'MarkerSize', 3);

plot(postPoint([1 end],2), postPoint([1 end],1), 'Color', [0.75 0.75 0.75],'LineWidth', 1.05);
plot(postPoint(:,2), postPoint(:,1), ['-o' lc], 'LineWidth', 2, 'MarkerSize', 3)