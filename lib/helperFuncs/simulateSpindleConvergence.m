function [spinConvFiring, pd] = simulateSpindleConvergence(hVel1, spindleIn, params)
    muscleVec = 1:5;
    numSims = 1000;
    numBoots = 1;
    plotExampleCombs = false;
    reflectHandVel = false;
    truncateBodyLobe = false;
    plotPDs = false;
    if nargin > 2, assignParams(who,params); end % overwrite parameters
    if reflectHandVel
        hVel1(:,1) = hVel1(:,1)*-1;
    end
    if truncateBodyLobe
        figure
        histogram(spindleIn{1})
    end
    %% For each number of muscle spindles to combine here
    for i = muscleVec
        
        %% For each bootrap iteration
        for boot = 1:numBoots
            %% Number of simulations
            for j = 1:numSims
                %% For a single simulation
                disp(['Muscle num ', num2str(i), ' Sim number ',  num2str(j)])
                % Make a vector that picks a number of random spindles.
                randMuscle = randi(length(spindleIn{1}(:,1)),i,1);
                % Scale each input to the postsynaptic neuron
                weights = 10*(rand(1, i)-0.5);
                %% If we arent combining anything, make it positive weights only.
                if i ==1
                    temp = spindleIn{boot}(randMuscle,:)' *abs(weights');
                else
                    temp = spindleIn{boot}(randMuscle,:)' * weights';
                end
                for mus = 1:i
                    lmT = fitlm(hVel1, spindleIn{boot}(randMuscle(mus),:));
                    pdT(mus) = atan2(lmT.Coefficients.Estimate(3), lmT.Coefficients.Estimate(2));
                    w(mus) = weights(mus);
                    vLen1(mus) = norm(lmT.Coefficients.Estimate(2:3));
                end
                %% 
                hVelAng = atan2(hVel1(:,2), hVel1(:,1));
                binVec = -pi:pi/8:pi;
                hVelInds = getIndicesInsideEdge(hVelAng, binVec);
                for bin = 1:length(binVec)-1
                    mFR(bin) = mean(temp(hVelInds(bin,:)));
                end
                % Add bias to make all firing positive
                temp = temp - min(mFR);
                % If it's less than zero still, set it to zero
                temp(temp<0)=0;
%                 temp = temp - min(temp);
                spinConvFiring{i, boot}(j,:) = temp;
                
%                 disp(rad2deg(pdT))
%                 disp(w)
                lm1 = fitlm(hVel1, spinConvFiring{i, boot}(j,:));
                pd{boot}(i,j) = atan2(lm1.Coefficients.Estimate(3), lm1.Coefficients.Estimate(2));
                vLen = norm(lm1.Coefficients.Estimate(2:3));
%                 disp(rad2deg(pd{boot}(i,j)))
                if plotPDs
                    vec1 = w(1)*vLen1(1);
                    vec2 = w(2)*vLen1(2);
                    figure
                    polarplot([pdT(1), pdT(1)], [0, vec1])
                    hold on
                    polarplot([pdT(2), pdT(2)], [0, vec2])
                    
                    polarplot([pd{boot}(i,j),pd{boot}(i,j)], [0, max(abs([vec1, vec2]))])
                    legend({'mus1', 'mus2', 'comb'})
                end
                if plotExampleCombs
                    figure
                    hVelMag = rownorm(hVel1);
                    polarscatter(hVelAng, temp)
                    hold on
                    polarplot([pd{boot}(i,j), pd{boot}(i,j)], [0, max(temp)])
                    polarplot(binVec(1:end-1), mFR)
                end
            end
        end
    end
end