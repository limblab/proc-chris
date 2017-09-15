

%%
close all
emgCols =  2:22;
muscleCols = 42:119;

binned = ex1.bin.data(1:43508,:);
cuneateNeurons = binned(:,150:168);
speed = sqrt(sum([binned.vx, binned.vy].^2, 2));
window1 = [[ex1.trials.data.bumpTime], [ex1.trials.data.bumpTime]+.2];
passiveFlag = inWindows(binned.t, window1);
moveFlag = speed>5;
activeFlag = ~passiveFlag & moveFlag;
 

for  i=1:width(cuneateNeurons)
    %% All Data
        %% Muscle only fits
    emgAllData{i} = fitlm(table2array(binned(:, emgCols)), table2array(cuneateNeurons(:,i)));
        %% Kinematic only fits
    kinAllData{i} = fitlm(table2array(binned(:, muscleCols)), table2array(cuneateNeurons(:,i)));
        %% Muscle and Kinematic Fits
    emgKinAllData{i} = fitlm(table2array(binned(:, [emgCols, muscleCols])), table2array(cuneateNeurons(:,i)));
    %% Passive Data
        %% Muscle only fits
    emgPassiveData{i} = fitlm(table2array(binned(passiveFlag,emgCols)), table2array(cuneateNeurons(passiveFlag, i)));
        %% Kinematic only fits
    kinPassiveData{i} = fitlm(table2array(binned(passiveFlag, muscleCols)), table2array(cuneateNeurons(passiveFlag, i)));
        %% Muscle and Kinematic Fits
    emgKinPassiveData{i} = fitlm(table2array(binned(passiveFlag, [emgCols, muscleCols])), table2array(cuneateNeurons(passiveFlag, i)));
    
    %% Active Data
        %% Muscle only fits
    emgActiveData{i} = fitlm(table2array(binned(activeFlag,emgCols)), table2array(cuneateNeurons(activeFlag, i)));
        %% Kinematic only fits
    kinActiveData{i} = fitlm(table2array(binned(activeFlag, muscleCols)), table2array(cuneateNeurons(activeFlag, i)));
        %% Muscle and Kinematic Fits
    emgKinActiveData{i} = fitlm(table2array(binned(activeFlag, [emgCols, muscleCols])), table2array(cuneateNeurons(activeFlag, i)));
    
    figure('Position', [100, 100, 1200,1200])
    sp1 = subplot(3,3,1);
    plot(emgAllData{i})
    ylabel('All Data')
    title('EMG')
    legend(sp1, 'off')
    dim = [.2 .7 .2 .2];
    str = ['R2 = ', num2str(emgAllData{1,i}.Rsquared.Adjusted)];
    annotation('textbox',dim,'String',str,'FitBoxToText','on');
    
    sp2 = subplot(3,3,2);
    plot(kinAllData{i})
    legend(sp2, 'off')
    title('Kinematics')
    dim = [.5 .7 .2 .2];
    str = ['R2 = ', num2str(kinAllData{1,i}.Rsquared.Adjusted)];
    annotation('textbox',dim,'String',str,'FitBoxToText','on');
    
    sp3 = subplot(3,3,3);
    plot(emgKinAllData{i})
    title('Both')
    legend(sp3, 'off')
    dim = [.7 .7 .2 .2];
    str = ['R2 = ', num2str(emgKinAllData{1,i}.Rsquared.Adjusted)];
    annotation('textbox',dim,'String',str,'FitBoxToText','on');
    
    sp4 = subplot(3,3,4);
    plot(emgPassiveData{i})
    ylabel('Passive')
    legend(sp4, 'off')
    dim = [.2 .4 .2 .2];
    str = ['R2 = ', num2str(emgPassiveData{1,i}.Rsquared.Adjusted)];
    annotation('textbox',dim,'String',str,'FitBoxToText','on');
    
    sp5 = subplot(3,3,5);
    plot(kinPassiveData{i})
    legend(sp5, 'off')
    dim = [.5 .4 .2 .2];
    str = ['R2 = ', num2str(kinPassiveData{1,i}.Rsquared.Adjusted)];
    annotation('textbox',dim,'String',str,'FitBoxToText','on');
    
    sp6 = subplot(3,3,6);
    plot(emgKinPassiveData{i})
    legend(sp6, 'off')
    dim = [.7 .4 .2 .2];
    str = ['R2 = ', num2str(emgKinPassiveData{1,i}.Rsquared.Adjusted)];
    annotation('textbox',dim,'String',str,'FitBoxToText','on');
    
    sp7 = subplot(3,3,7);
    plot(emgActiveData{i})
    legend(sp7, 'off')
    ylabel('Active')
    dim = [.2 .1 .2 .2];
    str = ['R2 = ', num2str(emgActiveData{1,i}.Rsquared.Adjusted)];
    annotation('textbox',dim,'String',str,'FitBoxToText','on');
    
    sp8 = subplot(3,3,8);
    plot(kinActiveData{i})
    legend(sp8, 'off')
    dim = [.5 .1 .2 .2];
    str = ['R2 = ', num2str(kinActiveData{1,i}.Rsquared.Adjusted)];
    annotation('textbox',dim,'String',str,'FitBoxToText','on');
    
    sp9 = subplot(3,3,9);
    plot(emgKinActiveData{i})
    legend(sp9, 'off')
    dim = [.7 .1 .2 .2];
    str = ['R2 = ', num2str(emgKinActiveData{1,i}.Rsquared.Adjusted)];
    annotation('textbox',dim,'String',str,'FitBoxToText','on');
    suptitle(['Unit ',num2str(i)])
end
