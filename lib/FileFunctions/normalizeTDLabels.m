function td = normalizeTDLabels(td)
    fields = fieldnames(td);
    for i = 1:length(fields)
        field = fields{i};
        switch field
            case 'idx_go_cue'
                newField{i} = 'idx_goCueTime';
            case 'RightCuneate_spikes'
                newField{i} = 'cuneate_spikes';
            case 'RightCuneate_unit_guide'
                newField{i} = 'cuneate_unit_guide';
            case 'RightCuneate_ts'
                newField{i} = 'cuneate_ts';
            case 'RightCuneate_naming'
                newField{i} = 'cuneate_naming';
            case 'target_direction'
                newField{i} = 'tgtDir';
            case 'bump_direction'
                newField{i} = 'bumpDir';
            otherwise
                newField{i} = field;
        end
    end
    cell2struct(struct2cell(td), newField)
end