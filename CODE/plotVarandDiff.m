function plotVarandDiff(x,y,varname, diffstats)
% PLOT VARIABLE AND DERIVATIVE. Simple function to plot a variable Y and
% its derivative diff(y), giving it's x-axis.
% USAGE: 
%   plotVarandDiff(x,y,[]) - plot Y and diff(Y)
%   plotVarandDiff([],y) - when you do not have the X values.
%   plotVarandDiff(x,y,varname) - varname is a string naming the variable Y.
%   plotVarandDiff(x,y,varname, diffstats) - ONLY IF matlab.utils package
%       is installed. Look for it on: 
%       https://github.com/alonsoJASL/matlab.utils

if nargin < 4
    diffstats = false;
elseif nargin < 3
    varname = 'Y';
    diffstats = false;    
end

gcf;

if isempty(x)
    x=1:length(y);
end

plot(x, y, '-', x(2:end), diff(y));
if diffstats == true
    try 
        plotHorzLine(x, (mean(diff(y)) + [0 std(diff(y)) -std(diff(y))]));
        legend(varname, strcat('diff(', varname,')'),strcat('mean(', varname,')'));
    catch e 
        if strcmpi(e.identifier, 'MATLAB:UndefinedFunction')
            disp('[WARNING] The function plotHorzLine was not found.');
            disp('You can find it in the matlab.utils package in: ');
            fprintf('https://github.com/alonsoJASL/matlab.utils \n');
            disp('or try running the function in its normal form: ');
            help plotVarandDiff;
        end
    end
elseif ~isempty(varname)
   legend(varname, strcat('diff(', varname,')'));    
end