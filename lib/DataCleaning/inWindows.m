function [ flag ] = inWindows( times, windows )
    flag = zeros(length(times),1);
    for i = 1:length(windows(:,1))
        flag(times>windows(i,1) & times<windows(i,2)) = true;
    end
    flag = logical(flag);
end

