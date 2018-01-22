function [allpaths, wendys] = getpathsperlabel(whichlabel, trackinfo, options)
% GET ALL SINGLE PATHS PER FINAL LABEL.
%
% Usage:
%           [allpaths, wendys] = getpathsperlabel(whichlabel, trackinfo)
%

if nargin < 3
    minimbool = false;
    clumpbool = false;
else
    [minimbool, clumpbool] = getoptions(options);
end

fprintf('%s: Getting all paths for clump %d.\n',...
    mfilename, whichlabel);
jumpsix=find(diff(trackinfo.clumpcode>0));
jumpsix=jumpsix+1;
if trackinfo.clumpcode(1)==0
    jumpsix = [1;jumpsix];
end
if trackinfo.clumpcode(end)==0
    jumpsix = [jumpsix;size(trackinfo,1)];
end
if mod(length(jumpsix),2)~=0
    jumpsix(end)=[];
end
wendys = reshape(jumpsix,2, length(jumpsix)/2)';
%wendys = wendys+1;

% join paths that only overlap on a single frame
if minimbool == true
    a = wendys(2:end,1) - wendys(1:end-1,2);
    idx = find(a==1);
    while ~isempty(idx)
        qx=1;
        wendys(idx(qx),2) = wendys(idx(qx)+1,2);
        wendys(idx(qx)+1,:) = [];
        
        a = wendys(2:end,1) - wendys(1:end-1,2);
        idx = find(a==1);
    end
end

allpaths = cell(size(wendys,1),1);
for jx=1:size(wendys,1)
    if wendys(jx,1) <= wendys(jx,2)
        allpaths{jx} = trackinfo(wendys(jx,1):wendys(jx,2),:);
    end
end

end

function [minimbool, clumpbool] = getoptions(s)
minimbool = false;
clumpbool = false;

if islogical(s)
    % old functionality
    minimbool = s;
else
    % user used the structure 'options'
    fnames = fieldnames(s);
    for ix=1:length(fnames)
        switch lower(fnames{ix})
            case 'minimbool'
                minimbool = s.(fnames{ix});
            case 'clumpbool'
                clumpbool = s.(fnames{ix});
            otherwise
                fprintf('%s: ERROR, option %s not recognised.', ...
                    mfilename, upper(fnames{ix}));
        end
    end
end
end