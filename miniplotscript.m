% miniscript to try plots that are not necessary to the flow of the code. 
% Its contents shoud change based on the context. 
% It is just a way to keep the code neat while doing tests.
%

ogar(tkp1) = kftr.regs.Area;
ogcirc(tkp1) = kftr.regs.circularity;

if debugvar == true
    f11=figure(11);
    subplot(2,4,[1 2 5 6])
    plotBoundariesAndPoints(ukfr.X, newfr.movedboundy, newfr.evoshape, 'c-');
    title(sprintf('Frame %d', frametplusT));
    if ukfr.hasclump == true
        plotBoundariesAndPoints([],[],bwboundaries(ukfr.thisclump), ':y');
    end
    if badbool == true
        ogregs = macregionprops(ognewfr.evomask);
        ar(tkp1) = ogregs.Area;
        circ(tkp1) = ogregs.circularity;
        plotBoundariesAndPoints([],[],ognewfr.evoshape, ':r');
    end
    
    subplot(2,4,[3 4])
    plot(trackinfo.timeframe, ogar, '-d',trackinfo.timeframe, ar,':.');
    axis tight
    title('Area')
    subplot(2,4,[7 8])
    plot(trackinfo.timeframe, ogcirc, '-d',trackinfo.timeframe, circ,':.');
    axis tight
    title('Circularity')
    
end
