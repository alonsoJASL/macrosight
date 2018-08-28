function gifFromPlotFunction(handles, filenames, fname, gifoptions)
% GIF FROM PLOT FUNCTION.
% Create a plot function and make a gif out of the frames in your filenmes,
% specified in a given range. The function MUST only receive the frame
% after loaded with function GETDATAFROMHANDLES.
%

if nargin < 4
    outname = 'somegif.gif';
    outputpath = './';
    delayTime = 0.4;
    rangeframes = 1:length(filenames);
else
    [outname, outputpath, delayTime, rangeframes] = getoptions(gifoptions,length(filenames));
end

% GIF options
numImages = length(rangeframes);

% Plot it once
figure(169)
ix=rangeframes(1);
fr = getdatafromhandles(handles, filenames{ix});
feval(fname, fr);

H = gcf;
f = getframe(H);
[im,map] = rgb2ind(f.cdata,256,'nodither');

im(1,1,1,numImages) = 0;

for ix=2:numImages
    fr = getdatafromhandles(handles, filenames{rangeframes(ix)});
    feval(fname, fr);
    
    f = getframe(gcf);
    im(:,:,1,ix) = rgb2ind(f.cdata,map,'nodither');
end

imwrite(im,map,fullfile(outputpath,outname),...
    'DelayTime',delayTime, 'LoopCount',inf);

end

function [outname, outputpath, delayTime, rangeframes] = getoptions(s, numframes)
outname = 'somegif.gif';
outputpath = './';
delayTime = 0.35;
rangeframes = 1:numframes;

fnames = fieldnames(s);
for jx=1:length(fnames)
    switch fnames{jx}
        case 'outname'
            outname = s.(fnames{jx});
            if ~contains(outname, '.gif')
                outname = [outname '.gif'];
            end
        case 'outputpath'
            outputpath = s.(fnames{jx});
        case 'delayTime'
            delayTime = s.(fnames{jx});
        case 'rangeframes'
            rangeframes = s.(fnames{jx});
            rangeframes = sort(rangeframes);
        otherwise
            fprintf('%s: Gif option [%s] not recognised.\n', ...
                mfilename, fnames{jx});
    end
end
end