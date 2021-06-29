close all
clear all
tableComb = [];
for i = 1:3
    switch i
        case 1
            monkey = 'Butter';
            date = '20190129';
            mappingFile = getSensoryMappings(monkey);
            prevDateFlag = datetime({mappingFile.date}, 'InputFormat', 'yyyyMMdd') <= datetime(date, 'InputFormat', 'yyyyMMdd');
            mappingFile = mappingFile(prevDateFlag);
        case 2
            monkey = 'Snap';
            date = '20190829';
            mappingFile = getSensoryMappings(monkey);
            prevDateFlag = datetime({mappingFile.date}, 'InputFormat', 'yyyyMMdd') <= datetime(date, 'InputFormat', 'yyyyMMdd');
            mappingFile = mappingFile(prevDateFlag);
        case 3
            monkey = 'Crackle';
            date = '20190418';
            mappingFile = getSensoryMappings(monkey);
            prevDateFlag = datetime({mappingFile.date}, 'InputFormat', 'yyyyMMdd') <= datetime(date, 'InputFormat', 'yyyyMMdd');
            mappingFile = mappingFile(prevDateFlag);
    end
    
    
    mappingFile = findDelete(mappingFile);
    mappingFile = findDistalArm(mappingFile);
    mappingFile = findHandCutaneousUnits(mappingFile);
    mappingFile = findProximalArm(mappingFile);
    mappingFile = findMiddleArm(mappingFile);
    mappingFile = findCutaneous(mappingFile);
    mappingFile = findGracile(mappingFile);
    mappingFile = findTrigem(mappingFile);
    mappingFile = findTorso(mappingFile);
    mappingFile = addObexDims(mappingFile, monkey);
    
%     mappingFile = mappingFile(strcmp([mappingFile.date], date))
    [fh1, table1] = plotMappingFileOnObex(mappingFile, monkey);
    tableComb = [tableComb; table1];
end
%% Compute average locations of different vars
meanShank = mean(tableComb.ObexCoords);
cutShank =  mean(tableComb([tableComb.Modality]==1,:).ObexCoords) - meanShank;
propShank = mean(tableComb([tableComb.Modality]==2,:).ObexCoords) - meanShank;
legShank =  mean(tableComb([tableComb.RFLocation]==1,:).ObexCoords) - meanShank;
torsoShank = mean(tableComb([tableComb.RFLocation]==2,:).ObexCoords) - meanShank;
proxShank =  mean(tableComb([tableComb.RFLocation]==3,:).ObexCoords) - meanShank;
midShank =  mean(tableComb([tableComb.RFLocation]==4,:).ObexCoords) - meanShank;
distalShank =  mean(tableComb([tableComb.RFLocation]==5,:).ObexCoords) - meanShank;
headShank =  mean(tableComb([tableComb.RFLocation]==6,:).ObexCoords) - meanShank;

cutPropVec = propShank -cutShank;
distProxVec = proxShank - distalShank;

%% Find vector of nucleus travel
orig = [0.4622, -2.3079];
cmPoint = [1.4539, -1.7385];
rlPoint = [3.0309, -0.2833];

vec1 = rlPoint - cmPoint;
vec1 = vec1/norm(vec1);
vec2(1) = -1*vec1(2);
vec2(2) = vec1(1);
vec2 = -1.*vec2;
edges1 = -1.5:0.5:5.5;
tableComb.proj2 = tableComb.ObexCoords * vec2';
figure
names1 = {'Leg', 'Torso', 'Proximal', 'MidArm', 'Distal', 'Head'};
for i= 1:6
    subplot(6,1,i)
    tabT = tableComb([tableComb.RFLocation]==i,:);
    histogram(tabT.proj2,edges1)
    title(names1{i})
    set(gca,'TickDir','out', 'box', 'off')

%     hold on
end


% legend({'Leg', 'Torso', 'Proximal', 'MidArm', 'Distal', 'Head'})
%%
tableComb.proj1 = tableComb.ObexCoords * vec1';
tabP = tableComb([tableComb.Modality]==2 & any([tableComb.RFLocation] == [2,3,4,5],2),:);
tabC = tableComb([tableComb.Modality]==1 & any([tableComb.RFLocation] == [2,3,4,5],2),:);



figure
h = histogram(tabP.proj1,10)
hold on
histogram(tabC.proj1,10)
legend({'Proprio', 'Cutaneous'})
ttest2(tabP.proj1, tabC.proj1)

edges = h.BinEdges;
figure
stackedHistogram(tabP.proj1, tabC.proj1, edges)
xlabel('mm from obex')

legend({'Cutaneous', 'Propio'})