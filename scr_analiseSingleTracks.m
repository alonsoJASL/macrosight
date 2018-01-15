%% INITIALISATION
initscript;

whichtrack = 8;
loadtrackscript;
%%

subidx = 420:470;
b(~ismember(frnumbers, subidx)) = [];
bx(~ismember(frnumbers, subidx)) = [];
frnumbers(~ismember(frnumbers, subidx)) = [];


%% 
arrangetracktablescript;

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

%%
close all

ixx = fix(linspace(1,length(bx),8));
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
    %plotBoundariesAndPoints([],[],cornies{ixx(whichfr)},'y*');
    plotBoundariesAndPoints([], [], T.rCentroid,'y-');
    plotBoundariesAndPoints([], [], T.rCentroid(ixx(whichfr),:),'yx');
    plotBoundariesAndPoints([], [], T.gCentroid(ixx(whichfr),:),'g+');
    axis square

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
    Vtxt = 'aspect ratio';
else
    V = T.(str);
    Vtxt = str;
end
end
