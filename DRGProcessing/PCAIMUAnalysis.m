close all
foreArmArr = table2array(tbl3);
upArmArr = table2array(tbl1);
handArr = table2array(tbl2);

[matElb, scoresElb] = pca(foreArmArr(elbowFlexion,:));
[matSho, scoresSho] = pca(upArmArr(shoulderFlexion,:));
[matWrist, scoresWrist] = pca(handArr(wristFlexion,:));

figure
plot(scoresElb)
title('PCA of forearm kin during elbow flexion')

extendedArmTime = input('Look at the plot and enter the index when the elbow is fully extended (a trough)');
extendedArmTime = extendedArmTime + elbowFlexion(1);
upArmCal = upArmArr(extendedArmTime,:);
lowArmCal = foreArmArr(extendedArmTime,:);
handCal = handArr(extendedArmTime,:);

upArmArr = upArmArr -upArmCal;
foreArmArr = foreArmArr - lowArmCal;
handArr = handArr - handCal;
