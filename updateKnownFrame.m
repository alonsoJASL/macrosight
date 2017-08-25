function [knownfr, kftr] = updateKnownFrame(ukfr, newfr, clumplab,...
    handles, clumptracktable, clumpidcodes)
%

filenames = dir(fullfile(handles.dataLa, '*.mat'));
filenames = {filenames.name};

knownfr = ukfr;

idx = find(knownfr.dataGL==ukfr.clumpseglabel);
dataG(idx) = 0;
clumphandles.overlappingClumps(idx)=0;

for kx=1:length(clumplab)
    dataG = dataG + newfr.evomask(:,:,kx);
    clumphandles.nonOverlappingClumps = ...
        clumphandles.nonOverlappingClumps + newfr.evomask(:,:,kx);
end


if knownfr.hasclump == true
    % 3.4.1.1 Change variables and save them back to the HDD
    fprintf('%s: a clump has been disambiguated!\n', mfilename);
    load(fullfile(handles.dataLa, filenames{knownfr.t}));
    
    dataL = knownfr.dataL;
    dataG = knownfr.dataGL;
    clumphandles = knownfr.clumphandles;
    
    idx = find(dataG==ukfr.clumpseglabel);
    dataG(idx) = 0;
    clumphandles.overlappingClumps(idx)=0;
    
    for kx=1:length(clumplab)
        dataG = dataG + newfr.evomask(:,:,kx);
        clumphandles.nonOverlappingClumps = ...
            clumphandles.nonOverlappingClumps + newfr.evomask(:,:,kx);
    end
    
    % update clumptracktable
    test1 = clumptracktable(tablenet.timeframe==knownfr.t,:);
    test2 = find(tablenet.timeframe==knownfr.t);
    indx = test2(test1.clumpcode==wuc);
    
    clumptracktable(indx,:).Variables = ...
        zeros(size(clumptracktable(indx,:).Variables));
    
    if isempty(find(clumptracktable.clumpcode==wuc, 1))
        % removing the clump code if the clump is completely removed
        fprintf('%s: Clump removed from dataset.\n', mfilename);
        clumpidcodes(clumpidcodes==wuc) = [];
    end
    
    
    ButtonName = questdlg('Do you want to save the updated variables?', ...
        'Update variables to HDD?','Yes', 'No','No');
    switch ButtonName
        case 'Yes'
            save(fullfile(filenames{knownfr.t}), ...
                'dataG','dataL','clumphandles','statsData','numNeutrop');
            save(fullfile('clumptrackingtables.mat'), ...
                'clumptracktable', 'clumpidcodes', 'timedfinalnetwork', ...
                'tablenet');
            
            fprintf('%s: variables have been updated to HDD.\n',...
                mfilename);
        case 'No'
            fprintf('%s: Nothing got saved to the hard drive.\n',...
                mfilename);
    end
    clear ButtonName;
    
    knownfr.hasclump = false;
    knownfr.clumpseglabel = [];
    knownfr.thisclump = [];
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
    
    midx = find([regs.Area]==max([regs.Area]));
    auxfr.regs(wtr) = regs(midx);
end

kftr = auxfr;

