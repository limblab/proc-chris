function neurons = getPaperNeurons(i)
butterDate = '20190129';
snapDate = '20190829';
crackleDate = '20190418';
s1Date = '20190710';
monkeyS1 = 'Duncan';
hanDate = '20171122';
array = 'cuneate';

windowAct= {'idx_movement_on', 0; 'idx_movement_on',13}; %Default trimming windows active
windowPas ={'idx_bumpTime',0; 'idx_bumpTime',13}; % Default trimming windows passive
switch i
    case 1
        neurons = getNeurons('Butter', butterDate,'CObump','cuneate',[windowAct; windowPas]);
    case 6
        neurons = getNeurons('Butter', '20180607','CObump', 'cuneate', [windowAct;windowPas]);

    case 2
        neurons = getNeurons('Snap', snapDate, 'CObump','cuneate',[windowAct; windowPas]);
    case 9
        neurons = getNeurons('Snap', '20190806', 'CObump','cuneate',[windowAct; windowPas]);
    case 3
        neurons = getNeurons('Crackle', crackleDate, 'CObump','cuneate',[windowAct; windowPas]);
    case 7
        neurons = getNeurons('Crackle', '20190327', 'CObump','cuneate',[windowAct; windowPas]);
    case 8
        neurons = getNeurons('Crackle', '20190213', 'CObump','cuneate',[windowAct; windowPas]);

    case 4
        neurons = getNeurons(monkeyS1, s1Date,'CObump','leftS1',[windowAct; windowPas]);
    case 5
        neurons = getNeurons('Han', hanDate, 'COactpas', 'LeftS1Area2', [windowAct;windowPas]);
end
end