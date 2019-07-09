function same = testSameModDepth(pd1, pd2)
    d1 = pd1.velModdepth;
    d2 = pd2.velModdepth;
    ci1 = pd1.velModdepthCI;
    ci2 = pd2.velModdepthCI;
    
    same = d1 > ci2(1) & d1 <ci2(2) & d2 > ci1(1) & d2 < ci2(2);
end