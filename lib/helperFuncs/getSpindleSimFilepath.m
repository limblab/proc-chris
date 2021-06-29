function fp = getSpindleSimFilepath(date1, startTime, endTime)
    fp1 = ['D:\MonkeyData\CO\SpindleSim\'];
    name1 = ['SpindleSim', strjoin(string(startTime),'_'), strjoin(string(endTime),'_' ),'_',date1];
    fp = strjoin([fp1, name1], '');
    disp(fp)
end