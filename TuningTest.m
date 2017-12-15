for i = 1:length(ex.bin.pdData.chan)
    tuningNum(i) = sum([ex.bin.pdData.posIsTuned(i), ex.bin.pdData.velIsTuned(i), ex.bin.pdData.forceIsTuned(i)]);
    tuningType(i,1) = ex.bin.pdData.posIsTuned(i);
    tuningType(i,2) = ex.bin.pdData.velIsTuned(i);
    tuningType(i,3) = ex.bin.pdData.forceIsTuned(i);
end
posTuningOnly = tuningType(:,1) & ~(tuningType(:,2) |tuningType(:,3));
velTuningOnly = tuningType(:,2) & ~(tuningType(:,1) |tuningType(:,3));
forceTuningOnly = tuningType(:,3) & ~(tuningType(:,1) |tuningType(:,2));