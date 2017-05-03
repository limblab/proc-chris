%% Data Prep
 clear all
close all
load('Lando3142017COactpasCDS.mat')
plotRasters = 0;
params.event_list = {'bumpTime'; 'ctrHoldTime'; 'bumpDir'};
params.extra_time = [.4,.4];
td = parseFileByTrial(cds, params);
td = getMoveOnsetAndPeak(td);
%% Pull out correct Trials
postBumpWindow = [.01, .1];
postBumpOffWindow = [.13,.22];
postMoveTonicWindow = [.4, .5];
postMoveTransWindow = [.01,.1];
units = [1:39];
devs = 1;
preBump = .5;
preMove = .5;
plotTuning= false;
 pCutoff = .05;
%pCutoff = .05;
%% get bump Trials
bumpTrials = td(~isnan([td.bumpDir])); 
upBump = bumpTrials([bumpTrials.bumpDir] == 90);
leftBump = bumpTrials([bumpTrials.bumpDir] ==180);
downBump = bumpTrials([bumpTrials.bumpDir] ==270);
rightBump = bumpTrials([bumpTrials.bumpDir]==0);

upMove = td([td.target_direction] == pi/2);
leftMove = td([td.target_direction] ==pi);
downMove = td([td.target_direction] ==3*pi/2);
rightMove = td([td.target_direction]==0);

%% Get spike counts before bump
preBumpSpikes = zeros(length(bumpTrials), length(bumpTrials(1).S1_spikes(1,:)));
for i = 1:length(bumpTrials)
    preBumpSpikes(i,:) = mean(bumpTrials(i).S1_spikes(bumpTrials(i).idx_bumpTime - preBump*100: bumpTrials(i).idx_bumpTime-1,:))*100;
end
%% Get spike counts before move
preMoveSpikes = zeros(length(td), length(td(1).S1_spikes(1,:)));
for i = 1:length(td)
    preMoveSpikes(i,:) = mean(td(i).S1_spikes(td(i).idx_movement_on - preMove*100: td(i).idx_movement_on-2,:))*100;
end
%% Get Up spike counts
spikesUpMoveTonic = zeros(length(upMove), length(td(1).S1_spikes(1,:)));
for i = 1:length(upMove)
    spikesUpMoveTonic(i,:) = mean(upMove(i).S1_spikes(upMove(i).idx_movement_on + 100*postMoveTonicWindow(1): upMove(i).idx_movement_on+ 100*postMoveTonicWindow(2), :))*100;
end

spikesUpMoveTrans = zeros(length(upMove), length(td(1).S1_spikes(1,:)));
for i = 1:length(upMove)
    spikesUpMoveTrans(i,:) = mean(upMove(i).S1_spikes(upMove(i).idx_movement_on + 100*postMoveTransWindow(1): upMove(i).idx_movement_on+ 100*postMoveTransWindow(2), :))*100;
end


spikesUpBump = zeros(length(upBump), length(td(1).S1_spikes(1,:)));
for i = 1:length(upBump)
    spikesUpBump(i,:) = mean(upBump(i).S1_spikes(upBump(i).idx_bumpTime + 100*postBumpWindow(1): upBump(i).idx_bumpTime + 100*postBumpWindow(2), :))*100;
end

spikesUpBumpOff = zeros(length(upBump), length(td(1).S1_spikes(1,:)));
for i = 1:length(upBump)
    spikesUpBumpOff(i,:) = mean(upBump(i).S1_spikes(upBump(i).idx_bumpTime + 100*postBumpOffWindow(1): upBump(i).idx_bumpTime + 100*postBumpOffWindow(2), :))*100;
end
%% Get Down spike counts
spikesdownMoveTonic = zeros(length(downMove), length(td(1).S1_spikes(1,:)));
for i = 1:length(downMove)
    spikesdownMoveTonic(i,:) = mean(downMove(i).S1_spikes(downMove(i).idx_movement_on + 100*postMoveTonicWindow(1): downMove(i).idx_movement_on+ 100*postMoveTonicWindow(2), :))*100;
end

spikesdownMoveTrans = zeros(length(downMove), length(td(1).S1_spikes(1,:)));
for i = 1:length(downMove)
    spikesdownMoveTrans(i,:) = mean(downMove(i).S1_spikes(downMove(i).idx_movement_on + 100*postMoveTransWindow(1): downMove(i).idx_movement_on+ 100*postMoveTransWindow(2), :))*100;
end

spikesdownBump = zeros(length(downBump), length(td(1).S1_spikes(1,:)));
for i = 1:length(downBump)
    spikesdownBump(i,:) = mean(downBump(i).S1_spikes(downBump(i).idx_bumpTime + 100*postBumpWindow(1): downBump(i).idx_bumpTime + 100*postBumpWindow(2), :))*100;
