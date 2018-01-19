# Movement and interactions of macrophages
This file follows the development of the script
[scr_movementandinteractions.m](../scr_movementandinteractions.m).
In this work, an analysis of the movement of the nuclei in the
**RED** channel will be made, focusing on the interactions that
happen before and after a couple of cells leave a clump.

This log will follow the development of the code. The overall flow
of the work should:
+ Initialise: through [initscript.m](../initscript.m) and by
  choosing a clump `whichclump`.
+ Choose the entries in `tablenet` that contain the tracks in
  `whichclump`. Get them into variable `trackinfo`.
+ Evaluate the tracks and choose an appropriate segment of the
  dataset that shows the cells before and after the clump.
+ Analyse the mean velocity before and after a certain amount of
  frames (10?, 100?, ...)
+ Analyse the direction before and after the clump.

## Exploration of the data
### Visualisation
Several qualitative tests have been carried out in order to determine the
best course of action for the automated analysis.
Function [`plotframeandpoint.m`](../plotframeandpoint.m) was developed
to show a frame, with the overlapping and non-overlapping cells, while
displaying a set of points of interest.

![visualisation-1](../figs/visualisation-log1.png)

### Velocity of nuclei inside and outside of clumps
A small test can be made to find out the velocity of nuclei within clumps
in variable `velclumps` and outside of them using variable `velsingles`.
This can be done through `tablenet` and `clumptracktable` in the following
way:
```Matlab
velsingles = tablenet(clumptracktable.clumpcode==0,:).velocity;
velclumps = tablenet(clumptracktable.clumpcode~=0,:).velocity;
```

| `mean(velclumps) +/- (std)` | `mean(velsingles) +/- (std)` |
|:-----------------:|:------------------:|
| 1.6115 +/- (1.3981) | 2.1671 +/- (1.6470) |

A brief analysis was made to see if the difference between both states
(clump and single) was significant for the mean velocity of the nuclei.
The analysis used `signrank` and it shows that the hypothesis of
`velclumps - velsingles` having zero median cannot be rejected.
