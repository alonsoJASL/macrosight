# Shape analysis log
This document describes the script `script_shapeanalysis.m`, which focuses in
the analysis of the shape of the independently detected cells into the
disambiguation of the clumps detected in different frames.

The first step is the call to the script `initscript.m` which does a number
of things:
+ Loads the folder name structure from the `/MACROPHAGES` folder, whether it
is from the first (`/MACROPHAGES/MACROS1`), second or third dataset.
+ If no processing has been done on it, then the right functions are called
and the `_mat_` folders are created and filled.
+ If all the `_mat_` folders are found, then a quick check is made to the
folders' paths to see if they are consistent with the actual names. This is
helpful when working between OS.
+ Load all relevant variables:
  + From the `handles` structure, the clump-development is built (or loaded).
The following variables are created:
    + `clumptracktable`
    + `clumpidcodes`
    + `timedfinalnetwork`
    + `tablenet`

## Select a clump by its unique label.
The next step involves choosing the uniquely identifiable clump from the table
`clumpidcodes`, called `wuc=clumpincodes(ix)`, where *wuc* refers to *Which Unique
Clump*. Then the next code is run:
```Matlab
ix=10;
wuc = clumpidcodes(ix);
labelsinclump = getlabelsfromcode(wuc);
```
Then we get the clump *life cycle* (`timeofclump`) and the extension of one
frame before and one frame after, to have the frames where the clump was not
yet formed, or has ceased to exist:
```Matlab
timeofclump = unique(tablenet(clumptracktable.clumpcode==wuc,:).timeframe);
clumpnucleirange = (timeofclump(1)-1):(timeofclump(end)+1);
tabletracks = tablenet(ismember(tablenet.timeframe, clumpnucleirange),:);
tableclump = clumptracktable(ismember(tablenet.timeframe, clumpnucleirange),:);
```
## Analyse the frames before and after the clump is formed
#### Select the frames that will have the analysis.
First of all, select the names of the files involved:
  ```Matlab
  singleframe = filenames(clumpnucleirange(1));
  clumpframe = filenames(clumpnucleirange(2));  
  ```
#### Then, load the data
Use `getdatafromhandles`, and to deal with less variables in the code, package
them into structures. We do the single frame, `sf`, structure first:
  ```Matlab
  [dataL, dataGL, clumphandles, dataR, dataGR] = ...
              getdatafromhandles(handles, singleframe);
  % sf := single frame
  sf.dataL = dataL;
  sf.dataGL = dataGL;
  sf.clumphandles = clumphandles;
  sf.dataR = dataR;
  sf.dataGR = dataGR;
  ```
Next, do the frame with a clump, `cf`, structure:
  ```Matlab
  [dataL, dataGL, clumphandles, dataR, dataGR] = ...
              getdatafromhandles(handles, clumpframe);
  % cf := clump frame
  sf.dataL = dataL;
  sf.dataGL = dataGL;
  sf.clumphandles = clumphandles;
  sf.dataR = dataR;
  sf.dataGR = dataGR;
  ```
  Notice that the generation of `sf, cf` only differ in the name of the structure
  variables. Also, do not forget to clear the helper variables used with the
  `getdatafromhandles.m` function:
  ```Matlab
  clear dataL dataGL clumphandles dataR dataGR
  ```
#### Populate `sf` and `cf` with important information
Information that will be included:
+ Original image `X`
+ labels from `labelsinclump`
+ Bounding boxes from `regionprops`
+ Boundaries from `bwboundaries`

## Follow independent cells with a cross correlation
In order to keep the size of the images and make localisation easier, the
function `imfilter` will be used instead of `xcorr2`.
+ Get initial position
```Matlab
testImage = imfilter(sf.dataGL, imcrop(sf.dataGL, sf.regs.BoundingBox));
[maxval, mxidx] = max(testImage(:));
[xx, yy] = ind2sub(mxidx);
```

## Interesting plots
