function macrophagesc(I, linedist, distperpix, options)
% MACROPHAGE-IMAGESC. Display images of macrophages removing the axes and
% applying a line of x pixels that correspond to y micrometers. All the
% information is displayed in the image. Default values are linedist=10e-6, 
% distperpix=0.21 um
%
% If an empty vector [] is input instead of an image I, then the function
% will try to position the bars in the corresponding
%
% USAGE:
%
%           macrophagesc(I);
%           macrophagesc(I, x, y);
%
%           macrophagesc;
%           macrophagesc([], x, y);
%           macrophagesc(_____, options);
%
%

if nargin < 4
    linwidth = 4;
    lincolour = 'c';
    linstyle = '-';
    mymap = jet;
    xtix = [];
    ytix = [];
    
    if nargin < 2
        linedist = 10e-6;
        distperpix = 0.21e-6;
    end
else
    if isempty(linedist)
        linedist = 10e-6;
    end
    if isempty(distperpix)
        distperpix = 0.21e-6;
    end
    [linwidth, lincolour, ...
        linstyle, mymap, ...
        xtix, ytix, axx] = getoptions(options);
end
x = linedist/distperpix;

if nargin < 1 || isempty(I)
    gcf;
    axx = axis;
else
    imagesc(I);
    if ~exist('axx')
        axx = axis;
    end
    if ~isempty(axx)
       axis(axx); 
    end
end
colormap(mymap);
xticklabels(xtix);
yticklabels(ytix);

axx = fix(axis);
X = 0.1*(axx(2)-axx(1));
Y = 0.1*(axx(4)-axx(3));
XY = [[axx(2)-X-x axx(2)-X]; [axx(4)-Y axx(4)-Y]];
line(XY(1,:), XY(2,:), 'color', lincolour, 'linestyle', ...
    linstyle,'linewidth', linwidth);
text(XY(1,1) -5 , XY(2,1)-15, fixvalsunits(linedist, 'm'), ...
    'color', lincolour, 'fontsize', 20);

end

function [linwidth, lincolour, linstyle, mymap, xtix, ytix, axx] = getoptions(s)
%
linwidth = 4;
lincolour = 'c';
linstyle = '-';
mymap = jet;
xtix = [];
ytix = [];
axx = [];
fnames = fieldnames(s); 
for ix=1:length(fnames)
    switch lower(fnames{ix})
        case 'linwidth'
            linwidth = s.(fnames{ix});
        case 'lincolour'
            lincolour = s.(fnames{ix});
        case 'mymap'
            mymap = s.(fnames{ix});
        case 'xtix'
            xtix = s.(fnames{ix});
        case 'ytix'
            ytix = s.(fnames{ix});
        case 'axx'
            axx = s.(fnames{ix});
        otherwise
            fprintf('%s: ERROR, option %s not supported.', ...
                mfilename, upper(fnames{ix}));
    end
end
end

function [str] = fixvalsunits(somedist, strunits)
%
prfxs =    {'T', 'G', 'M', 'k', '', 'm', '\mu', 'n', 'p'};
sizeunit = [1e12 1e9  1e6  1e3   1 1e-3   1e-6  1e-9 1e-12];

a = somedist./sizeunit';
idx = intersect(find(a>=0.09), find(a<=11));

str = sprintf('%3.4g [%s%s]', a(idx), prfxs{idx}, strunits);

end
