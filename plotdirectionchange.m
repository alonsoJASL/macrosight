function plotdirectionchange(anglestats, anglextras, addlegend)
%
if nargin < 3
    addlegend = false;
end
preXY = anglextras.preXY;
postXY = anglextras.postXY;

s = anglextras.s;
c = anglextras.c;

x1 = preXY(1,:);
y1 = postXY(1,:);

qq = preXY - repmat(x1, size(preXY,1),1);
qqq = [-s.*qq(:,2)+c.*qq(:,1) c.*qq(:,2)+s.*qq(:,1)];
qqq = qqq - repmat(qqq(end,:), size(qqq,1),1);

rr = postXY - repmat(y1, size(postXY,1),1);
rrr = [-s.*rr(:,2)+c.*rr(:,1) c.*rr(:,2)+s.*rr(:,1)];

hold on; grid on;
plot(qqq(:,2), qqq(:,1), '--d', ...
    qqq([1 end],2), qqq([1 end],1), 'r-o', ...
    'LineWidt', 2, 'MarkerSize', 7)
plot(rrr(:,2), rrr(:,1), ':*', rrr([1 end], 2), rrr([1 end],1), 'x-g', ...
    'LineWidth', 2, 'MarkerSize', 7)
THX = anglestats.thx;
ra = 0.25.*min(anglestats.bL, anglestats.afL);
if THX>0
    t=0:0.5:THX;
    plot(ra.*cosd(t), ra.*sind(t), 'm', ...
        ra.*cosd(t(end-5)), ra.*sind(t(end-5)),'vm', ...
        'LineWidth', 2, 'MarkerSize', 7)
else
    t=THX:0.5:0;
    plot(ra.*cosd(t), ra.*sind(t), 'm', ...
        ra.*cosd(t(5)), ra.*sind(t(5)),'^m', ...
        'LineWidth', 2, 'MarkerSize', 7)
end

if addlegend==true
legend('Pre-clump','Pre-line', 'Post-clump',  'Post-line',...
    'Change of dir (\theta)', ...
    'Location','southoutside','Orientation','horizontal')
end
%set(gcf, 'Position',[2   562   958   434]);

