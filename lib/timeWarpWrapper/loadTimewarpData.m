function [spikes_all_preselect, max_num_trials, movement_data_all, num_nrn, kinematics] = loadTimewarpData(td, params)
    model_name    =  'default';
    in_signals    =  {};% {'name',idx; 'name',idx};
    out_signals   =  {};% {'name',idx};
    plot_on       =  false;
    onlySorted    =  true;
    model_num     =  8;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (nargin >1); assignParams(who,params);end % overwrite parameters

    if model_num == 8 || model_num == 10 || model_num == 11
        for i = 1:length(td)
            for j = 1:length(td(1).cuneate_spikes(1,:))
                spikes_all_preselect{i,j} = td(i).cuneate_spikes(:,j);
            end
            kinematics{i} = [td(i).pos, td(i).vel, td(i).acc];
            movement_data_all{i} = zeros(length(td(i).pos(:,1)),1);
            movement_data_all{i}(td(i).idx_movement_on,1) = 1;
            movement_data_all{i}(td(i).idx_movement_on,2:3) = 1/sqrt(2);
        end
        
               
%         spikes_all_preselect = remove_duplicate_neurons(spikes_all_preselect',0.4); % Removes highly correlated units. Default correlation threshold is 0.4. 
        
        num_nrn = size(spikes_all_preselect,2);
        
        outer_target_on = td.target_direction;
    end

max_num_trials = size(spikes_all_preselect,1);
movement_data_all = movement_data_all';
end