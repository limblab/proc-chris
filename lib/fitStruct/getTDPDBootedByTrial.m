function pdTable = getTDPDBootedByTrial(trial_data, params)

out_signals      =  [];
trial_idx        =  1:length(trial_data);
in_signals      = 'vel';
num_boots        =  10;
distribution = 'Poisson';
bootForTuning = true;
do_plot = false;
prefix = '';
verbose = true;
if nargin > 1, assignParams(who,params); end % overwrite parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process inputs
assert(~isempty(out_signals),'Need to provide output signal')

out_signals = check_signals(trial_data(1),out_signals);
response_var = get_vars(trial_data(trial_idx),out_signals);

in_signals = check_signals(trial_data(1),in_signals);
num_in_signals = size(in_signals,1);
for i = 1:num_in_signals
    assert(length(in_signals{i,2})==2,'Each element of in_signals needs to refer to only two column covariates')
end
input_var = get_vars(trial_data(trial_idx),in_signals);

if ~isempty(prefix)
    if ~endsWith(prefix,'_')
        prefix = [prefix '_'];
    end
end
dirArr = zeros(size(response_var,2),1);
dirCIArr = zeros(size(response_var,2),2);
moddepthArr = zeros(size(response_var,2),1);
moddepthCIArr = zeros(size(response_var,2),2);
isTuned = false(size(response_var,2),1);
tab_append = cell(1,size(in_signals,1));

for in_signal_idx = 1:size(in_signals,1)
    if bootForTuning
        tab_append{in_signal_idx} = table(dirArr,dirCIArr,moddepthArr,moddepthCIArr,isTuned,...
                        'VariableNames',strcat(prefix,in_signals{in_signal_idx,1},{'PD','PDCI','Moddepth','ModdepthCI','Tuned'}));
        tab_append{in_signal_idx}.Properties.VariableDescriptions = {'circular','circular','linear','linear','logical'};
    else
        tab_append{in_signal_idx} = table(dirArr,moddepthArr,...
                        'VariableNames',strcat(prefix,in_signals{in_signal_idx,1},{'PD','Moddepth'}));
        tab_append{in_signal_idx}.Properties.VariableDescriptions = {'circular','linear'};
    end

    if do_plot
        h{in_signal_idx} = figure;
    end
end
bootInds = randi(length(trial_data),length(trial_data),num_boots);
params.model_type = 'glm';
for i = 1:num_boots
    params.train_idx     =  bootInds(:,i);
    [~, model1] = getModel(trial_data, params);
    bs(i,:,:) = model1.b;
end
angles = atan2(squeeze(bs(:, 3, :)), squeeze(bs(:,2,:)));
[angleMean, angleHigh, angleLow] = circ_mean(angles);

modDepths = sqrt(squeeze(bs(:,2,:)).^2 + squeeze(bs(:,3,:)).^2);
modDepthsMean = mean(modDepths);
modDepthsLow = prctile(modDepths, 5);
modDepthsHigh = prctile(modDepths, 95);

tab_append{1}.velPD = angleMean';
tab_append{1}.velPDCI = [angleLow', angleHigh'];
tab_append{1}.velModdepth= modDepthsMean';
tab_append{1}.velModdepthCI = [modDepthsLow', modDepthsHigh'];
starter = makeNeuronTableStarter(trial_data,params);
pdTable = horzcat(starter,tab_append{:});


end