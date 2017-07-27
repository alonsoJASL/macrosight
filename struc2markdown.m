function [ss] = struc2markdown(somopt, range)
nn = fieldnames(somopt);
if nargin < 2
    range = 1:length(nn);
end
ss = '|';
for qx=range
    ss = strcat(ss,sprintf('%s|',nn{qx}));
end; ss = sprintf('%s\n|', ss);
for qx=range
    ss = strcat(ss,':---:|');
end; ss = sprintf('%s\n|', ss);
for qx=range
    if isnumeric(somopt.(nn{qx}))
        ss = strcat(ss,sprintf('%4.2f|',somopt.(nn{qx})));
    elseif ischar(somopt.(nn{qx}))
        ss = strcat(ss,sprintf('%s|',somopt.(nn{qx})));
    else
        ss = strcat(ss,'Empty|');
    end
end