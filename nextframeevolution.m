function [newfr] = nextframeevolution(unknownfr, knowntracks, trackinfo,...
    clumplab, acopt)
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

if nargin < 5
    method = 'Chan-Vese';
    iter = 50;
    smoothf = 2;
    contractionbias = -0.1;
    erodenum = 1;
    whichfn = 'identity';
else
    [method, iter, smoothf, contractionbias, erodenum, whichfn] = getoptions(acopt);
end

tkp1 = find(trackinfo.timeframe==unknownfr.t);
fprintf('%s: Evolving shape to frame t%d = t%d+1.\n', ...
    mfilename, tkp1, (tkp1-1));

[rows, cols] = size(unknownfr.dataGL);

newfr.xy = zeros(length(clumplab),2);
newfr.movedboundy = cell(length(clumplab),1);
newfr.movedbb = zeros(length(clumplab),4);
newfr.evomask = zeros(rows, cols, length(clumplab));
newfr.evoshape = cell(length(clumplab),1);

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
    
    movedmask = imopen(poly2mask(boundy(:,2), boundy(:,1), ...
        rows, cols), ones(erodenum));
    
    g = imagefunction(unknownfr.dataGR, whichfn);
    evomask = activecontour(g, movedmask, iter, method, ...
        'ContractionBias',contractionbias,'SmoothFactor', smoothf);
    [evomask] = checkmask(evomask, unknownfr.dataL, trackinfo(tkp1,:).seglabel(wtr));
    evoshape = bwboundaries(evomask);
    
    newfr.evomask(:,:,wtr) = evomask.*trackinfo.seglabel(tkp1, wtr);
    newfr.evoshape{wtr} = evoshape{1};
    
    clear xin yin boundy bb movedmask evomask
end
end

function [method, iter, smoothf, contractionbias, erodenum, whichfn] = getoptions(s)
% get active contour options
erodenum = 1;
method = 'Chan-Vese';
iter = 50;
smoothf = 2;
contractionbias = -0.1;
whichfn = 'identity';

fnames = fieldnames(s);
for ix=1:length(fnames)
    name = fnames{ix};
    switch name
        case 'erodenum'
            erodenum = s.(name);
        case 'method'
            method = s.(name);
        case 'iter'
            iter = s.(name);
        case 'smoothf'
            smoothf = s.(name);
        case 'contractionbias'
            contractionbias = s.(name);
        case 'whichfn'
            whichfn = s.(name);
        otherwise
            fprintf('%s: ERROR. Incorrect option [%s] is NOT defined.\n',...
                mfilename, upper(name));
    end
end
end

function [g] = imagefunction(I, whichfn)
% image function used in active contours
switch lower(whichfn)
    case {'eye', 'nothing', 'identity'}
        g = I;
    case {'gradmag', 'gradients'}
        g = abs(imgradient(imfilter(I, fspecial('gaussian'))));
    case {'inversegrad', 'ig', 'inversegradient'}
        g = 1./(1+abs(imgradient(imfilter(I, fspecial('gaussian')))).^2);
    otherwise
        fprintf('%s: ERROR. wrong image function %s. Using identity.\n',...
            mfilename, upper(whichfn));
        g = I;
end
end

function [fixedmask] = checkmask(evomask, dataL, seglabel)
% check multiple shapes
fixedmask = evomask;
[auxevo, nx] = bwlabeln(fixedmask>0);
if nx > 1
    fprintf('%s: Mask separated after Active Contours, fixing...\n', mfilename);
    thisnucleus = dataL==seglabel;
    for qqx=1:nx
        testmat = bitand(auxevo==qqx, thisnucleus);
        if length(unique(testmat(:)))==1
            % only zeros => no intersection
            fixedmask(auxevo==qqx) = 0;
        end
    end
    fixedmask = imdilate(fixedmask, ones(3));
end
end