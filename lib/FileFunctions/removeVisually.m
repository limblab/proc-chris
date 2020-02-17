function td = removeVisually(td)
    switch td(1).monkey
        case 'Snap'
            switch td(1).date
                case '08-29-2019'
                    td = removeNeuronsVisually(td, struct('units1',[10,1;11,1;13,1;17,2;66,1;83,2;87,1;94,1]));
            end
    end
end