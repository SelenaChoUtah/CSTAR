% Load CWA file with optional re-sampling.
% Returns tri-axial data with the format: [timestamp x y z] in units of 'g'
% 
% Edited by Selena Cho 2/22/23 
%     It now resamples the gyro data along with acceleration
% 
% Example:
%
% % Load CWA file re-sampled at 100Hz
% Fs = 100;
% data = AX3_readFile('CWA-DATA.CWA');
% data.ACC = resampleACC(data, Fs);
% 
function D = resampleData(data, interpRate, method)
    if nargin < 3; method = 'pchip'; end
    
    if interpRate > 0
		% Remove any duplicate timestamps
		data.AXES = data.AXES(find(diff(data.AXES(:,1))>0),:);
		data.AXES = data.AXES(find(diff(data.AXES(:,1))>0),:);
	
        startTime = data.AXES(1,1);
        stopTime  = data.AXES(end,1);
    
		% gather and interpolate
		t = linspace(startTime, stopTime, (stopTime - startTime) * 24 * 60 * 60 * interpRate);
		D = zeros(length(t), 7);
		
		D(:,1) = t;
		for a=2:7
			D(:,a) = interp1(data.AXES(:,1),(data.AXES(:,a)),t,method,0);
		end
		
		% D is now the interpolated signal with time-stamps @interpRate
		
    else
		% Pass-through data with no interpolation
		D = data.ACC;
    end
	
end

