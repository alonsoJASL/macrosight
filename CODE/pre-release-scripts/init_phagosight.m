foldernames.dataRe = handles.dataRe;
foldernames.dataLa = handles.dataLa;
foldernames.dataHa = handles.dataHa;

handles = neutrophilAnalysis(foldernames.dataLa,0);
handles.dataHa = foldernames.dataHa; 

nodeNet = handles.nodeNetwork;
finalNet = handles.finalNetwork;

options.savebool = true;
options.outputpath = fullfile(dn,'RESULTS');
options.filename = 'fulldataset-nodenet.xlsx';

tablenet = nodenetwork2xls(nodeNet(:,1:31),options);
timedfinalnetwork = timednetwork(handles);

clumpcode = zeros(size(tablenet,1),1,'uint64');
clumpID = zeros(size(tablenet,1),1);

clumptracktable = table(clumpcode, clumpID);

for ix=1:handles.numFrames
    whichone = ix;
    [clumphandles, auxclumpTrack] = ...
        clumptracking(handles, tablenet, whichone);
    clumptracktable(tablenet.timeframe==whichone,:) = auxclumpTrack;
end

clumpidcodes = unique(clumptracktable.clumpcode(clumptracktable.clumpcode>0));
clumpidcodes(floor(clumpidcodes/1000)==0) = [];

save(fullfile(foldernames.dataHa,'clumptrackingtables.mat'), ...
    'clumptracktable', 'clumpidcodes', 'timedfinalnetwork', ...
    'tablenet');