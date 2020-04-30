function [M, SD, H, P] = compareAngleChanges(trackfeatures_set1, trackfeatures_set2, setnames, absbool)
%

if nargin < 3
    setnames = {'set1', 'set2'};
    absbool = true;
elseif nargin < 4
    absbool = true;
end

if absbool
    mcrsght_info('ABS(Angle)');
else
    mcrsght_info('Angles unchanged');
end

angleContact = vertcat(trackfeatures_set1.thx);
angleNoContact = vertcat(trackfeatures_set2.thx);


if absbool
    angleContact = abs(angleContact);
    angleNoContact = abs(angleNoContact);
end

m = [mean(angleContact) mean(angleNoContact)];
sd = [std(angleContact) std(angleNoContact)];

[pwill, hwill] = ranksum(angleContact, angleNoContact);
[httest, pttest] = ttest2(angleContact, angleNoContact);

if hwill==1
    rejwill = 'reject';
else
    rejwill = sprintf('nope\t');
end
if httest==1
    rejttest = 'reject';
else
    rejttest = sprintf('nope\t');
end

M.(setnames{1}) = m(1);
M.(setnames{2}) = m(2);

SD.(setnames{1}) = sd(1);
SD.(setnames{2}) = sd(2);

H.ttest = httest;
H.wilcoxon = hwill;

P.ttest = pttest;
P.wilcoxon = pwill;


if nargout == 0
    mcrsght_info(sprintf('   & With cell-cell  &  NO contact  &     WILLCOXON         &     T-TEST           &'));
    mcrsght_info(sprintf('mean (std)    &  mean (std)  & p-value & Can reject? & p-value & Can reject? &'));
    
    mcrsght_info(sprintf('& %3.2f (%2.2f)  & %3.2f (%2.2f)  &  %2.2f   & %s  &   %2.2f  & %s  &', ...
        m(1), sd(1), m(2), sd(2), pwill, rejwill, pttest, rejttest));
    
end


