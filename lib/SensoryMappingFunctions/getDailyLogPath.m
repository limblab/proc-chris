function path = getDailyLogPath(monkey)
    if strcmp(monkey, 'Snap')
        path = '\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\limblab\lab_folder\Animal-Miscellany\Snap 18 E1\Snap 18E1 Daily Log.xlsx';
    elseif strcmp(monkey, 'Rocket')
        path = 'D:\MonkeyData\SensoryMappings\RocketMappingSheet.xlsx';
    end
        
    end