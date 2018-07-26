function path1 = makeFileStructure(monkey, date, task )
        path1 = getBasicPath(monkey, date, getGenericTask(task));
        mkdir([path1, 'CDS'])
        mkdir([path1, 'TD'])
        mkdir([path1, 'NEV'])
        mkdir([path1, 'neuronStruct'])
        mkdir([path1, 'MotionTracking'])
end

