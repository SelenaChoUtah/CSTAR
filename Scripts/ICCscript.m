%% Figure out ICC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath(pwd))

currentFoldPath = cd;
processPath = dir(fullfile(currentFoldPath,'\Data\Process'));
processPath = processPath(~ismember({processPath.name}, {'.', '..'}));
subjectnum = processPath(listdlg('PromptString',{'Select Subjects to Pull (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{processPath.name}));

% Load Subject Data 
for i = 1:numel(subjectnum)
    % All of subject data saved in data
    id = string(subjectnum(i).name);
    data.(id) = load(fullfile(subjectnum(i).folder,subjectnum(i).name,'data.mat'));   

end

%% ------------------------------------------------------------------------
clearvars compData
task = {'amplitude','angVelocity'};
% With number of head turns, create structure of days x num of subjects
id = fieldnames(data);
j = 1;
for i = 1:length(id)
    try
    dataStruct = 'turnData';
    % check if there is at least 5 
    % subDay(i,1) = length(fieldnames(data.(id{i}).(dataStruct)));
    if length(fieldnames(data.(id{i}).(dataStruct))) >= 5
        for t = 1:length(task)
            dayNum = fieldnames(data.(id{i}).(dataStruct));
            for d = 1:5
                compData.(task{t})(j,d) = mean(data.(id{i}).(dataStruct).(dayNum{d}).head.(task{t}));
                compData.number(j,d) = length(data.(id{i}).(dataStruct).(dayNum{d}).head.(task{t}));
            end
        end
        j = j+1;
    end
    catch
        disp('No sensor')
    end
end

for t = 1:length(task)
    compBaseline.(task{t}) = mean(compData.(task{t}),1);
end

%% Looping through diff day averages

% task = {'amplitude','angVelocity','number'};
taskName = 'angVelocity';
fullData =  mean(compData.(taskName),2);
for i = 1:5
    partialData =  mean(compData.(taskName)(:,1:i),2);
    compareData = [partialData,fullData];

    [r(i), LB(i), UB(i),~,~,~] = ICC(compareData, 'A-k');
    % 
    % ICC(i) = computeICC(partialData, fullData, '2-1');
    % 
    % % SDD
    % meanActivity = mean([partialData, fullData]);
    % difference = abs(partialData - fullData);
    % SDD(i) = 1.96 * std(difference) / mean(meanActivity) * 100; % SDD as a percentage of the mean
end

% disp(["ICC: " ICC])
% disp(["SDD: " SDD])

%% For loop for ICC


function quantifyPhysicalActivity(reliabilityData1, reliabilityData2, numDays)

    % Input arguments:
    % reliabilityData1: NxM matrix where N is the number of days (e.g., 6) and M is the number of subjects/participants for the first measurement period.
    % reliabilityData2: 1xM matrix containing the six-day average of the second measurement period.
    % numDays: Integer representing the number of days (1 to 6) to be analyzed.
    
    
    ICC_values = zeros(1, numDays); 
    SDD_values = zeros(1, numDays); 
    
    for d = 1:numDays
        day_combinations = nchoosek(1:6, d); % Generate all combinations of 'd' days from 6 days
        num_combinations = size(day_combinations, 1);
        ICC_comb = zeros(num_combinations, 1);
        SDD_comb = zeros(num_combinations, 1);

        % Loop over all combinations
        for c = 1:num_combinations
            selectedDays = day_combinations(c, :);
            avg_activity1 = mean(reliabilityData1(selectedDays, :), 1); % Average of selected days in period 1

            % Compute ICC(2,1)
            ICC_comb(c) = computeICC(avg_activity1, reliabilityData2, '2.1');

            % Compute SDD (% of the mean)
            meanActivity = mean([avg_activity1, reliabilityData2]);
            difference = abs(avg_activity1 - reliabilityData2);
            SDD_comb(c) = 1.96 * std(difference) / mean(meanActivity) * 100; % SDD as a percentage of the mean
        end
        
        % Take the mean ICC and SDD across all combinations for each day count
        ICC_values(d) = mean(ICC_comb);
        SDD_values(d) = mean(SDD_comb);
    end
    
    % Display Results
    disp('Number of Days vs. ICC and SDD:')
    for d = 1:numDays
        fprintf('Days: %d | ICC: %.3f | SDD: %.2f%%\n', d, ICC_values(d), SDD_values(d));
    end
end