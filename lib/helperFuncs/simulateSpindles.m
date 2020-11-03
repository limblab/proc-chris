function [hVel1, spinFiring] = simulateSpindles(td, params)
    numSpindles = 1000;
    numBoots = 5;
    root = true;
    geometricCount = true;
    powerLaw = true;
    poissonNoise = true;
    forcesInput = [58.2, 38.7, 135.6, 135.6, 116.1, 406.5, 44.8, 174.3, 129.0, 129.0, 129.0, 154.8, 116.1,290.4,135.0, 135.6,116.1,135.6];

    if nargin > 1, assignParams(who,params); end % overwrite parameters
    if ~root
        forces = round(forcesInput);  
    else
        forces = round(sqrt(forcesInput));  
    end
    distalM = [1,2,6,7,12,13, 14,15,16,17,18,19,20,21,22, 27, 30, 31, 33, 35, 36];
    
    osNames = td(1).opensim_names; % get Opensim names
    os = cat(3,td.opensim); % get opensim out of Td
    len1 = cat(1,td.opensim);
    meanLen = mean(len1(:,15:53));
    meanLen(distalM) = [];
    unmapVec = 1:39;
    unmapVec(distalM) = [];
    mVel = os(:,54:end,:); % get only muscle velocities
    mVel(:,distalM,:) =[]; % get rid of distal muslces
    splitA = num2cell(mVel, [1 2]); %split A keeping dimension 1 and 2 intact
    mVelCat = vertcat(splitA{:});
    hVel = cat(3, td.vel); % get hand velocities
    hVel1 = cat(1,td.vel);
    mNames = osNames(54:end); % get only velocities
    mNames(distalM) =[]; % get rid of distal labels
    if geometricCount
        forces = sqrt(forcesInput.*meanLen);
        forces = round(numSpindles * forces/sum(forces));
    end
    for i = 1:length(mVelCat(1,:))
         if powerLaw
             mVelCat(:,i) = getPowerLaw(mVelCat(:,i));
         end
    end
    muscleMat = [];
    for i = 1:length(meanLen)
        muscleMat = [muscleMat; i*ones(forces(i), 1)];
    end
    for boot = 1:numBoots
        randInts= randi(length(muscleMat), numSpindles,1);
        spinFiring{boot} = addPoissonSpiking(mVelCat(:,muscleMat(randInts))');
    end

end