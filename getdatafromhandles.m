function [dataL, dataGL, clumphandles, dataR, dataGR] = getdatafromhandles(...
    handles, fname)

fprintf('%s: Loading dataLa files: %s\n', mfilename, fname);
la = load(fullfile(handles.dataLa, fname));

dataL = la.dataL;
dataGL = cleanupgreen(dataL, la.dataG);

clumphandles = la.clumphandles;
clumphandles.nonOverlappingClumps = ...
    (clumphandles.nonOverlappingClumps>0).*dataGL;
clumphandles.overlappingClumps = ...
    (clumphandles.overlappingClumps>0).*dataGL;

if nargout > 3
    fprintf('%s: Loading dataRe files: %s\n', mfilename, fname);
    re = load(fullfile(handles.dataRe, fname));
    dataR = re.dataR;
    dataGR = re.dataG;
end