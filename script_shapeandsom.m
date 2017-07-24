% Script file: SHAPE AND SOM
%
% 
%% INITIALISATION 
script_shapeanalysis;

%% SOM initialisation 
netsize = [10 10];
%ognet.trainFcn = 'trainru';
ognet = selforgmap(netsize);
ognet.trainParam.showWindow=0;
ognet.trainParam.epochs = 200;

% Create the corresponding bounding boxes
fprintf('\n%s: Getting initial SOMs by fitting them to sf.\n', mfilename);
for kx=1:length(clumplab)
    % Get the input data from the binary image
    sf.bintensities{kx} = sf.dataGL==clumplab(kx);
    %[sf.binput{kx}] = somGetInputData(sf.bintensities{kx});
    [sf.binput{kx}] = somGetInputData(sf.bintensities{kx}, sf.X);
    [sf.net{kx}] = train(ognet,sf.binput{kx}');
    sfpos = sf.net{kx}.IW{1}(:,1:2);
    cf.pos{kx} = sfpos + repmat(cf.xy(kx,2:-1:1)-sf.xy(kx,2:-1:1), size(sfpos,1),1);
    
    cf.OG{kx} = somBasicNetworks('supergrid', netsize, cf.pos{kx});
end
fprintf('%s: Initialisation of SOM finished.\n', mfilename);
clear kx uxuy wxy netpos sfpos;
%% Initial network evolution on sf (single frame)

cf.options.maxiter = 25;
cf.options.alphazero = 0.125;
cf.options.alphadtype = 'none';
cf.options.N0 = 3;
cf.options.ndtype = 'exp2';
cf.options.debugvar = false;
cf.options.steptype = 'intensity';
cf.options.gifname = [];

for kx=1:length(clumplab)
    [cf.binput{kx}] = somGetInputData(cf.thisclump, cf.X);
    % Note how the output of this SOM is the input for next frame!  somTrainingPlus(inputData, initnetwork, options)
    [cf.G{kx}, cf.nethandles(kx)] = somTrainingPlus(cf.binput{kx}, cf.OG{kx}, ...
        cf.options);
end