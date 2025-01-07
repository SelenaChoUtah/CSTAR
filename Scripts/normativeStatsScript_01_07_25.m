cd('C:\Users\chose\Box\C-STAR Pilot')
% cd("C:\Users\chose\Box\C-STAR Pilot")
addpath(genpath('Data\'))
addpath(genpath('CSTAR\'))

%% Everyone's data in one
currentFoldPath = cd;

processPath = dir(fullfile(currentFoldPath,'\Data\Process'));
processPath = processPath(~ismember({processPath.name}, {'.', '..'}));
subjectnum = processPath(listdlg('PromptString',{'Select Subjects to Pull (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{processPath.name}));

% Load Data 
for ii = 1:numel(subjectnum)
    % Save Data into Process
    id = string(subjectnum(ii).name);
    % disp(id)   
    data.(id) = load(fullfile(subjectnum(ii).folder,subjectnum(ii).name,'data.mat'));   
end

%% Remove turns greater than 360 bc not common

id = fieldnames(data);
for ii = 1:length(id)
    day = fieldnames(data.(id{ii}).turnData);
    
    for dd = 1:length(day)
        sensor = fieldnames(data.(id{ii}).turnData.(day{dd}));
        for ss = 1:length(sensor)
            aa = find(data.(id{ii}).turnData.(day{dd}).(sensor{ss}).amplitude>360);
            data.(id{ii}).turnData.(day{dd}).(sensor{ss}).amplitude(aa) = [];
            data.(id{ii}).turnData.(day{dd}).(sensor{ss}).angVelocity(aa) = [];
            data.(id{ii}).turnData.(day{dd}).(sensor{ss}).startstop(aa,:) = [];
        end
    end
end

%% mean
id = fieldnames(data);
for ii = 1:length(id)
    day = fieldnames(data.(id{ii}).turnData);
    
    for dd = 1:length(day)
        try
        idx_n = find(data.(id{ii}).turnData.(day{dd}).head.amplitude<45);
        idx_x = find(data.(id{ii}).turnData.(day{dd}).head.amplitude>45);

        smallTurnAmp(dd) = mean(nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude(idx_n)));
        largeTurnAmp(dd) = mean(nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude(idx_x)));
        % ang Velocity
        smallTurnVel(dd) = mean(nonzeros(data.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_n)));
        largeTurnVel(dd) = mean(nonzeros(data.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_x)));

        % number of turns and steps
        numOfTurns(dd) = length(data.(id{ii}).turnData.(day{dd}).head.amplitude);
        stepCount(dd) = data.(id{ii}).stepData.(day{dd}).waist.stepCount;

        % mean of turns
        ampData = nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude);
        meanAmp(dd) = mean(ampData);
        % angular velocity
        velData = nonzeros(data.(id{ii}).turnData.(day{dd}).head.angVelocity);
        meanVel(dd) = mean(velData);
        catch
        end
    end
    
    % All Turns
    stat.meanAmp(ii) = median(nonzeros(meanAmp));
    stat.meanVel(ii) = median(nonzeros(meanVel));

    % Amplitude
    stat.meansmallTurnAmp(ii) = mean(nonzeros(smallTurnAmp));
    stat.meanlargeTurnAmp(ii) = mean(nonzeros(largeTurnAmp));

    % Speed
    stat.meansmallTurnVel(ii) = mean(nonzeros(smallTurnVel));
    stat.meanlargeTurnVel(ii) = mean(nonzeros(largeTurnVel));

    % Quantity
    stat.meannumOfTurns(ii) = mean(nonzeros(numOfTurns));
    stat.stepCount(ii) = mean(nonzeros(stepCount));    

end





