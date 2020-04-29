function [trackinfo] = gettrackinfo(tablenet, clumptracktable, clumplab)
% GET TRACK INFORMATION. clumplab can be a vector of tracks or a single 
% track identifier. 
% 
trackinfo = [tablenet(ismember(tablenet.track, clumplab),[5 1 2 9 11 13 14]) ...
        clumptracktable(ismember(tablenet.track, clumplab),:)];
