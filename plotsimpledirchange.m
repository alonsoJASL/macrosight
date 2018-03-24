function plotsimpledirchange(prePoint, postPoint, clumpbool)

if clumpbool==true
    lc = 'r';
else
    lc = 'k';
end
   
hold on; 
plot(prePoint(:,2), prePoint(:,1), ...
    '-d', 'Color', [0.5 0.5 0.5], 'LineWidt', 2, 'MarkerSize', 4);

plot(postPoint([1 end],2), postPoint([1 end],1), 'Color', 0.75.*ones(1,3))%,...
plot(postPoint(:,2), postPoint(:,1), ['-*' lc], 'LineWidth', 2, 'MarkerSize', 4)