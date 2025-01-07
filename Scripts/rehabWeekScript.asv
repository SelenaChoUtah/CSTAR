cd('C:\Users\chose\Box\Digital Health Pilot - Multimodal Sensing')
cd('C:\Users\chose\Box\C-STAR Pilot')
addpath(genpath('Data\'))
addpath(genpath('CSTAR\'))

%% Load Data In
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

clearvars -except data

% Small v Large Turns

mtbi_ID = {'DHI003','DHI007','DHI008','DHI009','DHI010','DHI011','DHI012','DHI015','DHI016'};
for i = 1:length(mtbi_ID)
    mtbi.(mtbi_ID{i}) = data.(mtbi_ID{i});    
end
data = rmfield(data,mtbi_ID);

%% mean
id = fieldnames(data);
for ii = 1:length(id)
    day = fieldnames(data.(id{ii}).turnData);
    
    for dd = 1:length(day)
        try
        idx_n = find(data.(id{ii}).turnData.(day{dd}).head.amplitude<40);
        idx_x = find(data.(id{ii}).turnData.(day{dd}).head.amplitude>40);

        smallTurnAmp(dd) = mean(nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude(idx_n)));
        largeTurnAmp(dd) = mean(nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude(idx_x)));
        % ang Velocity
        smallTurnVel(dd) = mean(nonzeros(data.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_n)));
        largeTurnVel(dd) = mean(nonzeros(data.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_x)));

        % number of turns
        numOfTurns(dd) = length(data.(id{ii}).turnData.(day{dd}).head.amplitude);
        catch
        end
    end
    stat.smallTurnAmp(ii) = mean(nonzeros(smallTurnAmp));
    stat.largeTurnAmp(ii) = mean(nonzeros(largeTurnAmp));
    stat.smallTurnVel(ii) = mean(nonzeros(smallTurnVel));
    stat.largeTurnVel(ii) = mean(nonzeros(largeTurnVel));
    stat.numOfTurns(ii) = mean(nonzeros(numOfTurns));

end


id = fieldnames(mtbi);
for ii = 1:length(id)
    day = fieldnames(mtbi.(id{ii}).turnData);
    
    for dd = 1:length(day)
        try
            idx_n = find(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude<40);
            idx_x = find(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude>40);
            % amplitude
            smallTurnAmp(dd) = mean(nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude(idx_n)));
            largeTurnAmp(dd) = mean(nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude(idx_x)));
            % ang velocity
            smallTurnVel(dd) = mean(nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_n)));
            largeTurnVel(dd) = mean(nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_x)));

            % number of turns
            numOfTurns(dd) = length(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude);
        catch 
        end
    end
    mstat.smallTurnAmp(ii) = mean(nonzeros(smallTurnAmp));
    mstat.largeTurnAmp(ii) = mean(nonzeros(largeTurnAmp));
    mstat.smallTurnVel(ii) = mean(nonzeros(smallTurnVel));
    mstat.largeTurnVel(ii) = mean(nonzeros(largeTurnVel));
    mstat.numOfTurns(ii) = mean(nonzeros(numOfTurns));
end

%% median

id = fieldnames(data);
for ii = 1:length(id)
    day = fieldnames(data.(id{ii}).turnData);
    try
        for dd = 1:length(day)
            idx_n = find(data.(id{ii}).turnData.(day{dd}).head.amplitude < 45);
            idx_x = find(data.(id{ii}).turnData.(day{dd}).head.amplitude > 45);

            smallTurnAmp(dd) = median(nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude(idx_n)));
            largeTurnAmp(dd) = median(nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude(idx_x)));
            % ang Velocity
            smallTurnVel(dd) = median(nonzeros(data.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_n)));
            largeTurnVel(dd) = median(nonzeros(data.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_x)));
        end
        stat.smallTurnAmp(ii) = median(nonzeros(smallTurnAmp));
        stat.largeTurnAmp(ii) = median(nonzeros(largeTurnAmp));
        stat.smallTurnVel(ii) = median(nonzeros(smallTurnVel));
        stat.largeTurnVel(ii) = median(nonzeros(largeTurnVel));
    catch
    end
end

