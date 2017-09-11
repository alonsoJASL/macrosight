% miniscript to try small code. Its contents shoud change based on the
% context. It is just a way to keep the code neat while doing tests.
%
[newfr] = nextframeevolution(ukfr, kftr, trackinfo, clumplab, acopt);
newrgs = macregionprops(newfr.evomask);

a = 0.07;
b = 0.07;
uppbound = kftr.regs.Area*(1+a);
lowbound = kftr.regs.Area*(1-b);
badbool = false;

if newrgs.Area >= uppbound
    fprintf('\n\t %s: New area too large, OVER %d%% of previous Area.\n',...
        mfilename, a*100);
    acopt = acoptions('shrink'); 
    badnewfr = newfr;
    [newfr] = nextframeevolution(ukfr, kftr, trackinfo, clumplab, acopt);
    newrgs = macregionprops(newfr.evomask);
    badbool = true;
elseif newrgs.Area <= lowbound
    fprintf('\n\t %s: New area too small, UNDER %d%% of previous Area.\n',...
        mfilename,b*100);
    acopt = acoptions('grow'); 
    badnewfr = newfr;
    [newfr] = nextframeevolution(ukfr, kftr, trackinfo, clumplab, acopt);
    newrgs = macregionprops(newfr.evomask);
    badbool = true;
else
    fprintf('\n\t %s: ALL GOOD MAN!.\n',...
        mfilename);
    acopt = acoptions('nothing'); 
    badbool = false;
    [newfr] = nextframeevolution(ukfr, kftr, trackinfo, clumplab, acopt);
    newrgs = macregionprops(newfr.evomask);
end

function [opt] = acoptions(actype)
%
switch actype
    case 'shrink'
        opt.method = 'Chan-Vese';
        opt.iter = 100;
        opt.smoothf = 1.25;
        opt.contractionbias = 0.1;
        opt.erodenum = 5;
    case 'grow'
        opt.method = 'Chan-Vese';
        opt.iter = 200;
        opt.smoothf = 1;
        opt.contractionbias = -0.25;
        opt.erodenum = 5;
    case 'nothing'
        opt.method = 'Chan-Vese';
        opt.iter = 50;
        opt.smoothf = 1.5;
        opt.contractionbias = -0.1;
        opt.erodenum = 3;
end
end