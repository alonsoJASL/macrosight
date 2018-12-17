function plotsimpledirchange(prePoint, postPoint, clumpbool)

if clumpbool==true
    lc = 'r'; % normal
    %lc = 'g';
else
    lc = 'k';
end
   
hold on; 
if strcmp(lc, 'r') || strcmp(lc, 'k')
plot(prePoint(:,2), prePoint(:,1), ...
    '-d', 'Color', [0.5 0.5 0.5], 'LineWidt', 3, 'MarkerSize', 4);
else
    plot(prePoint(:,2), prePoint(:,1), ...
        '-d', 'Color', 'r', 'LineWidt', 3, 'MarkerSize', 4);
end

plot(postPoint([1 end],2), postPoint([1 end],1), 'Color', 0.75.*ones(1,3),...
    'LineWidth', 1.05)%,...
plot(postPoint(:,2), postPoint(:,1), ['-o' lc], 'LineWidth', 3, 'MarkerSize', 4)