function [newfr] = nextframeevolution(unknownfr, knowntracks, trackinfo, clumplab)
% EVOLUTION OF SHAPE INTO 'NEXT FRAME'. 
% 
% Usage:  [newfr] = nextframeevolution(unknownfr, knowntracks, trackinfo, clumplab)
% 
%          unknownfr := common information about frame. Structure that 
%                     contains general information about the "next" or 
%                     unknown frame:     
%                     -> dataL, dataGL, clumphandles, dataR, dataGR, X, t, hasclump
% 
%        knowntracks := information that depends on the tracks present in 
%                     a known frame. A structure that contains:
%                     -> 'regs'    'boundy'    'xy'
%          
%          trackinfo := general information about the tracks of the red
%                   channel. Used here to get positions and segmentation
%                   labels.
%
%           clumplab := Track labels corresponding to the nuclei that are
%                   contained inside the clump being studied.
%
 

tkp1 = find(trackinfo.timeframe==unknownfr.t);
fprintf('%s: Evolving shape to frame t%d = t%d+1.\n', ...
    mfilename, tkp1, (tkp1-1));

[rows, cols] = size(unknownfr.dataGL);

newfr.xy = zeros(length(clumplab),2);
newfr.movedboundy = cell(length(clumplab),1);
newfr.movedbb = zeros(length(clumplab),4);
newfr.evomask = zeros(rows, cols, length(clumplab));
newfr.evoshape = cell(length(clumplab),1);

acopt.framesAhead = 1;
acopt.method = 'Chan-Vese';
acopt.iter = 50;
acopt.smoothf = 2;
acopt.contractionbias = -0.1;

for wtr=1:length(clumplab)
    
    xin = trackinfo(tkp1,:).X(wtr);
    yin = trackinfo(tkp1,:).Y(wtr);
    
    boundy = knowntracks.boundy{wtr} + ...
        repmat([xin yin]-knowntracks.xy(wtr,:),...
        size(knowntracks.boundy{wtr},1),1);
    bb = knowntracks.regs(wtr).BoundingBox + ...
        ([yin xin 0 0] - [knowntracks.xy(wtr,2:-1:1) 0 0]);
    
    newfr.movedboundy{wtr} = boundy;
    newfr.movedbb(wtr,:) = bb;
    newfr.xy(wtr,:) = [xin yin];
    
    movedmask = imerode(poly2mask(boundy(:,2), boundy(:,1), ...
        rows, cols), ones(5));
    
    evomask = activecontour(unknownfr.dataGR, movedmask, acopt.iter, ...
        acopt.method, 'ContractionBias',acopt.contractionbias,...
        'SmoothFactor', acopt.smoothf);
    evoshape = bwboundaries(evomask);
    
    newfr.evomask(:,:,wtr) = evomask.*trackinfo.seglabel(tkp1, wtr);
    newfr.evoshape{wtr} = evoshape{1};
    
    clear xin yin boundy bb movedmask evomask
end