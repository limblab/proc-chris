rewardTrials = trial_data_actpas(strcmp({trial_data_actpas.result}, 'R'));
moveOnsetTD = getMoveOnsetAndPeak(rewardTrials);
trimmedTD = trimTD(moveOnsetTD, 'idx_movement_on', {'idx_movement_on', 30});
tensorAll=  cat(3, trimmedTD.S1_spikes);
nums = randperm(length(tensorAll(1,1,:)));
trainInds = nums(1:floor(.9*length(nums)));
testInds = nums(floor(.9*length(nums)):end);
trainTensorSkew = tensorAll(:,:,trainInds);
testTensorSkew = tensorAll(:,:, testInds);

trainTensor = permute(trainTensorSkew, [3, 1, 2]);
testTensor = permute(testTensorSkew, [3,1,2]);

h5create('ChipsDataCO', '/valid_data', [35, 31, 71], 'Datatype', 'int32')
h5create('ChipsDataCO', '/train_data', [306, 31, 71], 'Datatype', 'int32')
h5write('ChipsDataCO', '/valid_data', testTensor);
h5write('ChipsDataCO', '/train_data', trainTensor);

h5create('ChipsDataCO','/condition_labels_train', [0]);
h5create('ChipsDataCO','/condition_labels_valid', [0]);
h5create('ChipsDataCO','/conversion_factor', [0]     );
h5create('ChipsDataCO','/dt', [0]                    );
h5create('ChipsDataCO','/nspikifications', [0]       );
h5create('ChipsDataCO','/train_data' , [0]           );
h5create('ChipsDataCO','/train_ext_input'  , [0]     );
h5create('ChipsDataCO','/train_percentage' , [0]     );
h5create('ChipsDataCO','/train_truth' , [0]          );
h5create('ChipsDataCO','/valid_data'   , [0]         );
h5create('ChipsDataCO','/valid_ext_input' , [0]      );
h5create('ChipsDataCO','/valid_truth' , [0]          );

h5write('ChipsDataCO','/condition_labels_train', []);
h5write('ChipsDataCO','/condition_labels_valid', []);
h5write('ChipsDataCO','/conversion_factor', []     );
h5write('ChipsDataCO','/dt', []                    );
h5write('ChipsDataCO','/nspikifications', []       );
h5write('ChipsDataCO','/train_data' , []           );
h5write('ChipsDataCO','/train_ext_input'  , []     );
h5write('ChipsDataCO','/train_percentage' , []     );
h5write('ChipsDataCO','/train_truth' , []          );
h5write('ChipsDataCO','/valid_data'   , []         );
h5write('ChipsDataCO','/valid_ext_input' , []      );
h5write('ChipsDataCO','/valid_truth' , []          );

