pds = ex.bin.pdData;
cuneatePD = pds(strcmp(pds.array, 'Cuneate'), :);
tunedCuneate = cuneatePD(cuneatePD.posIsTuned | cuneatePD.velIsTuned| cuneatePD.forceIsTuned,:);
posTunedCuneate = cuneatePD(cuneatePD.posIsTuned,:);
velTunedCuneate = cuneatePD(cuneatePD.velIsTuned,:);
forceTunedCuneate = cuneatePD(cuneatePD.forceIsTuned,:);

thresh = pi/2;

