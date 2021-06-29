function [neurons, mdl]=  testForBimodality(neurons, params)
mdl= [];

if nargin > 1, assignParams(who,params); end % overwrite parameters

temp = neurons.pasTuningCurve;
temp1 =[];
if ~istable(temp)
for i = 1:length(temp)
    temp1 = [temp1; temp{i}{1}];
end
th = temp1.bins(1,:);
curves = temp1.velCurve;
else
    th = temp(1,:).bins;
    curves = temp.velCurve;
end
curves = bsxfun(@rdivide, curves, rownorm(curves)');
if length(curves(1,:))==8
elecs = neurons.chan;
ids = neurons.ID;
handVec = [1, .5, .2, .5, 1, .5,.2, .5];
handVec = handVec./norm(handVec);
handNeurons = logical(neurons.handUnit);
handTuningCurves = curves(handNeurons,:);
if length(handTuningCurves(:)) == 8
    meanHandTC = handTuningCurves;
else
    meanHandTC = mean(handTuningCurves);
end
handVec2 = meanHandTC;

sdFlag = logical(neurons.sameDayMap)  | abs(neurons.daysDiff) < 2;
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
else
    neurons.bimodProjMan = zeros(height(neurons),1);
    neurons.bimodProjMean = zeros(height(neurons),1);
    neurons.handLDAPred = zeros(height(neurons),1);
end
cutoffMan = .93;
cutoffMean = .955;
neurons.handPSTHMan = [neurons.bimodProjMan] < cutoffMan;
neurons.handPSTHMean = [neurons.bimodProjMean] < cutoffMean;
end