end

spikesdownBumpOff = zeros(length(downBump), length(td(1).S1_spikes(1,:)));
for i = 1:length(downBump)
    spikesdownBumpOff(i,:) = mean(downBump(i).S1_spikes(downBump(i).idx_bumpTime + 100*postBumpOffWindow(1): downBump(i).idx_bumpTime + 100*postBumpOffWindow(2), :))*100;
end
%% Get Right spike counts
spikesrightMoveTonic = zeros(length(rightMove), length(td(1).S1_spikes(1,:)));
for i = 1:length(rightMove)
    spikesrightMoveTonic(i,:) = mean(rightMove(i).S1_spikes(rightMove(i).idx_movement_on + 100*postMoveTonicWindow(1): rightMove(i).idx_movement_on+ 100*postMoveTonicWindow(2), :))*100;
end

spikesrightMoveTrans = zeros(length(rightMove), length(td(1).S1_spikes(1,:)));
for i = 1:length(rightMove)
    spikesrightMoveTrans(i,:) = mean(rightMove(i).S1_spikes(rightMove(i).idx_movement_on + 100*postMoveTransWindow(1): rightMove(i).idx_movement_on+ 100*postMoveTransWindow(2), :))*100;
end

spikesrightBump = zeros(length(rightBump), length(td(1).S1_spikes(1,:)));
for i = 1:length(rightBump)
    spikesrightBump(i,:) = mean(rightBump(i).S1_spikes(rightBump(i).idx_bumpTime + 100*postBumpWindow(1): rightBump(i).idx_bumpTime + 100*postBumpWindow(2), :))*100;
end

spikesrightBumpOff = zeros(length(rightBump), length(td(1).S1_spikes(1,:)));
for i = 1:length(rightBump)
    spikesrightBumpOff(i,:) = mean(rightBump(i).S1_spikes(rightBump(i).idx_bumpTime + 100*postBumpOffWindow(1): rightBump(i).idx_bumpTime + 100*postBumpOffWindow(2), :))*100;
end
%% Get Up spike counts
spikesleftMoveTonic = zeros(length(leftMove), length(td(1).S1_spikes(1,:)));
for i = 1:length(leftMove)
    spikesleftMoveTonic(i,:) = mean(leftMove(i).S1_spikes(leftMove(i).idx_movement_on + 100*postMoveTonicWindow(1): leftMove(i).idx_movement_on+ 100*postMoveTonicWindow(2), :))*100;
end

spikesleftMoveTrans = zeros(length(leftMove), length(td(1).S1_spikes(1,:)));
for i = 1:length(leftMove)
    spikesleftMoveTrans(i,:) = mean(leftMove(i).S1_spikes(leftMove(i).idx_movement_on + 100*postMoveTransWindow(1): leftMove(i).idx_movement_on+ 100*postMoveTransWindow(2), :))*100;
end

spikesleftBump = zeros(length(leftBump), length(td(1).S1_spikes(1,:)));
for i = 1:length(leftBump)
    spikesleftBump(i,:) = mean(leftBump(i).S1_spikes(leftBump(i).idx_bumpTime + 100*postBumpWindow(1): leftBump(i).idx_bumpTime + 100*postBumpWindow(2), :))*100;
end

spikesleftBumpOff = zeros(length(leftBump), length(td(1).S1_spikes(1,:)));
for i = 1:length(leftBump)
    spikesleftBumpOff(i,:) = mean(leftBump(i).S1_spikes(leftBump(i).idx_bumpTime + 100*postBumpOffWindow(1): leftBump(i).idx_bumpTime + 100*postBumpOffWindow(2), :))*100;
end

%% Plot tuning Curves
meanUpMoveTonic = mean(spikesUpMoveTonic);
sdUpMoveTonic = std(spikesUpMoveTonic);
meanUpMoveTrans = mean(spikesUpMoveTrans);
sdUpMoveTrans = std(spikesUpMoveTrans);
meanUpBump = mean(spikesUpBump);
sdUpBump = std(spikesUpBump);

meanUpBumpOff = mean(spikesUpBumpOff);
sdUpBumpOff = std(spikesUpBumpOff);

meandownMoveTonic = mean(spikesdownMoveTonic);
sddownMoveTonic = std(spikesdownMoveTonic);
meandownMoveTrans = mean(spikesdownMoveTrans);
sddownMoveTrans = std(spikesdownMoveTrans);
meandownBump = mean(spikesdownBump);
sddownBump = std(spikesdownBump);
meandownBumpOff = mean(spikesdownBumpOff);
sddownBumpOff = std(spikesdownBumpOff);

