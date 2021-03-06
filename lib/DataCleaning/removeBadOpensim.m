function [tdOut,removeTrials] = removeBadOpensim(td, params)
    bin_size = td(1).bin_size;
    zeroParam = 1e-10;
    ucThresh = .000001;
    removeDistal = true;
    if nargin > 1, assignParams(who,params); end % overwrite defaults
    
    removeTrials =[];
    
    for i = 1:length(td)
        trial = td(i);
        if isfield(trial, 'opensim')
        opensim = trial.opensim(:,15:53);
        joints = trial.opensim(:,1:7);
        else
            opensim = trial.muscle_len;
            joints = trial.joint_ang;
        end
        dOpensim = diff(opensim);
        mDOpensim = mean(dOpensim,2);
        unchanged = any(range(opensim) < ucThresh);
        jointsOutOfRange = ~areJointsInRange(joints);
        if  unchanged |jointsOutOfRange %| any(any(abs(dOpensim) < zeroParam)) |
            removeTrials = [removeTrials,i];
        end
        
    end
    disp(['Removing ', num2str(length(removeTrials)), ' trials due to bad opensim'])
    tdOut = td;
    tdOut(removeTrials) = [];
end