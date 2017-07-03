function [noisybw] = noisybw(BW, fgndstats, noisestats)
% Generate bw0 with different 
%

if nargin < 2
    unoise = 0.076629;
    varnoise = 0.0085682;
    
    ufgnd = 0.15642;
    varfgnd = 0.091072;
else
    try
        unoise = noisestats(1);
        varnoise = noisestats(2);
        
        ufgnd = fgndstats(1);
        varfgnd = fgndstats(2);
    catch e
        fprtinf('%s: ERROR with the noise parameters. Using default values',...
            mfilename);
        noisybw = noisy(BW);
    end
    
end

bck = ones(size(BW));
frgn = BW;

bck = bck.*(unoise + varnoise.*randn(size(bck)));
frgn = frgn.*(ufgnd + varfgnd.*randn(size(frgn)));

noisybw = bck+frgn;

