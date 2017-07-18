#Self Organising Maps (SOMs) log file
This document describes the script `script_shapeandsom.m` inside this package.
It derives some of its development from the `script_shapeanalysis.m`
[script](./shapeanalysis.md).
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
## A better way of evolving the SOMs
Using matlab's functions, we can guarantee to start at a network evolution from
the single frame, `sf`, that is perfectly matched to the binary segmentation of
the independent cells.
```Matlab
netsize = [8 8];
ognet = selforgmap(netsize);
ognet.trainParam.showWindow=0;
ognet.trainParam.epochs = 200;

% Create the corresponding bounding boxes
for kx=1:length(clumplab)
    % Get the input data from the binary image
    sf.bintensities{kx} = sf.dataGL==clumplab(kx);
    [sf.binput{kx}] = somGetInputData(sf.bintensities{kx});
    [sf.net{kx}] = train(ognet,sf.binput{kx}');
    sf.netpos = sf.net{kx}.IW{1};

    cf.OG{kx} = somBasicNetworks('supergrid', netsize, sf.netpos);
end
clear kx uxuy wxy;
```
+ From here, the networks would need to be moved based on the cross correlation
**movement vectors**.
+ Then, a simultaneous evolution of both SOMs could be fitted to the new data.
  + _An assumption is made here, that the slow movement of the cells would prevent an ambiguity or confusion between the networks._
  + _Because of the previous statement, there is room for two tests_
    1. Change `sf` and `cf` with time, so that `sf` always corresponds to `t`
    and `cf` corresponds to `t+1`.
    2. The other is to fix `sf` to frame `t` and move `cf` to frames `t+t0`
## Evolve the SOM to fit the binary cells in `sf`
+ First, create the parameters in the network, this involves

## Move points over to position in frame `frametplusT`

## Evolve to new frame
