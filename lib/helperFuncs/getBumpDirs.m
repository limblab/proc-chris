function [dirs, indDirs] = getBumpDirs(td)
    dirs = uniquetol([td.bumpDir], .001);
    dirs(isnan(dirs)) = [];
    indDirs = zeros(length(td), length(dirs));
    for i = 1:length(dirs)
        indDirs(:, i) = [td.bumpDir] == dirs(i);
    end
end