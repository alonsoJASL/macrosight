function [anglegram, aghandles] = computeMultiAnglegram(boundies, whix)
% COMPUTE MULTI SCALE ANGLEGRAM. Computes a mutliscale anglegram that
% produces a more-accurate, less-noisy anglegram by reducing the
% resolution. 
% 
% USAGE: 
%       [anglegram, aghandles] = computeMultiAnglegram(boundies, whix);
%
% SEE ALSO: computeAngleMatrix, computeCandidatePoints
%

if nargin < 2
    whix = 1;
end

auxaghandles.oganglegram = computeAngleMatrix(boundies,whix,1);
anglegram = zeros(size(auxaghandles.oganglegram,1), ...
    size(auxaghandles.oganglegram,2),10);
angelgram(:,:,1) = auxaghandles.oganglegram;

for neighjump=2:10
    [anglegram(:,:,neighjump)] = computeAngleMatrix(boundies,whix,2*neighjump);
end

auxaghandles.agstd = std(anglegram, 0, 3);
anglegram = mean(anglegram,3);

if nargout < 2
    aghandles = auxaghandles;
end