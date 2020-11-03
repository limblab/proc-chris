function [rm, rl, cm, cl] = getObexDims(monkey)
switch monkey
    case 'Butter'
        rm = [1.37, 2.8];
        rl = [5.08,4.32];
        cm = [2.86,-.88];
        cl = [6.54, 0.61];
    case 'Crackle'
        rm = [2.1, 2.5];
        rl = [5.3,3.2];
        cm = [3.1,-2.2];
        cl = [6.2, -1.5];
    case 'Snap'
        rm = [1.2, 2.4];
        rl = [4.4,3.1];
        cm = [2.2,-2.3];
        cl = [5.3, -1.6];
end
end