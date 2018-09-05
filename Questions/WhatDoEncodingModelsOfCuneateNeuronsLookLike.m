%% Load all files for comparison
clear all
monkey = 'Butter';
date = '20180405';
mappingLog = getSensoryMappings(monkey);
tdButter =getTD(monkey, date, 'RW');
%% Preprocess them (binning, trimming etc)
tdButter = getRWMovements(tdButter);
tdButter= removeBadTrials(tdButter);
tdButter = trimTD(tdButter, {'idx_movement_on'}, 'idx_endTime');
tdButter= binTD(tdButter, 5);



butterNaming = tdButter.cuneate_unit_guide;

butterForce = cat(1, tdButter.force);
butterVel = cat(1, tdButter.vel);
butterPos = cat(1, tdButter.pos);
butterNeurons = cat(1, tdButter.cuneate_spikes);
butterSortedNeurons = butterNeurons(:,butterNaming(:,2)~=0);
%% Fitting encoding GLMs to predict firing as a function of kinematics and forces
for i = 1:length(butterSortedNeurons(1,:))
    butterFullModel{i} = fitglm([butterForce, butterVel, butterPos], butterSortedNeurons(:,i), 'Distribution', 'Poisson');
    Full(i) = butterFullModel{i}.Rsquared.Adjusted;
    
    butterPosModel{i} = fitglm([butterPos], butterSortedNeurons(:,i), 'Distribution', 'Poisson');
    Pos(i) = butterPosModel{i}.Rsquared.Adjusted;
    
    butterVelModel{i} = fitglm([butterVel], butterSortedNeurons(:,i), 'Distribution', 'Poisson');
    Vel(i) = butterVelModel{i}.Rsquared.Adjusted;
    
    butterForceModel{i} = fitglm([butterForce], butterSortedNeurons(:,i), 'Distribution', 'Poisson');
    Force(i) = butterForceModel{i}.Rsquared.Adjusted;
    
    butterSpeedModel{i} = fitglm(rownorm(butterVel), butterSortedNeurons(:,i), 'Distribution', 'Poisson');
    Speed(i) = butterSpeedModel{i}.Rsquared.Adjusted;
    
    butterVelSpeedModel{i} = fitglm([rownorm(butterVel)', butterVel], butterSortedNeurons(:,i),'Distribution', 'Poisson');
    VelSpeed =  butterVelSpeedModel{i}.Rsquared.Adjusted;
    disp([ num2str(i), ' is done of ', num2str(length(butterSortedNeurons(1,:)))])
end
%% Rotating to put into a table
Full = Full';
Pos = Pos';
Vel = Vel';
Force = Force';
Speed = Speed';
VelSpeed= VelSpeed';
%% Plotting R2s to inspect how they look
butterR2table = table(Full, Pos, Vel, Force, Speed);
figure
suptitle('Encoding Models of Butter Neurons 20180405 Binned @ 100 ms')
subplot(5,1,1)
histogram(butterR2table.Full)
title('Full')
subplot(5,1, 2)
histogram(butterR2table.Pos)
title('Pos')
subplot(5,1,3)
histogram(butterR2table.Vel)
title('Vel')
subplot(5,1,4)
histogram(butterR2table.Force)
title('Force')
subplot(5,1,5)
histogram(butterR2table.Speed)
title('Speed')
linkaxes
xlim([-.05, .3])
xlabel('R2 of encoding model')
ylabel('# of neurons')
% Average for the full model is .03
% Max for the full model is .
%%
figure
for i = 0:.01:.4

    thresh = i;
    velSig = Vel(Full>thresh);
    speedSig = Speed(Full>thresh);
    velSpeedRatio = velSig ./ speedSig;
    velSpeedDif = velSig - speedSig;
    histogram(velSpeedDif, 15)
    title(['Threshold is ', num2str(i)])
    pause()
end

%%
addingSpeedR2 = VelSpeed - Vel;
addingVelR2 =  VelSpeed - Speed;
figure
for i = 0:.01:.4
    hold off
    thresh = i;
    addingSpeedR2Sig = addingSpeedR2(Full>thresh);
    addingVelR2Sig = addingVelR2(Full>thresh);
    histogram(addingSpeedR2Sig)
    hold on
    histogram(addingVelR2Sig)
    
    title(['Threshold is ', num2str(i)])
    legend
    pause()
end
