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
ix=1;
wuc=flabs(ix);
trackinfo=alltracks{ix};

jumpsix=find(diff(trackinfo.clumpcode>0));
if mod(length(jumpsix),2)~=0
    jumpsix(end)=[];
end
wendys = reshape(jumpsix,2, length(jumpsix)/2)';
wendys(:,1) = wendys(:,1)+1;

thesepaths = cell(size(wendys,1),1);
for jx=1:size(wendys,1)
    thesepaths{jx} = trackinfo(wendys(jx,1):wendys(jx,2),:);
end

% from here, just choose a path and check the evolutions

%% NOW TRY THE SAME WITH CLUMPS