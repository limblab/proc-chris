close all
filteredEMG = zeros(height(cds.emg(:,1)),7);
for i = 1:22
    rawEMG = cds.emg(:, i+1);
    filteredEMG(:,i) = emgProcessing(table2array(rawEMG));
    downEMG(:,i) = decimate(filteredEMG(:,i), 100);
end

%%
cutEMG = downEMG(1:44448,:);
binned = ex.bin.data(1:44448,:);
brachialisLen = binned.pectoralis_sup_len*1000;
brachialisVel = binned.pectoralis_sup_muscVel*1000;
brachialisUnit = binned.RightCuneateCH75ID1;
binnedArray = table2array(binned);
%%
[t, mu, dmudt, spindleOut] = runHasan(brachialisLen, brachialisVel, 1);
disp('1')
[t, mu, dmudt, spindleOut2] = runHasan(brachialisLen, brachialisVel, 2);
disp('1')
[t, mu, dmudt, spindleOut3] = runHasan(brachialisLen, brachialisVel, 3);
disp('1')
[t, mu, dmudt, spindleOut4] = runHasan(brachialisLen, brachialisVel, 4);
disp('1')

%%
bumpWindows = [
%%
close all
shorteningFlag = (brachialisVel)>.001;
spindleFlag = (spindleOut)>0;
figure
fit1 = fitlm([brachialisLen(shorteningFlag),brachialisVel(shorteningFlag)], brachialisUnit(shorteningFlag));
plot(fit1)
figure
scatter(spindleOut(spindleFlag), brachialisUnit(spindleFlag))
fit2 = fitlm(spindleOut(spindleFlag), brachialisUnit(spindleFlag));
plot(fit2)

%%
close all
fitMuscles = fitlm(binnedArray(:,40:117), brachialisUnit)
fitDoFs = fitlm(binnedArray(:,26:39), brachialisUnit)
figure
plot(fitMuscles)
figure
plot(fitDoFs)

%%
fitMuscle = fitlm([brachialisLen,brachialisVel], brachialisUnit)
figure
plot(fitMuscle)
%%
close all
fitSpindle1 = fitlm(spindleOut, brachialisUnit)
fitSpindle2= fitlm(spindleOut2, brachialisUnit)
fitSpindle3= fitlm(spindleOut3, brachialisUnit)
fitSpindle4= fitlm(spindleOut4, brachialisUnit)

figure 
plot(fitSpindle1)
figure 
plot(fitSpindle2)
figure 
plot(fitSpindle3)
figure 
plot(fitSpindle4)
%%
fitGLM = cvglmnet(binnedArray(:,40:117),brachialisUnit, 'poisson')