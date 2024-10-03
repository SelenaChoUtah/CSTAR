function segmentPolarStruct = segmentPolar(polar, timepoint, timeLength)
    %UNTITLED4 Summary of this function goes here
    %   Detailed explanation goes here
    
    task = fieldnames(timepoint);
    polarStr = polar.time;
    fs = polar.fs;
    polarDatetime = datetime(polarStr,'Format', 'HH:mm:ss');

    for tt = 1:length(task)
        startTimeStr = string(timepoint.(task{tt}));        

        % Find the time index
        matchStartTime = strcmp(polarStr,startTimeStr);
        startIndex = find(matchStartTime,1,"first");

        endTimeStr = string(timepoint.(task{tt})+seconds(timeLength.(task{tt})/100));
        matchEndTime = strcmp(polarStr,endTimeStr);
        endIndex = find(matchEndTime,1,"last");

        segmentPolarStruct.(task{tt}).ecg = polar.ecg(startIndex:endIndex,:);
        segmentPolarStruct.(task{tt}).fs = fs;
        
    end
    
end