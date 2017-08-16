function [fr] = getCommonVariablesPerFrame(handles, trackinfo, wuc, fname, t)
% GET COMMON VARIABLES PER FRAME. Simple function to de-clutter code. 
% 

[fr] = getdatafromhandles(handles, fname);
idx = find(trackinfo.timeframe==t);

fr.t=t;
if trackinfo.clumpcode(idx) == wuc
    fprintf('%s: Clump found. Loading clump information.\n', mfilename);
    fr.hasclump = true;
    fr.clumpseglabel = trackinfo.clumpseglabel(idx);
    fr.thisclump = (fr.dataGL==fr.clumpseglabel);
else
    fr.hasclump = false;
    fr.clumpseglabel = [];
    fr.thisclump = [];
end