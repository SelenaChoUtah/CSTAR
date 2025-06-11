% cd('C:\Users\chose\Box\C-STAR Pilot')
cd('D:\CSTAR')

addpath(genpath('CSTAR\'))
addpath(genpath('Data\'))
currentFoldPath = cd;
processPath = dir(fullfile(currentFoldPath,'\Data\Preprocess'));
processPath = processPath(~ismember({processPath.name}, {'.', '..'}));

% zipPath = fullfile("\Data\zipDataFolder\");
zipPath = fullfile("C:\Users\chose\Box\C-STAR Pilot\Data\zipDataFolder");

for i = 3:24%:length(folderList)
    folderName = [processPath(i).folder filesep processPath(i).name];
    zipFileName = fullfile(zipPath, [processPath(i).name '.zip']);
    
    if exist(folderName, 'dir')
        zip(zipFileName, folderName);
        fprintf('Zipped folder: %s --> %s\n', folderName, zipFileName);
    else
        warning('Folder not found: %s', folderName);
    end
end