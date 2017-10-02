%% INITIALISATION
initscript;
rootdir = handlesdir.pathtodir;

a = dir(fullfile(rootdir,[handlesdir.data '_mat_TRACKS_*']));
a={a.name};
a(contains(a,'NOTHING')) = [];
%%
whichtrack = 8;

whichTrackIdx = find(contains(a, sprintf('lab%d-', whichtrack)));
b = dir(fullfile(rootdir, a{whichTrackIdx}, '*.mat'));
b={b.name};
vect = zeros(length(b),1);
for ix=1:length(b)
    c = b{ix}(end-6:end-4);
    d = str2num(c);
    jx=1;
    while isempty(d)
        jx=jx+1;
        d=str2num(c(jx:end));
    end
    vect(ix) = d;
end
clear ix jx c d;

[frnumbers, bx] = sort(vect);
b = b(bx);

%% VISUALISE TRACK 
for whichfr = 1:length(bx)
    
    fprintf('%s: Loading file:\n %s\n', mfilename,...
        fullfile(rootdir, a{whichTrackIdx}, b{whichfr}));
    load(fullfile(rootdir, a{whichTrackIdx}, b{whichfr}));
    
    plotBoundariesAndPoints(frameinfo.X, frameinfo.initboundy, ...
        frameinfo.outboundy,'m-');
    axis(bbox2axis(frameinfo.regs.BoundingBox));
    title(sprintf('Frame Number: %d. - indx: %d',frnumbers(whichfr), whichfr));
    axis off;
    
    pause(0.2);
end

%% PLOT RESULTS

T = [];
for whichfr = 1:length(bx)
    %fprintf('%s: Loading file:\n %s\n', mfilename, fullfile(rootdir, a{whichTrackIdx}, b{whichfr}));
    load(fullfile(rootdir, a{whichTrackIdx}, b{whichfr}));
    
    T = [T;struct2table(frameinfo.regs)];
end

% what to plot
[m1.yleft, m1.lableft] = getvectorandtext(T, 'Orientation');
[m1.yright, m1.labright] = getvectorandtext(T, 'AspectRatio');
[m2.yleft, m2.lableft] = getvectorandtext(T,'Solidity');
[m2.yright, m2.labright] = getvectorandtext(T,'EquivDiameter');

%%
close all

ixx = (15:25:length(frnumbers));
Nixx = length(ixx);

f33=figure(33);
set(gcf, 'Position', get(0, 'ScreenSize'))
subplot(3,Nixx,((1:Nixx)+Nixx));
plotleftright(frnumbers, m1);

subplot(3,Nixx,((1:Nixx)+2*Nixx));
plotleftright(frnumbers, m2);

%
bb = bbox2axis(T(ixx,:).BoundingBox);
bb = [min(bb(:,1)) max(bb(:,2)) min(bb(:,3)) max(bb(:,4))];
for whichfr = 1:Nixx
    load(fullfile(rootdir, a{whichTrackIdx}, b{ixx(whichfr)}));
    
    figure(33)
    subplot(3,Nixx,whichfr)
    
    plotBoundariesAndPoints(frameinfo.X, frameinfo.initboundy, ...
        frameinfo.outboundy,'m-');

    axis(bb);
    title(sprintf('tk = %d', frnumbers(ixx(whichfr))));
    axis off
end


m1p = m1; m1p.yleft = m1p.yleft(ixx); m1p.yright = m1p.yright(ixx); 
m1p.linl = 'bo'; m1p.linr = 'kd';

m2p = m2; m2p.yleft = m2p.yleft(ixx); m2p.yright = m2p.yright(ixx);
m2p.linl = 'bo'; m2p.linr = 'kd';

%
subplot(3,Nixx,((1:Nixx)+Nixx));
hold on
plotleftright(frnumbers(ixx), m1p);
subplot(3,Nixx,((1:Nixx)+2*Nixx));
hold on
plotleftright(frnumbers(ixx), m2p);


function [V, Vtxt] = getvectorandtext(T, str)
% 
if strcmpi(str, 'aspectratio')
    V = T.MinorAxisLength ./ T.MajorAxisLength;
    Vtxt = 'aspectRatio = minorAxis / majorAxis';
else
    V = T.(str);
    Vtxt = str;
end
end
