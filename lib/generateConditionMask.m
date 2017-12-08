cond =[];
for i = 1:length(td_move)
    cond = [cond; dir_act(i)*ones(length(td_act(i).pos(:,1)), 1)];
end