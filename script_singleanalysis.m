% script: Single shape evolution + shape analysis
%
%% INITIALISATION
initscript;

load DATASETHOLES
clumptracktable(ismember(tablenet.timeframe, DATASETHOLES),:) = [];
tablenet(ismember(tablenet.timeframe, DATASETHOLES),:) = [];
%% FOREACH TR IN TABLENET.FINALLABEL GET TRACKINFO(TR) TABLES

flabs = unique(tablenet.finalLabel);
flabfreq = zeros(length(flabs),1);
cllength = zeros(length(flabs),1);
alltracks = cell(length(flabs),1);

for ix=1:length(flabs)
    wuc = flabs(ix);
    % get labels from the clump
    clumplab = getlabelsfromcode(wuc);
    trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 11 13 14]) ...
        clumptracktable(ismember(tablenet.track, clumplab),:)];
    flabfreq(ix) = size(trackinfo,1);
    cllength(ix) = sum(trackinfo.clumpcode>0);
    alltracks{ix} = trackinfo;
end

idxshorttrax = (flabfreq - cllength) < 40;
flabs(idxshorttrax) = [];
flabfreq(idxshorttrax) = [];
cllength(idxshorttrax) = [];
alltracks(idxshorttrax) = [];

%% CHOOSE ONE TRACK AND SEPARATE INTO MANY SINGLE PATHS (TRACK >> PATH)
clc;

%ix=1;
for ix=1:length(flabs)
wuc=flabs(ix);
trackinfo=alltracks{ix};

fprintf('Getting all paths for clump %d.\n', wuc);
jumpsix=find(diff(trackinfo.clumpcode>0));
if trackinfo.clumpcode(1)==0
    jumpsix = [1;jumpsix];
end
if trackinfo.clumpcode(end)==0
    jumpsix = [jumpsix;size(trackinfo,1)];
end
if mod(length(jumpsix),2)~=0
    jumpsix(end)=[];
end
wendys = reshape(jumpsix,2, length(jumpsix)/2)';
wendys(:,1) = wendys(:,1)+1;

allpaths = cell(size(wendys,1),1);
for jx=1:size(wendys,1)
    allpaths{jx} = trackinfo(wendys(jx,1):wendys(jx,2),:);
end

outfolder = sprintf('%s_mat_TRACKS_lab%d',handlesdir.data, wuc);
if ~isdir(fullfile(handlesdir.pathtodir, outfolder))
    fprintf('%s: Creating folder %s.\n', mfilename, outfolder);
    mkdir(fullfile(handlesdir.pathtodir, outfolder));
end
outtrackname = sprintf('label%dtracks-knwonfr', wuc);

% from here, just choose a path and check the evolutions
acopt=acoptions('nothing');
for jx=1:length(allpaths)
    fprintf('\n%s: Analysing path=%d/%d from TRACK=%d\n',...
        mfilename, jx, length(allpaths), wuc);
    thispath = allpaths{jx};
    if size(thispath,1)>1
        framet = thispath.timeframe(1);
        [knownfr] = getCommonVariablesPerFrame(handles, thispath, wuc, ...
            filenames{framet}, framet);
        [kftr] = getKnownTracksVariables(knownfr, thispath, clumplab, 1);
        
        save(fullfile(handlesdir.pathtodir, outfolder, ...
            sprintf('%s%d-acNOTHING.mat',outtrackname,framet)),...
            'knownfr', 'kftr');
        
        for tk=1:(size(thispath,1)-1)
            frametplusT = thispath.timeframe(tk+1);
            [ukfr] = getCommonVariablesPerFrame(handles, thispath, wuc, ...
                filenames{frametplusT}, frametplusT);
            [newfr] = nextframeevolution(ukfr, kftr, trackinfo, clumplab, acopt);
            %miniscript;
            
            [knownfr, kftr] = updateKnownFrame(ukfr, newfr, clumplab);
            save(fullfile(handlesdir.pathtodir, outfolder, ...
                sprintf('%s%d.mat',outtrackname,frametplusT)),...
                'knownfr', 'kftr', 'newfr');
        end
    else
        fprintf('%s: Track too short!')
    end
end
end
