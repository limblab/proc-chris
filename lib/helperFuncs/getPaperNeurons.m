function neurons = getPaperNeurons(i, windowAct, windowPas, suffix)

if nargin < 4 ; suffix='MappedNeurons';end


butterDate = '20190129';
snapDate = '20190829';
crackleDate = '20190418';
s1Date = '20190710';
monkeyS1 = 'Duncan';
hanDate = '20171122';
array = 'cuneate';

switch i
    case 1
        neurons = getNeurons('Butter', butterDate,'CObump','cuneate',[windowAct; windowPas], suffix);
    case 2
        neurons = getNeurons('Snap', snapDate, 'CObump','cuneate',[windowAct; windowPas], suffix);
    case 3
        neurons = getNeurons('Crackle', crackleDate, 'CObump','cuneate',[windowAct; windowPas], suffix);
    case 4
        neurons = getNeurons(monkeyS1, s1Date,'CObump','leftS1',[windowAct; windowPas], suffix);
    case 5
        neurons = getNeurons('Han', hanDate, 'COactpas', 'LeftS1Area2', [windowAct;windowPas], suffix);
    case 6
        neurons = getNeurons('Butter', '20180607','CObump', 'cuneate', [windowAct;windowPas], suffix);
    case 7
        neurons = getNeurons('Crackle', '20190327', 'CObump','cuneate',[windowAct; windowPas], suffix);
    case 8
        neurons = getNeurons('Crackle', '20190213', 'CObump','cuneate',[windowAct; windowPas], suffix);
    case 9
        neurons = getNeurons('Snap', '20190806', 'CObump','cuneate',[windowAct; windowPas], suffix);   
    case 10
        neurons = getNeurons('Han', '20170105','COactpas', 'LeftS1Area2', [windowAct;windowPas], suffix); 
    case 11
        neurons = getNeurons('Chips', '20170913', 'COactpas', 'LeftS1Area2', [windowAct;windowPas], suffix);
    case 12
        neurons = getNeurons('Rocket', '20200729', 'CObump', 'cuneate', [windowAct;windowPas], suffix);
    case 13
        neurons = getNeurons('Butter', '20190128', 'CObump', 'cuneate', [windowAct;windowPas], suffix);
    case 14
         monkey = 'Snap';
         date = '20190829';
         suffix = 'ResortNeurons';
         neurons = getNeurons(monkey, date, 'CObump', 'cuneate', [windowAct;windowPas], suffix);
     case 15
         suffix = 'ResortNeurons';
         monkey = 'Crackle';
         date = '20190418';
         neurons = getNeurons(monkey, date, 'CObump', 'cuneate', [windowAct;windowPas], suffix);
     case 16
         suffix = 'ResortNeurons';
         monkey = 'Butter';
         date = '20180607';
         neurons = getNeurons(monkey, date, 'CObump', 'cuneate', [windowAct;windowPas], suffix);
     case 17
         
         suffix = 'ResortNeurons';
         monkey = 'Butter';
         date = '20190128';
         neurons = getNeurons(monkey, date, 'CObump', 'cuneate', [windowAct;windowPas], suffix);
    case 18
        suffix = 'RedoResortNeurons';
         monkey = 'Crackle';
         date = '20190327';
         neurons = getNeurons(monkey, date, 'CObump', 'cuneate', [windowAct;windowPas], suffix);
    case 19
        suffix = 'ResortNeurons';
         monkey = 'Snap';
         date = '20190806';
         neurons = getNeurons(monkey, date, 'CObump', 'cuneate', [windowAct;windowPas], suffix);
    case 20
        
    case 21
         monkey ='Crackle';
         date = '20190509';
         suffix = 'MappedNeurons';

         neurons = getNeurons(monkey, date, 'CObump', 'cuneate', [windowAct;windowPas], suffix);
    case 23
        monkey = 'Lando';
        date = '20170917';
        suffix = 'MappedNeurons';
        neurons = getNeurons(monkey, date, 'CObump', 'cuneate', [windowAct;windowPas], suffix);
    otherwise
        neurons = [];
end
if isempty(neurons)
    warning('This didnt work')
end
end