function [spinConvFiring, pd] = simulateSpindleConvergence(hVel1, spindleIn, params)
    muscleVec = 1:10;
    numSims = 1000;
    numBoots = 5;
    if nargin > 2, assignParams(who,params); end % overwrite parameters
    for i = muscleVec
        for boot = 1:numBoots
            for j = 1:numSims
                disp(['Muscle num ', num2str(i), ' Sim number ',  num2str(j)])
                randMuscle = randi(length(spindleIn{1}(:,1)),i,1);
                weights = 10*(rand(1, i)-0.5);
                temp = spindleIn{boot}(randMuscle,:)' * weights';
                temp = temp - min(temp);
                spinConvFiring{i, boot}(j,:) = temp;
                lm1 = fitlm(hVel1, spinConvFiring{i, boot}(j,:));
                pd{boot}(i,j) = atan2(lm1.Coefficients.Estimate(3), lm1.Coefficients.Estimate(2));
            end
        end
    end
end