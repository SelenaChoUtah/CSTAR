function ICC = computeICC(data1, fullData, icc_type)
    % Inputs:
    % data1, data2: Data vectors for the two periods to compute ICC between.
    % icc_type: Type of ICC to compute (e.g., '2.1' for two-way random, absolute agreement)

    n = length(data1);
    mean1 = mean(data1);
    mean2 = mean(fullData);
    
    % Sum of squares
    SS_between = sum((data1 - mean1).^2) + sum((fullData - mean2).^2);
    SS_within = sum((data1 - fullData).^2);    
    
    switch icc_type
        case '2-1'
        % ICC(2.1) calculation (Two-way random effects model, absolute agreement)
        MS_between = SS_between / (n - 1);
        MS_within = SS_within / n;
        ICC = (MS_between - MS_within) / (MS_between + MS_within);
    end
end