function [dirs, indDirs] = getTargetDirs(td)
    dirs = uniquetol([td.target_direction], .001);
    dirs(isnan(dirs)) = [];
    indDirs = zeros(length(td), length(dirs));
    for i = 1:length(dirs)
        indDirs(:, i) = [td.target_direction] == dirs(i);
    end
end