mcrsght_info('Select the demo from the list:', 'MACROSIGHT_DEMOS');

mcrsght_info('Select contact events - save to xls.', '1');
mcrsght_info('Load from saved data - plot results','2');
mcrsght_info('Load from saved data - statistical analysis','3');
mcrsght_info('Demo tidy function','9');
mcrsght_info('Cancel','C');

demoinput_ = input('Your choice [default=1]: ', 's');
if isempty(demoinput_)
    demoinput_ = '1';
end

switch demoinput_
    case '1'
        demoSelectContactSingle; 
    case '2'
        demoLoadXLSandPlot;
    case '3'
        demoStatisticalAnalysis;
    case '9'
        tidy;
    otherwise 
        mcrsght_info('Cancelled demo.');
end
clear demoinput_;