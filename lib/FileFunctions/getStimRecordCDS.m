function [cds, stim] = getStimRecordCDS(filepath)
labCDS = 6;
arrayCDS = 'arrayleftS1';
monkeyCDS = 'monkeyHan';
taskCDS = 'taskCObump';
ranBy = 'ranByChris';

direc = dir(filepath);
fileList = {direc.name};
ns5List =[];
wvList = [];
ns5Num = [];
wvNum = [];
nevList =[];
nevNum = [];
for i = 1:length(fileList)
    name = fileList{i};
    if contains(name,'spikesExtracted.ns5')
        ns5List{end+1}= name;
        tmp = split(name, '_');
        ns5Num(end+1) = str2num(tmp{end-1});
    end
    if contains(name, 'waveformsSent')
        wvList{end+1} = name;
        tmp = split(name, '_');
        wvNum(end+1) = str2num(tmp{end}(1:end-4));
    end
    if contains(name, '.nev') & ~contains(name, '-s.nev') & ~contains(name, 'spikesExtracted');
        nevList{end+1} = name;
        tmp = split(name, '_')
        nevNum(end+1) = str2num(tmp{end}(end-4:end-4));
    end
    if contains(name, '-s.nev')
        cdsName = 'Han_20191217_leftS1_CObump__chanINTERLEAVEDstim_A1-INTERLEAVED_A2-INTERLEAVED_1.nev';
    end

end
[s, inds] = sort(ns5Num);
[s1, inds1] = sort(wvNum);
ns5List = ns5List(inds);
wvList=  wvList(inds1);
startTime = 1/30000;
for i = 1:length(ns5List)
    disp(['Loaded ', num2str(i), ' of ', num2str(length(ns5List))])
    dat = openNSx([filepath, ns5List{i}]);
    load([filepath, wvList{1}])
    datT = dat.Data(2,:);
    wvSent = diff(datT>3000)==1;
    numWV = sum(wvSent);
    tVec = linspace(0, dat.MetaTags.DataDurationSec, length(datT));
    stim{i}.t = tVec(logical(wvSent));
    stim{i}.waveSent = waveforms.waveSent;
    stim{i}.chanSent = waveforms.chanSent;
    stim{i}.params = waveforms.parameters;
    startTime = tVec(end);
end

cds = commonDataStructure();
for i =1 :length(nevList)
    cds.file2cds([filepath, nevList{i}],labCDS,arrayCDS,monkeyCDS,taskCDS,ranBy,'ignoreJumps');
end
end