meanrightMoveTonic = mean(spikesrightMoveTonic);
sdrightMoveTonic = std(spikesrightMoveTonic);
meanrightMoveTrans = mean(spikesrightMoveTrans);
sdrightMoveTrans = std(spikesrightMoveTrans);
meanrightBump = mean(spikesrightBump);
sdrightBump = std(spikesrightBump);
meanrightBumpOff = mean(spikesrightBumpOff);
sdrightBumpOff = std(spikesrightBumpOff);

meanleftMoveTonic = mean(spikesleftMoveTonic);
sdleftMoveTonic = std(spikesleftMoveTonic);
meanleftMoveTrans = mean(spikesleftMoveTrans);
sdleftMoveTrans = std(spikesleftMoveTrans);
meanleftBump = mean(spikesleftBump);
sdleftBump = std(spikesleftBump);
meanleftBumpOff = mean(spikesleftBumpOff);
sdleftBumpOff = std(spikesleftBumpOff);

rhoMoveTonic = [meanrightMoveTonic; meanUpMoveTonic; meanleftMoveTonic; meandownMoveTonic; meanrightMoveTonic];
highRhoMoveTonic = [meanrightMoveTonic + devs*sdrightMoveTonic; meanUpMoveTonic + devs*sdUpMoveTonic; meanleftMoveTonic + devs*sdleftMoveTonic; meandownMoveTonic + devs*sddownMoveTonic; meanrightMoveTonic + devs*sdrightMoveTonic];
lowRhoMoveTonic = [meanrightMoveTonic - devs*sdrightMoveTonic; meanUpMoveTonic - devs*sdUpMoveTonic; meanleftMoveTonic - devs*sdleftMoveTonic; meandownMoveTonic - devs*sddownMoveTonic; meanrightMoveTonic - devs*sdrightMoveTonic];
lowRhoMoveTonic(lowRhoMoveTonic <0) = 0;

rhoMoveTrans = [meanrightMoveTrans; meanUpMoveTrans; meanleftMoveTrans; meandownMoveTrans; meanrightMoveTrans];
highRhoMoveTrans = [meanrightMoveTrans + devs*sdrightMoveTrans; meanUpMoveTrans + devs*sdUpMoveTrans; meanleftMoveTrans + devs*sdleftMoveTrans; meandownMoveTrans + devs*sddownMoveTrans; meanrightMoveTrans + devs*sdrightMoveTrans];
lowRhoMoveTrans = [meanrightMoveTrans - devs*sdrightMoveTrans; meanUpMoveTrans - devs*sdUpMoveTrans; meanleftMoveTrans - devs*sdleftMoveTrans; meandownMoveTrans - devs*sddownMoveTrans; meanrightMoveTrans - devs*sdrightMoveTrans];
lowRhoMoveTrans(lowRhoMoveTrans <0) = 0;

rhoBump = [meanrightBump; meanUpBump; meanleftBump; meandownBump; meanrightBump];
highRhoBump =[meanrightBump + devs*sdrightBump; meanUpBump + devs*sdUpBump; meanleftBump + devs*sdleftBump; meandownBump + devs*sddownBump; meanrightBump + devs*sdrightBump];
lowRhoBump = [meanrightBump - devs*sdrightBump; meanUpBump - devs*sdUpBump; meanleftBump - devs*sdleftBump; meandownBump - devs*sddownBump; meanrightBump - devs*sdrightBump];
lowRhoBump(lowRhoBump<0) = 0;

rhoBumpOff = [meanrightBumpOff; meanUpBumpOff; meanleftBumpOff; meandownBumpOff; meanrightBumpOff];
highRhoBumpOff =[meanrightBumpOff + devs*sdrightBumpOff; meanUpBumpOff + devs*sdUpBumpOff; meanleftBumpOff + devs*sdleftBumpOff; meandownBumpOff + devs*sddownBumpOff; meanrightBumpOff + devs*sdrightBumpOff];
lowRhoBumpOff = [meanrightBumpOff - devs*sdrightBumpOff; meanUpBumpOff - devs*sdUpBumpOff; meanleftBumpOff - devs*sdleftBumpOff; meandownBumpOff - devs*sddownBumpOff; meanrightBumpOff - devs*sdrightBumpOff];
lowRhoBumpOff(lowRhoBumpOff<0) = 0;

theta = [0, pi/2, pi, 3*pi/2, 2*pi];
circle = linspace(0, 2*pi, 100);
meanFiringBeforeBump = mean(preBumpSpikes);
meanFiringBeforeMove = mean(preMoveSpikes);

upMoveTonicTuned = zeros(length(units),1);
downMoveTonicTuned = zeros(length(units),1);
leftMoveTonicTuned = zeros(length(units),1);
rightMoveTonicTuned = zeros(length(units),1);

