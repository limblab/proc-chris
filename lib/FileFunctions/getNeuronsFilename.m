function fn =  getNeuronsFilename(monkey, date, task)
    fn = [strjoin({monkey, date, task}, '_'), '_NeuronStruct.mat'];
end