function [RotatedAcc,q] = RotateAcc(acc,t)
% This function rotates the 3d acceleration vector to face down. Use this
% function to adjust for any intial offset in the position / alignment of
% an IMU. This function will use average of the first t samples of data in
% order to align the IMU properly. 

% If there is an error with the alignment, check to make sure the first 3
% seconds of the recording are still.

if size(acc,2) ~=3
    acc = acc';
end

if size(acc,2)~=3
    disp('Acceleration vector must be a nx3 dimensional array');
    return
end

avgAcc = mean(acc(1:t,:),1);

v = [0,0,norm(avgAcc)];
u = cross(avgAcc,v);
u = u/norm(u);

theta = acos(dot(avgAcc,v)/(norm(avgAcc)*norm(v)));

q0 = cos(theta/2);
q123 = sin(theta/2)*u;

q = [q0, q123];

RotatedAcc = RotateVector(acc,q);
end
