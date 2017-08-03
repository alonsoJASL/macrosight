function [dataL, dataGL, clumphandles, dataR, dataGR] = getdatafromhandles(...
    handles, fname)

if nargout == 1
    % in case the user only wants one single structure with all the
    % information
    fprintf('%s: Packaging all information into one single structure.\n',...
        mfilename);
    [dataLL, dataGL, clumphandles, dataR, dataGR] = ...
        getdatafromhandles(handles, fname);
    sf.dataL = dataLL;
    sf.dataGL = imerode(dataGL>0, ones(1)).*dataGL;
    sf.clumphandles = clumphandles;
    sf.dataR = dataR;
    sf.dataGR = dataGR;
    sf.X = cat(3, dataR, dataGR, zeros(size(dataR)));
    
    dataL = sf;
    return;
end
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