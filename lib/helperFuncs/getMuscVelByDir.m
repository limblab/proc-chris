function [muscVel, dirs] = getMuscVelByDir(td, bumpFlag)

    osNames = td(1).opensim_names; % get Opensim names
    if bumpFlag
        [dirs, indArr] = getBumpDirs(td);
    else
        [dirs, indArr] = getTargetDirs(td);
    end
    dirs = sort(dirs);
    for i = 1:length(dirs)
        tdDir = td(logical(indArr(:,i)));
        os = cat(3, tdDir.opensim);
        mVel = os(:,54:end,:);
        hVel = cat(3, tdDir.vel);
        hVel1(:,:,i) = mean(hVel,3);
        mNames = osNames(54:end);
        muscVel(:,:,i) = mean(mVel,3);
    end


end