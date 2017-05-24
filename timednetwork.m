function [timedFinalnetwork] = timednetwork(handles)
% TIMED FINAL NETWORK turns the finalNet variable from the handles
% structure (handles.finalNetwork) into a matrix of size:
% [numberOfFrames X numberOfTracks] that on each row contains the
% identifiers of only the objects present within that frame.
%
% USAGE:
%           (1) [timedFinalnetwork] = timednetwork(handles)
%           (2) [timedFinalnetwork] = timednetwork(nodeNet, finalNet)
%
%

% check if is structure handles with values
try
    nodeNet = handles.nodeNetwork;
    finalNet = handles.finalNetwork;
catch err
    fprintf('%s: ERROR. Structure does not contain %s and %s.\n',...
        mfilename, 'finalNetwork','nodeNetwork');
    timedFinalNetwork = [];
    return;
end

numOfTracks = size(finalNet,2);
timedFinalnetwork = zeros(size(finalNet));

for ix=1:numOfTracks
    l = nodeNet(ix,6); % Label = Unique ID of Neotrophil
    
    times = nodeNet(finalNet(finalNet(:,ix)>0,ix),5)-1;
    startL = times(1);
    finishL = times(end);
    parent = 0;
    
    timedFinalnetwork(times+1,ix) = l;
    
    % fprintf('%d %d %d %d\n', l,startL, finishL, parent);
    
end

% maybe there are more images than are shown.
if length(timedFinalnetwork(:,1)) < handles.numFrames
    n = length(timedFinalnetwork(:,1));
    m = handles.numFrames;
    timedFinalnetwork = [timedFinalnetwork;...
        zeros(m-n,length(timedFinalnetwork(1,:)))];
end

