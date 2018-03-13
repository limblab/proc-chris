function factorOut= stretchFactors(factors)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
factorOut = [];
for i =1:length(factors(1,1,:))
    factorOut = [factorOut; factors(:,:,i)'];
end
end

