function plotRedAndGreenChannels(framestruc)
%

clf;

cmapr = [sort(rand(254,1)) zeros(254,1) zeros(254,1)];
cmapr = [0 0 0; cmapr];
cmapgr = [zeros(254,1) sort(rand(254,1)) zeros(254,1)];
cmapgr = [0 0 0; cmapgr];

subplot(2,3,[1 2 4 5])
macrophagesc(framestruc.X);
axis image
sp1 = subplot(2,3,3);
macrophagesc(framestruc.dataR);
sp2 = subplot(2,3,6);
macrophagesc(framestruc.dataGR);

set(gcf, 'position', [72 263 1453 692]);
tightfig;
set(gcf, 'position', [72 263 1453 692]);

set(sp2,'Colormap',cmapgr);
set(sp1,'Colormap',cmapr);
