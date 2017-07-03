function [clumphandles, auxclumpTrack] = ...
    clumptracking(handles, tablenet, whichone)
%

[~, filenames] = loadone(handles.dataLa, 'all');

thisframetable = tablenet(tablenet.timeframe==whichone,:);
clumpcode = zeros(size(thisframetable,1),1,'uint64');
clumpID = zeros(size(thisframetable,1),1);
auxclumpTrack = table(clumpcode, clumpID);

[~,~, clumphandles] = getdatafromhandles(handles, filenames{whichone});

clumpaux = unique(clumphandles.overlappingClumps);
clumpaux(1) = [];
clumphandles.clumpID = clumpaux;
clumphandles.numOver = length(clumphandles.clumpID);

[overboundies] = bwboundaries(clumphandles.overlappingClumps>0);
%[noverboundies] = bwboundaries(clumphandles.nonOverlappingClumps>0);

if ~isempty(overboundies)
    for jx=1:clumphandles.numOver
        whosin = find(inpolygon(thisframetable.X, thisframetable.Y, ...
            overboundies{jx}(:,1), overboundies{jx}(:,2)));
        
        nucleilabelsonclump = thisframetable(whosin,:).finalLabel;
        ccode = getclumpcode(nucleilabelsonclump);
        
        auxclumpTrack.clumpcode(whosin) = ccode;
        auxclumpTrack.clumpID(whosin) = clumphandles.clumpID(jx);
    end
else 
    fprintf('%s: No clumps found on frame: %s', mfilename, filenames{whichone});
end