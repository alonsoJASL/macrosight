% Script file: EVOLVE THE SHAPE from a XCORR position following
%
%% INITIALISATION
script_singleshape;
knownfr = kanduk.knownfr;
ukfr = kanduk.ukfr;
trackinfo = kanduk.trackinfo;

clear kanduk;
%% 
ix =1; % this value comes from script_singleshape
jx = 8;
oneuk = ukfr(jx);

% SOM
% for the input data, I have to use the known frame information or
% the clump info.
mask = bb2mask(oneuk.movedbb, handles.rows, handles.cols);
nuclei = oneuk.dataL==trackinfo.seglabel(ix+jx);
mask = mask-bitand(mask, nuclei);

intensities = oneuk.dataGR.*mask;
oneindata = somGetInputData(intensities, oneuk.X);

incr = 8;

pos = oneuk.movedboundy(1:incr:end,2:-1:1);
netsize = size(pos,1);
oneuk.OG =  somBasicNetworks('circle', netsize, pos);

somopt.maxiter = 500;
somopt.alphazero = 0.25;
somopt.alphadtype = 'none';
somopt.N0 = 5;
somopt.ndtype = 'exp2';
somopt.debugvar = false;
somopt.steptype = 'intensity';
somopt.gifname = [];
somopt.incr = incr;

[oneuk.G, oneuk.nethandles] = somTrainingPlus(oneindata, oneuk.OG, somopt);

disp(struc2markdown(somopt, [1 2 3 4 5 7 9]));
figure(43)
clf
plotGraphonImage(oneuk.X, oneuk.OG)
plotGraphonImage([], oneuk.G)
legend('Original network', 'Evolved shape')
axis([362.0484  436.3710   95.2872  249.0364])