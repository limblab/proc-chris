function td = tdTo50ms(td)
% This is just a helper fuction to make sure all of the TDs are at the
% correct bin size for my scripts
bin_size = td(1).bin_size;
if bin_size >.05
    error('Its already binned larger than 50 ms')
else
    multiple = .05/bin_size;
    if mod(multiple,1) ~=0
        error('Current bin size cannot be combined into 50 ms bins')
    end
    td = binTD(td, multiple);
end
end