upMoveTransTuned = zeros(length(units),1);
downMoveTransTuned = zeros(length(units),1);
leftMoveTransTuned = zeros(length(units),1);
rightMoveTransTuned = zeros(length(units),1);

upBumpTuned = zeros(length(units), 1);
downBumpTuned = zeros(length(units), 1);
leftBumpTuned = zeros(length(units), 1);
rightBumpTuned = zeros(length(units), 1);

upBumpOffTuned = zeros(length(units), 1);
downBumpOffTuned = zeros(length(units), 1);
leftBumpOffTuned = zeros(length(units), 1);
rightBumpOffTuned = zeros(length(units), 1);

upDownMoveTonicTuned = zeros(length(units),1);
upLeftMoveTonicTuned = zeros(length(units),1);
upRightMoveTonicTuned = zeros(length(units), 1);
downRightMoveTonicTuned = zeros(length(units), 1);
downLeftMoveTonicTuned = zeros(length(units), 1);
leftRightMoveTonicTuned = zeros(length(units),1);

upDownMoveTransTuned = zeros(length(units),1);
upLeftMoveTransTuned = zeros(length(units),1);
upRightMoveTransTuned = zeros(length(units), 1);
downRightMoveTransTuned = zeros(length(units), 1);
downLeftMoveTransTuned = zeros(length(units), 1);
leftRightMoveTransTuned = zeros(length(units),1);

upDownBumpTuned = zeros(length(units),1);
upLeftBumpTuned = zeros(length(units),1);
upRightBumpTuned = zeros(length(units), 1);
downRightBumpTuned = zeros(length(units), 1);
downLeftBumpTuned = zeros(length(units), 1);
leftRightBumpTuned = zeros(length(units),1);

upDownBumpOffTuned = zeros(length(units),1);
upLeftBumpOffTuned = zeros(length(units),1);
upRightBumpOffTuned = zeros(length(units), 1);
downRightBumpOffTuned = zeros(length(units), 1);
downLeftBumpOffTuned = zeros(length(units), 1);
leftRightBumpOffTuned = zeros(length(units),1);

