function [generalinfo, trackfeatures, anglechanges, plotpoints] = ...
    calculateAngleChanges(tablenet, clumptracktable, contactEvents, benchmarkEvents)
% 

calculateBenchmarks = nargin == 4;

allrowsix = size(contactEvents,1);

for rowix=1:allrowsix
    
    mT = contactEvents(rowix,:);
    
    wuc= mT.whichclump;
    clumplab = mT.whichlabel;
    
    trackinfo = gettrackinfo(tablenet, clumptracktable, clumplab);
    
    ffix=mT.initialframe;
    lfix=mT.finalframe;
    
    generalinfo(rowix).datasetID = mT.whichdataset;
    generalinfo(rowix).clumpID = wuc;
    generalinfo(rowix).clumplabel = clumplab;
    generalinfo(rowix).clumprange = [ffix lfix];
    generalinfo(rowix).nbeforeclump = mT.clumpinit - mT.initialframe;
    generalinfo(rowix).nafterclump = mT.finalframe - mT.clumpfin;
    
    [trackfeatures(rowix), anglechanges(rowix)] = getanglechanges(trackinfo, wuc, [ffix lfix]);
    [plotpoints(rowix).plotprepoints, plotpoints(rowix).plotpostpoints] = getpointsforplot(anglechanges(rowix));
    
    if calculateBenchmarks == true
        mTS = benchmarkEvents(rowix,:);
        fbnchix = mTS.initialfr_pre;
        lbnchix = mTS.finalfr_pre;
        
        [~, ~, trackfeatures(rowix).bnchmrk, anglechanges(rowix).bnchmk] = ...
            getanglechanges(trackinfo, wuc, [ffix lfix], [fbnchix lbnchix]);
        
        [plotpoints(rowix).bnchmrk.plotprepoints, plotpoints(rowix).bnchmrk.plotpostpoints] = ...
            getpointsforplot(anglechanges(rowix).bnchmk);
        
        generalinfo(rowix).bnchmrkrange = [fbnchix lbnchix];
        generalinfo(rowix).nbnchmrk = mTS.finalfr_pre - mTS.initialfr_pre;
    end    
end