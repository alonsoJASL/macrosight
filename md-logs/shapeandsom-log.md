# Self Organising Maps (SOMs) log file
This document describes the script `script_shapeandsom.m` inside this package.
It derives some of its development from the file 
[`script_shapeanalysis.m`](./shapeanalysis-log.md).
## Initialising the SOM network
+ Use `somGetInputData` to get some input data.
```Matlab
kx = 1;
sf.bintensities{kx} = sf.dataGL==clumplab(kx);
[sf.binput{kx}] = somGetInputData(sf.bintensities{kx});
```
+ Bounding box for box inside cells. Define this into the same `sf` structure,
and do it for each nuclei inside the
```Matlab
for kx=1:length(clumplab)
    uxuy = sf.regs(kx).Centroid - sf.regs(kx).EquivDiameter/4;
    wxy = sf.regs(kx).EquivDiameter/2;
    sf.sombb(kx,:) = [uxuy wxy wxy];
end
```
+ Define the structure of the network
```Matlab
sf.netpos = somGetNetworkPositions('supergrid',[10 10], sf.sombb(kx,:));
```
+ Finally, define the network itself:
```Matlab
OG = somBasicNetworks('supergrid', [10 10], sf.netpos);
```
The separation in this document is intended for explanation purposes. In
reality, the wehole processing is made inside the same loop.
```Matlab
for kx=1:length(clumplab)
    % Get the input data from the binary image
    sf.bintensities{kx} = sf.dataGL==clumplab(kx);
    [sf.binput{kx}] = somGetInputData(sf.bintensities{kx});

    uxuy = sf.regs(kx).Centroid - sf.regs(kx).EquivDiameter/4;
    wxy = sf.regs(kx).EquivDiameter/2;
    sf.sombb(kx,:) = [uxuy wxy wxy];

    sf.netpos{kx} = somGetNetworkPositions('supergrid',[10 10], sf.sombb(kx,:));

    sf.OG{kx} = somBasicNetworks('supergrid', [10 10], sf.netpos{kx});
end
clear kx uxuy wxy;
```
## Evolve the SOM to fit the binary cells in `sf`
Using matlab's functions, we can guarantee to start at a network
evolution from the single frame, `sf`, that is perfectly matched to
the binary segmentation of the independent cells.
```Matlab
netsize = [8 8];
ognet = selforgmap(netsize);
ognet.trainParam.showWindow=0;
ognet.trainParam.epochs = 200;

% Create the corresponding bounding boxes
fprintf('\n%s: Getting initial SOMs by fitting them to sf.\n', mfilename);
for kx=1:length(clumplab)
    % Get the input data from the binary image
    sf.bintensities{kx} = sf.dataGL==clumplab(kx);
    [sf.binput{kx}] = somGetInputData(sf.bintensities{kx});
    [sf.net{kx}] = train(ognet,sf.binput{kx}');
    sfpos = sf.net{kx}.IW{1};
    cfpos = sfpos + repmat(cf.xy(kx,:)-sf.xy(kx,:), size(sfpos,1),1);

    cf.OG{kx} = somBasicNetworks('supergrid', netsize, cfpos);
end
fprintf('%s: Initialisation of SOM finished.\n', mfilename);
clear kx uxuy wxy netpos cfpos;
```
+ From here, the networks would need to be moved based on the cross correlation
**movement vectors**.
+ Then, a simultaneous evolution of both SOMs could be fitted to the new data.
  + _An assumption is made here, that the slow movement of the cells would prevent an ambiguity or confusion between the networks._
+ Because of the previous statement, there is room for two tests.
    1. Change `sf` and `cf` with time, so that `sf` always corresponds to `t`
    and `cf` corresponds to `t+1`.
    2. The other is to fix `sf` to frame `t` and move `cf` to frames `t+t0`

Now, some plots:
```Matlab
% plot the images and both 'moved' SOM points.
plotGraphonImage(cf.dataGL, cf.OG{2})
plotGraphonImage([], cf.OG{1})
% plot original and moved boundaries for all cells.
plotBoundariesAndPoints([],sf.boundy{1}, sf.boundy{2}, 'c-')
plotBoundariesAndPoints([],[], cf.movedboundy{1}, 'm-')
plotBoundariesAndPoints([],[], cf.movedboundy{2}, 'g-')
```
### Move points over to position in frame `frametplusT`
This step was performed in the previous section, by taking the auxiliary variables `sfpos` and `cfpos` to get the positions from the MATLAB-trained
network and traspose them into the new initial position determined by
the [cross correlation](./shapeanalysis-log.md).
### Evolve to new frame
There are two possibilities for the implementation

Two possibilities:
+ Evolve, by using the clump at `cf`.
+ Evolve by using the intensities and the clump, like
`cf.thisclump.*cf.dataGR`
  + This involves trying the SOM with intensities when initialising
  from `sf`.
