function plotVarandDiff(x,y,varname, diffstats)

if nargin < 4
    diffstats = true;
elseif nargin < 3
    varname = 'Y';
    diffstats = true;    
end

gcf;

plot(x, y, '-', x(2:end), diff(y));
if diffstats == true
    plotHorzLine(x, (mean(diff(y)) + [0 std(diff(y)) -std(diff(y))]));
%     legend(varname, strcat('diff(', varname,')'),...
%         strcat('mean(', varname,')'));
else
%    legend(varname, strcat('diff(', varname,')'));
end