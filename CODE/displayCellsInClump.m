function [cicltable, winsclump] = displayCellsInClump(tablenetplusclumps, wuc, S, verbose)
% DISPLAY CELLS IN CLUMP. Displays a table with all the information of the
% track in frames where all cells involved in a clump are present at the
% same time.
%
% USAGE:
% [cicltable, winsclump] = displayCellsInClump(fulltnet, wuc, S)
%
% OUTPUT:
%   cicltable := "Cells In Clump Life Table", is the subtable containing
%   the specific clump (wuc) in from the first timeit appears (minus S
%   frames) until the last time it appears (plus S frames).
%
%   winsclump := "frame Windows with Clump"
%
% INPUT:
%
%
if nargin < 4
    verbose = (nargout == 0);
end
mcrsght_info(sprintf('Analysing clump %d', wuc));

% get labels from the clump
clumplab = getlabelsfromcode(wuc);

if length(clumplab)==2
    trinfo = tablenetplusclumps(ismember(tablenetplusclumps.track, clumplab),...
        [5 1 2 9 11 13 14 32 33]);
    
    trinf = cell(length(clumplab),1);
    for jx=1:length(clumplab)
        trinf{jx} = trinfo(trinfo.finalLabel==clumplab(jx),:);
    end
    
    % time frames in clump
    tfc = unique(trinfo(trinfo.clumpcode==wuc,1).timeframe);
    
    brtfc = find(diff(tfc)>1);
    winfc = [[1;brtfc+1] [brtfc;length(tfc)]];
    
    if verbose == true
        mcrsght_info('Cells in clump: ');
        disp(tfc(winfc));
        
        mcrsght_info(sprintf('Cell labels: %d and %d', clumplab(1), clumplab(2)));
        disp(trinfo(ismember(trinfo.timeframe,(max(1,tfc(1)-S)):(tfc(end)+S)),:));
    else
        try
            cicltable = trinfo(ismember(...
                trinfo.timeframe,(max(1,tfc(1)-S)):(tfc(end)+S)),:);
            winsclump = tfc(winfc);
        catch
            mcrsght_info('Unable to generate Cels in Clump table.', 'WARNING', verbose);
            if nargout > 0
                cicltable = [];
                winsclump = [];
            end
        end
    end
    
else
    mcrsght_info('Only support for clumps with two cells', 'WARNING', verbose);
    if nargout > 0
        cicltable = [];
        winsclump = [];
    end
end