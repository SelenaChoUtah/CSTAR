function Opal = readOpalData_v2(filename)
% readOpalData - reads data from .h5 file and returns a structure with
%   accelerometer and gyro data
%
% filename = name of the file to process
%
% Opal = structure returned witht the data
%   .sampleRate = data collection rate
%   .time = time vector to use with data at this sampleRate
%   .sensor = array of structures with data from each sensor
%       .caseID = number on the monitor case
%       .monitorLabel = label for the body position of monitor
%       .acc = accelerometer data with x,y,z fields
%       .gyro = gyroscope data with x,y,z fields
%    
%   Updated on 5/22/2018 to work with Opal Hardward v2 - Peter Fino

% try
%     vers = hdf5read(filename, '/FileFormatVersion');
% catch
%     try
%         vers = hdf5read(filename, '/File_Format_Version');
%     catch
%         error('Couldn''t determine file format');
%     end
% end
% if vers < 2
%     error('This example only works with version 2 of the data file')
% end

useMonitorLabels = {};
monitorLabels = {};
monitorCaseIDs = {};


sensors     = h5info(filename, '/Sensors');
processed   = h5info(filename, '/Processed');
nDevices    = length(sensors.Groups);

for monitorIdx = 1:nDevices
    
    caseID = sensors.Groups(monitorIdx).Name;
    monitorLabel = strtrim(string(h5readatt(filename, [sensors.Groups(monitorIdx).Name '/Configuration'], 'Label 0')));
    
%     if ~isempty(useMonitorLabels) && isempty(strmatch(monitorLabel, useMonitorLabels, 'exact'))
%         continue;
%     end
    
    accPath = [sensors.Groups(monitorIdx).Name '/Accelerometer'];
    gyroPath = [sensors.Groups(monitorIdx).Name '/Gyroscope'];
    magPath = [sensors.Groups(monitorIdx).Name '/Magnetometer'];
    orientPath = [processed.Groups(monitorIdx).Name '/Orientation'];
    
    includeAcc = h5readatt(filename, [sensors.Groups(monitorIdx).Name '/Configuration'], 'Accelerometer Enabled');
    includeGyro = h5readatt(filename, [sensors.Groups(monitorIdx).Name '/Configuration'], 'Gyroscope Enabled');
    includeMag = h5readatt(filename, [sensors.Groups(monitorIdx).Name '/Configuration'], 'Magnetometer Enabled');
    
    sampleRate = h5readatt(filename, [sensors.Groups(monitorIdx).Name '/Configuration'], 'Sample Rate');
    sampleRate = double(sampleRate);
    
%     buttonStatus = hdf5read(filename, [caseID '/ButtonStatus']);
    
    if includeAcc
        data = hdf5read(filename, accPath);
        acc.x = data(1,:);
        acc.y = data(2,:);
        acc.z = data(3,:);
        acc.units = strtrim(h5readatt(filename, [sensors.Groups(monitorIdx).Name '/Accelerometer'], 'Units'));
    end
    if includeGyro
        data = hdf5read(filename, gyroPath);
        gyro.x = data(1,:);
        gyro.y = data(2,:);
        gyro.z = data(3,:);
        gyro.units = strtrim(h5readatt(filename, [sensors.Groups(monitorIdx).Name '/Gyroscope'], 'Units'));
    end
    
    data = hdf5read(filename, orientPath);
    q = [data(1,:)' data(2,:)' data(3,:)' data(4,:)'];
    
    if includeMag
         data = hdf5read(filename, magPath);
         mag.x = data(1,:);
         mag.y = data(2,:);
         mag.z = data(3,:);
         mag.units = strtrim(h5readatt(filename, [sensors.Groups(monitorIdx).Name '/Magnetometer'], 'Units'));
     end


    Opal.sensor(monitorIdx).caseID = caseID;
    Opal.sensor(monitorIdx).monitorLabel = monitorLabel;
    Opal.sensor(monitorIdx).acc = acc;
    Opal.sensor(monitorIdx).gyro = gyro;
    Opal.sensor(monitorIdx).orient = q;
    Opal.sensor(monitorIdx).mag = mag;
%     Opal.sensor(monitorIdx).buttonStatus = buttonStatus;
end

Opal.sampleRate = sampleRate;
Opal.time = [0:length(data)-1]*(1/sampleRate);
warning off all