function [kftr] = getKnownTracksVariables(knownfr, trackinfo, clumplab, tk)
% 
framet = trackinfo.timeframe(tk);
kftr.regs = regionprops(zeros(size(knownfr.dataGR)), ...
    'BoundingBox', 'Perimeter',  'Area',...
    'EquivDiameter', 'MajorAxisLength', ...
    'MinorAxisLength');
kftr.boundy = cell(length(clumplab),1);
kftr.xy = zeros(length(clumplab),2);

for wtr=1:length(clumplab)
    % K.F.Tf = Known Frames' TRacks
    thisseglabel = trackinfo.seglabel(tk, wtr);
    thiscell = knownfr.clumphandles.nonOverlappingClumps==thisseglabel;
    regs = regionprops(thiscell, 'BoundingBox', 'Perimeter', 'Area',...
        'EquivDiameter', 'MajorAxisLength', 'MinorAxisLength');
    boundy = bwboundaries(thiscell);
    xin = trackinfo(trackinfo.timeframe==framet,:).X(wtr);
    yin = trackinfo(trackinfo.timeframe==framet,:).Y(wtr);
    
    kftr.regs(wtr) = regs;
    kftr.boundy{wtr} = boundy{1};
    kftr.xy(wtr,:) = [xin yin];
    
    clear thisseglabel thiscell regs boundy xin yin
end