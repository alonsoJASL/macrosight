# Shape analysis: continued ...
In this log file, the analysis will be made onto one single cell. Inside
the `MACROS` dataset, track `2` has been identified as a cell that evolves
from frame `t=1` until frame `t=498`. This track goes through multiple
clumps, as seen when displaying all the clumps that have track `2` in them:
```Matlab
> clumpidcodes(clumpidcodes-fix(clumpidcodes./1000)*1000 ==2)

ans =

  18×1 uint64 column vector

                3002
                4002
                8002
               19002
               50002
               60002
             5003002
             8007002
            60010002
            60013002
            75060002
            79060002
         19008007002
         21005003002
         60013010002
         60014013002
      60014013010002
   61060017014013002
```
In this evaluation, we will focus on clump `8002`, which only appears in
frame `t=417`. This can be displayed with the code:
```Matlab
plotTracks(handles, 2, [2 8]);
```

The figure displays the two tracks (i.e `2` and `8`) that form clump
`8002`. It can be seen that
![tracks-8-and-2](./figs/clump8002-track2.png)

The analysis will be made from frames `t=418:495`, which can be seen in
the figure below. The selected track is highlighted.
![tracks-8-and-2](./figs/cl8002-tr2-analysiswindow.png)

Inspection of the previous image shows that track `8` would also be
suitable for trying in this analysis. The following development will be
done with track `2`, however track `8` could be done as well.
## Isolation of track `2` within the frames of interest
The track number needs to be matched with the label shown on the
segmentation. Because of how the labels are made within @phagosight,
the track number, `tablenet.track`, could differ from the final label,
`tablenet.finalLabel`. Furthermore, both track and final label, also
differ from the segmentation label `tablenet.seglabel`
(the one actually showing in the frame).

An analysis will be made to link the track label to the segmentation label
will be made. The relevant information is already in `handles.finalNetwork`
or better yet, in `tablenet`. The relevant columns: `timeframe`, `seglabel`
`track` and `finalLabel` can be found in the following way:
```Matlab
trackinfo = tablenet(tablenet.track==2,[5 11 13 14]);
```
A selection of the entries of `tablenet` that contain track `2` is already
made. Then, finding the frames to study goes to indexing the new
`trackinfo` variable. In this case, since the tracks spawn from
`t=1`, indexing is straightforward. An example of the first ten entries
of the desired time frames is shown next:
```Matlab
>> trackinfo(418:427,:)

ans =

  10×4 table

    timeframe    seglabel    track    finalLabel
    _________    ________    _____    __________

    418          7           2        2         
    419          7           2        2         
    420          6           2        2         
    421          7           2        2         
    422          6           2        2         
    423          7           2        2         
    424          6           2        2         
    425          6           2        2         
    426          7           2        2         
    427          7           2        2    
```
The `track` and `finalLabel` entries to the table have the same values,
as expected, but the `seglabel` value varies depending on the time frame.
In this simple example, it suffices to delete the entries of
`trackinfo` that will not be used:
```Matlab
 trackinfo(1:417,:)=[];
```
In order to isolate the segmentations of the green channels at the frame
of interest, every column in `trackinfo` corresponds to a parallel array
which can be accessed at the entry `t` when loading a frame.
Such frame `trackinfo.timeframe(ix)` will then have the correct
segmentation label in `trackinfo.seglabel(ix)`.
