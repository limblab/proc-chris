run= true;
unitNum = 1;
while run
    if strcmp(input('Do you want to input another file \n', 's'), 'y')
        moreUnits=true;
        date = input('Enter the date of the file (yyyymmdd) \n','s');

        while moreUnits
            mappingFile(unitNum).date = date;
            mappingFile(unitNum).chan =  input('Enter the channel \n');
            mappingFile(unitNum).id =input('Enter the unitID \n');
            mappingFile(unitNum).pc = input('Enter proprioceptive (p) or cutaneous (c) \n','s');
            desc = input('Describe the receptive field \n','s');
            mappingFile(unitNum).desc = string(desc);
            if strcmp(input('is there another Unit? y/n \n', 's'), 'y')
                moreUnits=true;
                unitNum = unitNum+1;
            else
                moreUnits=false;
            end
        end
    else
        run = false;
        disp('completed sensory mapping entry')
    end
end