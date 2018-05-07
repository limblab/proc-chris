

for mm = 1:2
    clear;

    folder='C:\data\Han\Han_20180310_chic201802\';
    prefix='Han_20180310_chic201802'; % no underscore after prefix please
    
    % all parameters need to be the same size matrix
    amp1=[10,10,20,20,30,30];%in uA
    pWidth1=[200,200,200,200,200,200];%in us
    amp2=[10,10,20,20,30,30];%in uA
    pWidth2=[200,200,200,200,200,200];%in us
    
    interphase=[53,53,53,53,53,53,53];
    interpulse=[300,300,300,300,300,300];
    polarities = [0,1,0,1,0,1]; % 0 = cathodic first
   
    
    nPulses=1; % pulses per train
    nomFreq=5;
    nTests=750; % # of trains

    chanList=[25]; % pick some channels

    arg = {'interleaveChanList',1};
    saveImpedance=0;
%     if(mm == 1)
%         saveImpedance = 1;
%     else
%         saveImpedance = 0;
%     end

    runStimAndRecord;
end
