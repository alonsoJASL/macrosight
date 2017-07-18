% Script file: SHAPE AND SOM
%
% 
%% INITIALISATION 
script_shapeanalysis;

%% SOM initialisation 
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

% FROM HERE...
% a good idea would be to evolve both networks simultaneously... 

%% Matlab's SOM implementation
kx = 1;
ognet = selforgmap([10 10]);
ognet.trainParam.showWindow=0;

% Train the Network
[sf.net{kx},tr] = train(ognet,sf.binput{kx}');
cf.OG{kx} = somBasicNetworks('supergrid', [10 10], sf.net{kx}.IW{1});

%% Initial network evolution on sf (single frame)

kx=1;
sf.options(kx).maxiter = 1000;
sf.options(kx).alphazero = 0.25;
sf.options(kx).alphadtype = 'linear';
sf.options(kx).N0 = 5;
sf.options(kx).ndtype = 'exp2';
sf.options(kx).debugvar = false;

% Note how the output of this SOM is the input for next frame!
[cf.OG{kx}, sf.nethandles(kx)] = somTraining(sf.binput{kx}, sf.OG{kx}, ...
    sf.options(kx));