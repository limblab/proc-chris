function goodTime = findGoodTime(dataIn)
    
    smallGrad = gradient(dataIn) <.005;
    doubleGrad = abs(gradient(gradient(dataIn)));
    badTime = all([doubleGrad(1:end-7)<1e-6, doubleGrad(2:end-6)<1e-6, doubleGrad(3:end-5)<1e-6, doubleGrad(4:end-4)<1e-6, doubleGrad(5:end-3)<1e-6, doubleGrad(6:end-2)<1e-6, doubleGrad(7:end-1)<1e-6, doubleGrad(8:end)<1e-6],2);
    badTime1= zeros(length(badTime),1);
    for i = 11:length(badTime)-10
        if(badTime(i))
            badTime1(i-10:i+10) = 1;
        end
    end
    goodTime = [ones(7,1); ~badTime1];
end