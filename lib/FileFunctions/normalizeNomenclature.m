function normalizeNomenclature(stringSearch, stringReplace, basePath)
% Function needed due to inconsistencies with file naming. This is a way to change all references from 'RightCuneate' to 'cuneate' etc.
% in files that I have collected. This will make scripting much easier, as the CDS looks at these file names to populate the structure.
% Recursively traverses the tree starting at the base path provided, changing all names containing the stringSearch with the stringReplace
    local = dir(basePath);
    for i = 3:length(local)
       if local(i).isdir
           normalizeNomenclature(stringSearch, stringReplace, [local(i).folder,filesep, local(i).name]);
       else
           name = local(i).name;
           if contains(name, stringSearch)
               oldname = name;
               newname = strrep(oldname, stringSearch, stringReplace);
               movefile([basePath,filesep, oldname], [basePath,filesep, newname]);
               java.io.File([basePath,filesep,oldname]).renameTo(java.io.File([basePath, filesep, newname]));
           end
    end
end

