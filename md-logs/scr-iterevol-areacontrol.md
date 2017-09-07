# Evolution of shape: Area restrictions and active contours' parameters
This log file is a continuation of the file
[`scr-iteravolution-vs-leaking.md`](./scr-iteravolution-vs-leaking.md).
The focus of this (hopefully small) log file is to address some issues
that occur with the segmentation in the previous file regarding the
shape of the cell being segmented and the control we can **realistically**
have over the MATLAB function `activecontour.m`.

We know about the parameters of `activecontour.m` that can be addressed,
they involve:
+ **Method:** Choose from `'Chan-Vese'` and `'edge'`
+ **Iterations:** How many times the program is run. Typical values used here
are `options.iter=25` and `options.iter=50`.
+ **Smooth Factor:** Parameter that forces the contour to be _soft, smooth
or regular_. Typical values used in this application are
`options.smoothf= 1.5` and `options.smoothf= 2`, when the method used is
`Chan-Vese`.
+ **Contraction Bias:** Is the tendency of the contour to expand or shrink.

This function does not allow a finer control over the parameters, the
evolution or the finer details (restricting size, volume or area of the
contours). 
