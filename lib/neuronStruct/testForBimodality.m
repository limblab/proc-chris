function [neurons, mdl]=  testForBimodality(neurons, params)
mdl= [];

if nargin > 1, assignParams(who,params); end % overwrite parameters

th = neurons.pasTuningCurve.bins;
th = th(1,:);
curves = neurons.pasTuningCurve.velCurve;
curves = bsxfun(@rdivide, curves, rownorm(curves)');
elecs = neurons.chan;
ids = neurons.ID;
handVec = [1, .5, .2, .5, 1, .5,.2, .5];
handVec = handVec./norm(handVec);
handNeurons = logical(neurons.handUnit);
handTuningCurves = curves(handNeurons,:);
meanHandTC = mean(handTuningCurves);
handVec2 = meanHandTC;

sdFlag = logical(neurons.sameDayMap);
handFlag = logical(neurons.handUnit);
nonHandFlag = ~logical(neurons.handUnit);
handCurves = curves(sdFlag & handFlag,:);
nonHandCurves = curves(sdFlag & nonHandFlag,:);
c1 = [handCurves;nonHandCurves];
y1 = [zeros(length(handCurves(:,1)),1); ones(length(nonHandCurves(:,1)),1)];

if isempty(mdl)
    mdl = fitcdiscr(c1, y1);
end
predClasses = predict(mdl, curves);
predTraining = predict(mdl, c1);

% figure
% polarplot([th,th(1)], [mdl.Mu(1,:), mdl.Mu(1,1)])
proj = curves*handVec'./rownorm(curves)';
proj2 = curves*handVec2'./rownorm(curves)';

% theta = [0:pi/4: 7*pi/4,0];
% for i = 1:length(curves(:,1))
%     figure
%     polarplot([th(i,:),th(i,1)], [handVec, handVec(1)])
%     hold on
%     polarplot([th(i,:),th(i,1)], [curves(i,:), curves(i,1)])
%     title(['E ', num2str(elecs(i)), ' U ', num2str(ids(i))])
%     pause
% end
neurons.bimodProjMan = proj;
neurons.bimodProjMean = proj2;
neurons.handLDAPred = predClasses;
end