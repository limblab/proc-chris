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
            case 'tgtDir'
                newField{i} = 'target_direction';
            case 'bump_direction'
                newField{i} = 'bumpDir';
            case 'date_time'
                newField{i} = 'date';
            case 'tgtDir'
                newField{i} = 'target_direction';
            otherwise
                newField{i} = field;
        end
    end
    td = cell2struct(struct2cell(td), newField)
end