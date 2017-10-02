function [varagout] = plotleftright(x, yleft, yright, lfinfo)
% plot two functions on the same axis
% 

if nargin == 2
    lfinfo = yleft;
    [linl, linr, labl, labr, yleft, yright] =  getoptions(lfinfo);
    
elseif nargin < 4
    linl = '-*';
    linr = '-+';
    labl = inputname(2);
    labr = inputname(3);
else
    [linl, linr, labl, labr, ~, ~] =  getoptions(lfinfo);
end

gca;
yyaxis left
plot(x, yleft, linl, 'markersize', 8, 'linewidth', 1.5); 
grid on;
ylabel(labl);
yyaxis right
plot(x, yright, linr, 'markersize', 8, 'linewidth', 1.5);
grid on;
ylabel(labr);

end

function [linl, linr, labl, labr, yleft, yright] =  getoptions(s)
    linl = '-*';
    linr = '-+';
    labl = 'left';
    labr = 'right';
    yleft = [];
    yright = [];
    
    fnames = fieldnames(s);
    for ix=1:length(fnames)
       switch lower(fnames{ix}) 
           case {'linl', 'linleft'}
               linl = s.(fnames{ix});
           case {'linr', 'linright'}
               linr = s.(fnames{ix});
           case {'labl', 'lableft'}
               labl = s.(fnames{ix});
           case {'labr', 'labright'}
               labr = s.(fnames{ix});
           case 'yleft'
               yleft = s.(fnames{ix});
           case 'yright'
               yright = s.(fnames{ix});
           otherwise 
               fprintf('%s: ERRROR, option %s not recognised!', ...
                   mfilename, upper(fnames{ix}));
       end
    end
    end