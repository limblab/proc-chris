clear all
close all
td = getTD('Butter', '20190322', 2);
[~, td] = getTDidx(td, 'result', 'R');
td = trimTD(td, 'idx_goCue', 'idx_endTime');
