function td = removeHighSpeedAtOnset(td, params)
speedLimit = 5;
if nargin > 1, assignParams(who,params); end % overwrite defaults
td1 = trimTD(td, 'idx_movement_on_min', 'idx_movement_on_min');
speeds = cat(1, td1.speed);
td(speeds>speedLimit) = [];
disp(['Removing ', num2str(sum(speeds>speedLimit)), ' trials due to high speed at movement onset'])


end