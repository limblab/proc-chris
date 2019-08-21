function logMat1 = getIndicesInsideEdge(vec1, edges)
    logMat = zeros(length(edges)-1, length(vec1));
    for i = 1:length(edges)-1
        logMat(i,:) =  logical([vec1 > edges(i) & vec1 < edges(i+1)]);
    end
    logMat1 = logical(logMat);
end