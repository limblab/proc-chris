function crList = findMatchingNeurons(neurons1, neurons2)
comparisons = {'chan', 'actPD', 'actTuningCurve', 'dcMove', 'modDepthMove'};
sameList = [];
crList = [];
    for i = 1:height(neurons1)
        neuronsSame = neurons2([neurons2.chan] == neurons1.chan(i), :);
        for j = 1:height(neuronsSame)
            sameUnit = true;
            for k = 1:length(comparisons)
                if contains(comparisons{k}, 'PD')
                    pd1= neurons1.(comparisons{k})(i,:);
                    pd2= neuronsSame.(comparisons{k})(j,:);
                    if ~testSamePDs(pd1, pd2) | ~testSameModDepth(pd1, pd2)
                        sameUnit=false;
                    end
                elseif contains(comparisons{k}, 'TuningCurve')
                    tc1 = neurons1.(comparisons{k})(i,:);
                    tc2 = neuronsSame.(comparisons{k})(j,:);
                    if ~compareTuningCurve(tc1, tc2)
                        sameUnit=false;
                    end
                elseif contains(comparisons{k},'DC')
                    dc1 = neurons1.(comparisons{k})(i,:);
                    dc2 = neuronsSame.(comparisons{k})(j,:);
                    if abs(dc1-dc2)/dc1 > .2
                        sameUnit =false;
                    end
                end
            end
            if sameUnit
                crList = [crList; neurons1.chan(i), neurons1.ID(i), neuronsSame.chan(j), neuronsSame.ID(j)];
                sameList = [sameList; neurons1(i,:); neuronsSame(j,:)];
            end
        end
    end
end