function [opt] = acoptions(actype)
% ACTIVE CONTOUR OPTIONS. For easy initialisation. 
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