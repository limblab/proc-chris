function td = getSpindleFiring(td, params)

spindleBin = .005;
binSize = td(1).bin_size;
padLen = .100;

if nargin > 1, assignParams(who,params); end % overwrite defaults



allMusc = [td(1).opensim_names];
muscles = allMusc(contains([td(1).opensim_names], '_len'));

muscleLens = cat(1,td.opensim);
muscle1 = muscleLens(:,contains([td(1).opensim_names], '_len'));
for k= 1:length(muscle1(1,:))
    nanx = isnan(muscle1(:,k));
    t = 1:numel(muscle1(:,k));
    muscle1(nanx,k) = interp1(t(~nanx), muscle1(~nanx,k), t(nanx));
end
muscleMean = mean(muscle1);
for i =1:length(td)   
    t = linspace(binSize, binSize*length(td(i).vel(:,1))+ padLen, length(td(i).vel(:,1))+padLen/binSize);
    t = (t - t(1))';
    opensim = td(i).opensim;
    opensim = opensim(:, contains([td(1).opensim_names],'_len')); 
    trialLength = binSize *length(opensim(:,1));
    resampT =  spindleBin:spindleBin:t(end);
    tic
    clear rOut rdOut rsOut
    for j = 1:39
        len = opensim(:, j);
        prependLen = [len(1)*ones(floor((padLen/binSize)), 1) ; len];
        normLen = prependLen/muscleMean(j);
        resampLen = interp1(t, normLen, resampT);
        
        diffLen = diff(resampLen)*1300;
        diffLen = [diffLen(1) diffLen];
        
        [~, dataB, ~, dataC] = sarcSimDriver(resampT, [.3; 0*ones(length(diffLen)-1,1)],[.3; 0*ones(length(diffLen)-1,1)], diffLen); 
        [r, rd, rs] = sarc2spindle(dataB, dataC,1.5,2.0,0.03,1,0);
        
        r = resample(r, resampT, 1/binSize);
        rd = resample(rd, resampT, 1/binSize);
        rs = resample(rs, resampT, 1/binSize);
        r = r(floor(padLen/binSize):end);
        rd = rd(floor(padLen/binSize):end);
        rs = rs(floor(padLen/binSize):end);
        
        rOut(:,j) = r;
        rdOut(:,j) = rd;
        rsOut(:,j) = rs;
        disp(['Done with muscle ', num2str(j)])
    end
    toc
    disp(['Trial ', num2str(i) ' complete of ', num2str(length(td))])
    td(i).spindleFR = [rOut, rdOut, rsOut];
    
end
end