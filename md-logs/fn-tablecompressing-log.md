# Function: Table compression based on clumps being analysed
In this function, a description of the function that aligns the table
into a more readable layout. This is necessary to turn the table from:

|timeframe|X|Y|seglabel|track|finalLabel|clumpcode|clumpID|
|-----|-----|-----|-----|-----|-----|-----|-----|
|418|317.41|302.24 | 6|8|8|0|0|0|      
|418|236.47|395.8|7|2|2|0|0|      
|419|317.24|305.07|6|8|8|0|0|
|419|237.49|397.72|7|2|2|0|0
|420|317.09|306.01|5|8|8|0|0|
|420|235.51|398.6|6|2|2|0|0|    

into:

|timeframe|X|Y|seglabel|track|finalLabel|clumpcode|clumpID|
|-----|-----|-----|-----|-----|-----|-----|-----|
|418|`[317.41 236.47]`|`[302.24 395.8]`|`[6 7]`|`[8 2]`|`[8 2]`|0|0|0|      
|419|`[317.24 237.49]`|`[305.07 397.72]`|`[6 7]`|`[8 2]`|`[8 2]`|0|0|
|420|`[317.09 235.51]`|`[306.01 398.6]`|`[5 6]`|`[8 2]`|`[8 2]`|0|0|

which means that there is one row per `timeframe` and the different
clump-dependant variables: `X,Y,seglabel,track,` and `finalLabel` can be
accessed by the same position of the labels in the analysed clump.

## The function
```Matlab
function [ticompressed] = tablecompression(trackinfo, clumplab)
% TABLE COMPRESSION BASED ON A CLUMP BEING ANALYSED. Be sure to use only a
% table (trackinfo) that has already been reduced to show a particular pair
% of cells that eventually form a clump.
%
% USAGE: [ticompressed] = tablecompression(trackinfo)
%

aa = table2struct(trackinfo(1:length(clumplab):end,:));
jx=1:length(clumplab):size(trackinfo,1);
fields = {'X','Y','seglabel','track','finalLabel'};

for ix=1:length(jx)
    for kx=1:length(fields)
        auxvect = zeros(1,length(clumplab));
        for qx=1:length(clumplab)
            auxvect(qx) =  trackinfo(jx(ix)+(qx-1),:).(fields{kx});
        end
        aa(ix).(fields{kx}) = auxvect;
    end
    aa(ix).clumpseglabel = aa(ix).seglabel(1)*(aa(ix).clumpcode>0);
end

ticompressed = struct2table(aa);
```
Normally, the user would call this function like
```Matlab
trackinfo = tablecompression(trackinfo);
```
