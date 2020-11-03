function fp = getSpindleSimFilepath(date, startTime, endTime)
    fp1 = ['D:\MonkeyData\CO\SpindleSim\'];
    name1 = ['SpindleSim', strjoin(string(startTime),'_'), strjoin(string(endTime),'_')];
    fp = strjoin([fp1, name1], '');
end