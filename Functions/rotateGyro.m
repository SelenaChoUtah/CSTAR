function [G_data] = rotateGyro(gyroData,Rot_data,order,Fc,Fs,fullWindow,calibrateWindow)
    % Filters[data] data using butterworth filter with specified [order] order,
    % [Fc] cuttoff frequency and [Fs] sampling frequency. [rData] is the
    % rotation angles found by rotateIMU using the accelerometer.
    [b,a] = butter(order/2,(Fc/(Fs/2)));
    Sway_data = filtfilt(b,a,gyroData);
    fullV = (Sway_data(:,3));
    fullML = (Sway_data(:,1));
    fullAP = (Sway_data(:,2));

     % Initialize Variables
    actualVert = [];
    actualML = [];
    actualAP = [];

    % Calibrate using windows of large walking bouts
    for c = 1:length(fullWindow)
        % Take the window of walking bouts
        swayV = fullV(calibrateWindow(c,1):calibrateWindow(c,2));
        swayML = fullML(calibrateWindow(c,1):calibrateWindow(c,2));
        swayAP = fullAP(calibrateWindow(c,1):calibrateWindow(c,2));

        sectionV = fullV(fullWindow(c,1):fullWindow(c,2));
        sectionML = fullML(fullWindow(c,1):fullWindow(c,2));
        sectionAP = fullAP(fullWindow(c,1):fullWindow(c,2));
        
        % Filtered data is corrected to original coordinate system and averaged
        % across each plane, then substracted from it's corrected data to reach
        % [0,0].
        trueAP = sectionAP.*(cos(Rot_data(c,1)))- (sectionV).*(Rot_data(c,1));
        trueVP = sectionAP.*(Rot_data(c,1))+ (sectionV).*(cos(Rot_data(c,1)));
        trueML = sectionML.*(cos(Rot_data(c,2)))- (trueVP).*(Rot_data(c,2));
        trueV = sectionML.*(Rot_data(c,2))+(trueVP).*(cos(Rot_data(c,2)));
    
        % Estimate of tilt angle
        sV = mean(trueV);
        sML = mean(trueML);
        sAP = mean(trueAP);

        Vert = trueV - sV;
        ML = trueML - sML;
        AP = trueAP - sAP;

        actualVert = [actualVert; Vert];
        actualML = [actualML; ML];
        actualAP = [actualAP; AP];     
    
    end

    G_data = [actualAP actualML actualVert];
end