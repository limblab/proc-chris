function mat = getMatFromYPR(yaw, pitch, roll)
rYaw = [cos(yaw), -sin(yaw), 0; sin(yaw), cos(yaw), 0 ;0,0,1];
rPitch = [cos(pitch),0, sin(pitch) ; 0,1,0 ; -sin(pitch),0, cos(pitch)];
rRoll = [1,0,0;0,cos(roll), -sin(roll), 0; sin(roll), cos(roll)];
mat = rYaw*rPitch*rRoll;
end

