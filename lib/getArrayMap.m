function [ arrayPath ] = getArrayMap( monkey, array )

    mapName = dir([getBasePath(monkey), 'ArrayMaps\', array, '\*.cmp']);
      arrayPath = [getBasePath(monkey), 'ArrayMaps\', array, '\',mapName.name];
      

end