id = fieldnames(mtbi);
for ii = 1:length(id)
    day = fieldnames(mtbi.(id{ii}).turnData);
    for dd = 1:length(day)
        try
            idx_n = find(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude < 40);
            idx_x = find(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude > 40);
            % amplitude
            smallTurnAmp(dd) = median(nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude(idx_n)));
            largeTurnAmp(dd) = median(nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude(idx_x)));
            % ang velocity
            smallTurnVel(dd) = median(nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_n)));
            largeTurnVel(dd) = median(nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_x)));
        catch
        end
    end
    mstat.smallTurnAmp(ii) = median(nonzeros(smallTurnAmp));
    mstat.largeTurnAmp(ii) = median(nonzeros(largeTurnAmp));
    mstat.smallTurnVel(ii) = median(nonzeros(smallTurnVel));
    mstat.largeTurnVel(ii) = median(nonzeros(largeTurnVel));
end

%% Mean with all turn with NO binning

id = fieldnames(data);
for ii = 1:length(id)
    day = fieldnames(data.(id{ii}).turnData);
    try
        for dd = 1:length(day)
            % amplitude
            ampData = nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude);
            allAmp(dd) = median(ampData);
            % angular velocity
            velData = nonzeros(data.(id{ii}).turnData.(day{dd}).head.angVelocity);
            allVel(dd) = median(velData);
        end
        stat.medallAmp(ii) = median(nonzeros(allAmp));
        stat.medallVel(ii) = median(nonzeros(allVel));
    catch
    end
end

id = fieldnames(mtbi);
for ii = 1:length(id)
    day = fieldnames(mtbi.(id{ii}).turnData);
    for dd = 1:length(day)
        try
            % amplitude
            ampData = nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude);
            allAmp(dd) = median(ampData);
            % angular velocity
            velData = nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.angVelocity);
            allVel(dd) = median(velData);
        catch
        end
    end
    mstat.medallAmp(ii) = median(nonzeros(allAmp));
    mstat.medallVel(ii) = median(nonzeros(allVel));
end

%% Mean of all turns

id = fieldnames(data);
for ii = 1:length(id)
    day = fieldnames(data.(id{ii}).turnData);
    try
        for dd = 1:length(day)
            % amplitude
            ampData = nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude);
            allAmp(dd) = mean(ampData);
            % angular velocity
            velData = nonzeros(data.(id{ii}).turnData.(day{dd}).head.angVelocity);
            allVel(dd) = mean(velData);
        end
        stat.meanallAmp(ii) = mean(nonzeros(allAmp));
        stat.meanallVel(ii) = mean(nonzeros(allVel));
    catch
    end
end

id = fieldnames(mtbi);
for ii = 1:length(id)
    day = fieldnames(mtbi.(id{ii}).turnData);
    for dd = 1:length(day)
        try
            % amplitude
            ampData = nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude);
            allAmp(dd) = mean(ampData);
            % angular velocity
            velData = nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.angVelocity);
            allVel(dd) = mean(velData);
        catch
        end
    end
    mstat.meanallAmp(ii) = mean(nonzeros(allAmp));
    mstat.meanallVel(ii) = mean(nonzeros(allVel));
end




%% Scatter Plot Small V Big turns
close all

figure
hold on
scatter(stat.smallTurnAmp,stat.largeTurnAmp,'filled')
scatter(mstat.smallTurnAmp,mstat.largeTurnAmp,'filled')
xlabel('Small Turn Amp (deg)')
ylabel('Large Turn Amp (deg)')
xlim([10 40])
ylim([40 300])
% ylim([50 100])
legend("HC","mTBI")
title("Amplitude 40 deg Large v Small")

figure
hold on
scatter(stat.smallTurnVel,stat.largeTurnVel,'filled')
scatter(mstat.smallTurnVel,mstat.largeTurnVel,'filled')
xlabel('Small Turn Amp (deg/s)')
ylabel('Large Turn Amp (deg/s)')
xlim([30 90])
ylim([40 200])
legend("HC","mTBI")
title("AngVelocity of small v Large 40 deg")

%%

close all

% Plot for Amplitude
figure
hold on
scatter(stat.medallAmp, stat.medallVel, 'filled')  % Healthy control (HC)
scatter(mstat.medallAmp, mstat.medallVel, 'filled')  % mTBI
xlabel('med Amplitude (deg)')
ylabel('med Angular Velocity (deg/s)')
xlim([10 150])
ylim([10 150])
legend("HC", "mTBI")
title("med Amplitude vs med Angular Velocity")

