function n1 = getMeanEncoding(neurons)
    n2 = neurons(:,6:end);
    n3 = neurons(:,1:5);
    varNames = n2.Properties.VariableNames;
    for i = 1:length(varNames)
        for  j= 1:height(n2)
            n1(j).(varNames{i}) = mean(n2.(varNames{i})(j));
        end
    end
   n1 = struct2table(n1);
    n1 = [n3, n1];
end