function [hVel1, spinFiring] = simulateSpindlesByMuscle(td, params)

    powerLaw = true;

    if nargin > 1, assignParams(who,params); end % overwrite parameters

    
    osNames = td(1).opensim_names; % get Opensim names
    os = cat(3,td.opensim); % get opensim out of Td
    len1 = cat(1,td.opensim);
    meanLen = mean(len1(:,15:53));
    
    mVel = os(:,54:end,:); % get only muscle velocities
    splitA = num2cell(mVel, [1 2]); %split A keeping dimension 1 and 2 intact
    mVelCat = vertcat(splitA{:});
    hVel = cat(3, td.vel); % get hand velocities
    hVel1 = cat(1,td.vel);
    mNames = osNames(54:end); % get only velocities

    for i = 1:length(mVelCat(1,:))
         if powerLaw
             mVelCat(:,i) = getPowerLaw(mVelCat(:,i));
         end
    end
    for samp = 1:100
        spinFiring(:,:,samp) = addPoissonSpiking(mVelCat);
    end


end