function same = testSamePDs(pd1, pd2)
    d1 = pd1.velPD;
    d2 = pd2.velPD;
    ci1 = pd1.velPDCI;
    ci2 = pd2.velPDCI;
    
    same = d1 > ci2(1) & d1 <ci2(2) & d2 > ci1(1) & d2 < ci2(2);
end