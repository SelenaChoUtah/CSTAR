function [heartRate, time] = rr2bpm(ann, fs)

%UNTITLED3 Summary of this function goes here
%   Turns rr intervals in bpm

% By Selena Cho
% Last Updated: October 15th, 2025

% Convert ms to s
rrInterval = diff(ann)/fs;
bpm = 60./rrInterval;

heartRate = bpm;
time = rrInterval;


end