function mat = getMatFromYPR(yaw, pitch, roll)
    for i = 1:length(yaw)
        rYaw = [cosd(yaw(i)), -sind(yaw(i)), 0; sind(yaw(i)), cosd(yaw(i)), 0 ;0,0,1];
        rPitch = [cosd(pitch(i)),0, -sind(pitch(i)) ; 0,1,0 ; sind(pitch(i)),0, cosd(pitch(i))];
        rRoll = [1,0,0;0,cosd(roll(i)), -sind(roll(i)); 0, sind(roll(i)), cosd(roll(i))];
        mat(i,:,:) = rYaw*rPitch*rRoll;
    end
end

