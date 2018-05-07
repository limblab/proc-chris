

%establish cerebus connection
initializeCerebus();


    %% start recording:

ctr=0;
tmp=dir(folder);
folder = 'C://data/';
fName = 'Jango_20180508_DRGAcute_BreakoutA_001';

while isempty(cell2mat(strfind({tmp.name},fstr))) & ctr<10
    cbmex('fileconfig',fName,'',0)
    pause(.5);
    cbmex('fileconfig',fName,'DRG acute',1);
    pause(1);
    ctr=ctr+1;
    tmp=dir(folder);
end
if ctr==10
   warning('tried to start recording and failed') 
end

amps = sweepForAmplitudes();
stimmed = acuteGTOStim(amps);

%% stop recording:
cbmex('fileconfig',fName,'',0)
%     impedanceData=stimObj.testElectrodes();
%     save([folder,'impedance', tStr,num2str(j),'.mat'],'impedanceData','-v7.3')
pause(2)


% clear stim object and leave the function
cbmex('close')


pause(2);


