function mapping = getSensoryMappings(monkey)
    if strcmp(monkey, 'Butter')
        load([getBasePath(), 'SensoryMappings', filesep, 'ButterMapping20190522.mat'])
        mapping = mappingFile;
    elseif strcmp(monkey, 'Lando')
        load([getBasePath(), 'SensoryMappings', filesep, 'LandoCompiledSensoryMappings.mat'])
        mapping = mappingFile;
    elseif strcmp(monkey, 'Crackle')
        load([getBasePath(), 'SensoryMappings', filesep, 'CrackleMapping20201021.mat'])
        mapping = mappingFile;
    elseif strcmp(monkey, 'Snap')
        load([getBasePath(), 'SensoryMappings', filesep, 'SnapMapping20191010.mat'])
        mapping = mappingFile;
    elseif strcmp(monkey, 'Rocket')
        load([getBasePath(), 'SensoryMappings', filesep, 'RocketMapping20201019.mat'])
    else
        mapping = [];
    end
end