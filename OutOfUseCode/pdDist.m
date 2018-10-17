close all
tunedVec = [ex.bin.pdData.posIsTuned];
angleVec = [ex.bin.pdData.posDir];
velModDepth = ex.bin.pdData.posModdepth;
arrName = ex.bin.pdData.array;
figure
for i = 1:height(ex.bin.pdData)
    if (tunedVec(i) == 1)
        theta = [angleVec(i), angleVec(i)];
        rho = [0,velModDepth(i)];
        if strcmp(arrName{i},'RightCuneate')
            polar(theta, rho, 'b')
            hold on
%         else
%             polar(theta, rho, 'r')
%             hold on
        end
    end
end
title('Position Tuning')

tunedVec = [ex.bin.pdData.velIsTuned];
angleVec = [ex.bin.pdData.velDir];
velModDepth = ex.bin.pdData.velModdepth;
arrName = ex.bin.pdData.array;
figure
for i = 1:height(ex.bin.pdData)
    if (tunedVec(i) == 1)
        theta = [angleVec(i), angleVec(i)];
        rho = [0,velModDepth(i)];
        if strcmp(arrName{i},'RightCuneate')
            polar(theta, rho, 'b')
            hold on
%         else
%             polar(theta, rho, 'r')
%             hold on
        end
    end
end
title('Velocity Tuning')