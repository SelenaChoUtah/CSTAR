function [A_data,Rot_data] = rotateIMU(accData,order,Fc,Fs,fullWindow,calibrateWindow)
    %% Filters[data] data using butterworth filter with specified [order] order,
    % [Fc] cuttoff frequency and [Fs] sampling frequency.
    % order = 4;
    % Fc = 40;
    % Fs = 100;
    [b,a] = butter(order/2,(Fc/(Fs/2)));
    Sway_data = filtfilt(b,a,accData);%./9.81;
    fullV = ((Sway_data(:,3)).*-1);
    fullML = (Sway_data(:,1));
    fullAP = (Sway_data(:,2));

    % Initialize Variables
    actualVert = [];
    actualML = [];
    actualAP = [];
    Rot_data = [];

    % Calibrate using windows of large walking bouts or static in lab
    for c = 1:height(fullWindow)
        % Take the window of walking bouts
        swayV = fullV(calibrateWindow(c,1):calibrateWindow(c,2));
        swayML = fullML(calibrateWindow(c,1):calibrateWindow(c,2));
        swayAP = fullAP(calibrateWindow(c,1):calibrateWindow(c,2));

        if fullWindow(c,2) <= length(fullV)            
            sectionV = fullV(fullWindow(c,1):fullWindow(c,2));
            sectionML = fullML(fullWindow(c,1):fullWindow(c,2));
            sectionAP = fullAP(fullWindow(c,1):fullWindow(c,2));        
        
            % Filtered data is corrected to original coordinate system and averaged
            % across each plane, then substracted from it's corrected data to reach
            % [0,0].
            trueAP = sectionAP.*(cos(asin(mean(swayAP))))- (sectionV).*(mean(swayAP));
            trueVP = sectionAP.*(mean(swayAP))+ (sectionV).*(cos(asin(mean(swayAP))));
            trueML = sectionML.*(cos(asin(mean(swayML))))- (trueVP).*(mean(swayML));
            trueV = sectionML.*(mean(swayML))+(trueVP).*(cos(asin(mean(swayML))))-1;
        
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
            Rot_data = [Rot_data; sAP, sML];

        else
            continue
        end
    
    end
        
    A_data = [actualAP actualML actualVert].*9.81;    
        
end