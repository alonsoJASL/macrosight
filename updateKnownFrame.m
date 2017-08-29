function [knownfr, kftr] = updateKnownFrame(ukfr, newfr, clumplab)
% UPDATE KNOWN FRAME FROM SHAPE EVOLUTION. This function takes the current
% frame and updates it to contain the new cells previously calculated. It
% also produces the updated boundaries and region properties (regionprops)
% for the aforrementioned cells.
%
% USAGE:
%       [knownfr, kftr] = updateKnownFrame(ukfr, newfr, clumplab)
%

knownfr = ukfr;

if knownfr.hasclump == true
    idx = find(knownfr.dataGL==ukfr.clumpseglabel);
    knownfr.dataGL(idx) = 0;
    knownfr.clumphandles.overlappingClumps(idx)=0;
    
    knownfr.hasclump = false;
    knownfr.clumpseglabel = [];
    knownfr.thisclump = [];
    
    for kx=1:length(clumplab)
        knownfr.dataGL = knownfr.dataGL + newfr.evomask(:,:,kx);
        knownfr.clumphandles.nonOverlappingClumps = ...
            knownfr.clumphandles.nonOverlappingClumps + newfr.evomask(:,:,kx);
    end
else
    labs = unique(newfr.evomask);
    labs(1) = [];
    for kx=1:length(labs)
        idx = find(knownfr.dataGL==labs(kx));
        knownfr.dataGL(idx) = 0;
        knownfr.clumphandles.nonOverlappingClumps(idx)=0;
    end
    
    for kx=1:length(clumplab)
        knownfr.dataGL = knownfr.dataGL + newfr.evomask(:,:,kx);
        knownfr.clumphandles.nonOverlappingClumps = ...
            knownfr.clumphandles.nonOverlappingClumps + newfr.evomask(:,:,kx);
    end
end

% 3.4.2 Update kftr
auxfr.regs = regionprops(zeros(size(knownfr.dataGR)), ...
    'BoundingBox', 'Perimeter', 'Area','EquivDiameter', 'MajorAxisLength', ...
    'MinorAxisLength');
auxfr.boundy = newfr.evoshape;
auxfr.xy = newfr.xy;

for wtr=1:length(clumplab)
    thiscell = newfr.evomask(:,:,wtr)>0;
    regs = regionprops(thiscell, 'BoundingBox', 'Perimeter', 'Area', ...
        'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength');
    
    midx = [regs.Area]==max([regs.Area]);
    auxfr.regs(wtr) = regs(midx);
end

kftr = auxfr;

