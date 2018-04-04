function coActPasPlotting(inStruct)
%coActPasPlotting: Plots the popultaion stats based on the computed firing
%rates in each direction from the CO active passive task
%   Inputs: See this section. Need a structure with the PD angle for both
%   move and bump directions, whether it is 'tuned', by some metric, the
%   difference in angle between active and passive dirs, the change in
%   firing from baseline in both move and bump conditions, and the
%   modulation depth (calculated somehow) of those conditions

%   Outputs: Plots of 
%   1) active PD dir vs passive PD dir for each neuron
%   2) angle between these PDs
%   3) Firing rate change from baseline across all directions
%   4) Modulation depths in active vs. passive cases

date1 =         inStruct.date;
array=          inStruct.array;
angBump=        {inStruct.angBump};
angMove =       {inStruct.angMove};
tuned =         [inStruct.tuned];
pasActDif =     inStruct.pasActDif;
dcBump =        [inStruct.dcBump];
dcMove =        [inStruct.dcMove];
modDepthMove =  [inStruct.modDepthMove];
modDepthBump =  [inStruct.modDepthBump];

f3 = figure;
angBumpTunedTemp= [angBump{tuned}];
angBumpTuned = [angBumpTunedTemp.mean];
angMoveTunedTemp = [angMove{tuned}];
angMoveTuned = [angMoveTunedTemp.mean];
scatter(rad2deg(angBumpTuned), rad2deg(angMoveTuned))
hold on
plot([-180, 180], [-180, 180])
ylim([-180, 180])
xlim([-180, 180])
title('Angle of PD in Active/Passive Conditions')
xlabel('Passive PD')
ylabel('ActivePD')
set(gca,'TickDir','out', 'box', 'off', 'xtick', [-180,-135, -90,-45,0,45, 90, 135, 180],'ytick', [-180,-135, -90,-45,0,45, 90, 135, 180])
save2pdf(['ActiveVsPassive_',array,'_',  date1,'.pdf'],f3)

pasActDif = angleDiff(angBumpTuned, angMoveTuned);
f4 =figure;
histogram(rad2deg(pasActDif),15)
title('Angle Between Active and Passive')
% pctSigBump = sum(sigDifBump)/12;
% pctSigMove = sum(sigDifMove)/12;
save2pdf(['AngleBetweenActPas_',array,'_',  date1,'.pdf'],f4)

f5 = figure; 
nBins = 15;
h1 = histogram(dcBump(tuned),nBins);
width = h1.BinWidth; 
hold on
histogram(dcMove(tuned),'BinWidth', width)
legend('Bump change', 'Move Change')
title('Move Avg. Firing vs. Bump Avg. Firing')
save2pdf(['AvgFiringMoveVsBump_',array,'_',  date1,'.pdf'], f5)

f6 = figure;
scatter(modDepthMove(tuned), modDepthBump(tuned))
title('Modulation Depth in Active vs. Passive')
xlabel('Max Modulation Depth in Active')
ylabel('Max Modulation Depth in Passive')
set(gca,'TickDir','out', 'box', 'off')
save2pdf(['ModDepth_',array,'_', date1,'.pdf'], f6)

end

