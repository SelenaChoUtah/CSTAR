% Load CWA file with optional re-sampling.
% Returns tri-axial data with the format: [timestamp x y z] in units of 'g'
%
% Example:
%
% % Load CWA file re-sampled at 100Hz
% Fs = 100;
% data = resampleCWA('CWA-DATA.CWA', Fs);
% 
function D = resampleCWA(filename, interpRate)
	
	% fprintf('\t\treading file data\n');
	data = CWA_readFile(filename);
	
	% fprintf('\t\tinterpolating data\n');
    D = resampleData(data, interpRate);
	
end
