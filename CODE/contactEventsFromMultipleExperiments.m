function [contactEventsTable] = contactEventsFromMultipleExperiments(basefilename, experimentfolders, S)
% CONTACT EVENTS FROM MULTIPLE EXPERIMENTS. Extension from the function
% selectContactEvents, which aggregates the results from all experiments in
% cell array experimentfolders
%
% USAGE:
%       [contactEventsTable] = contactEventsFromMultipleExperiments(basefilename, experimentfolders)
%
if nargin <3
    S = 5;
end

contactEventsTable = table();

for ix=1:length(experimentfolders)
    whichDs = experimentfolders{ix};
    try
        [tablenet, clumptracktable, clumpidcodes, ~] = ...
            setupInitialStructures(basefilename, whichDs);

        [T] = selectContactEvents([tablenet clumptracktable], clumpidcodes, S, whichDs);
        clc;
        contactEventsTable = [contactEventsTable;T];
    catch e
        mcrsght_info(sprintf('Folder %s failed for some reason. Press any key to continue.',...
            whichDs), 'ERROR');
    end
end