# Evolution of shape from cross correlation following
This log file explains the development of the
[`script_evolveshape`](../script_evolveshape.m) script file.
## Initialisation
The script is initialised by running the [single shape](../script_singleshape.m)
script

Alternatively, if the data is known and has been saved, the user could run
the code:
```Matlab
initscript;
foldername = 'PATH/TO/DATA_mat_XCORR';
experimentName = 'clump8002-tr2.mat';

load(fullfile(foldername, experimentName));
```
### Variables loaded into the workspace.
The variables loaded to the workspace are:
+ `trackinfo`. Contains all the information of the numebr of frames, track
labels and segmentation labels.
+ `knownfr` and `ukfr`, which contain the **known and unknown frames** that
will be analysed.

_One must be really careful when loading these experiments, since the files
tend to get really big (over 2GB for a subset of 80 images). Also, be sure
to be using MATLAB's MAT file storing v7.3 or higher._

## Evolution of shapes (in general)
The evolution of shapes will follow a similar workflow as the file
[`script_shapeandsom.m`](../script_shapeandsom.m), since that is the original
attempt to follow a shape with cross correlation and the evolving it. In this
work, the steps before evolving a shape will be more generic, so that more
techniques can be applied.

The workflow for the evolution is 
