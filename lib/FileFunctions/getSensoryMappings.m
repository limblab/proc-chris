function mapping = getSensoryMappings(monkey)
    if strcmp(monkey, 'Butter')
        load([getBasePath(), 'SensoryMappings', filesep, 'ButterMapping20180611.mat'])
        mapping = mappingFile;
    elseif strcmp(monkey, 'Lando')
        load([getBasePath(), 'SensoryMappings', filesep, 'LandoCompiledSensoryMappings.mat'])
        mapping = mappingFile;
    end
end