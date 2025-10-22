function qrsData = detectQRS_pipeline(ecg, fs)
% detectQRS_pipeline
% 
% Implements a QRS detection and beat-to-beat HR estimation pipeline:
%   1. Wavelet transform for QRS detection
%   2. Local maxima/minima for R-peak localization
%   3. Hilbert transform for QRS envelope and area (SNR)
%   4. Morphological feature extraction
%   5. HDBSCAN clustering of morphological features
%   6. RR interval and HR estimation with 5-beat smoothing
%
% INPUTS:
%   ecg : 1D ECG signal
%   fs  : sampling frequency (Hz)
%
% OUTPUT:
%   qrsData : structure with fields:
%       .peaks        → sample indices of detected QRS
%       .features     → table of morphological features
%       .clusterLabel → cluster assignment from HDBSCAN
%       .RR            → RR intervals (s)
%       .HR            → HR (bpm)
%       .HRsmooth      → smoothed HR (bpm)
%
% Dependencies: Signal Processing Toolbox, Wavelet Toolbox, Statistics Toolbox

%% --- Step 1. Wavelet-based QRS candidate detection ---
% Using 'db4' mother wavelet, typical for ECG QRS detection
wname = 'db4';
maxLevel = 4;
[c,l] = wavedec(ecg, maxLevel, wname);
% Reconstruct detail coefficients (levels 1–3)
detSum = zeros(size(ecg));
for i = 1:min(3, maxLevel)
    d = detcoef(c,l,i);
    d_up = wrcoef('d', c, l, wname, i);
    detSum = detSum + abs(d_up);
end
detSmooth = smoothdata(detSum,'gaussian',round(0.02*fs));
thresh = median(detSmooth) + 3*mad(detSmooth,1);
mask = detSmooth > thresh;

% Clean up mask regions
mask = bwareaopen(mask, round(0.03*fs)); % remove very short regions
mask = imdilate(mask, strel('line', round(0.03*fs), 0)); % expand slightly

%% --- Step 2. Find local maxima/minima in each candidate region ---
L = bwlabel(mask);
peaks = [];
for r = 1:max(L,[],'all')
    idx = find(L==r);
    s = max(1, idx(1)-round(0.05*fs));
    e = min(length(ecg), idx(end)+round(0.05*fs));
    segment = ecg(s:e);
    [pks, locs] = findpeaks(segment, 'MinPeakDistance', round(0.08*fs));
    for j = 1:numel(locs)
        peaks = [peaks; s + locs(j) - 1];
    end
end
peaks = unique(peaks);

%% --- Step 3. Hilbert transform for envelope and AUC (SNR) ---
win = round(0.08*fs); % ±80 ms window
nPeaks = numel(peaks);
AUC = zeros(nPeaks,1);
amp = zeros(nPeaks,1);
width = zeros(nPeaks,1);
slopeL = zeros(nPeaks,1);
slopeR = zeros(nPeaks,1);

for i = 1:nPeaks
    idx = peaks(i);
    s = max(1, idx-win);
    e = min(length(ecg), idx+win);
    seg = ecg(s:e);
    env = abs(hilbert(seg));
    AUC(i) = trapz(env) / fs;
    amp(i) = ecg(idx);

    % Estimate width at half amplitude
    base = median(seg([1:round(0.1*fs), end-round(0.1*fs)+1:end]));
    halfAmp = base + (amp(i)-base)/2;
    left = find(seg(1:(idx-s+1))<halfAmp,1,'last');
    right = find(seg((idx-s+1):end)<halfAmp,1,'first');
    if isempty(left), left = 1; end
    if isempty(right), right = length(seg); end
    width(i) = (right + (idx-s+1) - left)/fs;

    % Slopes
    leftIdx = max(1, idx - round(0.02*fs));
    rightIdx = min(length(ecg), idx + round(0.02*fs));
    slopeL(i) = (ecg(idx) - ecg(leftIdx)) / ((idx-leftIdx)/fs);
    slopeR(i) = (ecg(rightIdx) - ecg(idx)) / ((rightIdx-idx)/fs);
end

%% --- Step 4. Feature table ---
features = table(peaks, amp, AUC, width, slopeL, slopeR, ...
    'VariableNames', {'Index','Amplitude','AUC','Width','SlopeL','SlopeR'});

%% --- Step 5. HDBSCAN clustering (via Statistics Toolbox) ---
% MATLAB supports HDBSCAN via hdbscan function (R2023b+). For older versions, use external package.
if exist('hdbscan','file')
    X = [features.Amplitude, features.AUC, features.Width, ...
         features.SlopeL, features.SlopeR];
    minClustSize = 10;
    clusterObj = hdbscan(X, 'MinClusterSize', minClustSize);
    clusterLabel = clusterObj.ClusterID;
else
    warning('HDBSCAN not found. Using k-means (2 clusters) as placeholder.');
    X = [features.Amplitude, features.AUC, features.Width, ...
         features.SlopeL, features.SlopeR];
    clusterLabel = kmeans(X,2);
end
features.Cluster = clusterLabel;

%% --- Step 6. Identify physiologic clusters with stable RR intervals ---
physHR = [40 180]; % bpm
RRmean = [];
goodIdx = false(height(features),1);
for cid = unique(clusterLabel(:))'
    if cid == -1, continue; end
    f = features(features.Cluster==cid,:);
    f = sortrows(f,'Index');
    if height(f) < 4, continue; end
    t = f.Index/fs;
    RR = diff(t);
    RRcv = std(RR)/mean(RR);
    HR = 60./RR;
    if all(HR>physHR(1)) && all(HR<physHR(2)) && RRcv < 0.12
        goodIdx(features.Cluster==cid) = true;
    end
end
likelyQRS = features(goodIdx,:);

%% --- Step 7. Compute RR intervals and HR ---
tQRS = likelyQRS.Index / fs;
RR = diff(tQRS);
HR = 60 ./ RR;
HRsmooth = movmedian(HR,5);

%% --- Output structure ---
qrsData.peaks = likelyQRS.Index;
qrsData.features = likelyQRS;
qrsData.clusterLabel = clusterLabel;
qrsData.RR = [NaN; RR];
qrsData.HR = [NaN; HR];
qrsData.HRsmooth = [NaN; HRsmooth];

end
