function str1 = getBumpDirStr(trial)
    switch mod(trial.bumpDir, 360)
        case 0
            str1 = 'Right';
        case 45
            str1 = 'Up Right';
        case 90
            str1 = 'Up';
        case 135
            str1 = 'Up Left';
        case 180
            str1 = 'Left';
        case 225
            str1 = 'Down Left';
        case 270
            str1 = 'Down';
        case 315
            str1 = 'Down Right';
        otherwise
            str1 = 'Failure';
    end
end