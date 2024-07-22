function sortData = sortIntoDays(reorient)

%   sortIntoDays Sorts sensor data into days based on timestamps.
%
%   SORTDATA = SORTINTODAYS(REORIENT) sorts sensor data into days based on
%   timestamps. The function takes the reoriented sensor data in the REORIENT
%   structure and organizes it into a new structured format where data is sorted
%   into individual days. Each day contains the timestamp, acceleration data,
%   and gyroscope data for each sensor location.
%
%   Input:
%       REORIENT: A structured data format containing reoriented sensor data.
%                 Data is organized by subject ID and sensor location.
%
%   Output:
%       SORTDATA: A structured data format containing sensor data sorted into
%                 individual days. Data is organized by subject ID, sensor
%                 location, and day.
%
%   Example input/output structure:
%       reorient."subjectID"."sensorLocation"."data"
%           - "subjectID" : e.g., 'S01'
%           - "sensorLocation" : e.g., 'head', 'neck', 'waist'
%           - "data" : time information, Resampled sensor data (tri-acceleration, tri-gyroscope) 
%
%   Example output structure:
%       sortData."subjectID"."sensorLocation"."dayX"."data"
%           - "subjectID" : e.g., 'S01'
%           - "sensorLocation" : e.g., 'head', 'neck', 'waist'
%           - "dayX" : Data for each day, including timestamp, acceleration,
%                      and gyroscope data.
%           - "data" : e.g., 'time', 'acc', 'gyro' <- it's now split
%           into different fields
%
%   By Selena Cho
%   Last Updated: April 1st, 2024

%-------------------------------------------------------------------------%

    fprintf("Sorting into days\n")
    sortData = struct();
    subID = string(fieldnames(reorient));
    for id = 1:length(subID)
        sensor = string(fieldnames(reorient.(subID(id))));
        for j = 1:length(sensor)
            time = datetime(reorient.(subID(id)).(sensor{j})(:,1), 'convertfrom', 'datenum', 'Format', 'd');
            cmpTime = day(datetime(reorient.(subID(id)).(sensor{j})(:,1), 'convertfrom', 'datenum', 'Format', 'd'));
            start = time(1);
            stop = time(end);            
            array = day(datetime(start:calendarDuration(0, 0, 1):stop));
            loc = [];
            for a = 1:length(array)
                loc(a,1) = find(cmpTime==array(a),1,'first');
                loc(a,2) = find(cmpTime==array(a),1,'last');
            end
            for b = 1:length(loc)
                dayname = strcat('day', string(b));
                sortData.(subID(id)).(dayname).(sensor{j}).time = reorient.(subID(id)).(sensor{j})(loc(b,1):loc(b,2),1);
                sortData.(subID(id)).(dayname).(sensor{j}).acc = reorient.(subID(id)).(sensor{j})(loc(b,1):loc(b,2),2:4);
                sortData.(subID(id)).(dayname).(sensor{j}).gyro = reorient.(subID(id)).(sensor{j})(loc(b,1):loc(b,2),5:7);
            end
        end
    end

end


