%--------------------------------------------------------------------------
% 
%     Script for the normative stats paper. There are 
%     muiltiple other renditions and this one is mostly 
%     focused on head-n-body turns. 
%     Last Updated 4/8/2024
% 
%     1) Loading processed data in
%     2) Head-on-body turns (neck and trunk)
%     3) Histogram of percentage of head turn v amp v vel
% 
%--------------------------------------------------------------------------

cd('C:\Users\chose\Box\C-STAR Pilot')
addpath(genpath('Data\'))
addpath(genpath('CSTAR\'))
addpath(genpath('ProcessData\'))


%% 1) Loading in Data
currentFoldPath = cd;

% CSTAR
processPath = dir(fullfile(currentFoldPath,'\Data\Process'));
% DHI-Lab
% processPath = dir(fullfile(currentFoldPath,'\ProcessData\Continuous'));
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

%% 2) Head-on-body turns (neck and trunk)
% Saving into daily averages per person to meanVar and stdVar

% S is reference to Space and B is to the trunk
variables = {'amplitudeB','amplitudeS','angVelB','angVelS'};

% Head-on-trunk and Head-on-thoracic
segment = {'headOnTrunkCount','headOnNeckCount'};

hot = struct();
% Stable v Volitional
id = fieldnames(data);
for ii = 1:length(id)
    for ss = 1:length(segment)
        days = fieldnames(data.(id{ii}).(segment{ss}));
        for dd = 1:length(days)
            turnType = {'stabilization','volitional'};
            for tt = 1:length(turnType)
                for vv = 1:length(variables)
                    meanVar.(id{ii}).(segment{ss}).(turnType{tt}).(variables{vv})(dd) = mean(data.(id{ii}).(segment{ss}).(days{dd}).(turnType{tt}).(variables{vv}));
                    stdVar.(id{ii}).(segment{ss}).(turnType{tt}).(variables{vv})(dd) = std(data.(id{ii}).(segment{ss}).(days{dd}).(turnType{tt}).(variables{vv}));
                    meanVar.(id{ii}).(segment{ss}).(turnType{tt}).count(dd) =  length(data.(id{ii}).(segment{ss}).(days{dd}).(turnType{tt}).(variables{vv}));
                end
            end
        end  
    end
end

% Weekly average from each subject
for ii = 1:length(id)
    for ss = 1:length(segment)
        for tt = 1:length(turnType)
            variables = fieldnames(meanVar.(id{ii}).(segment{ss}).(turnType{tt}));
            for vv = 1:length(variables)
                hot.(segment{ss}).(turnType{tt}).(variables{vv})(ii,1) = round(mean(meanVar.(id{ii}).(segment{ss}).(turnType{tt}).(variables{vv})),2);
                hot.(segment{ss}).(turnType{tt}).(variables{vv})(ii,2) = round(std(meanVar.(id{ii}).(segment{ss}).(turnType{tt}).(variables{vv})),2);
            end
        end
    end
end

% Average on the entire group
for ss = 1:length(segment)
    for tt = 1:length(turnType)
        for vv = 1:length(variables)
            hotGroup.(segment{ss}).(turnType{tt}).(variables{vv}) = mean(hot.(segment{ss}).(turnType{tt}).(variables{vv}));
        end
    end
end

% Array to Table for export

for ss = 1:length(segment)    
    for tt = 1:length(turnType)
        hotTable.(segment{ss}).(turnType{tt}) = cell2table(variables);
        for vv = 1:length(variables)
            hotTable.(segment{ss}).(turnType{tt}) = struct2table(hotGroup.(segment{ss}).(turnType{tt}));
        end
        filename = 'hotTable.xlsx';
        sheetName = append(segment{ss},turnType{tt});
        writetable(hotTable.(segment{ss}).(turnType{tt}),filename,'Sheet',sheetName)
    end
end

%% 3) Histogram of percentage of head turn v amp v vel
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
             
            aa = find(data.(id{ii}).turnData.(day{dd}).(sensor{ss}).angVelocity >800);
            data.(id{ii}).turnData.(day{dd}).(sensor{ss}).amplitude(aa) = [];
            data.(id{ii}).turnData.(day{dd}).(sensor{ss}).angVelocity(aa) = [];
            data.(id{ii}).turnData.(day{dd}).(sensor{ss}).startstop(aa,:) = [];
        end
    end
end

% Initialize an empty array to store the two-column data
compiledData = [];

id = fieldnames(data);
for ii = 1:length(id)
    days = fieldnames(data.(id{ii}).turnData);
    for dd = 1:length(days)
        try
        dayCompiledData = [data.(id{ii}).turnData.(days{dd}).head.amplitude, data.(id{ii}).turnData.(days{dd}).head.angVelocity];
    
        % Append to the compiledData array
        compiledData = [compiledData; dayCompiledData];
        catch
        end        
    end
end

%%
close all
hist3(compiledData,{0:50:300 15:100:800})
xlabel('amplitude')
ylabel('angular velocity')


% Define bin edges for amplitude and angular velocity
xEdges = 0:20:300;       % for amplitude (column 1)
yEdges = 0:20:300;     % for angular velocity (column 2)

% Create 2D histogram using custom edges
[n, edges] = hist3(compiledData, 'Edges', {xEdges, yEdges});

% Normalize to get percentage
totalCount = sum(n(:));
percentageData = (n / totalCount) * 100;

% Plot the histogram bars
figure;
bar3(percentageData);

% Label axes
xlabel('Amplitude');
ylabel('Angular Velocity');
zlabel('Percentage');

% Adjust x and y tick positions and labels to match bin centers
xticks(1:length(xEdges)-1);
xticklabels(arrayfun(@(i) sprintf('%d', xEdges(i)), 1:length(xEdges)-1, 'UniformOutput', false));

yticks(1:length(yEdges)-1);
yticklabels(arrayfun(@(i) sprintf('%d', yEdges(i)), 1:length(yEdges)-1, 'UniformOutput', false));

% Optional: Rotate y-axis labels for readability
ax = gca;
ax.YTickLabelRotation = 45;

exportgraphics(gcf, 'histo.pdf', 'ContentType', 'vector', 'BackgroundColor', 'none');

%%

close all

% Define bin edges for amplitude and angular velocity
xEdges = 0:10:150;        % for amplitude (column 1)
yEdges = 0:30:330;        % for angular velocity (column 2)

% Create 2D histogram using custom edges
[n, edges] = hist3(compiledData, 'Edges', {xEdges, yEdges});

% Normalize to get percentage
totalCount = sum(n(:));
percentageData = (n / totalCount) * 100;

% Calculate bin centers (for surf plot)
xCenters = edges{1}(1:end-1) + diff(edges{1})/2;
yCenters = edges{2}(1:end-1) + diff(edges{2})/2;

% Create meshgrid for surf plot
[X, Y] = meshgrid(xCenters, yCenters);

% Transpose percentageData to align with meshgrid orientation
Z = percentageData(1:end-1,1:end-1)';

% Plot with surf
figure;
surf(X, Y, Z,'FaceAlpha',0.5)
% shading interp;  % optional: smooth color interpolation
% colorbar;        % optional: show color scale

% Label axes
xlabel('Amplitude');
ylabel('Angular Velocity');
zlabel('Percentage');

title('Histogram');
view(45, 30);  % adjust view angle if needed


%% LME Head Count v Step Count

cc = 1;
subID = fieldnames(data);

for ii = 1:length(subID)
    dayNum = fieldnames(data.(subID{ii}).turnData);
    for dd = 1:length(dayNum)
        try
        id(cc,1) = subID{ii};
        stepCount(cc,1) = data.(subID{ii}).stepData.(dayNum{dd}).waist.stepCount;
        headCount(cc,1) = length(data.(subID{ii}).turnData.(dayNum{dd}).head.amplitude);
        cc = cc+1;
        catch
            disp("Missing")
        end
    end
end

headVstep = table(id,headCount,stepCount);

lme = fitlme(headVstep, 'stepCount ~ headCount + (1|id)')

%% adjusted r2

y = headVstep.stepCount;
y_hat_fixed = predict(lme, headVstep, 'Conditional', false);
var_fixed = var(y_hat_fixed);
var_random = 1770.6^2;
var_residual = 2396.4^2;

R2_m = var_fixed / (var_fixed + var_random + var_residual);
R2_c = (var_fixed + var_random) / (var_fixed + var_random + var_residual);
n = 155;
p = 1; 
adjR2_m = 1 - (1 - R2_m)*(n - 1)/(n - p - 1);



