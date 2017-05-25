function plotcellprops(cellprops)
% 

fnames = fieldnames(cellprops);
numProps = length(fnames);

switch num2str(numProps)
    case {'1','2','3'}
        a = numProps;
        b = 1;
    case {'4','5','6'}
        a = 3;
        b = 2;
    case {'7','8','9'}
        a = 3;
        b = 3;
end

for ix=1:numProps
    thisprop = [cellprops.(fnames{ix})];
    meanprop = mean(thisprop);
    stdprop = std(thisprop);
    
    subplot(b,a,ix)
    plot([cellprops.(fnames{ix})]);
    plotHorzLine(thisprop, [meanprop-stdprop meanprop meanprop+stdprop]);
    grid on;
    axis tight;
    title(fnames{ix});
    
    
end
end

function plotHorzLine(vector, values)
% Plot a(many) horizontal line(s) on a plot.
% 
gcf;
hold on;

if length(vector)==1
    nPoints = vector;
else
    nPoints = length(vector);
end

for ix=1:length(values)
    plot([1 nPoints], [values(ix) values(ix)]);
end
end
