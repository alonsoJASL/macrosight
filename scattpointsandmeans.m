function scattpoinstandmeans(ptscirc, circ)
marksize = 15;
scatter(ptscirc(:,1), ptscirc(:,2), marksize,'.', 'linewidth', 2);
hold on
scatter(circ(:,1), circ(:,2), 4*marksize,'dk', 'linewidth', 2);
grid on
end