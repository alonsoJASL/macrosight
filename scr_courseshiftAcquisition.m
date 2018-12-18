% COURSE SHIFT (ANGLE CHANGE) ACQUISITION
% Runs on a specific dataset, acquiring all direction changes from the
% cases obtained in SCR_REVIEWDATASETFORINTERACTIONS.
%
%
%% INITIALISATION
tidy;
whichmacro = 3;
initscript_dev;
% initscript; %
T = readtable('./macros123.xlsx');
T(~contains(upper(T.whichdataset), ['MACROS' num2str(whichmacro)]),:) = [];

TS = readtable('./macros123singles.xlsx');
TS(~contains(upper(TS.whichdataset), ['MACROS' num2str(whichmacro)]),:) = [];

%%
%figure
allrowsix = size(T,1);

try
    load('angleChanges.mat');
    
    if sum(ismember(experimentInfo.whichmacro, whichmacro))==0
        disp('adding new dataset information');
        indx2start = length(clumptrackfeatures);
        experimentInfo = [experimentInfo; table(whichmacro, size(T,1), ...
            'VariableNames',{'whichmacro','numExperiments'})];
    else
        indx2start = find([clumptrackfeatures.datasetID]==whichmacro,1);
    end
    
catch e
    fprintf('%s: no angle strcture found, creating a new one.\n', mfilename);
    experimentInfo = table(whichmacro, size(T,1), 'VariableNames',...
        {'whichmacro','numExperiments'});
    indx2start = 0;
end
%
%rowix=9;
for rowix=1:allrowsix
    
    mT = T(rowix,:);
    mTS = TS(rowix,:);
    
    wuc= mT.whichclump;
    clumplab = mT.whichlabel;
    
    trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
        clumptracktable(ismember(tablenet.track, clumplab),:)];
    
    ffix=mT.initialframe;
    lfix=mT.finalframe;
    
    fbnchix = mTS.initialfr_pre;
    lbnchix = mTS.finalfr_pre;
    
    [clumptrackfeatures(indx2start+rowix),...
        clumpanglechanges(indx2start+rowix),...
        bnchmktrackfeatures(indx2start+rowix),...
        bnchmkanglechanges(indx2start+rowix)] = ...
        getanglechanges(trackinfo, wuc, [ffix lfix], [fbnchix lbnchix]);
    
    [clumpplot(indx2start+rowix).plotprepoints,...
        clumpplot(indx2start+rowix).plotpostpoints] = ...
        getpointsforplot(clumpanglechanges(indx2start+rowix));
    
    [bnchmkplot(indx2start+rowix).plotprepoints,...
        bnchmkplot(indx2start+rowix).plotpostpoints] = ...
        getpointsforplot(bnchmkanglechanges(indx2start+rowix));
    
    generalinfo(indx2start+rowix).datasetID = whichmacro;
    generalinfo(indx2start+rowix).clumpID = wuc;
    generalinfo(indx2start+rowix).clumplabel = clumplab;
    generalinfo(indx2start+rowix).clumprange = [ffix lfix];
    generalinfo(indx2start+rowix).controlrange = [fbnchix lbnchix];
    generalinfo(indx2start+rowix).nbeforeclump = mT.clumpinit - mT.initialframe;
    generalinfo(indx2start+rowix).nafterclump = mT.finalframe - mT.clumpfin;
    generalinfo(indx2start+rowix).ncontrol = mTS.finalfr_pre - mTS.initialfr_pre;
end

%
save('angleChanges.mat', 'generalinfo','clumptrackfeatures', ...
    'clumpanglechanges','bnchmktrackfeatures', 'bnchmkanglechanges', ...
    'clumpplot', 'bnchmkplot', 'experimentInfo');
fprintf('%s: Structure Saved.\n', mfilename);

