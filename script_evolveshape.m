% Script file: EVOLVE THE SHAPE from a XCORR position following
%
%% INITIALISATION
script_singleshape;

knownfr = kanduk.knownfr;
ukfr = kanduk.ukfr;
trackinfo = kanduk.trackinfo;

clear kanduk;


%% SOM

ix =1; % this value comes from script_singleshape
jx = 8;
oneuk = ukfr(jx);
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

%% ACTIVE CONTOURs

ix =1; % this value comes from script_singleshape
jx = 2;
oneuk = ukfr(jx);

oneuk.movedmask = poly2mask(...
    oneuk.movedboundy(:,2), oneuk.movedboundy(:,1),...
    handles.rows, handles.cols);

acopt.framesAhead = jx;
acopt.method = 'Chan-Vese';
acopt.iter = 100;
acopt.smoothf = 2;
acopt.contractionbias = 0;

BW1 = activecontour(oneuk.dataGR, oneuk.movedmask, acopt.iter, ...
    acopt.method, 'ContractionBias',acopt.contractionbias,...
    'SmoothFactor', acopt.smoothf);

% MANY
if true
    % switch to true to show images
    disp(struc2markdown(acopt));
    subplot(2,4,(jx))
    plotBoundariesAndPoints(oneuk.X, oneuk.movedboundy, ...
        bwboundaries(BW1), 'm-');
    axis image
    %axis([314.2098  507.0632  101.2963  248.2321]); % for jx=8
    %axis([297.0161  546.3065  108.7216  308.7449]); % for all frames jx=1:8
    % axis([367.5890  527.0729   83.3455  234.1093]); % for all frames jx=17:24
    axis([244.3710  393.0161  268.4417  365.4679]); % track 8, jx=1:8
    title(sprintf('Known frame: %d / Unknown frame: %d (t+t0=%d+%d)',...
        ix,jx,ix,jx));
    legend('Initialisation', 'boundary starting point', ...
        'After active contours');
end