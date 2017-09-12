% miniscript to try small code. Its contents shoud change based on the
% context. It is just a way to keep the code neat while doing tests.
%
[newfr] = nextframeevolution(ukfr, kftr, trackinfo, clumplab, acopt);
newrgs = macregionprops(newfr.evomask);

a = 0.05;
b = 0.05;
whichfield = 'Area';

uppbound = kftr.regs.(whichfield)*(1+a);
lowbound = kftr.regs.(whichfield)*(1-b);
badbool = false;

ognewfr = newfr(1);
if newrgs(1).(whichfield) >= uppbound
    acopt = acoptions('shrink');
    fprintf('\n\t %s: New %s too large, OVER %d%% of previous measurement.\n',...
            mfilename, upper(whichfield), a*100);
    badnewfr = newfr;
    [newfr] = nextframeevolution(ukfr, kftr, trackinfo, clumplab, acopt);
    newrgs = macregionprops(newfr.evomask);
    badbool = true;
elseif newrgs(1).(whichfield) <= lowbound
    fprintf('\n\t %s: New %s too small, UNDER %d%% of previous measurement.\n',...
        mfilename, upper(whichfield), b*100);
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
        opt.erodenum = 7;
    case 'grow'
        opt.method = 'Chan-Vese';
        opt.iter = 200;
        opt.smoothf = 1;
        opt.contractionbias = -0.25;
        opt.erodenum = 3;
    case 'nothing'
        opt.method = 'Chan-Vese';
        opt.iter = 50;
        opt.smoothf = 1.5;
        opt.contractionbias = -0.1;
        opt.erodenum = 5;
end
end