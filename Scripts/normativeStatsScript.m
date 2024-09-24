addpath(genpath(pwd))
currentFoldPath = cd;

processPath = dir(fullfile(currentFoldPath,'\Data\Process'));
processPath = processPath(~ismember({processPath.name}, {'.', '..'}));
subjectnum = processPath(listdlg('PromptString',{'Select Subjects to Pull (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{processPath.name}));

% Load Data 
for i = 1:numel(subjectnum)
    % Save Data into Process
    id = string(subjectnum(i).name);
    % disp(id)   
    data.(id) = load(fullfile(subjectnum(i).folder,subjectnum(i).name,'data.mat'));   

end

%% Wear Time, hour, days

% Weartime per day
aa = 1;
id = fieldnames(data);
for i = 1:length(id)
    numDay = fieldnames(data.(id{i}).timeData);
    for j = 1:length(numDay)
        sensor = fieldnames(data.(id{i}).timeData.(numDay{j}));
        for s = 1:length(sensor)
            wearTime.(sensor{s})(j,i) = data.(id{i}).timeData.(numDay{j}).(sensor{s}).wearTime;            
        end
        aa = aa+1;
    end
end


for i = 1:length(turn.dailyCV.head.amplitude)
    statsMean.head.amplitudeCV(i) = mean(nonzeros(turn.dailyCV.head.amplitude(:,i)));
end


disp("Average Wear Time per Day")
disp(["head" mean(wearTime.head) std(wearTime.head)])
disp(["Neck" mean(wearTime.neck) std(wearTime.neck)])
disp(["Waist" mean(wearTime.waist) std(wearTime.waist)])

results = [
    "sensor", "head", "neck", "thoracic";
    "mean", mean(wearTime.head),mean(wearTime.neck),mean(wearTime.waist);
    "std", std(wearTime.head),std(wearTime.neck),std(wearTime.waist)
]

% Write to CSV
filename = 'wearTimeResults.csv';
writematrix(results, filename);

% Number of Days worn
id = fieldnames(data);
for i = 1:length(id)
    numDay = fieldnames(data.(id{i}).timeData);
    aa = 0;
    for j = 1:length(numDay)        
        sensor = fieldnames(data.(id{i}).timeData.(numDay{j}));
        for s = 1:length(sensor)
            
        end
        aa = aa+1;
    end
    wearWeek.(sensor{s})(aa,1)  = aa;
end

% disp(["Average Days of Week" mean(wearWeek) std(wearWeek)])
disp("Average Wear Day per Week")
results = [
    "sensor", "head", "neck", "thoracic";
    "mean", mean(wearWeek.head),mean(wearWeek.neck),mean(wearWeek.waist);
    "std", std(wearWeek.head),std(wearWeek.neck),std(wearWeek.waist)
]

%% Turn Statistics

turnMetric = {'amplitude', 'angVelocity','turnDuration'};
id = fieldnames(data);
for i = 1:length(id)
    dayNum = fieldnames(data.(id{i}).turnData);
    for d = 1:length(dayNum)
        sensor = fieldnames(data.(id{i}).turnData.(dayNum{d}));
        for s = 1:length(sensor)
            for t = 1:length(turnMetric)
                turn.dailyAverage.(sensor{s}).(turnMetric{t})(d,i) = mean(data.(id{i}).turnData.(dayNum{d}).(sensor{s}).(turnMetric{t}));
                turn.dailyStDev.(sensor{s}).(turnMetric{t})(d,i) = std(data.(id{i}).turnData.(dayNum{d}).(sensor{s}).(turnMetric{t}));
                turn.dailyNumber.(sensor{s}).(turnMetric{t})(d,i) = length(data.(id{i}).turnData.(dayNum{d}).(sensor{s}).(turnMetric{t}));
                turn.dailyCV.(sensor{s}).(turnMetric{t})(d,i) = std(data.(id{i}).turnData.(dayNum{d}).(sensor{s}).(turnMetric{t}))/mean(data.(id{i}).turnData.(dayNum{d}).(sensor{s}).(turnMetric{t}));
            end
        end
    end 
    for t = 1:length(turnMetric)
        for s = 1:length(sensor)
            turn.weeklyAverage.(sensor{s}).(turnMetric{t})(i,i) = mean(dailyAverage.(sensor{s}).(turnMetric{t}));
            turn.weeklyStDev.(sensor{s}).(turnMetric{t})(i,i) = std(dailyStDev.(sensor{s}).(turnMetric{t}));
            turn.weeklyNumberAverage.(sensor{s}).(turnMetric{t})(i,i) = mean(dailyNumber.(sensor{s}).(turnMetric{t}));
            turn.weeklyCV.(sensor{s}).(turnMetric{t})(i,i) = mean(dailyCV.(sensor{s}).(turnMetric{t}));
        end
    end
end

% results = [
%     "sensor", "head", "neck", "thoracic";
%     "mean", mean(wearTime.head),mean(wearTime.neck),mean(wearTime.waist);
%     "std", std(wearTime.head),std(wearTime.neck),std(wearTime.waist)
% ]

% % Write to CSV
% filename = 'normativeResults.xls';
% writematrix(results, filename,'Sheet','Step Count');

%% Step Statistics

turnMetric = {'amplitude', 'angVelocity','turnDuration'};
id = fieldnames(data);
for i = 1:length(id)
    dayNum = fieldnames(data.(id{i}).turnData);
    for d = 1:length(dayNum)
        sensor = fieldnames(data.(id{i}).turnData.(dayNum{d}));
        for s = 1:length(sensor)
            for t = 1:length(turnMetric)
                dailyAverage.(sensor{s}).(turnMetric{t})(d,1) = mean(data.(id{i}).turnData.(dayNum{d}).(sensor{s}).(turnMetric{t}));
                dailyStDev.(sensor{s}).(turnMetric{t})(d,1) = std(data.(id{i}).turnData.(dayNum{d}).(sensor{s}).(turnMetric{t}));
                dailyNumber.(sensor{s}).(turnMetric{t})(d,1) = length(data.(id{i}).turnData.(dayNum{d}).(sensor{s}).(turnMetric{t}));
                dailyCV.(sensor{s}).(turnMetric{t})(d,1) = std(data.(id{i}).turnData.(dayNum{d}).(sensor{s}).(turnMetric{t}))/mean(data.(id{i}).turnData.(dayNum{d}).(sensor{s}).(turnMetric{t}));
            end
        end
    end
end


%% Macro, steps per day, steps per hour, physical activity rate

id = fieldnames(data);
for i = 1:length(id)
    numDay = fieldnames(data.(id{i}).stepData);
    for j = 2:length(numDay)-1
        sensor = fieldnames(data.(id{i}).stepData.(numDay{j}));
        for s = 1:length(sensor)
            StepsPerDay.(id{i}).stepCount(j-1) = data.(id{i}).stepData.(numDay{j}).stepsTotal24;
            BoutsPerHour.(id{i}).stepCount(j-1) = data.(id{i}).stepData.(numDay{j}).stepsHour;
        end
    end
end

% average per person
subID = fieldnames(StepsPerDay);
stepCountAvg = zeros(length(subID),1);
stepCountVar = zeros(length(subID),1);
stepBoutAvg = zeros(length(subID),1);
stepBoutVar = zeros(length(subID),1);
for i = 1:length(subID)
    stepCountAvg(i) = mean(StepsPerDay.(subID{i}).stepCount);
    stepCountVar(i) = var(StepsPerDay.(subID{i}).stepCount);
    stepBoutAvg(i) = mean(BoutsPerHour.(subID{i}).stepCount);
    stepBoutVar(i) = var(BoutsPerHour.(subID{i}).stepCount);
end

results = [
    "metric", "step count day" "steps per hour";
    "mean",  mean([stepCountAvg stepBoutAvg]);
    "std", sqrt(mean(stepCountVar)),sqrt(mean(stepBoutVar));
];

filename = 'normativeResults.xls';
writematrix(results, filename,'Sheet',"Step Count");

%% Turns per day, per hour

id = fieldnames(data);
for i = 1:length(id)
    numDay = fieldnames(data.(id{i}).turnData);
    for j = 2:length(numDay)-1
        sensor = fieldnames(data.(id{i}).turnData.(numDay{j}));
        for s = 1:length(sensor)
            turn.(id{i}).(sensor{s}).meanAmplitude(j-1) = mean(data.(id{i}).turnData.(numDay{j}).(sensor{s}).amplitude);
            turn.(id{i}).(sensor{s}).varAmplitude(j-1) = var(data.(id{i}).turnData.(numDay{j}).(sensor{s}).amplitude);
            turn.(id{i}).(sensor{s}).meanSpeed(j-1) = mean(data.(id{i}).turnData.(numDay{j}).(sensor{s}).angVelocity);
            turn.(id{i}).(sensor{s}).varSpeed(j-1) = var(data.(id{i}).turnData.(numDay{j}).(sensor{s}).angVelocity);
            turn.(id{i}).(sensor{s}).meanDuration = mean((data.(id{i}).turnData.(numDay{j}).(sensor{s}).startstop(:,2)-data.(id{i}).turnData.(numDay{j}).(sensor{s}).startstop(:,1))/100);
            turn.(id{i}).(sensor{s}).varDuration = var((data.(id{i}).turnData.(numDay{j}).(sensor{s}).startstop(:,2)-data.(id{i}).turnData.(numDay{j}).(sensor{s}).startstop(:,1))/100);
            
        end
    end
end
%%
id = fieldnames(turn);
for i = 1:length(id)
    sensor = fieldnames(data.(id{i}).turnData.(numDay{j}));
    for s = 1:length(sensor)
        
    end
end

results = [
    "sensor", "head", "thoracic", "lumbar" ;
    "mean",  mean([]);
    "std", sqrt(mean(stepCountVar)),sqrt(mean(stepBoutVar));
]


