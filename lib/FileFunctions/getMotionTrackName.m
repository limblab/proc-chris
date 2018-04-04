function [ name ] = getMotionTrackName( monkey, date, task, number)
%getMotionTrackName: gets the correctly formatted name for the motion
%tracking file
    name = [monkey, '_', date, '_', task, '_', num2str(number, '%03i'), '_motionTracking.mat'];
end