close all
clear all
data1 = h5read('C:\Users\wrest\Documents\DeeplabcutWorking\HanCO_camera1_171460DeepCut_resnet50_HanCODec6shuffle1_50000.h5', '/df_with_missing/table');
start = 2000;
end1  = 4500;

kin = data1.values_block_0([1,2,4,5,7,8],start:end1)';


scatter(kin(:,1), kin(:,2))
hold on
scatter(kin(:,3), kin(:,4))
scatter(kin(:,5), kin(:,6))

set(gca, 'YDir', 'reverse')