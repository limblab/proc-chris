function path1 = makeFileStructure(monkey, date, task, resort )
        if nargin <4
            resort= false;
        end
        path1 = getBasicPath(monkey, date, getGenericTask(task), resort);
        mkdir([path1, 'CDS'])
        mkdir([path1, 'TD'])
        mkdir([path1, 'NEV'])
        mkdir([path1, 'neuronStruct'])
        mkdir([path1, 'MotionTracking'])
end

