function tab = getKinTable(td, params)
tab = table();
tab.pos = cat(1, td.pos);
tab.vel = cat(1, td.vel);
tab.acc = cat(1, td.acc);

end
