clearvars -except td1
monkey = 'Duncan';
task = 'CObumpmove';
date = '20191106';
num1 = 1;
smoothWidth = .03;
if ~exist('td1')
    td = getTD(monkey, date, task, num1);
    td = getSpeed(td);
    td = tdToBinSize(td, 10);
    td = getMoveOnsetAndPeak(td);
    td = removeUnsorted(td);
    
    td1 = smoothSignals(td, struct('signals', ['LeftS1_spikes'], 'calc_rate',true, 'width', smoothWidth));

end

dirsM = unique([td1.target_direction]);
dirsM(isnan(dirsM)) = [];

bumps = td1(~isnan([td1.bumpDir]));

dirsB = unique([bumps.bumpDir]);
dirsB(isnan(dirsB)) = [];

map = [deg2rad([bumps.bumpDir]); bumps.target_direction];
chBump = bumps([bumps.idx_goCueTime] > [bumps.idx_bumpTime]);
mBump = bumps([bumps.idx_goCueTime] < [bumps.idx_bumpTime]);
nBump = td1(isnan([td1.idx_bumpTime]));

%%
nBump(isnan([nBump.idx_movement_on])) = [];
chBump = trimTD(chBump, 'idx_bumpTime', {'idx_bumpTime', 13});
mBump = trimTD(mBump, 'idx_bumpTime', {'idx_bumpTime',13});

nBump = trimTD(nBump, {'idx_goCueTime',25}, {'idx_goCueTime', 38});
%%
close all
chPos = cat(1, chBump.pos);
mPos = cat(1, mBump.pos);
nPos = cat(1, nBump.pos);

chVel = cat(1, chBump.vel);
mVel = cat(1, mBump.vel);
nVel = cat(1, nBump.vel);
    
figure
hold on
scatter(nPos(:,1), nPos(:,2))
scatter(mPos(:,1), mPos(:,2))
scatter(chPos(:,1), chPos(:,2))


title('Position in each case')
legend('Movement', 'No Bump', 'chBump')


figure
hold on
scatter(nVel(:,1), nVel(:,2))
scatter(mVel(:,1), mVel(:,2))
scatter(chVel(:,1), chVel(:,2))

title('Velocity')
legend('Movement', 'Move Bump', 'chBump')

%%
guide = td1.LeftS1_unit_guide;

firingN = cat(1, nBump.LeftS1_spikes);
firingM = cat(1, mBump.LeftS1_spikes);
firingCH = cat(1, chBump.LeftS1_spikes);

for unitNum = 1:length(guide(:,1))
    for j = 1:numFolds
        disp(['Fitting unit ', num2str(unitNum)])
        lmN = fitlm(nVel, firingN(:,unitNum));
        lmM = fitlm(mVel, firingM(:,unitNum));
        lmCH = fitlm(chVel, firingCH(:,unitNum));

        pdN(unitNum) = atan2(lmN.Coefficients.Estimate(3), lmN.Coefficients.Estimate(2));
        sensN(unitNum) = norm(lmN.Coefficients.Estimate(2:3));

        pdM(unitNum) = atan2(lmM.Coefficients.Estimate(3), lmM.Coefficients.Estimate(2));
        sensM(unitNum) = norm(lmM.Coefficients.Estimate(2:3));

        pdCH(unitNum) = atan2(lmCH.Coefficients.Estimate(3), lmCH.Coefficients.Estimate(2));
        sensCH(unitNum) = norm(lmCH.Coefficients.Estimate(2:3));
    end
end
flag = pdCH==0 | pdN == 0 | pdM ==0;
pdCH(flag) = [];
pdM(flag) = [];
pdN(flag) =[];
%%
figure
scatter(pdCH, pdN)
title('CH PD vs Movement PD')
hold on
plot([-pi, pi], [-pi, pi], 'r--')

figure
scatter(pdM, pdN)
title('Movement Bump PD vs Movement PD')
hold on
plot([-pi, pi], [-pi, pi], 'r--')

figure
scatter(pdCH, pdM)
title('CH PD vs MoveBump PD')
hold on
plot([-pi, pi], [-pi, pi], 'r--')
%%
close all
guide = td1.LeftS1_unit_guide;
for unitNum = 1:length(guide(:,1))
ch =figure;
suptitle('Center hold bumps')

m = figure;
suptitle('Movement bumps')

n = figure;
suptitle('Movements')

for i = 1:length(dirsM)
    chDir = chBump([chBump.target_direction] == dirsM(i));
    mDir = mBump([mBump.target_direction] == dirsM(i));
    nDir = nBump([nBump.target_direction] == dirsM(i));
    
    frCH{i} = cat(3, chDir.LeftS1_spikes);
    frM{i} = cat(3, mDir.LeftS1_spikes);
    frN{i} = cat(3, nDir.LeftS1_spikes);
    
    a1 = subplot(8,1,i, 'Parent', ch);
    plot(a1, squeeze(frCH{i}(:, unitNum, :)))
    ylim([0, 100])
    
    b1 = subplot(8, 1, i, 'Parent', m);
    plot(b1, squeeze(frM{i}(:,unitNum,:)))
    ylim([0, 100])
    
    c1 = subplot(8,1,i, 'Parent', n);
    plot(c1, squeeze(frN{i}(:,unitNum,:)))
    ylim([0, 100])
end
end
