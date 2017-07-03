function [dataGL] = cleanupgreen(dataL, dataG)
% CLEAN UP GREEN CHANNEL. Removes cells on green channel (dataG) that do
% not have a corresponding cell in the red channel (dataL).
%
% Usage: 
%           [dataGL] = cleanupgreen(dataL, dataG)
%

if ischar(dataL)
    fprintf('%s: Retrieving dataG and dataL matrices.\n', mfilename);
    basefilename = dataL;
    
    if ~isdir(basefilename)
    currdata = load(basefilename);
    else
        fprinft('%s: ERROR. Directories like %s are NOT supported.\n', ...
            mfilename, basefilename);
        dataGL = [];
        return;
    end
    
    [dataGL] = cleanupgreen(currdata.dataL, currdata.dataG);
    return;
end

dataGLa = bwlabeln(dataG>0);
prelabgreen = unique(dataGLa);
prelabgreen(1) = [];

dataGL = zeros(size(dataG));

for ix=1:length(prelabgreen)
    thisG = dataGLa==ix;
    testM = bitand(thisG, dataL>0);
    if ~isempty(find(testM>0, 1))
        lab = unique(testM.*dataL);
        lab(1) = [];
        dataGL = dataGL + (thisG.*lab(1));
    end
end

