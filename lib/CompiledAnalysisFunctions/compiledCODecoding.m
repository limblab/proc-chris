function [results, predicted] = compiledCODecoding(td, params)
    array= 'cuneate';
    if nargin > 1, assignParams(who,params); end % overwrite parameters
    td = smoothSignals(td, struct('signals', [array, '_spikes']));
    td = removeBadNeurons(td);
    [~, td]= getTDidx(td,'result', 'r');
    % td= removeBadTrials(td);
    td= td(~isnan([td.idx_movement_on]));
    td = trimTD(td, {'idx_movement_on'}, 'idx_endTime');
    td= tdToBinSize(td, 50);


    %% Decoding accuracy:
    Naming = td.([array, '_unit_guide']);

    Vel = cat(1, td.vel);
    Pos = cat(1, td.pos);
    Neurons = cat(1,td.([array, '_spikes']));
    SortedNeurons = Neurons(:, Naming(:,2) ~=0);

    numBoots  =100;
    P = .9;
    for i = 1:numBoots
        [m,n] = size(SortedNeurons) ;
        idx = randperm(m)  ;

        Training = SortedNeurons(idx(1:round(P*m)),:);
        TrainingPosX = Pos(idx(1:round(P*m)),1);
        TrainingPosY = Pos(idx(1:round(P*m)),2);
        TrainingVelX = Vel(idx(1:round(P*m)),1);
        TrainingVelY = Vel(idx(1:round(P*m)),2);
        TrainingSpeed = rownorm(Vel(idx(1:round(P*m)),:));

        Testing = SortedNeurons(idx(round(P*m)+1:end),:) ;
        TestingPosX = Pos(idx(round(P*m)+1:end),1);
        TestingPosY = Pos(idx(round(P*m)+1:end),2);
        TestingVelX = Vel(idx(round(P*m)+1:end),1);
        TestingVelY = Vel(idx(round(P*m)+1:end),2);
        TestingSpeed = rownorm(Vel(idx(round(P*m)+1:end),:));


        PosXModel = fitlm(Training, TrainingPosX);
        PosYModel = fitlm(Training, TrainingPosY);
        VelXModel = fitlm(Training, TrainingVelX);
        VelYModel = fitlm(Training, TrainingVelY);
        SpeedModel = fitlm(Training, TrainingSpeed);

    %   
        predicted{i} = [predict(VelXModel, Testing), TestingVelX];
        R2(i).pos = [corr(predict(PosXModel, Testing),TestingPosX).^2, corr(predict(PosYModel, Testing), TestingPosY).^2 ];
        R2(i).vel = [corr(predict(VelXModel, Testing), TestingVelX).^2, corr(predict(VelYModel, Testing), TestingVelY).^2];
        R2(i).speed= corr(predict(SpeedModel, Testing), TestingSpeed').^2;

    end

    PosMean = mean(cat(1, R2.pos),2);
    VelMean = mean(cat(1, R2.vel),2);
    SpeedMean = [R2.speed];

    SpeedBoot = sort(SpeedMean);
    PosBoot = sort(PosMean);
    VelBoot = sort(VelMean);
    
    SpeedLow = SpeedBoot(floor(.025*numBoots));
    SpeedHigh = SpeedBoot(floor(.975*numBoots));
    PosLow = PosBoot(floor(.025*numBoots));
    PosHigh =PosBoot(floor(.975*numBoots));
    VelLow = VelBoot(floor(.025*numBoots));
    VelHigh = VelBoot(floor(.975*numBoots));
    
    
    results.PosMean = mean(PosMean);
    results.PosMeanLow = PosLow;
    results.PosMeanHigh = PosHigh;
    results.VelMean = mean(VelMean);
    results.VelMeanLow = VelLow;
    results.VelMeanHigh = VelHigh;
    results.SpeedMean = mean(SpeedMean);
    results.SpeedLow = SpeedLow;
    results.SpeedHigh = SpeedHigh;
    
    tab = struct2table(results);
    if nargin >2 
        neurons.decoding = tab;
    end
end