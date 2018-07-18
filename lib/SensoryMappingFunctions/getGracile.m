function isGracile = getGracile(monkey, elec)
    if strcmp(monkey, 'Butter')
        isGracile = any(elec == [78, 88,68,58,56,27,36,18,35,16,24,7,26,14,3,13,2,77,74,64,73,54,61,44,21,22]);
    else strcmp(monkey, 'Lando')
        isGracile = any(elec == [78 88 68 58 56 48 57 38 47 28 37 36 18 45 46 8 35 16 24 7 26 6 25 5 15 4 14 3 13 2 77 67 76 66 75 65]);
    end
end