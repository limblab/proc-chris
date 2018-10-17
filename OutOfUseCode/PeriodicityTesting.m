upTrials = td([td.target_direction]== pi/2);
leftTrials = td([td.target_direction] == pi);
downTrials = td([td.target_direction] == 3*pi/2);
rightTrials = td([td.target_direction] == 0);

for i =1:length(upTrials)
    meanFiringPostMoveUp(i)= mean(upTrials(i).RightCuneate_spikes(upTrials(i).idx_movement_on:upTrials(i).idx_movement_on+50));   
end

for i =1:length(downTrials)
    meanFiringPostMoveDown(i)= mean(downTrials(i).RightCuneate_spikes(downTrials(i).idx_movement_on:downTrials(i).idx_movement_on+50));   
end

for i =1:length(rightTrials)
    meanFiringPostMoveRight(i)= mean(rightTrials(i).RightCuneate_spikes(rightTrials(i).idx_movement_on:rightTrials(i).idx_movement_on+50));   
end

for i =1:length(leftTrials)
    meanFiringPostMoveLeft(i)= mean(leftTrials(i).RightCuneate_spikes(leftTrials(i).idx_movement_on:leftTrials(i).idx_movement_on+50));   
end

figure
plot(meanFiringPostMoveUp)
hold on
plot(meanFiringPostMoveDown)
plot(meanFiringPostMoveRight)
plot(meanFiringPostMoveLeft)