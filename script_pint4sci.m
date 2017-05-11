% script file: figures for pint4sci
%

[dn,ds] = loadnames('macros',chooseplatform);
[X, xatt] = readParseSome(fullfile(dn,ds), (45:10:185));

%%
figure(1)
for ix =1:size(X,4)
    subplot(3,5,ix);
    imagesc(X(:,:,:,ix));
    axis image;
end

%%
X1 = X(:,:,:,7);
figure(2)
clf
imagesc(X1);
axis image;

%%
x = [250 427 375 150];
y = [160 300 100 150];

indx = sort(randi(size(X,4),1,3));

clf
az = -25;
el = 60;

for jx=1:1
    [cx,cy,c] = improfile(X(:,:,:,indx(jx)), x,y);
      
    figure(30+jx)
    plot3(cx,cy, c(:,:,1), '-r', ...
        cx,cy, c(:,:,2), '-g', ...
        cx,cy, c(:,:,3), '-k',...
        'LineWidth', 3);
    axis([1 size(X,2) 1 size(X,1) 0 1]);
    axis ij;
    
    grid on;
    [XX, YY] = meshgrid((1:size(X,2)),(1:size(X,1)));
    [ZZ] = ones(size(X,1), size(X,2));
    view(0,10)
    hold on
    surf(XX, YY, 0.015.*ZZ, X1, 'edgecolor', 'none')
    alpha(0.85);
    hold off
end
pause; 

[az,el] = view;
%%

xx = (0:360) + az;
yy = fix(22.5.*sind(xx))+ el;

f = getframe(gcf);
[im,map] = rgb2ind(f.cdata,256,'nodither');
%
im(1,1,1,length(xx)) = 0;
%
for j=1:length(xx)
    view(xx(j),yy(j));
    set(gca,'box','off');
    set(gcf,'color','w');
    f = getframe(gcf);
    im(:,:,1,j) = rgb2ind(f.cdata,map,'nodither');
    %pause(0.01);
end
imwrite(im,map,'pint4sci-improfile.gif',...
    'DelayTime',0,'LoopCount',inf);

