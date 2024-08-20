function totalCount = headOnTrunk(headMinusTrunk,startstop)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    count = 0;
    [m,n] = size(startstop);
    for i = 1:m
        if startstop(i,2)>length(headMinusTrunk)
            break            
        elseif any(headMinusTrunk(startstop(i,1):startstop(i,2))>30)
            count = count+1;
        end
    end
    totalCount = count;
end