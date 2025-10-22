cd('C:\Users\chose\Box\Digital Health Pilot - Multimodal Sensing')
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

%%
id = fieldnames(data);
for ii = 1:length(id)
    day = fieldnames(data.(id{ii}).turnData);
    
        for dd = 1:length(day)
            try
            % amplitude
            ampData = nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude);
            allAmp(dd) = median(ampData);
            meanAmp(dd) = mean(ampData);
            % angular velocity
            velData = nonzeros(data.(id{ii}).turnData.(day{dd}).head.angVelocity);
            allVel(dd) = median(velData);
            meanVel(dd) = mean(velData);
            numOfTurns(dd) = length(data.(id{ii}).turnData.(day{dd}).head.amplitude);
            stepCount(dd) = data.(id{ii}).stepData.(day{dd}).waist.stepCount;
            catch
            end
        end
        stat.medallAmp(ii) = median(nonzeros(allAmp));
        stat.medallVel(ii) = median(nonzeros(allVel));
        stat.meanAmp(ii) = median(nonzeros(meanAmp));
        stat.meanVel(ii) = median(nonzeros(meanVel));
        stat.numOfTurns(ii) = mean(nonzeros(numOfTurns));
        stat.stepCount(ii) = mean(nonzeros(stepCount));
   
end

% Small v Large Turns

id = fieldnames(data);
for ii = 1:length(id)
    day = fieldnames(data.(id{ii}).turnData);
    
        for dd = 1:length(day)
            try
            idx_n = find(data.(id{ii}).turnData.(day{dd}).head.amplitude < 40);
            idx_x = find(data.(id{ii}).turnData.(day{dd}).head.amplitude > 40);

            smallTurnAmp(dd) = median(nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude(idx_n)));
            largeTurnAmp(dd) = median(nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude(idx_x)));
            smallnumOfTurns(dd) = length(nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude(idx_n)));
            largenumOfTurns(dd) = length(nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude(idx_x)));
            % ang Velocity
            smallTurnVel(dd) = median(nonzeros(data.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_n)));
            largeTurnVel(dd) = median(nonzeros(data.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_x)));
            catch
                % disp([ii,"day ",dd])
            end
        end
        stat.smallTurnAmp(ii) = median(nonzeros(smallTurnAmp));
        stat.largeTurnAmp(ii) = median(nonzeros(largeTurnAmp));
        stat.smallTurnVel(ii) = median(nonzeros(smallTurnVel));
        stat.largeTurnVel(ii) = median(nonzeros(largeTurnVel));
        stat.smallTurns(ii) = median(nonzeros(smallnumOfTurns));
        stat.largeTurns(ii) = median(nonzeros(largenumOfTurns));
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

        % number of turns
        numOfTurns(dd) = length(data.(id{ii}).turnData.(day{dd}).head.amplitude);
        catch
        end
    end
    stat.meansmallTurnAmp(ii) = mean(nonzeros(smallTurnAmp));
    stat.meanlargeTurnAmp(ii) = mean(nonzeros(largeTurnAmp));
    stat.meansmallTurnVel(ii) = mean(nonzeros(smallTurnVel));
    stat.meanlargeTurnVel(ii) = mean(nonzeros(largeTurnVel));
    stat.meannumOfTurns(ii) = mean(nonzeros(numOfTurns));

end

%% All Questionaires
% import C:\Users\chose\Box\Digital Health Pilot - Multimodal Sensing\REDCap data Export\scores

mtbi_ID = {'DHI003','DHI007','DHI008','DHI009','DHI010','DHI011','DHI012','DHI015','DHI016','DHI017'};
id = string(mtbi_ID)';

scores.label = ismember(string(scores.subID),id);

scores.label = ismember(string(scores.subID),id);
scores.medVel = stat.medallVel'; 
scores.medAmp = stat.medallAmp'; 
scores.meanVel = stat.meanVel'; 
scores.meanAmp = stat.meanAmp'; 

