function [eventsTable] = selectContactEvents(tablenetplusclumps, clumpidcodes, S, whichdataset, automatic)
% SELECT CONTACT EVENTS. Semi-automatic method to select contact events to
% evaluate change in direction. 
%
% USAGE: 
% [eventsTable] = selectContactEvents(tablenetplusclumps, clumpidcodes, S, whichdataset, automatic)
% 
% INPUTS:
%       tablenetplusclumps := table containing all the tracks/clumps information
%                             (tablenetplusclumps = [tablenet clumptracktable];)
%             clumpidcodes := clump id codes array
%                        S := number of frames before/after contact
%                             (default=5)
%             whichdataset := name of dataset.
%                automatic := create table automatically (default=false) -
%                             feature still in development!
% 
%

if nargin < 3
    S = 5;
    whichdataset = 'macros';
    automatic = false;
elseif nargin < 4
    whichdataset = 'macros';
    automatic = false;
elseif nargin < 5
    automatic = false;
end
whichdataset = [lower(whichdataset) '-'];

rows = length(clumpidcodes)*10;
cols = 7;
varTypes = {'string', 'uint64', 'uint8', 'uint8', 'uint8', 'uint8', 'uint8'};
varNames = {'whichdataset',	'whichclump', 'whichlabel', 'initialframe','finalframe','clumpinit','clumpfin'};
eventsTable = table('Size', [rows cols], 'VariableTypes', varTypes, ...
    'VariableNames',  varNames);

idx=1;
for ix=1:length(clumpidcodes)
    wuc = clumpidcodes(ix);
    clumplabels = getlabelsfromcode(wuc);
    [clumplifetable, clumpwindows] = displayCellsInClump(tablenetplusclumps, wuc, S, false);
    
    if ~isempty(clumplifetable) && size(clumpwindows,2)==2
        
        for jx=1:size(clumpwindows, 1)
            clumpinit = clumpwindows(jx, 1);
            clumpfin  = clumpwindows(jx, 2);
            initialframe = clumpinit - S;
            finalframe = clumpfin + S;
            
            for k=1:length(clumplabels)
                if automatic == true
                    [initialframe, finalframe] = verifyEventAuto(...
                        clumplifetable, clumplabels(k), initialframe, finalframe);
                else
                    [initialframe, finalframe] = verifyEventManual(...
                        clumplifetable, clumplabels(k), initialframe, finalframe);
                end
                if ~isempty(initialframe)
                    eventsTable.whichdataset(idx) = [whichdataset num2padstr(idx, 3)];
                    eventsTable.whichclump(idx) = wuc;
                    eventsTable.whichlabel(idx) = clumplabels(k);
                    eventsTable.initialframe(idx) = initialframe;
                    eventsTable.finalframe(idx) = finalframe;
                    eventsTable.clumpinit(idx) = clumpinit;
                    eventsTable.clumpfin(idx)  = clumpfin;
                    
                    idx = idx+1;
                end
            end
        end
    end
end
if automatic==true
    mcrsght_info('Automatic selection of events still in development. Results may vary.', 'WARNING');
end
eventsTable(~contains(eventsTable.whichdataset, whichdataset), :) = [];
end

function [inifr, finfr] = verifyEventAuto(clumplifetable, label, initialframe, finalframe)
clumplifetable = clumplifetable(clumplifetable.finalLabel==label, :);
timeframes = clumplifetable.timeframe;
intersectionframes = timeframes(ismember(timeframes, initialframe:finalframe));

if ~isempty(intersectionframes)
    inifr = intersectionframes(1);
    finfr = intersectionframes(end);
else
    inifr = [];
    finfr = [];
end

end

function [inifr, finfr] = verifyEventManual(clumplifetable, label, initialframe, finalframe)
clumplifetable = clumplifetable(clumplifetable.finalLabel==label, :);
timeframes = clumplifetable.timeframe;

mcrsght_info(sprintf('Verify the following event spanning from %d to %d:', ...
    initialframe, finalframe), 'ATTENTION');

disp(clumplifetable(ismember(timeframes, initialframe:finalframe),:));
intersectionframes = timeframes(ismember(timeframes, initialframe:finalframe));

if ~isempty(intersectionframes)
    mcrsght_info(sprintf('The event should go from frame %d to %d:', ...
        initialframe, finalframe), 'ATTENTION');
    
    str = input(sprintf('The event CAN go from %d to %d, is that OK? Y/N/C [Y]', ...
        intersectionframes(1), intersectionframes(end)), 's');
    if isempty(str); str='Y'; end
    if strcmpi(str, 'Y')
        inifr = initialframe;
        finfr = finalframe;
    elseif strcmpi(str, 'N')
        strini = input(sprintf('Provide the new value for the starting frame [%d]', ...
            initialframe), 's');
        if isempty(strini)
            inifr=initialframe;
        else
            inifr=str2num(strini);
        end
        strfin = input(sprintf('Provide the new value for the ending frame [%d]', ...
            finalframe), 's');
        if isempty(strfin)
            finfr=finalframe;
        else
            finfr=str2num(strfin);
        end
        
    else % cancel clump
        inifr = [];
        finfr = [];
    end
else
    inifr = [];
    finfr = [];
end
end