for i = units
    if plotTuning
        maxRho = max([highRhoMoveTonic(:,i); highRhoBump(:,i)]);
        meanPreBumpFiringUnitI = meanFiringBeforeBump(i);
        meanPreMoveFiringUnitI = meanFiringBeforeMove(i);
        circleRhoBump = meanPreBumpFiringUnitI.*ones(1,length(circle));
        circleRhoMove = meanPreMoveFiringUnitI.*ones(1,length(circle));
        figure
        p = polar(0, maxRho);

        set(p, 'Visible', 'off')
        hold on
        polar(circle, circleRhoMove, 'b')
        polar(theta, highRhoMoveTonic(:,i)','r')
        polar(theta, rhoMoveTonic(:,i)', 'k')
        polar(theta, lowRhoMoveTonic(:,i)', 'r')
        title(['Electrode ', num2str(td(1).S1_unit_guide(i, 1)), ' Unit',  num2str(td(1).S1_unit_guide(i, 2)), ' Movement Tonic'])

        maxRho = max([highRhoMoveTrans(:,i); highRhoBump(:,i)]);
        meanPreBumpFiringUnitI = meanFiringBeforeBump(i);
        meanPreMoveFiringUnitI = meanFiringBeforeMove(i);
        circleRhoBump = meanPreBumpFiringUnitI.*ones(1,length(circle));
        circleRhoMove = meanPreMoveFiringUnitI.*ones(1,length(circle));
        figure
        p = polar(0, maxRho);

        set(p, 'Visible', 'off')
        hold on
        polar(circle, circleRhoMove, 'b')
        polar(theta, highRhoMoveTrans(:,i)','r')
        polar(theta, rhoMoveTrans(:,i)', 'k')
        polar(theta, lowRhoMoveTrans(:,i)', 'r')
        title(['Electrode ', num2str(td(1).S1_unit_guide(i, 1)), ' Unit',  num2str(td(1).S1_unit_guide(i, 2)), ' Movement Trans'])

        figure
        p = polar(0, maxRho);
        set(p, 'Visible', 'off')
        hold on
        polar(circle, circleRhoBump, 'b')
        polar(theta, highRhoBump(:,i)', 'r')
        polar(theta, rhoBump(:,i)', 'k')
        polar(theta, lowRhoBump(:,i)', 'r')
        title(['Electrode ', num2str(td(1).S1_unit_guide(i, 1)), ' Unit',  num2str(td(1).S1_unit_guide(i, 2)), ' Bump'])
    end
    anovaUpMoveTonic(i) = anovan([preMoveSpikes(:,i); spikesUpMoveTonic(:,i)],{[ones(length(preMoveSpikes(:,i)),1);2*ones(length(spikesUpMoveTonic(:,i)),1)]}, 'display', 'off');
    anovaUpMoveTrans(i) = anovan([preMoveSpikes(:,i); spikesUpMoveTrans(:,i)],{[ones(length(preMoveSpikes(:,i)),1);2*ones(length(spikesUpMoveTrans(:,i)),1)]}, 'display', 'off');
    anovaUpBump(i) = anovan([preBumpSpikes(:,i); spikesUpBump(:,i)],{[ones(length(preBumpSpikes(:,i)),1);2*ones(length(spikesUpBump(:,i)),1)]}, 'display', 'off');
    anovaUpBumpOff(i) = anovan([preBumpSpikes(:,i); spikesUpBumpOff(:,i)],{[ones(length(preBumpSpikes(:,i)),1);2*ones(length(spikesUpBumpOff(:,i)),1)]}, 'display', 'off');
    
    upChangeBump = mean(spikesUpBump(:,i))-mean(preBumpSpikes(:,i));
    upChangeBumpOff = mean(spikesUpBumpOff(:,i))-mean(preBumpSpikes(:,i));
    upChangeSame(i) = (sign(upChangeBump) == sign(upChangeBumpOff));
    
    anovadownMoveTonic(i) = anovan([preMoveSpikes(:,i); spikesdownMoveTonic(:,i)],{[ones(length(preMoveSpikes(:,i)),1);2*ones(length(spikesdownMoveTonic(:,i)),1)]}, 'display', 'off');
    anovadownMoveTrans(i) = anovan([preMoveSpikes(:,i); spikesdownMoveTrans(:,i)],{[ones(length(preMoveSpikes(:,i)),1);2*ones(length(spikesdownMoveTrans(:,i)),1)]}, 'display', 'off');
    anovadownBump(i) = anovan([preBumpSpikes(:,i); spikesdownBump(:,i)],{[ones(length(preBumpSpikes(:,i)),1);2*ones(length(spikesdownBump(:,i)),1)]}, 'display', 'off');
    anovadownBumpOff(i) = anovan([preBumpSpikes(:,i); spikesdownBumpOff(:,i)],{[ones(length(preBumpSpikes(:,i)),1);2*ones(length(spikesdownBumpOff(:,i)),1)]}, 'display', 'off');

    downChangeBump = mean(spikesdownBump(:,i))-mean(preBumpSpikes(:,i));
    downChangeBumpOff = mean(spikesdownBumpOff(:,i))-mean(preBumpSpikes(:,i));
    downChangeSame(i) = (sign(downChangeBump) == sign(downChangeBumpOff));
    
    anovaleftMoveTonic(i) = anovan([preMoveSpikes(:,i); spikesleftMoveTonic(:,i)],{[ones(length(preMoveSpikes(:,i)),1);2*ones(length(spikesleftMoveTonic(:,i)),1)]}, 'display', 'off');
    anovaleftMoveTrans(i) = anovan([preMoveSpikes(:,i); spikesleftMoveTrans(:,i)],{[ones(length(preMoveSpikes(:,i)),1);2*ones(length(spikesleftMoveTrans(:,i)),1)]}, 'display', 'off');    
    anovaleftBump(i) = anovan([preBumpSpikes(:,i); spikesleftBump(:,i)],{[ones(length(preBumpSpikes(:,i)),1);2*ones(length(spikesleftBump(:,i)),1)]}, 'display', 'off');
    anovaleftBumpOff(i) = anovan([preBumpSpikes(:,i); spikesleftBumpOff(:,i)],{[ones(length(preBumpSpikes(:,i)),1);2*ones(length(spikesleftBumpOff(:,i)),1)]}, 'display', 'off');

    leftChangeBump = mean(spikesleftBump(:,i))-mean(preBumpSpikes(:,i));
    leftChangeBumpOff = mean(spikesleftBumpOff(:,i))-mean(preBumpSpikes(:,i));
    leftChangeSame(i) = (sign(leftChangeBump) == sign(leftChangeBumpOff));
    
    anovarightMoveTonic(i) = anovan([preMoveSpikes(:,i); spikesrightMoveTonic(:,i)],{[ones(length(preMoveSpikes(:,i)),1);2*ones(length(spikesrightMoveTonic(:,i)),1)]}, 'display', 'off');
    anovarightMoveTrans(i) = anovan([preMoveSpikes(:,i); spikesrightMoveTrans(:,i)],{[ones(length(preMoveSpikes(:,i)),1);2*ones(length(spikesrightMoveTrans(:,i)),1)]}, 'display', 'off');
    anovarightBump(i) = anovan([preBumpSpikes(:,i); spikesrightBump(:,i)],{[ones(length(preBumpSpikes(:,i)),1);2*ones(length(spikesrightBump(:,i)),1)]}, 'display', 'off');
    anovarightBumpOff(i) = anovan([preBumpSpikes(:,i); spikesrightBumpOff(:,i)],{[ones(length(preBumpSpikes(:,i)),1);2*ones(length(spikesrightBumpOff(:,i)),1)]}, 'display', 'off');

    
    rightChangeBump = mean(spikesrightBump(:,i))-mean(preBumpSpikes(:,i));
    rightChangeBumpOff = mean(spikesrightBumpOff(:,i))-mean(preBumpSpikes(:,i));
    rightChangeSame(i) = (sign(rightChangeBump) == sign(rightChangeBumpOff));
    
    anovaUpDownMoveTonic(i) = anovan([spikesUpMoveTonic(:,i); spikesdownMoveTonic(:,i)],{[ones(length( spikesUpMoveTonic(:,i)),1);2*ones(length( spikesdownMoveTonic(:,i)),1)]}, 'display', 'off');
    anovaUpDownMoveTrans(i) = anovan([spikesUpMoveTrans(:,i); spikesdownMoveTrans(:,i)],{[ones(length( spikesUpMoveTrans(:,i)),1);2*ones(length( spikesdownMoveTrans(:,i)),1)]}, 'display', 'off');
    anovaUpDownBump(i) = anovan([spikesUpBump(:,i); spikesdownBump(:,i)],{[ones(length( spikesUpBump(:,i)),1);2*ones(length( spikesdownBump(:,i)),1)]}, 'display', 'off');
    
    anovaUpLeftMoveTonic(i) = anovan([spikesUpMoveTonic(:,i); spikesleftMoveTonic(:,i)],{[ones(length( spikesUpMoveTonic(:,i)),1);2*ones(length( spikesleftMoveTonic(:,i)),1)]}, 'display', 'off');
    anovaUpLeftMoveTrans(i) = anovan([spikesUpMoveTrans(:,i); spikesleftMoveTrans(:,i)],{[ones(length( spikesUpMoveTrans(:,i)),1);2*ones(length( spikesleftMoveTrans(:,i)),1)]}, 'display', 'off');
    anovaUpLeftBump(i) = anovan([spikesUpBump(:,i); spikesleftBump(:,i)],{[ones(length( spikesUpBump(:,i)),1);2*ones(length( spikesleftBump(:,i)),1)]}, 'display', 'off');
    
    anovaUpRightMoveTonic(i) = anovan([spikesUpMoveTonic(:,i); spikesrightMoveTonic(:,i)],{[ones(length( spikesUpMoveTonic(:,i)),1);2*ones(length( spikesrightMoveTonic(:,i)),1)]}, 'display', 'off');
    anovaUpRightMoveTrans(i) = anovan([spikesUpMoveTrans(:,i); spikesrightMoveTrans(:,i)],{[ones(length( spikesUpMoveTrans(:,i)),1);2*ones(length( spikesrightMoveTrans(:,i)),1)]}, 'display', 'off');
    anovaUpRightBump(i) = anovan([spikesUpBump(:,i); spikesrightBump(:,i)],{[ones(length( spikesUpBump(:,i)),1);2*ones(length( spikesrightBump(:,i)),1)]}, 'display', 'off');
    
    anovaDownLeftMoveTonic(i) = anovan([spikesdownMoveTonic(:,i); spikesleftMoveTonic(:,i)],{[ones(length( spikesdownMoveTonic(:,i)),1);2*ones(length( spikesleftMoveTonic(:,i)),1)]}, 'display', 'off');
    anovaDownLeftMoveTrans(i) = anovan([spikesdownMoveTrans(:,i); spikesleftMoveTrans(:,i)],{[ones(length( spikesdownMoveTrans(:,i)),1);2*ones(length( spikesleftMoveTrans(:,i)),1)]}, 'display', 'off');
    anovaDownLeftBump(i) = anovan([spikesdownBump(:,i); spikesleftBump(:,i)],{[ones(length( spikesdownBump(:,i)),1);2*ones(length( spikesleftBump(:,i)),1)]}, 'display', 'off');
    
    anovaDownRightMoveTonic(i) = anovan([spikesdownMoveTonic(:,i); spikesrightMoveTonic(:,i)],{[ones(length( spikesdownMoveTonic(:,i)),1);2*ones(length( spikesrightMoveTonic(:,i)),1)]}, 'display', 'off');
    anovaDownRightMoveTrans(i) = anovan([spikesdownMoveTrans(:,i); spikesrightMoveTrans(:,i)],{[ones(length( spikesdownMoveTrans(:,i)),1);2*ones(length( spikesrightMoveTrans(:,i)),1)]}, 'display', 'off');
    anovaDownRightBump(i) = anovan([spikesdownBump(:,i); spikesrightBump(:,i)],{[ones(length( spikesdownBump(:,i)),1);2*ones(length( spikesrightBump(:,i)),1)]}, 'display', 'off');
    
    anovaLeftRightMoveTonic(i) = anovan([spikesleftMoveTonic(:,i); spikesrightMoveTonic(:,i)],{[ones(length( spikesleftMoveTonic(:,i)),1);2*ones(length( spikesrightMoveTonic(:,i)),1)]}, 'display', 'off');
    anovaLeftRightMoveTrans(i) = anovan([spikesleftMoveTrans(:,i); spikesrightMoveTrans(:,i)],{[ones(length( spikesleftMoveTrans(:,i)),1);2*ones(length( spikesrightMoveTrans(:,i)),1)]}, 'display', 'off');
    anovaLeftRightBump(i) = anovan([spikesleftBump(:,i); spikesrightBump(:,i)],{[ones(length( spikesleftBump(:,i)),1);2*ones(length( spikesrightBump(:,i)),1)]}, 'display', 'off');
    
    if anovaUpMoveTonic(i)<pCutoff
        upMoveTonicTuned(i) = 1;
    end
    if anovadownMoveTonic(i)<pCutoff
        downMoveTonicTuned(i) = 1;
    end
    if anovaleftMoveTonic(i)<pCutoff
        leftMoveTonicTuned(i) = 1;
    end
    if anovarightMoveTonic(i)<pCutoff
        rightMoveTonicTuned(i) = 1;
    end
    
    if anovaUpMoveTrans(i)<pCutoff
        upMoveTransTuned(i) = 1;
    end
    if anovadownMoveTrans(i)<pCutoff
        downMoveTransTuned(i) = 1;
    end
    if anovaleftMoveTrans(i)<pCutoff
        leftMoveTransTuned(i) = 1;
    end
    if anovarightMoveTrans(i)<pCutoff
        rightMoveTransTuned(i) = 1;
    end
    
    if anovaUpBump(i)<pCutoff
        upBumpTuned(i) = 1;
    end
    if anovadownBump(i)<pCutoff
        downBumpTuned(i) = 1;
    end
    if anovaleftBump(i)<pCutoff
        leftBumpTuned(i) = 1;
    end
    
    if anovaUpDownMoveTonic(i)<pCutoff
        upDownMoveTonicTuned(i) = 1;
    end  
    if anovaUpDownBump(i)<pCutoff
        upDownBumpTuned(i) = 1;
    end  
    if anovaUpLeftMoveTonic(i)<pCutoff
        upLeftMoveTonicTuned(i) = 1;
    end  
    if anovaUpLeftBump(i)<pCutoff
       upLeftBumpTuned(i) = 1;
    end  
    if anovaUpRightMoveTonic(i)<pCutoff
        upRightMoveTonicTuned(i) = 1;
    end 
    
    
    if anovaUpDownMoveTrans(i)<pCutoff
        upDownMoveTransTuned(i) = 1;
    end   
    if anovaUpLeftMoveTrans(i)<pCutoff
        upLeftMoveTransTuned(i) = 1;
    end  
    if anovaUpRightMoveTrans(i)<pCutoff
        upRightMoveTransTuned(i) = 1;
    end 
    
    
    if anovaUpRightBump(i)<pCutoff
        upRightBumpTuned(i) = 1;
    end  
    if anovaDownLeftMoveTonic(i)<pCutoff
        downLeftMoveTonicTuned(i) = 1;
    end  
    if anovaDownLeftBump(i)<pCutoff
        downLeftBumpTuned(i) = 1;
    end  
    if anovaDownRightMoveTonic(i)<pCutoff
        downRightMoveTonicTuned(i) = 1;
    end  
    if anovaDownRightBump(i)<pCutoff
        downRightBumpTuned(i) = 1;
    end  
    if anovaLeftRightMoveTonic(i)<pCutoff
        leftRightMoveTonicTuned(i) = 1;
    end  
    if anovaLeftRightBump(i)<pCutoff
        leftRightBumpTuned(i) = 1;
    end  
    
    if anovaUpRightBump(i)<pCutoff
        upRightBumpTuned(i) = 1;
    end  
    if anovaDownLeftMoveTrans(i)<pCutoff
        downLeftMoveTransTuned(i) = 1;
    end  
    if anovaDownLeftBump(i)<pCutoff
        downLeftBumpTuned(i) = 1;
    end  
    if anovaDownRightMoveTrans(i)<pCutoff
        downRightMoveTransTuned(i) = 1;
    end  
    if anovaDownRightBump(i)<pCutoff
        downRightBumpTuned(i) = 1;
    end  
    if anovaLeftRightMoveTrans(i)<pCutoff
        leftRightMoveTransTuned(i) = 1;
    end  
    if anovaLeftRightBump(i)<pCutoff
        leftRightBumpTuned(i) = 1;
    end 
    
    if anovarightBumpOff(i)<pCutoff
        rightBumpOffTuned(i) = 1;
    end 
    if anovaleftBumpOff(i)<pCutoff
        leftBumpOffTuned(i) = 1;
    end
    if anovaUpBumpOff(i)<pCutoff
        upBumpOffTuned(i) = 1;
    end
    if anovadownBumpOff(i)<pCutoff
        downBumpOffTuned(i) = 1;
    end
end
anyMoveTonicTuning = [upMoveTonicTuned | downMoveTonicTuned| leftMoveTonicTuned| rightMoveTonicTuned];
anyMoveTransTuning = [upMoveTransTuned | downMoveTransTuned| leftMoveTransTuned| rightMoveTransTuned];
anyBumpTuning = [upBumpTuned | downBumpTuned| leftBumpTuned| rightBumpTuned];

onOffBumpTuning= [(upBumpTuned& upBumpOffTuned & upChangeSame') | (downBumpTuned & downBumpOffTuned& downChangeSame') | (leftBumpTuned & leftBumpOffTuned & leftChangeSame')| (rightBumpTuned & rightBumpOffTuned & rightChangeSame')];

percentOnOffBumpTuning = sum(onOffBumpTuning)./length(onOffBumpTuning);

bestMoveTonicP = min([anovaUpMoveTonic; anovadownMoveTonic; anovaleftMoveTonic; anovarightMoveTonic]);
bestMoveTransP = min([anovaUpMoveTrans; anovadownMoveTrans; anovaleftMoveTrans; anovarightMoveTrans]);
bestBumpP = min([anovaUpBump; anovadownBump; anovaleftBump; anovarightBump]);

difMoveTonicTuning = [upDownMoveTonicTuned| upLeftMoveTonicTuned| upRightMoveTonicTuned| downLeftMoveTonicTuned| downRightMoveTonicTuned| leftRightMoveTonicTuned];
difMoveTransTuning = [upDownMoveTransTuned| upLeftMoveTransTuned| upRightMoveTransTuned| downLeftMoveTransTuned| downRightMoveTransTuned| leftRightMoveTransTuned];
difBumpTuning = [upDownBumpTuned| upLeftBumpTuned| upRightBumpTuned| downLeftBumpTuned| downRightBumpTuned| leftRightBumpTuned];

percentMoveTonicTuned = sum(anyMoveTonicTuning)./length(anyMoveTonicTuning);
percentMoveTransTuned = sum(anyMoveTransTuning)./length(anyMoveTransTuning);

percentBumpTuned = sum(anyBumpTuning)./length(anyBumpTuning);
percentUpBumpTuned = sum(upBumpTuned)./length(upBumpTuned);
percentDownBumpTuned = sum(downBumpTuned)./length(downBumpTuned);
percentLeftBumpTuned = sum(leftBumpTuned)./length(leftBumpTuned);
percentRightBumpTuned = sum(rightBumpTuned)./length(rightBumpTuned);


percentUpMoveTonicTuned = sum(upMoveTonicTuned)./length(upMoveTonicTuned);
percentDownMoveTonicTuned = sum(downMoveTonicTuned)./length(downMoveTonicTuned);
percentLeftMoveTonicTuned = sum(leftMoveTonicTuned)./length(leftMoveTonicTuned);
percentRightMoveTonicTuned = sum(rightMoveTonicTuned)./length(rightMoveTonicTuned);

percentDifMoveTonicTuned = sum(difMoveTonicTuning)./length(difMoveTonicTuning);

percentUpMoveTransTuned = sum(upMoveTransTuned)./length(upMoveTransTuned);
percentDownMoveTransTuned = sum(downMoveTransTuned)./length(downMoveTransTuned);
percentLeftMoveTransTuned = sum(leftMoveTransTuned)./length(leftMoveTransTuned);
percentRightMoveTransTuned = sum(rightMoveTransTuned)./length(rightMoveTransTuned);

percentDifMoveTransTuned = sum(difMoveTransTuning)./length(difMoveTransTuning);
percentDifBumpTuned = sum(difBumpTuning)./length(difBumpTuning);

moveTonicTunedUnits = td(1).S1_unit_guide(anyMoveTonicTuning,:);
moveTransTunedUnits = td(1).S1_unit_guide(anyMoveTransTuning,:);
bumpTunedUnits = td(1).S1_unit_guide(anyBumpTuning,:);