% median
scores.medsmallTurnAmp = stat.smallTurnAmp';
scores.medlargeTurnAmp = stat.largeTurnAmp';
scores.medsmallTurnVel = stat.smallTurnVel';
scores.medlargeTurnVel = stat.largeTurnVel';
% mean
scores.meansmallTurnAmp = stat.meansmallTurnAmp';
scores.meanlargeTurnAmp = stat.meanlargeTurnAmp';
scores.meansmallTurnVel = stat.meansmallTurnVel';
scores.meanlargeTurnVel = stat.meanlargeTurnVel';

scores.numOfTurns = stat.meannumOfTurns';
scores.smallTurns = stat.smallTurns';
scores.largeTurns = stat.largeTurns';
scores.stepCount = stat.stepCount';

scores.sexCat = categorical(scores.Sex);
scores.concussionCat = categorical(scores.Concussion);
scores.adjustedAge = scores.Age - mean(scores.Age);

%% plot function

varNames = fieldnames(scores)';

 % Select X variable using list dialog
[xIdx, xOk] = listdlg('PromptString', 'Select X Variable:', 'SelectionMode', 'single', 'ListString', varNames);
if ~xOk, return; end
xVarName = varNames{xIdx};

% Select Y variable using list dialog
[yIdx, yOk] = listdlg('PromptString', 'Select Y Variable:', 'SelectionMode', 'single', 'ListString', varNames);
if ~yOk, return; end
yVarName = varNames{yIdx};

figure
scatterhist(scores.(xVarName), scores.(yVarName), 'group',scores.Dominant,'Kernel','on')
% legend({'HC', 'mTBI'}, 'Location', 'best');
legend
xlabel(xVarName);
ylabel(yVarName);
title(append(xVarName, ' vs ', yVarName));

