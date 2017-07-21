% Script file: SHAPE AND SOM
%
% 
%% INITIALISATION 
script_shapeanalysis;

%% SOM initialisation 
netsize = [8 8];
ognet = selforgmap(netsize);
ognet.trainParam.showWindow=0;
ognet.trainParam.epochs = 150;

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

kx=1;
[cf.binput{kx}] = somGetInputData(cf.thisclump, cf.X);

cf.options.maxiter = 10;
cf.options.alphazero = 0.125;
cf.options.alphadtype = 'linear';
cf.options.N0 = 3;
cf.options.ndtype = 'exp2';
cf.options.debugvar = true;
cf.options.steptype = 'intensity';

% Note how the output of this SOM is the input for next frame!  somTrainingPlus(inputData, initnetwork, options)
[cf.G{kx}, cf.nethandles(kx)] = somTrainingPlus(cf.binput{kx}, cf.OG{kx}, ...
    cf.options);