function vel = getPowerLaw(velIn)
    negFlag = velIn<0;
    velIn = abs(velIn);
    velIn = sqrt(velIn);
    velIn(negFlag) = velIn(negFlag)*0;
    vel = velIn;
end