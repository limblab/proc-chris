function isGracile = getGracile(monkey, elec)
    if strcmp(monkey, 'Butter')
        isGracile = any(elec == [78,88,68,58,56, 27,36,18, 35,16,24,7,26,14,3,13,2,77,74,64,73,54,61,44,21,22,94,85,40]);
    else strcmp(monkey, 'Lando')
        error('not parsed yet. Find Landos gracile units')
    end
end