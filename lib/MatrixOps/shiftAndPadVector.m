function shiftVec = shiftAndPadVector(vec, num)
    if num > 0 
        shiftVec = [zeros(num,1); vec(1:length(vec)-num)];
    elseif num<0
        shiftVec = [vec(abs(num):end); zeros(abs(num),1)];
    else
        shiftVec = vec;
end