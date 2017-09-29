%% INITIALISATION
initscript;
rootdir = handlesdir.pathtodir;
%%
a = dir(fullfile(rootdir,[handlesdir.data '_mat_TRACKS_*']));
a={a.name};
a(contains(a,'NOTHING')) = [];

whichTrackIdx = 8;
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
%%
ixx = find(ismember(frnumbers, 109:208));

T = [];
for whichfr = 1:length(ixx)
    
    fprintf('%s: Loading file:\n %s\n', mfilename,...
        fullfile(rootdir, a{whichTrackIdx}, b{ixx(whichfr)}));
    load(fullfile(rootdir, a{whichTrackIdx}, b{ixx(whichfr)}));
    
    if whichfr <=10
        figure(1)
        subplot(3,10,whichfr)
    else
        figure(2)
        subplot(3,10,whichfr-10)
    end
    plotBoundariesAndPoints(frameinfo.X, frameinfo.initboundy, ...
        frameinfo.outboundy,'m-');
    axis(bbox2axis(frameinfo.regs.BoundingBox));
    title(strcat('Frame Number: ', num2str(frnumbers(ixx(whichfr)))));
    axis off
    
    
    T = [T;struct2table(frameinfo.regs)];
end

figure(1)
subplot(3,10,11:20);
yyaxis left
plot(frnumbers(ixx(1:10)), T.circularity(1:10), '-*'); grid on;
ylabel('Circularity');
yyaxis right
plot(frnumbers(ixx(1:10)), T.EquivDiameter(1:10), '-+'); grid on;
ylabel('Equivalent Diameter');

subplot(3,10,21:30);
plot(frnumbers(ixx(1:10)), T.MinorAxisLength(1:10)./T.MajorAxisLength(1:10), '-*');
ylabel('aspectRatio = minoAxis / majorAxis'); grid on
yyaxis right
plot(frnumbers(ixx(1:10)), T.Solidity(1:10), '-+'); grid on;
ylabel('Solidity');

figure(2)
subplot(3,10,11:20);
yyaxis left
plot(frnumbers(ixx(11:20)), T.circularity(11:20), '-*'); grid on;
ylabel('Circularity');
yyaxis right
plot(frnumbers(ixx(11:20)), T.EquivDiameter(11:20), '-+'); grid on;
ylabel('Equivalent Diameter');

subplot(3,10,21:30);
plot(frnumbers(ixx(11:20)), T.MinorAxisLength(11:20)./T.MajorAxisLength(11:20), '-*');
ylabel('aspectRatio = minoAxis / majorAxis'); grid on;
yyaxis right
plot(frnumbers(ixx(11:20)), T.Solidity(11:20), '-+'); grid on;
ylabel('Solidity');



%%

T=[];
for whichfr = 1:length(bx)
    
    fprintf('%s: Loading file:\n %s\n', mfilename,...
        fullfile(rootdir, a{whichTrackIdx}, b{bx(whichfr)}));
    load(fullfile(rootdir, a{whichTrackIdx}, b{bx(whichfr)}));
    
    
    %subplot(3,10,whichfr-7)
    plotBoundariesAndPoints(frameinfo.X, frameinfo.initboundy, ...
        frameinfo.outboundy,'m-');
    axis(bbox2axis(frameinfo.regs.BoundingBox));
    title(sprintf('Frame Number: %d. - indx: %d',frnumbers(whichfr), whichfr));
    axis off;
    
    pause;
    
    T = [T;struct2table(frameinfo.regs)];
end

%% Load table
T = [];
for whichfr = 1:length(bx)
    
    fprintf('%s: Loading file:\n %s\n', mfilename,...
        fullfile(rootdir, a{whichTrackIdx}, b{bx(whichfr)}));
    load(fullfile(rootdir, a{whichTrackIdx}, b{bx(whichfr)}));
    
    T = [T;struct2table(frameinfo.regs)];
end
%
figure(33)
set(gcf, 'Position', get(0, 'ScreenSize'))
subplot(3,20,21:40);
yyaxis left
plot(frnumbers, T.circularity, '-*'); grid on;
ylabel('Circularity');
yyaxis right
plot(frnumbers, T.EquivDiameter, '-+'); grid on;
ylabel('Equivalent Diameter');
subplot(3,20,41:60);
plot(frnumbers, T.MinorAxisLength./T.MajorAxisLength, '-*');
ylabel('aspectRatio = minoAxis / majorAxis'); grid on;
yyaxis right
plot(frnumbers, T.Solidity, '-+'); grid on;
ylabel('Solidity');

ixx = (1:15:length(frnumbers));
Nixx = length(ixx);

bb = bbox2axis(T(ixx,:).BoundingBox);
bb = [min(bb(:,1)) max(bb(:,2)) min(bb(:,3)) max(bb(:,4))];
for whichfr = 1:Nixx
    
    fprintf('%s: Loading file:\n %s\n', mfilename,...
        fullfile(rootdir, a{whichTrackIdx}, b{ixx(whichfr)}));
    load(fullfile(rootdir, a{whichTrackIdx}, b{ixx(whichfr)}));
    
    figure(33)
    subplot(3,Nixx,whichfr)
    
    plotBoundariesAndPoints(frameinfo.X, frameinfo.initboundy, ...
        frameinfo.outboundy,'m-');
    %axis image;
    axis(bb);
    title(sprintf('tk = %d', frnumbers(ixx(whichfr))));
    axis off
end

subplot(3,Nixx,((1:Nixx)+Nixx));
hold on
yyaxis left
plot(frnumbers(ixx), T.circularity(ixx), 'bo:'); grid on;
ylabel('Circularity');
yyaxis right
plot(frnumbers(ixx), T.EquivDiameter(ixx), 'kd:'); grid on;
ylabel('Equivalent Diameter');
subplot(3,Nixx,((1:Nixx)+2*Nixx));
hold on
yyaxis left
plot(frnumbers(ixx),...
    T.MinorAxisLength(ixx)./T.MajorAxisLength(ixx), 'bo:');
ylabel('aspectRatio = minorAxis / majorAxis'); grid on;
yyaxis right
plot(frnumbers(ixx), T.Solidity(ixx), 'kd:'); grid on;
ylabel('Solidity');
