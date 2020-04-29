function [nodeNetTable] = nodenetwork2xls(nodeNet, options)
% NODE NETWORK TO XLS FILE. Converts the node network matrix from
% phagosight into an 
% 
if nargin<2
    savebool = false;
    outputpath = '.';
    filename = 'somenodenet.xlsx';
else
    [savebool, outputpath, filename] = getoptions(options);
end

% phagosight's varnames
varnames = {'X', 'Y', 'Z', 'dist2closest', 'timeframe', 'ID', 'parent',...
    'child', 'velocity', 'volume', 'seglabel', 'keyhole', 'track', ...
    'finalLabel', 'bb_xinit', 'bb_yinit', 'bb_zinit', 'bb_xwidth',...
    'bb_ywidth', 'bb_zwidth', 'a21', 'a22', 'a23', 'a24', 'a25',...
    'vol2surf', 'sphericity', 'diffdistbrackets', 'a29', ...
    'dist2disappear', 'dist2appear'};
nodeNetTable = array2table(nodeNet, 'VariableNames', varnames);

% clean nodeNetwork
nodeNetTable(isnan(nodeNetTable.X), :) = [];
nodeNetTable(nodeNetTable.finalLabel==0,:) = [];


if savebool == true || nargout == 0 
    writetable(nodeNetTable, fullfile(outputpath, filename));
end
end

function [savebool, outputpath, filename] = getoptions(s)
% 
savebool = false;
outputpath = '.';
filename = 'somenodenet.xlsx';

fnames = fieldnames(s);
for ix=1:length(fnames)
    name = fnames{ix};
    switch name
        case 'savebool'
            savebool = s.(name);
        case 'outputpath'
            outputpath = s.(name);
        case 'filename'
            filename = s.(name);
        otherwise
            fprintf('%s: ERROR, option %s not found.\n',mfilename, name);
    end
end

end