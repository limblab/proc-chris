function firing = addPoissonSpiking(osIn)
    osIn = osIn + min(osIn);
    velScale = 50 ./ quantile(osIn, .9);
    osIn = osIn.*velScale;
    firing = poissrnd(osIn/10);
    
end