% ARRANGE TRACK TABLE
%
try
    T = [];
    gCentroid = [];
    rCentroid = [];
    numpeaks = zeros(length(bx),1);
    cornies = cell(length(bx),1);
    angie = cell(length(bx), 1);
    anglesumve = cell(length(bx), 1);
    mam = cell(length(bx), 1);
    stam = cell(length(bx), 1);
    
    for whichfr = 1:length(bx)
        %fprintf('%s: Loading file:\n %s\n', mfilename, fullfile(rootdir, a{whichTrackIdx}, b{whichfr}));
        load(fullfile(rootdir, a{whichTrackIdx}, b{whichfr}));
        
        [cornies{whichfr}, ~, ch] = computeCorners([], frameinfo.outboundy{1});
        angie{whichfr} = ch.anglegram;
        anglesumve{whichfr} = ch.anglesumve;
        mam{whichfr} = ch.mam;
        stam{whichfr} = ch.stam;
        minval{whichfr} = ch.minval;
        minlocations{whichfr} = ch.minlocations;
        
        numpeaks(whichfr) = ch.guesslabel-1;
        
        aa = poly2mask(frameinfo.outboundy{1}(:,2), frameinfo.outboundy{1}(:,1), ...
            handles.rows, handles.cols);
        gCentroid = [gCentroid;regionprops('table',aa,'Centroid')];
        rCentroid = [rCentroid;regionprops('table',aa.*(frameinfo.dataL>0),'Centroid')];
        
        T = [T;struct2table(frameinfo.regs)];
    end
    
    rCentroid.Properties.VariableNames{1} = 'rCentroid';
    gCentroid.Properties.VariableNames{1} = 'gCentroid';
    rCentroid.Variables = rCentroid.rCentroid(:,2:-1:1);
    gCentroid.Variables = gCentroid.gCentroid(:,2:-1:1);
    
    T = [T table(numpeaks) rCentroid gCentroid];
    % what to plot
    [m1.yleft, m1.lableft] = getvectorandtext(T, 'Orientation');
    [m1.yright, m1.labright] = getvectorandtext(T, 'AspectRatio');
    [m2.yleft, m2.lableft] = getvectorandtext(T,'Solidity');
    [m2.yright, m2.labright] = getvectorandtext(T,'EquivDiameter');
catch e
    disp('ERROR. You need the vectors [bx], [b], [frnumbers]');
end