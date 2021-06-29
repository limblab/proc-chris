function [td, date, num1] = getPaperFiles(num, tenMs)
    if nargin <2
       tenMs = []; 
    end
     switch num
            case 1
                monkey= 'Butter';
                date = '20190129';
                num1 = 2;
                td = getTD(monkey, date, 'CO',num1, tenMs);
            case 2
                monkey = 'Snap';
                date = '20190829';
                num1 =2;
                td = getTD(monkey, date, 'CO',num1, tenMs);

            case 3
                monkey = 'Crackle';
                date = '20190418';
                num1 =1;
                td = getTD(monkey, date, 'CO', num1, tenMs);
            case 4
                monkey = 'Duncan';
                date = '20190710';
                num1 = 1;
                td = getTD(monkey,date,'CObumpmove', num1, tenMs);
                array = 'leftS1';
                if strcmp(monkey, 'Duncan') 
                    td(~isnan([td.idx_bumpTime]) & [td.idx_goCueTime]< [td.idx_bumpTime])=[];
                    td([td.tgtDist]<8) = [];
                end
            case 5
                monkey = 'Han';
                date = '20171122';
                array = 'LeftS1Area2';
                num1 = 1;
                td = getTD(monkey, date, 'CO', num1, tenMs);
         case 6
             monkey = 'Butter';
             date = '20180607';
             array = 'cuneate';
             num1 = 1;
             td = getTD(monkey, date, 'CO', num1, tenMs);
         case 7
             monkey = 'Crackle';
             date = '20190327';
             array = 'cuneate';
             num1 = 1;
             td = getTD(monkey, date, 'CO', num1, tenMs);
         case 8
             monkey = 'Crackle';
             date = '20190213';
             array = 'cuneate';
             num1 = 1;
             td = getTD(monkey, date, 'CO', num1, tenMs);
         case 9
             monkey = 'Snap';
             date = '20190806';
             array = 'cuneate';
             num1 = 1;
             td = getTD(monkey, date, 'CO', num1, tenMs);
         case 10
             monkey = 'Han';
             date = '20170105';
             array = 'LeftS1Area2';
             num1 = 1;
             td = getTD(monkey, date, 'CO', num1, tenMs);
         case 11
             monkey = 'Chips';
             date = '20170913';
             array = 'LeftS1Area2';
             num1 =1;
             td = getTD(monkey, date, 'CO', num1, tenMs);
         case 12
             monkey = 'Rocket';
             date = '20200729';
             array = 'cuneate';
             num1 =1;
             td = getTD(monkey,date, 'CO', num1, tenMs);
         case 13
             monkey= 'Butter';
            date = '20190128';
            num1 = 1;
            td = getTD(monkey, date, 'CO',num1, tenMs);
         case 14
             monkey = 'Snap';
             date = '20190829';
             num1 =2;
             td = getTD(monkey, date, 'CO', num1, tenMs, true);
         case 15
             monkey = 'Crackle';
             date = '20190418';
             num1 = 1;
             td = getTD(monkey,date, 'CO', num1, tenMs, true);
         case 16
             monkey = 'Butter';
             date = '20180607';
             num1 = 1;
             td = getTD(monkey, date, 'CO', num1, tenMs, true);
         case 17
             monkey = 'Butter';
             date = '20190128';
             num1 = 1;
             td = getTD(monkey, date, 'CO', num1, tenMs, true);
         case 18
             monkey = 'Crackle';
             date = '20190327';
             num1 = 1;
             td = getTD(monkey, date, 'CO', num1, tenMs, true);
          case 19
             monkey = 'Snap';
             date = '20190806';
             num1 = 1;
             td = getTD(monkey, date, 'CO', num1, tenMs, true);
         case 20
             monkey = 'Rocket';
             date = '20200729';
             array = 'cuneate';
             num1 =1;
             td = getTD(monkey, date, 'CO', num1, tenMs, true);
         case 21
             monkey ='Crackle';
             date = '20190509';
             array = 'cuneate';
             num1=1;
             td = getTD(monkey, date, 'CO', num1, tenMs);
             
         case 22
             monkey = 'Crackle';
             date = '20190501';
             array = 'cuneate';
             num1 = 1;
             td =getTD(monkey, date, 'CO', num1,tenMs);
         case 23
             monkey = 'Lando';
             date = '20170917';
             array = 'cuneate';
             num1 = 1;
             td = getTD(monkey, date, 'CO', num1, tenMs);
         case 24 
             monkey = 'Han';
             date = '20171201';
             array = 'LeftS1Area2';
             num1 = 1;
             td = getTD(monkey, date, 'COactpas', num1, tenMs);
     end
end