figure
gscatter(scores.(xVarName), scores.(yVarName), scores.Dominant)
xlabel(xVarName)
ylabel(yVarName)
title(append(xVarName, ' vs ', yVarName))
% Add text labels at each data point
for i = 1:length(scores.subID)
    text(scores.(xVarName)(i), scores.(yVarName)(i), scores.subID{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end
% legend({'HC', 'mTBI'}, 'Location', 'best');
legend()

%%

 % Select X variable using list dialog
[xIdx, xOk] = listdlg('PromptString', 'Select X Variable:', 'SelectionMode', 'single', 'ListString', varNames);
if ~xOk, return; end
xVarName = varNames{xIdx};

% Select Y variable using list dialog
[yIdx, yOk] = listdlg('PromptString', 'Select Y Variable:', 'SelectionMode', 'single', 'ListString', varNames);
if ~yOk, return; end
yVarName = varNames{yIdx};

% Select Z variable using list dialog
[zIdx, zOk] = listdlg('PromptString', 'Select Y Variable:', 'SelectionMode', 'single', 'ListString', varNames);
if ~zOk, return; end
zVarName = varNames{zIdx};

figure
scatter3(scores.(xVarName), scores.(yVarName), scores.(zVarName))
xlabel(xVarName)
ylabel(yVarName)
title(append(xVarName, ' vs ', yVarName))
% Add text labels at each data point
for i = 1:length(scores.subID)
    text(scores.(xVarName)(i), scores.(yVarName)(i),scores.(zVarName)(i), scores.subID{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end
% legend({'HC', 'mTBI'}, 'Location', 'best');
legend()


%% CP Screen Plot

varNames = fieldnames(scores)';

 % Select X variable using list dialog
[xIdx, xOk] = listdlg('PromptString', 'Select X Variable:', 'SelectionMode', 'single', 'ListString', varNames);
if ~xOk, return; end
xVarName = varNames{xIdx};

% Select Y variable using list dialog
[yIdx, yOk] = listdlg('PromptString', 'Select Y Variable:', 'SelectionMode', 'single', 'ListString', varNames);
if ~yOk, return; end
yVarName = varNames{yIdx};

figure
scatterhist(scores.(xVarName), scores.(yVarName), 'group',scores.label,'Kernel','on')
legend({'HC', 'mTBI'}, 'Location', 'best');
xlabel(xVarName);
ylabel(yVarName);
title(append(xVarName, ' vs ', yVarName));

figure
gscatter(scores.(xVarName), scores.(yVarName), scores.label)
xlabel(xVarName)
ylabel(yVarName)
title(append(xVarName, ' vs ', yVarName))
% Add text labels at each data point
for i = 1:length(scores.subID)
    text(scores.(xVarName)(i), scores.(yVarName)(i), scores.subID{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end
legend({'HC', 'mTBI'}, 'Location', 'best');

%% gscatter

% gscatter of medVel vs. age with concussion and control groups
figure
gscatter(scores.Age,scores.medVel,scores.label)
ylabel('Median Speed')
xlabel('Age')

%% Descriptive Stats - split mtbi and HC 

mtbi_ID = {'DHI003','DHI007','DHI008','DHI009','DHI010','DHI011','DHI012','DHI015','DHI016','DHI017'};
varNames = scores.subID;
j = 1;
k = 1;
for i = 1:length(varNames)
    if any(strcmp(varNames{i}, mtbi_ID))
        % Save the data corresponding to the mtbi_ID to the mtbi struct
        mtbi(j,:) = scores(i,:);
        j = j+1;

    else 
        hc(k,:) = scores(i,:);
        k = k+1;
    end 
end

%% Split age by 30 years old

varNames = scores.subID;
j = 1;
k = 1;
for i = 1:length(varNames)
    if scores.Age(i) >= 30
        older(j,:) = scores(i,:);
        j = j+1;

    else 
        younger(k,:) = scores(i,:);
        k = k+1;
    end 
end

%% Print out stats

varNames = fieldnames(scores)';
[xIdx, xOk] = listdlg('PromptString', 'Select X Variable:', 'SelectionMode', 'single', 'ListString', varNames);
if ~xOk, return; end
xVarName = varNames{xIdx};
disp(['HC ' xVarName ' mean (sd)' string(mean(hc.(xVarName))) string(std(hc.(xVarName)))])
disp(['mTBI ' xVarName ' mean (sd)' string(mean(mtbi.(xVarName))) string(std(mtbi.(xVarName)))])



%% fitglm for entire table HC+mTBI
clc
varNames = fieldnames(scores)';
[xIdx, xOk] = listdlg('PromptString', 'Select X Variable:', 'SelectionMode', 'multiple', 'ListString', varNames);

% Adjusted Age
for i = 1:length(xIdx)
    mdl = append(varNames(xIdx(i)),'~ concussionCat + adjustedAge + sexCat + adjustedAge*concussionCat');
    glm = fitglm(scores, string(mdl))
end

%% not adjusted age

varNames = fieldnames(scores)';
[xIdx, xOk] = listdlg('PromptString', 'Select X Variable:', 'SelectionMode', 'multiple', 'ListString', varNames);

for i = 1:length(xIdx)
    mdl = append(varNames(xIdx(i)),'~ concussionCat + Age + sexCat + Age*concussionCat');
    glm = fitglm(scores, string(mdl))
end

%% fitglm for younger and older 
clc
varNames = fieldnames(older)';
[xIdx, xOk] = listdlg('PromptString', 'Select X Variable:', 'SelectionMode', 'multiple', 'ListString', varNames);

disp("Older >=30")
for i = 1:length(xIdx)
    mdl = append(varNames(xIdx(i)),'~ concussionCat + sexCat ');
    glm = fitglm(older, string(mdl))
end

disp("Younger <30")
for i = 1:length(xIdx)
    mdl = append(varNames(xIdx(i)),'~ concussionCat + sexCat ');
    glm = fitglm(younger, string(mdl))
end

%% fitglm for hc
clc
varNames = fieldnames(scores)';
[xIdx, xOk] = listdlg('PromptString', 'Select X Variable:', 'SelectionMode', 'multiple', 'ListString', varNames);

for i = 1:length(xIdx)
    mdl = append(varNames(xIdx(i)),'~ Age + sexCat');
    glm = fitglm(hc, string(mdl))
end

%% fitflm for mtbi
clc
varNames = fieldnames(scores)';
[xIdx, xOk] = listdlg('PromptString', 'Select X Variable:', 'SelectionMode', 'multiple', 'ListString', varNames);

for i = 1:length(xIdx)
    mdl = append(varNames(xIdx(i)),'~ Age + sexCat');
    glm = fitglm(mtbi, string(mdl))
end

%%
% glm = fitglm(scores, 'Concussion ~ medlargeTurnVel + Age')

% mdl = fitglm(data, 'Participants ~ tts + speed + duration + Age', 'Distribution', 'binomial', 'Link', 'logit');

%% Loading in FGA data

% id = string(mtbi_ID)';
% midx = find(ismember(string(fgaexcel1.subID),id)==1);
% hcidx = find(ismember(string(fgaexcel1.subID),id)==0);
% 
% mtbi_fga = fgaexcel1.fgaScore(midx);
% hc_fga = fgaexcel1.fgaScore(hcidx);
% 
% fgaexcel1.label = ismember(string(fgaexcel1.subID),id);
% fgaexcel1.medVel = stat.medallVel'; 
% fgaexcel1.medAmp = stat.medallAmp'; 
% 
% fgaexcel1.smallTurnAmp = stat.smallTurnAmp';
% fgaexcel1.largeTurnAmp = stat.largeTurnAmp';
% fgaexcel1.smallTurnVel = stat.smallTurnVel';
% fgaexcel1.largeTurnVel = stat.largeTurnVel';
% fgaexcel1.numOfTurns = stat.numOfTurns';

%% violin plots
close all

Violin2(mtbi.Age,1,'ViolinColor',[0 0 1],'Showdata',true,'Sides','Left','ShowMean',true);
Violin2(hc.Age,1,'ViolinColor',[1 0 0],'Showdata',true,'Sides','Right','ShowMean',true);

%%
% Assuming your table is named 'data' with columns 'Sex' and 'Group'
% 'Group' contains values like 'mtbi' and 'hc'

% Count the occurrences of each Sex in each Group
mtbiCounts = groupcounts(scores.Sex(scores.label == 1));
hcCounts = groupcounts(scores.Sex(scores.label == 0));

% Define the categories for plotting
categories = unique(scores.Sex); % This assumes 'Sex' is categorical or strings
groupLabels = {'MTBI', 'HC'};

% Combine data into a matrix for grouped bar chart
counts = [mtbiCounts, hcCounts];

% Plot a grouped bar chart
figure;
bar(categorical(categories), counts);
legend(groupLabels, 'Location', 'northeast');
xlabel('Sex');
ylabel('Count');
title('Sex Distribution by Group');

%% scatterhist with head turn vel from home on one axis, and miniBEST total score on the other axis?
figure
scatterhist(fgaexcel1.fgaScore, fgaexcel1.medVel, 'group',fgaexcel1.label);
legend({'HC', 'mTBI'}, 'Location', 'best');
xlabel('FGA Score');
ylabel('Median Head Turn Vel');
title('Scatterhist by Group');


figure
h = scatterhist(fgaexcel1.fgaScore, fgaexcel1.medVel, 'group',fgaexcel1.label);
xlabel('FGA Score');
ylabel('Median Head Turn Vel');
hold on;
clr = get(h(1),'colororder');
boxplot(h(2),fgaexcel1.fgaScore,fgaexcel1.label,'orientation','horizontal',...
     'label',{'',''},'color',clr);
boxplot(h(3),fgaexcel1.medVel,fgaexcel1.label,'orientation','horizontal',...
     'label', {'',''},'color',clr);
set(h(2:3),'XTickLabel','');
view(h(3),[270,90]);  % Rotate the Y plot
axis(h(1),'auto');  % Sync axes
hold off;

%%
close all
figure
scatterhist(fgaexcel1.fgaScore, fgaexcel1.medAmp, 'group',fgaexcel1.label,'Kernel','on')
xlabel('FGA Score');
ylabel('Median Head Turn Amp');
legend({'HC', 'mTBI'}, 'Location', 'best');

figure
scatterhist(fgaexcel1.fgaScore, fgaexcel1.smallTurnAmp, 'group',fgaexcel1.label,'Kernel','on')
xlabel('FGA Score');
ylabel('Median smallTurnAmp');
legend({'HC', 'mTBI'}, 'Location', 'best');

figure
scatterhist(fgaexcel1.fgaScore, fgaexcel1.largeTurnAmp, 'group',fgaexcel1.label,'Kernel','on')
xlabel('FGA Score');
ylabel('Median largeTurnAmp');
legend({'HC', 'mTBI'}, 'Location', 'best');

%% Vel
figure
scatterhist(fgaexcel1.fgaScore, fgaexcel1.smallTurnVel, 'group',fgaexcel1.label,'Kernel','on')
xlabel('FGA Score');
ylabel('Median smallTurnVel');
legend({'HC', 'mTBI'}, 'Location', 'best');

figure
scatterhist(fgaexcel1.fgaScore, fgaexcel1.largeTurnVel, 'group',fgaexcel1.label,'Kernel','on')
xlabel('FGA Score');
ylabel('Median largeTurnVel');
legend({'HC', 'mTBI'}, 'Location', 'best');

%% Num of Turns
figure
scatterhist(fgaexcel1.fgaScore, fgaexcel1.numOfTurns, 'group',fgaexcel1.label,'Kernel','on')
xlabel('FGA Score');
ylabel('Num of Turns');
legend({'HC', 'mTBI'}, 'Location', 'best');

corr(fgaexcel1.fgaScore, fgaexcel1.medVel)

% Violin2(mtbi_fga,1,'ViolinColor',[0 0 1],'Showdata',true,'Sides','Left','ShowMean',true);
% Violin2(hc_fga,1,'ViolinColor',[1 0 0],'Showdata',true,'Sides','Right','ShowMean',true);

%% OLDDDDDD

%% HC - Healthy Controls

id = fieldnames(hc);
for ii = 1:length(id)
    day = fieldnames(hc.(id{ii}).turnData);
    
    for dd = 1:length(day)
        try
        idx_n = find(hc.(id{ii}).turnData.(day{dd}).head.amplitude<40);
        idx_x = find(hc.(id{ii}).turnData.(day{dd}).head.amplitude>40);

        smallTurnAmp(dd) = mean(nonzeros(hc.(id{ii}).turnData.(day{dd}).head.amplitude(idx_n)));
        largeTurnAmp(dd) = mean(nonzeros(hc.(id{ii}).turnData.(day{dd}).head.amplitude(idx_x)));
        % ang Velocity
        smallTurnVel(dd) = mean(nonzeros(hc.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_n)));
        largeTurnVel(dd) = mean(nonzeros(hc.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_x)));

        % number of turns
        numOfTurns(dd) = length(hc.(id{ii}).turnData.(day{dd}).head.amplitude);
        catch
        end
    end
    hcstat.smallTurnAmp(ii) = mean(nonzeros(smallTurnAmp));
    hcstat.largeTurnAmp(ii) = mean(nonzeros(largeTurnAmp));
    hcstat.smallTurnVel(ii) = mean(nonzeros(smallTurnVel));
    hcstat.largeTurnVel(ii) = mean(nonzeros(largeTurnVel));
    hcstat.numOfTurns(ii) = mean(nonzeros(numOfTurns));

end


id = fieldnames(hc);
for ii = 1:length(id)
    day = fieldnames(data.(id{ii}).turnData);
    try
        for dd = 1:length(day)
            % amplitude
            ampData = nonzeros(hc.(id{ii}).turnData.(day{dd}).head.amplitude);
            allAmp(dd) = median(ampData);
            % angular velocity
            velData = nonzeros(hc.(id{ii}).turnData.(day{dd}).head.angVelocity);
            allVel(dd) = median(velData);
        end
        hcstat.medallAmp(ii) = median(nonzeros(allAmp));
        hcstat.medallVel(ii) = median(nonzeros(allVel));
    catch
    end
end