function segmentBit = segmentBittium(bittium, timepoint, timeLength, sternum)
    %UNTITLED4 Summary of this function goes here
    %   Detailed explanation goes here
    
    data = bittium;
    
    task = fieldnames(timepoint);
    accstr = data.accTime;
    for tt = 1:length(task)
        timestr = string(timepoint.(task{tt}));        

        % Find the time index
        matchAccTime = strcmp(accstr,timestr);
        accIndex = find(matchAccTime,1,"first");

        % Cut the segment + bit before/after of bittium acceleration
        fs = 100;
        extra = 0; %s
        before = accIndex - (fs*extra);
        after = accIndex + timeLength.(task{tt}) + (fs*extra);

        bittiumAccRaw = data.acc(before:after,:);

        [correlation, lag] = xcorr(bittiumAccRaw(:,3), sternum(:,3));
        [~, maxIndex] = max(correlation);
        timeLag = lag(maxIndex);
%         timeLag = finddelay(sternum(:,3),bittiumAccRaw(:,3));

%         start = accIndex;% + timeLag;
%         stop = accIndex + timeLength.(task{tt})-1;% + timeLag -1;
        start = accIndex;% + timeLag;
        stop = accIndex + timeLength.(task{tt})-1;% + timeLag -1;
        
        segmentBit.(task{tt}).acc = data.acc(start:stop,:);
%         figure
%         plot(opal.DHI001.(task{tt}).sternum.acc(:,end))
%         hold on
%         plot(segmentBit.(task{tt}).acc(:,end))

        segmentBit.(task{tt}).ecgDS = data.ecgDS(start:stop,:);

        % For the NOT resample ECG
        startEcg = 250*(start/100);
        stopEcg = 250*(stop/100);
        segmentBit.(task{tt}).ecg = data.ecg(startEcg:stopEcg,:);
        % segmentBit.(task{tt}).filtEcg = data.filtEcg(startEcg:stopEcg,:);
                
        % Save sampling frequency
        segmentBit.(task{tt}).fsEcg = data.fsEcg;
        segmentBit.(task{tt}).fsAcc = data.fsAcc;
    end    
end