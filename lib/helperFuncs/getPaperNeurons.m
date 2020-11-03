function neurons = getPaperNeurons(i, windowAct, windowPas)
butterDate = '20190129';
snapDate = '20190829';
crackleDate = '20190418';
s1Date = '20190710';
monkeyS1 = 'Duncan';
hanDate = '20171122';
array = 'cuneate';

switch i
    case 1
        neurons = getNeurons('Butter', butterDate,'CObump','cuneate',[windowAct; windowPas]);
    case 2
        neurons = getNeurons('Snap', snapDate, 'CObump','cuneate',[windowAct; windowPas]);
    case 3
        neurons = getNeurons('Crackle', crackleDate, 'CObump','cuneate',[windowAct; windowPas]);
    case 4
        neurons = getNeurons(monkeyS1, s1Date,'CObump','leftS1',[windowAct; windowPas]);
    case 5
        neurons = getNeurons('Han', hanDate, 'COactpas', 'LeftS1Area2', [windowAct;windowPas]);
    case 6
        neurons = getNeurons('Butter', '20180607','CObump', 'cuneate', [windowAct;windowPas]);
    case 7
        neurons = getNeurons('Crackle', '20190327', 'CObump','cuneate',[windowAct; windowPas]);
    case 8
        neurons = getNeurons('Crackle', '20190213', 'CObump','cuneate',[windowAct; windowPas]);
    case 9
        neurons = getNeurons('Snap', '20190806', 'CObump','cuneate',[windowAct; windowPas]);   
    case 10
        neurons = getNeurons('Han', '20170105','COactpas', 'LeftS1Area2', [windowAct;windowPas]); 
    case 11
        neurons = getNeurons('Chips', '20170913', 'COactpas', 'LeftS1Area2', [windowAct;windowPas]);
    case 12
        neurons = getNeurons('Rocket', '20200729', 'CObump', 'cuneate', [windowAct;windowPas]);
    otherwise
        neurons = [];
end
end