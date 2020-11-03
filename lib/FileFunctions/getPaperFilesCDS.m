function [cds, date, num1] = getPaperFilesCDS(num)
     switch num
            case 1
                monkey= 'Butter';
                date = '20190129';
                num1 = 2;
                cds = getCDS(monkey, 'CO',date);
            case 2
                monkey = 'Snap';
                date = '20190829';
                num1 =2;
                cds = getCDS(monkey, 'CO',date);

            case 3
                monkey = 'Crackle';
                date = '20190418';
                num1 =1;
                cds = getCDS(monkey, 'CO',date);
            case 4
                monkey = 'Duncan';
                date = '20190710';
                num1 = 1;
                cds = getCDS(monkey, 'CObumpmove',date);
                array = 'leftS1';
            case 5
                monkey = 'Han';
                date = '20171122';
                array = 'LeftS1Area2';
                num1 = 1;
                cds = getCDs(monkey, 'CO',date);
         case 6
             monkey = 'Butter';
             date = '20180607';
             array = 'cuneate';
             num1 = 1;
             cds = getCDS(monkey, 'CO',date);
         case 7
             monkey = 'Crackle';
             date = '20190327';
             array = 'cuneate';
             num1 = 1;
             cds = getCDS(monkey, 'CO',date);
         case 8
             monkey = 'Crackle';
             date = '20190213';
             array = 'cuneate';
             num1 = 1;
             cds = getCDS(monkey, 'CO',date);
         case 9
             monkey = 'Snap';
             date = '20190806';
             array = 'cuneate';
             num1 = 1;
             cds = getCDS(monkey, 'CO',date);
         case 10
             monkey = 'Han';
             date = '20170105';
             array = 'LeftS1Area2';
             num1 = 1;
             cds = getCDS(monkey, 'CO',date);
         case 11
             monkey = 'Chips';
             date = '20170913';
             array = 'LeftS1Area2';
             num1 =1;
             cds = getCDS(monkey, 'CO',date);
         case 12
             monkey = 'Rocket';
             date = '20200729';
             array = 'cuneate';
             num1 =1;
             cds = getCDS(monkey, 'CO',date);
        end
end