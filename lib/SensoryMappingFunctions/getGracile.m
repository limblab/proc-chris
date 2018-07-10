function isGracile = getGracile(monkey, elec)
    if strcmp(monkey, 'Butter')
        isGracile = any(elec == [1, 2,3,4,5,9,10,11,12,13,14,19,20,21,22,29,30,31,32,39,40,41,42,49,50,59,60,69,70,79,80,89]);
    else strcmp(monkey, 'Lando')
        error('not parsed yet. Find Landos gracile units')
    end
end