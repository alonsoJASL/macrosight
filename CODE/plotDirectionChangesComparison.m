function plotDirectionChangesComparison(points2plot, preaxis, linecolour)
%

if nargin < 2
    preaxis = [-30 40 -20 35];
    linecolour = 'r';
elseif nargin < 3
    linecolour = 'r';
end

for jx=1:length(points2plot)
    plotsimpledirchange(points2plot(jx).plotprepoints, points2plot(jx).plotpostpoints, linecolour);
    %yticklabels([]);
    axis(preaxis)
end
grid on;