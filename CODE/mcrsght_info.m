function mcrsght_info(msg, mname, condition2print)
% MACROSIGHT INFO. Function for output to console based. Use jointly with
% sprintf. A breakline (\n) character is always print.
% confition2print = true (default), 
% if condition2print == false, then nothing gets shown in console.
% 

if nargin < 2
    mname = 'INFO';
    condition2print = true;
elseif nargin < 3
    condition2print = true;
end


if condition2print == true
    fprintf('[%s] %s\n', mname, msg);
end

