function fh1 = plotMappingFileOnObex(mappingFile, monkey)
    path1= 'C:\Users\wrest\Pictures\ReviewerResponse\CNPhotos\';
    units = unique([mappingFile.elec]);
    for i = 1:length(units)
        mapUnit = mappingFile([mappingFile.elec] == units(i));
        obexCoords(i,:) = mapUnit(1,:).obexCoord;
        cut = sum([mapUnit.cutaneous]);
        prop = sum([mapUnit.proprio]);
        spindle = sum([mapUnit.spindle]);
        [~, modality(i)] = max([cut, spindle]);
        
        
        prox = sum([mapUnit.proximal]);
        mid = sum([mapUnit.midArm]);
        distal = sum([mapUnit.distal]);
        lowLimb = sum([mapUnit.gracile]);
        head = sum([mapUnit.trigem]);
        torso = sum([mapUnit.torso]);
        

         [~, rfLoc(i)] = max([lowLimb,torso,prox, mid, distal, head]);
        
%          if rfLoc(i) ==1
%             keyboard 
%          end
         
        cuneate = sum(~[mapUnit.gracile] & ~[mapUnit.trigem]);
        gracile = sum([mapUnit.gracile]);
        trigem = sum([mapUnit.trigem]);
        [~, nuc(i)] = max([cuneate, gracile, trigem]);
    end
    modVec = {'Cutaneous', 'Spindle'};
    modColors = linspecer(2);
    fh1 = figure;
    scatter(0, 0, 32, 'filled')
    hold on
    gscatter(obexCoords(:,1), obexCoords(:,2), modVec(modality)')
    title([monkey, ' Modality Plot'])
    xlabel('X distance from Obex')
    ylabel('Y distance from Obex')
    xlim([-1,7])
    ylim([-4,4])

    rfVec = {'LowLimb', 'Torso','prox', 'mid', 'distal', 'Head'};
    rfColors = linspecer(6);
    fh2 = figure;
    scatter(0,0,32, 'filled')
    hold on
    gscatter(obexCoords(:,1), obexCoords(:,2), rfVec(rfLoc)')
    title([monkey, ' RFLocation Plot'])
    xlabel('X distance from Obex')
    ylabel('Y distance from Obex')    
    xlim([-1,7])
    ylim([-4,4])

    
    nucVec = {'Cuneate', 'Gracile', 'Trigeminal'};
    nucColors = linspecer(3);
    fh3 = figure;
    scatter(0,0,32, 'filled')
    hold on
    gscatter(obexCoords(:,1), obexCoords(:,2), nucVec(nuc)')
    title([monkey, ' Nucleus Plot'])
    xlabel('X distance from Obex')
    ylabel('Y distance from Obex')
    xlim([-1,7])
    ylim([-4,4])
    
    saveas(fh1, [path1, monkey,'ModalityPlot.pdf'])
    saveas(fh1, [path1, monkey,'ModalityPlot.png'])
    
    saveas(fh2, [path1, monkey,'RFLocPlot.pdf'])
    saveas(fh2, [path1, monkey,'RFLocPlot.png'])
    
    saveas(fh3, [path1, monkey,'NucleusPlot.pdf'])
    saveas(fh3, [path1, monkey,'NucleusPlot.png'])
end