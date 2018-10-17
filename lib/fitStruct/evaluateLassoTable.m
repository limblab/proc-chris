function [tableMetrics] = evaluateLassoTable(lassoTable)
    fields = fieldnames(lassoTable);
    fields = fields(3:end);
    
    for i = 1:length(lassoTable)
        tableMetrics(i).chan = lassoTable(i).chan;
        tableMetrics(i).ID = lassoTable(i).ID;
        for j = 1:length(fields)
            if contains(fields{j}, 'PC', 'IgnoreCase', true)
                tableMetrics(i).(fields{j}) = lassoTable(i).(fields{j}).Rsquared.Adjusted;
            elseif contains(fields{j}, 'Lasso', 'IgnoreCase', true)
                tableMetrics(i).(fields{j}) =  1;
            elseif contains(fields{j}, 'Full' , 'IgnoreCase', true)
                tableMetrics(i).(fields{j}) = lassoTable(i).(fields{j}).Rsquared.Adjusted;
            else
                error('Not a valid model')
            end
        end
    end
end

