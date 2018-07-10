function path1 = makeFileStructure(monkey, date, task )
    compName = getenv('computername');
    arch = computer('arch');
    if strcmp(compName, 'FSM8M1SMD2')
        %% GOB2
        whichComp = 'GOB2';
        path1 = ['C:\Users\csv057\Documents\MATLAB\MonkeyData\',task, '\', monkey, '\',date, '\'];
        mkdir([path1, 'CDS'])
        mkdir([path1, 'TD'])
        mkdir([path1, 'NEV'])
        mkdir([path1, 'neuronStruct'])
        mkdir([path1, 'MotionTracking'])
    elseif strcmp(compName, 'Chris-desktop')
        %% my desktop (PC version)
        whichComp = 'home';
        path1 = ['C:\Users\wrest_000\Documents\MATLAB\MonkeyData\',task, '\', monkey, '\',date, '\'];
        mkdir([path1, 'CDS'])
        mkdir([path1, 'TD'])
        mkdir([path1, 'NEV'])
        mkdir([path1, 'neuronStruct'])
        mkdir([path1, 'MotionTracking'])
    elseif strcmp(compName, 'Chris-desktop')
        %% my desktop (PC version)
        whichComp = 'home';
        path1 = ['C:\Users\wrest_000\Documents\MATLAB\MonkeyData\',task, '\', monkey, '\',date, '\'];
        mkdir([path1, 'CDS'])
        mkdir([path1, 'TD'])
        mkdir([path1, 'NEV'])
        mkdir([path1, 'neuronStruct'])
        mkdir([path1, 'MotionTracking'])
    elseif strcmp(compName, 'RESEARCHPC')
        %% My (old) laptop
        whichComp = 'laptop';
        path1 = ['C:\Users\wrest_000\Documents\MATLAB\MonkeyData\',task, '\',monkey,'\',date, '\'];
        mkdir([path1, 'CDS'])
        mkdir([path1, 'TD'])
        mkdir([path1, 'NEV'])
        mkdir([path1, 'neuronStruct'])
        mkdir([path1, 'MotionTracking'])
    elseif strcmp(compName, 'LAPTOP-DK2LKBEH')
        %% My (new) laptop
        whichComp = 'laptop2';
        path1 = ['C:\Users\wrest\Documents\MATLAB\MonkeyData\',task, '\',monkey,'\',date, '\'];
        mkdir([path1, 'CDS'])
        mkdir([path1, 'TD'])
        mkdir([path1, 'NEV'])
        mkdir([path1, 'neuronStruct'])
        mkdir([path1, 'MotionTracking'])
    else 
        error('Computer not recognized......... Exiting');
    end
end

