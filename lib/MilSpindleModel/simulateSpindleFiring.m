function td = simulateSpindleFiring(td, params)
    load_system('MuscleSpindleGUIModel')

    padLen = .1;
    osNames = td(1).opensim_names;
    muscles = osNames(contains(osNames, '_len'));
    
    
    osTemp = cat(1,td.opensim);
    lenMin = mean(osTemp(:, contains(osNames, 'len')));
    
    
    for i = 1:length(td)
        type1A = zeros(length(td(i).pos(:,1)), length(muscles));
        type2 = zeros(length(td(i).pos(:,1)), length(muscles));
        
        for j = 1:length(muscles)
            time = [.001:.001:td(i).bin_size*length(td(i).pos(:,1))+ padLen]';
            temp = td(i).opensim(:,find(strcmp(osNames, muscles{j})));
            temp1 = [temp(1)*ones(padLen*1000, 1);temp]./lenMin(j);
            MuscLen = timeseries(temp1, time);
            
            DynGam = timeseries(zeros(length(time),1),time);
            StatGam = timeseries(zeros(length(time),1),time);
            
            assignin('base', 'MuscLen', MuscLen);
            assignin('base', 'DynGam', DynGam);
            assignin('base', 'StatGam', StatGam);
            
            set_param('MuscleSpindleGUIModel', 'StopTime', num2str(time(end)));
            simOut = sim('MuscleSpindleGUIModel');
            
            type1A(:,j) = Primary(padLen/td(1).bin_size+2:end);
            type2(:,j) = Secondary(padLen/td(1).bin_size+2:end);
                     
        end
        disp(['Done with trial ', num2str(i), ' of ', num2str(length(td))])
        td(i).type1A = type1A;
        td(i).type2 = type2;
        
    end
    
end