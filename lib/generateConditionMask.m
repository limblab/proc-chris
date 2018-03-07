function [condMask] = generateConditionMask(td_move)
    td_move = td_move(~isnan([td_move.target_direction]));
    dir_act = 0:length(unique([td_move.target_direction]))-1;
    for i = 1:length(td_move)
        condMask(i) = floor(td_move(i).target_direction/(pi/2));
    end
end