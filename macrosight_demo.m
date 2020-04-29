mcrsght_info('Select the demo from the list:', 'MACROSIGHT_DEMOS');

mcrsght_info('Select contact events - save to xls.', '1');
mcrsght_info('Load from xls - plot results','2');

demoinput_ = input('Your choice [default=1]: ', 's');
if isempty(demoinput_)
    demoinput_ = '1';
end

switch demoinput_
    case '1'
        demoSelectContactSingle; 
    case '2'
        demoLoadXLSandPlot;
end