% Plot for Angular Velocity
figure
hold on
scatter(stat.meanallAmp, stat.meanallVel, 'filled')  % Healthy control (HC)
scatter(mstat.meanallAmp, mstat.meanallVel, 'filled')  % mTBI
xlabel('Mean Amplitude (deg)')
ylabel('Mean Angular Velocity (deg/s)')
xlim([10 150])
ylim([10 150])
legend("HC", "mTBI")
title("Mean Angular Velocity of Turns")

%% Plot for Number Of Turns
figure
hold on
scatter(nonzeros(stat.numOfTurns), nonzeros(stat.numOfTurns), 'filled')  % Healthy control (HC)
scatter(nonzeros(mstat.numOfTurns), nonzeros(mstat.numOfTurns), 'filled')  % mTBI
% xlabel('Mean Amplitude (deg)')
% ylabel('Mean Angular Velocity (deg/s)')
% xlim([10 150])
% ylim([10 150])
legend("HC", "mTBI")
title("Mean Angular Velocity of Turns")

%% t-test  

disp(["Mean of HC Num of Turns ", mean(nonzeros(stat.numOfTurns)), std(nonzeros(stat.numOfTurns))])
disp(["Mean of mTBI Num of Turns ", mean(nonzeros(mstat.numOfTurns)), std(nonzeros(mstat.numOfTurns))])
disp("T-Test Number of Turns")
[~, p, ci, ~] = ttest2(nonzeros(stat.numOfTurns), nonzeros(mstat.numOfTurns))



disp(["Mean of HC Amplitude ", mean(nonzeros(stat.meanallAmp)), std(nonzeros(stat.meanallAmp))])
disp(["Mean of mTBI Amplitude ", mean(nonzeros(mstat.meanallAmp  )), std(nonzeros(mstat.meanallAmp))])
disp("T-Test Turn Amplitude")
[~, p, ci, ~] = ttest2(nonzeros(stat.meanallAmp), nonzeros(mstat.meanallAmp))

disp(["Mean of HC Ang Velocity", mean(nonzeros(stat.meanallVel)), std(nonzeros(stat.meanallVel))])
disp(["Mean of mTBI Ang Velocity", mean(nonzeros(mstat.meanallVel  )), std(nonzeros(mstat.meanallVel))])
disp("T-Test Turn Ang Velocity")
[~, p, ci, ~] = ttest2(nonzeros(stat.meanallVel), nonzeros(mstat.meanallVel))


%% mtbi symptom scores

mtbi_symptoms = scores([2 6 7 8 9 10 11],:);
close all

figure
nexttile
plot(mstat.medallVel,mtbi_symptoms.nsi_total_score,'*')
xlabel("median ang Velocity")
ylabel("NSI Score")
% Add text labels at each data point
for i = 1:length(mstat.medallVel)
    text(mstat.medallVel(i), mtbi_symptoms.nsi_total_score(i), mtbi_ID{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end
nexttile
plot(mstat.medallVel,mtbi_symptoms.qolibri_100,'*')
xlabel("median ang Velocity")
ylabel("Qolibri Score")
% Add text labels at each data point
for i = 1:length(mstat.medallVel)
    text(mstat.medallVel(i), mtbi_symptoms.qolibri_100(i), mtbi_ID{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end

%%mtbi_symptoms = nsiquolibriScores([2 6 7 8 9 10 11],:);
close all

figure
nexttile
plot(mstat.largeTurnVel,mtbi_symptoms.nsi_total_score,'*')
xlabel("large mean ang Velocity")
ylabel("NSI Score")
% Add text labels at each data point
for i = 1:length(mstat.largeTurnVel)
    text(mstat.largeTurnVel(i), mtbi_symptoms.nsi_total_score(i), mtbi_ID{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end
nexttile
plot(mstat.largeTurnVel,mtbi_symptoms.qolibri_100,'*')
xlabel("large mean ang Velocity")
ylabel("Qolibri Score")
% Add text labels at each data point
for i = 1:length(mstat.largeTurnVel)
    text(mstat.largeTurnVel(i), mtbi_symptoms.qolibri_100(i), mtbi_ID{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end

%% Cycle through every score

scoreNames = mtbi_symptoms.Properties.VariableNames;

figure
for ss = 2:length(scoreNames)
    
    nexttile
    plot(mstat.medallVel,mtbi_symptoms.(scoreNames{ss}),'*')
    xlabel("large mean ang Velocity")
    ylabel(scoreNames{ss})
    % % Add text labels at each data point
    for i = 1:length(mstat.largeTurnVel)
        text(mstat.medallVel(i), mtbi_symptoms.(scoreNames{ss})(i), mtbi_ID{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    end
end


