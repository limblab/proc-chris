function enc = enc2tab(encoding, flag)
fields = fieldnames(encoding);

for i = 1:length(fields)
    if ~strcmp(fields{i}(1:5), 'model')
        vec = encoding.(fields{i});
        s = size(vec);
        if s(1) < s(2)
            vec = vec';
        end
        enc1.(fields{i}) = vec(flag);
    end
end
enc = struct2table(enc1);
end