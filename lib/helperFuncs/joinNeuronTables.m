function neurons = joinNeuronTables(neuronsCell)
%% Function to join tables between neurons with potentially different numbers of columns
%% It essentially deletes the extra columns from the variables with more
for i = 1:length(neuronsCell)
    fld1 = fieldnames(neuronsCell{i});
    fld1(end-2:end) =[];
    if i == 1
        fldInter = fld1(:);
    end
    fldInter = intersect(fldInter, fld1);
end
neuronsNew =[];
for i = 1:length(neuronsCell)
    fld1 = fieldnames(neuronsCell{i});
    fld1(end-2:end) =[];
    diff1 = setdiff(fld1,fldInter);
    for j = 1:length(diff1)
        neuronsCell{i}.(diff1{j}) = [];
    end
    neuronsNew = [neuronsNew; neuronsCell{i}];
end
neurons = neuronsNew;
end