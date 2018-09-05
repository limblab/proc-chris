load('C:\Users\wrest\Documents\MATLAB\SensoryMappings\Butter\ButterMapping20180611.mat');

for i = 1:length(mappingFile)
        if contains(mappingFile(i).desc, {'leg', 'foot', 'heel', 'hip', 'butt', 'tail'}, 'IgnoreCase', true)
            map(i) = 0;
        elseif strcmp(mappingFile(i).pc, 'c')
            map(i) = 1;
        elseif strcmp(mappingFile(i).pc, 'p') & ~mappingFile(i).spindle
            map(i) = 2;
        elseif mappingFile(i).spindle
            map(i)=3;
        end   
end
   
disp([num2str(sum(map == 0)) , ' of ', num2str(length(map)), ' neurons are gracile'])
disp([num2str(sum(map ~= 0)) , ' of ', num2str(length(map)), ' neurons are cuneate'])
disp([num2str(sum(map == 3)) , ' of ', num2str(length(map)), ' neurons are muscle spindle'])
disp([num2str(sum(map == 1)) , ' of ', num2str(length(map)), ' neurons are cutaneous'])

