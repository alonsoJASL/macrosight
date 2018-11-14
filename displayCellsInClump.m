function [cicltable, winsclump] = displayCellsInClump(fulltnet, wuc, S)
% DISPLAY CELLS IN CLUMP. Displays a table with all the information of the
% track in frames where all cells involved in a clump are present at the
% same time.
% 
% USAGE: 
% [cicltable, winsclump] = displayCellsInClump(fulltnet, wuc, S)
%
% OUTPUT:
%   cicltable := "Cells In Clump Life Table", is the subtable containing
%   
%   winsclump := "frame Windows with Clump"
% 
% INPUT:
%           
%

fprintf('Analysing clump %d\n', wuc);

% get labels from the clump
clumplab = getlabelsfromcode(wuc);

if length(clumplab)==2
    trinfo = fulltnet(ismember(fulltnet.track, clumplab),...
                        [5 1 2 9 11 13 14 32 33]);
    
    trinf = cell(length(clumplab),1);
    for jx=1:length(clumplab)
        trinf{jx} = trinfo(trinfo.finalLabel==clumplab(jx),:);
    end
    
   
    % time frames in clump
    tfc = unique(trinfo(trinfo.clumpcode==wuc,1).timeframe);
        
    brtfc = find(diff(tfc)>1);
    winfc = [[1;brtfc+1] [brtfc;length(tfc)]];
    
    disp('In clump: ')
    disp(tfc(winfc));
    
    fprintf('Cell labels: %d and %d')
    disp(trinfo(ismember(trinfo.timeframe,(max(1,tfc(1)-S)):(tfc(end)+S)),:));
    
    if nargout > 0
        cicltable = trinfo(ismember(...
            trinfo.timeframe,(max(1,tfc(1)-S)):(tfc(end)+S)),:);
        winsclump = winfc;
    end
    
else
    fprintf('\n%s. Only support for clumps with two cells\n', mfilename);
    if nargout > 0
        cicltable = [];
        winsclump = [];
    end
end