function [actPDs, pasPDs, actPDsHigh, actPDsLow, pasPDsHigh, pasPDsLow] = shiftPDsToLine(actPDs, pasPDs, actPDsHigh, actPDsLow, pasPDsHigh, pasPDsLow)
pds = [actPDs, pasPDs];
pdsOut = pds;
for i= 1:length(pds)
    if abs(diff(pds(i,:))) > 180
        if abs(pds(i,1))> abs(pds(i,2))
            actPDs(i,1) = actPDs(i) + -1*sign(pds(i,1))*180;
            actPDsHigh(i) = actPDsHigh(i) + -1*sign(pds(i,1))*180;
            actPDsLow(i) = actPDsLow(i) + -1*sign(pds(i,1))*180;
        else
            pasPDs(i) = pasPDs(i) + -1*sign(pds(i,2))*180;
            pasPDsHigh(i) = pasPDsHigh(i) + -1*sign(pds(i,2))*180;
            pasPDsLow(i) = pasPDsLow(i) + -1*sign(pds(i,2))*180;
        end
    end
end
end