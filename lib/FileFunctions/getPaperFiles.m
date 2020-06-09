function [td, date] = getPaperFiles(num)
     switch num
            case 1
                monkey= 'Butter';
                date = '20190129';
                td = getTD(monkey, date, 'CO',2);
            case 2
                monkey = 'Snap';
                date = '20190829';
                number =2;
                td = getTD(monkey, date, 'CO',2);

            case 3
                monkey = 'Crackle';
                date = '20190418';
                number =1;
                td = getTD(monkey, date, 'CO', number);
            case 4
                monkey = 'Duncan';
                date = '20190710';
                number = 1;
                td = getTD(monkey,date,'CObumpmove', number);
                array = 'leftS1';
                if strcmp(monkey, 'Duncan') 
                    td(~isnan([td.idx_bumpTime]) & [td.idx_goCueTime]< [td.idx_bumpTime])=[];
                    td([td.tgtDist]<8) = [];
                end
            case 5
                monkey = 'Han';
                date = '20171122';
                array = 'LeftS1Area2';
                number = 1;
                td = getTD(monkey, date, 'COactpas', number);
         case 6
             monkey = 'Butter';
             date = '20180607';
             array = 'cuneate';
             number = 1;
             td = getTD(monkey, date, 'CO', number);
         case 7
             monkey = 'Crackle';
             date = '20190327';
             array = 'cuneate';
             number = 1;
             td = getTD(monkey, date, 'CO', number);
         case 8
             monkey = 'Crackle';
             date = '20190213';
             array = 'cuneate';
             number = 1;
             td = getTD(monkey, date, 'CO', number);
         case 9
             monkey = 'Snap';
             date = '20190806';
             array = 'cuneate';
             number = 1;
             td = getTD(monkey, date, 'CO', number);
             
        end
end