function td = removeHighSpeedAtOnset(td, params)
speedLimit = 20;
if nargin > 1, assignParams(who,params); end % overwrite defaults
td1 = trimTD(td, 'idx_movement_on', 'idx_movement_on');
speeds = cat(1, td1.speed);
td(speeds>speedLimit) = [];
disp(['Removing ', num2str(sum(speeds>speedLimit)), ' trials due to high speed at movement onset'])


end