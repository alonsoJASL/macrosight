function [boxdata, boxgroups] = getBoxplotComparisonData(varargin)
% GET DATA FOR BOXPLOTS AND STATISTICAL ANALYSIS.
%

numGroups = length(varargin);
fnames = fieldnames(varargin{1});

boxgroups = [];
for ix=1:length(fnames)
    Tab = [];
    for jx=1:numGroups
        thisVector = vertcat(varargin{jx}.(fnames{ix}));
        Tab = [Tab; thisVector];
        if ix==1
            boxgroups = [boxgroups; jx.*ones(size(thisVector))];
        end
    end
    boxdata.(fnames{ix}) = Tab;
end
