function isGracile = getGracile(monkey, elec)
    if strcmp(monkey, 'Butter')
        isGracile = any(elec == [1 2 3 4 5 9 10 11 12 13 14 19 20 21 22 29 30 31 32 39 40 41 42 44 49 50 59 60 62 69 70 79 80 89]);
    elseif strcmp(monkey, 'Lando')
        isGracile = any(elec == [78 88 68 58 56 48 57 38 47 28 37 36 18 45 46 8 35 16 24 7 26 6 25 5 15 4 14 3 13 2 77 67 76 66 75 65 93 94 95 96]);
    elseif strcmp(monkey, 'Crackle')
        isGracile = any(elec == [1, 13]);
    elseif strcmp(monkey, 'Snap')
        isGracile = any(elec == [1,2,3,4,5,6,13,14,15,16,17,25,26,27,28,37,38,39,49,50]);
    end
end