function td = tdToBinSize(td, binSizeIn)
% This is just a helper fuction to make sure all of the TDs are at the
% correct bin size for my scripts
bin_size = td(1).bin_size*1000;
binSizeInms = binSizeIn;
if bin_size > binSizeInms
    error('Its already binned larger than your desired bin')
else
    multiple = binSizeInms/bin_size;
    if mod(multiple,1) ~=0
        error('Current bin size cannot be combined into your desired bin size')
    end
    td = binTD(td, multiple);
end
end

