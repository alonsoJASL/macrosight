function [ds2v] = distset2vect(setofpoints, vectorpoint, selfdist)
% DISTANCE FROM SET OF POINTS TO VECTOR
% Assume vector is a 1XN and setofpoints is MXN
% 

if nargin < 3 
    selfdist = false;
end
qq = setofpoints - repmat(vectorpoint, [size(setofpoints,1), 1]);

if selfdist == true
    fprintf('%s: Attatching a zero to the beginning of the vector, %s.\n',...
        mfilename, [32 'representing dist(vectorpoint, vectorpoint)']);
    ds2v = [0;sqrt(sum(qq.^2,2))];
else
    ds2v = sqrt(sum(qq.^2,2));
end





