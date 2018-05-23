function [ tsArray ] = getTsArray( timeStamps )
    tsArray =[];
    for i = 1:length(timeStamps)
        unit = repmat(i, height(timeStamps{i}), 1);
        unitTs = [timeStamps{i}.ts, unit];
        tsArray = [tsArray; unitTs];
    end

end

