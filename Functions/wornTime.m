function timing = wornTime(acc)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    aa = abs(acc);
    [m,n] = size(aa);
    
    timing = zeros(3,1);
    for i = 1:n
        bb = find(aa(:,i)<0.05);
        cc = diff(bb);
        dd = find(cc<2);
        % converting to hours
        ee = sum(cc(dd))/100/60/60;
        mm = m/100/60/60;
        timing(i) = mm-ee;
    end
end