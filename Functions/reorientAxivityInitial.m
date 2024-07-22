function reorient = reorientAxivityInitial(subject)

%   REORIENT = REORIENTAXIVITYINITIAL(SUBJECT) reorients Axivity sensor data
%   to a consistent orientation. The function rotates the acceleration vector
%   to face downwards for sensors located at the head and rotates the acceleration
%   vector for other sensors to a consistent orientation.
%
%   Input:
%       SUBJECT: A structured data format containing raw Axivity sensor data.
%                Data is organized by subject ID and sensor location.
%
%   Output:
%       REORIENT: A structured data format containing reoriented Axivity sensor
%                 data. Data is organized by subject ID and sensor location.
%
%   Example input/output structure:
%       subject."subjectID"."sensorLocation"."data"
%           - "subjectID" : e.g., 'S01'
%           - "sensorLocation" : e.g., 'head', 'neck', 'waist'
%           - "data" : time information, Resampled sensor data (tri-acceleration, tri-gyroscope) 
% 
%   By Selena Cho
%   Last Updated: April 1st, 2024

%-------------------------------------------------------------------------%

    % fprintf("Reorient Sensor\n")

    reorient = struct();
    subID = string(fieldnames(subject));
    % Wrong?
    % Head sensor accel (V,ML,AP)=(ax,az,-ay)
    % Neck+Lumbar accel (V,ML,AP)=(ay,-ax,az)

     for id = 1:length(subID)
        sensor = string(fieldnames(subject.(subID(id))));
        for j = 1:length(sensor)
            acc = subject.(subID(id)).(sensor{j})(:,2:4);
            gyro = subject.(subID(id)).(sensor{j})(:,5:7);
            if strcmp(sensor(j),'head')
                reorient.(subID(id)).(sensor{j})(:,1) = subject.(subID(id)).(sensor{j})(:,1);
                thetax = -90;
                % rot_x = [1, 0, 0; 
                %         0, cosd(thetax), -sind(thetax); 
                %         0, sind(thetax), cosd(thetax)]; 
                thetay = 90;
                rot_y = [cosd(thetay), 0, sind(thetay); 
                        0, 1, 0; 
                        -sind(thetay), 0, cosd(thetay)]; 
                thetaz = 180;
                rot_z = [cosd(thetaz), -sind(thetaz), 0; 
                        sind(thetaz), cosd(thetaz), 0; 
                        0, 0, 1]; 

                % Rotate the vectors
                rotAcc = (rot_y * rot_z * acc')';
                rotGyro = (rot_y * rot_z * gyro')';
                reorient.(subID(id)).(sensor{j})(:,2:4) = rotAcc;
                reorient.(subID(id)).(sensor{j})(:,5:7) = rotGyro;

            else
                reorient.(subID(id)).(sensor{j})(:,1) = subject.(subID(id)).(sensor{j})(:,1);
                
                thetax = -90;
                rot_x = [1, 0, 0; 
                        0, cosd(thetax), -sind(thetax); 
                        0, sind(thetax), cosd(thetax)]; 
                thetay = 180;
                rot_y = [cosd(thetay), 0, sind(thetay); 
                        0, 1, 0; 
                        -sind(thetay), 0, cosd(thetay)]; 
                % thetaz = -90;
                % rot_z = [cosd(thetaz), -sind(thetaz), 0; 
                %         sind(thetaz), cosd(thetaz), 0; 
                %         0, 0, 1]; 

                % Rotate the vectors
                rotAcc = (rot_y * rot_x * acc')';
                rotGyro = (rot_y * rot_x *  gyro')';
                reorient.(subID(id)).(sensor{j})(:,2:4) = rotAcc;
                reorient.(subID(id)).(sensor{j})(:,5:7) = rotGyro;
            end
        end
     end


     
    % for id = 1:length(subID)
    %     sensor = string(fieldnames(subject.(subID(id))));
    %     for j = 1:length(sensor)
    %         if strcmp(sensor(j),'head')
    %             reorient.(subID(id)).(sensor{j})(:,1) = subject.(subID(id)).(sensor{j})(:,1);
    %             reorient.(subID(id)).(sensor{j})(:,2) = subject.(subID(id)).(sensor{j})(:,2);
    %             reorient.(subID(id)).(sensor{j})(:,3) = subject.(subID(id)).(sensor{j})(:,4);
    %             reorient.(subID(id)).(sensor{j})(:,4) = -subject.(subID(id)).(sensor{j})(:,3);
    %             reorient.(subID(id)).(sensor{j})(:,5) = subject.(subID(id)).(sensor{j})(:,5);
    %             reorient.(subID(id)).(sensor{j})(:,6) = subject.(subID(id)).(sensor{j})(:,7);
    %             reorient.(subID(id)).(sensor{j})(:,7) = -subject.(subID(id)).(sensor{j})(:,6);
    %         else
    %             reorient.(subID(id)).(sensor{j})(:,1) = subject.(subID(id)).(sensor{j})(:,1);
    %             reorient.(subID(id)).(sensor{j})(:,2) = subject.(subID(id)).(sensor{j})(:,3);
    %             reorient.(subID(id)).(sensor{j})(:,3) = -subject.(subID(id)).(sensor{j})(:,2);
    %             reorient.(subID(id)).(sensor{j})(:,4) = subject.(subID(id)).(sensor{j})(:,4);
    %             reorient.(subID(id)).(sensor{j})(:,5) = subject.(subID(id)).(sensor{j})(:,6);
    %             reorient.(subID(id)).(sensor{j})(:,6) = -subject.(subID(id)).(sensor{j})(:,5);
    %             reorient.(subID(id)).(sensor{j})(:,7) = subject.(subID(id)).(sensor{j})(:,7);
    %         end
    %     end
    % end

end