function out11 = findResistive(dirs, indFlag)
    if ~exist('indFlag') | ~indFlag
    for i =1:length(dirs)
        switch dirs(i)
            case 0
                out11(i) = 180;
            case 45
                out11(i) = 225;
            case 90
                out11(i) = 270;
            case 135
                out11(i) = 315;
            case 180
                out11(i) = 0;
            case 225
                out11(i) = 45;
            case 270
                out11(i) = 90;
            case 315
                out11(i) = 135;
        end
    end
    else
        for i =1:length(dirs)
        switch dirs(i)
            case 1
                out11(i) = 5;
            case 2
                out11(i) = 6;
            case 3
                out11(i) = 7;
            case 4
                out11(i) = 8;
            case 5
                out11(i) = 1;
            case 6
                out11(i) = 2;
            case 7
                out11(i) = 3;
            case 8
                out11(i) = 4;
        end
    end
end