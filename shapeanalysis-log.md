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
t = 1;
framet = clumpnucleirange(t);
frametplusT = clumpnucleirange(t+1);
  ```
The information is then accessed via the filename stored in cell variable
 `filenames{framet}`.

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
  Notice that the generation of `sf, cf` only differ in the name of the
  structure variables. Also, do not forget to clear the helper variables
  used with the `getdatafromhandles.m` function: 
  ```Matlab
  clear dataL dataGL clumphandles dataR dataGR
  ```
  A future version of this code should incorporate all this processing into
  function `getdatafromhandles.m`, to make scripts cleaner.
#### Populate `sf` and `cf` with important information
Information that will be included:
+ Original image `X`
```Matlab
sf.X = cat(3, sf.dataR, sf.dataGR, zeros(size(sf.dataR)));
cf.X = cat(3, cf.dataR, cf.dataGR, zeros(size(cf.dataR)));
```
+ Binary object properties from `regionprops`, and boundaries for single cells
detected on `framet`.
```Matlab
cf.regs = regionprops(cf.clumphandles.overlappingClumps==10);
for jx=1:length(clumplab)
    auxbinmat = sf.clumphandles.nonOverlappingClumps==clumplab(1);
    sf.regs(jx) = regionprops(auxbinmat);
    sf.boundy{jx} = bwboundaries(auxbinmat);
end
```
+ On `cf`, include the clump that is currently being worked on:
```Matlab
cf.thisclump = cf.clumphandles.overlappingClumps==10;
```
## Follow independent cells with a cross correlation
In order to keep the size of the images and make localisation easier, the
function `imfilter` will be used instead of `xcorr2`.
+ Get initial position
```Matlab
for kx=1:length(clumplab)
    testImage = imfilter(sf.dataGR, imcrop(sf.dataGR, sf.regs(kx).BoundingBox));
    [maxval, mxidx] = max(testImage(:));
    [yinit, xinit] = ind2sub(size(sf.dataGR), mxidx);
    sf.xy(kx,:) = [yinit xinit];
end
clear testImage maxval mxidx yinit xinit;
```
Check the initial position of the points using function
```Matlab
plotBoundariesAndPoints(sf.X, [],sf.xy)
```
+ Get the maximum position on `frametplusT` with the information of the
independent cell in `framet`:
```Matlab
for kx=1:length(clumplab)
    testImage = imfilter(cf.dataGR.*cf.thisclump, imcrop(sf.dataGR, sf.regs(kx).BoundingBox));
    [maxval, mxidx] = max(testImage(:));
    [yinit, xinit] = ind2sub(size(sf.dataGR), mxidx);
    cf.xy(kx,:) = [yinit xinit];
end
clear testImage maxval mxidx yinit xinit;
```
+ Move the boundaries from the independent cell in `sf.boundy` using the
movement from the cross correlation:
```Matlab
for kx=1:length(clumplab)
    cf.movedboundy{kx} = sf.boundy{kx} + ...
        repmat(cf.xy(kx,:)-sf.xy(kx,:), size(sf.boundy{kx},1),1);
end
```
+ The moved boundaries in `cf.movedboundy` will be used as initialised points
for the **SOM** or **ASM**. This can be accessed [here](./shapeandsom.md).
## Some plots
```Matlab
figure(1)
clf
plotTracks(handles,2,clumplab);
title(sprintf('Nuclei that belong to clump %d, moving through time.', wuc));
```
```Matlab
figure(2)
plotBoundariesAndPoints(cf.dataGL, sf.boundy, cf.movedboundy, 'm-')
hold on
rectangle('Position', minibb);
title('Moved boundary');
```
