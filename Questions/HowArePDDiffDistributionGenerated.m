clear all
close all
%% Generate the points in the PD cloud
x = (rand(145, 2)-.5)*2;
n = rownorm(x);
noise  = .1;

x(rownorm(x) >1 , :) = []; % Remove those that aren't spherical
pd = rad2deg(getPD(x, noise)) ; % Generate PDs based on their angle from the center
dist = []; 
useUniform = true;
useGaussian = false;
figure

%% Plot PDs by color for visualization
pdC = floor(pd+181);
colors = linspecer(360);
colorsPD = colors(pdC, :);
scatter(x(:,1), x(:,2), 16, colorsPD, 'filled')
axis equal
set(gca,'TickDir','out', 'box', 'off')
temp = rownorm(x); % find the distance from the center for each point
nPermM = .0016/20;
numIters = 100;
numElecs = floor(100*4/pi);
recordRad = 50;


%% If you want to draw uniformly in the region around a recording electrode
if useUniform
p = 50:50:500; % Radius of recording volume to use

for i = 1:length(p)
    numNeurons(i) = nPermM*pi*p(i)^2
end
%%
figure2();
hold on
for p1= 1:length(p) % iterate through relative recording volume sizes
    pdCompiled{p1} = [];
    disp(['Working on spiral radius' , num2str(p(p1))])
    for i = 1:numIters
        disp(['Working on iteration', num2str(i)])
    x = (rand(floor(numNeurons(p1)*4/pi), 2)-.5).*p(p1);
    x(rownorm(x) >(p(p1)/2) , :) = []; % Remove those that aren't circular
%     if p1 == 5
%         figure2();
%         scatter(x(:,1), x(:,2))
%         pause
%     end
    elecs = (rand(numElecs, 2)-.5).*p(p1);
    elecs(rownorm(elecs) > (p(p1)/2) - recordRad, :) = [];
    for j = 1:length(elecs(:,1))
        units = x(rownorm(x-elecs(j,:)) < recordRad,:);
        if ~isempty(units) & length(units(:,1)) >1
        for k = 1:length(units(:,1))
            for m = 1:length(units(:,1))
                angle1 = atan2(units(k,2), units(k,1));
                angle2 = atan2(units(m,2), units(m,1));
                angleDifs{p1, i, j}(k, m) = angleDiff(angle1, angle2, true, false);% Find the PD diff
            end
        end
        temp = triu(angleDifs{p1, i, j});
        temp(temp==0) = [];
        pdCompiled{p1} = [pdCompiled{p1}, temp];
        end
    end
    end
end
%%
for i = 1:length(p)
    figure2();
    dist1 = pdCompiled{i};
    histogram(rad2deg(pdCompiled{i}), 0:10:180, 'EdgeColor', 'none', 'Normalization', 'probability')
    title(['Spiral radius of ',num2str(p(i))])
    xlabel('PD change (degrees)')
    ylabel('Percent of Neurons')
end
%% The uniform distribution is a somewhat unrealistic depiction of what to expect.
%% Gaussian sampling is more likely
elseif useGaussian
    gSD = .02:.02:.1; % Radius of recording volume to use
    figure2();
    hold on
    for p1= 1:length(gSD) % iterate through relative recording volume sizes
    disp(['Working on size equals ', num2str(gSD(p1))])
    circRad = gSD(p1); % Input the radius of the circle
    centerInd = find(temp-circRad >0); % Make sure that you pick a center point that doesnt have any edge effects
    pdDifs = []; 
    gSD1 = gSD(p1);
    neuronsPerSample = 50;
    %% For each point that you can pick
    for i = 1:length(centerInd)
        inCircle =[];
        r = mvnrnd(x(centerInd(i),:), [gSD1, gSD1], neuronsPerSample);
        pd1 = getPD(r, noise);
        for j = 1:neuronsPerSample
            for k = 1:neuronsPerSample
                pdDif(j,k) = angleDiff(pd1(j), pd1(k), true, false);
            end
        end
        temp1 = triu(pdDif); % Find upper triangular PD shifts (diagonal is always zero and matric is symmetric)
        temp2 = temp1; 
        temp2(temp2==0) = []; % get rid of any zeros
        pdDifs =  [pdDifs,temp2]; % Add it to the list
    end
    %% Plotting
    pdDifs = rad2deg(pdDifs);
    subplot(length(gSD), 1,p1)
    pdSave{p1} = pdDifs;
    histogram(pdDifs, 0:10:180, 'EdgeColor', 'none', 'Normalization', 'probability')
    xlim([0, 180])
    set(gca,'TickDir','out', 'box', 'off')
    if p1 ~=length(gSD)
        set(gca, 'XTickLabel', []);
    end
%     ylim([0, 1])
    title(['Gauss SD = ', num2str(gSD(p1))])
    end
    suptitle('Effects of gaussian SD of cortical swirls')
    xlabel('Pd distance (deg)')
    ylabel('% of units')
end
function pdOut = getPD(xIn, noise)
    pdOut = atan2(xIn(:,2), xIn(:,1)) + normrnd(0, deg2rad(noise), length(xIn(:,1)), 1);
    pdOut(pdOut>pi) = pdOut(pdOut>pi) - 2*pi;
    pdOut(pdOut<-pi) = pdOut(pdOut<-pi) +2*pi;
end