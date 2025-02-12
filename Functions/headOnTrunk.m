function hotTurns = headOnTrunk(headMinusTrunk,startstop,head,waist)
% Looks if there is a difference between head and trunk signal
%   Detailed explanation goes here
    count = 0;
    stabilizationCount = 0;
    volitionalCount = 0;
    [m,~] = size(startstop);
   
    for i = 1:m
        if startstop(i,2)>length(headMinusTrunk)
            break            
        elseif any(headMinusTrunk(startstop(i,1):startstop(i,2))>30)
            count = count+1;
            % see if head or trunk leads the turn
            % Volitional - head moves first
            % Stabilizational trunk moves first
            if mean(headMinusTrunk(startstop(i,1):startstop(i,2))) < 0
                stabilizationCount = stabilizationCount+1;
                ss(stabilizationCount,:) = [startstop(i,1) startstop(i,2)];     
            else
                volitionalCount = volitionalCount+1;
                vv(volitionalCount,:) = [startstop(i,1) startstop(i,2)];
            end

            % [p,l] = findpeaks(head(startstop(i,1):startstop(i,2)));
            % [k,c] = findpeaks(waist(startstop(i,1):startstop(i,2)));
            % 
            % nexttile
            % hold on;
            % plot(head(startstop(i,1):startstop(i,2)), 'r'); % Plot head signal in blue
            % plot(l, p, 'ro', 'MarkerFaceColor', 'r'); % Plot peaks in red circles
            % 
            % plot(waist(startstop(i,1):startstop(i,2)), 'g'); % Plot waist signal in green
            % plot(c, k, 'mo', 'MarkerFaceColor', 'm'); % Plot peaks in magenta circles
            % plot(headMinusTrunk(startstop(i,1):startstop(i,2)))
            
        end
    end

    % Stabilization descriptive stats
    time = (0:(1/100):(60*60*24))';
    for s = 1:length(ss)
        hotTurns.stabilization.amplitude(s) = abs(trapz(time(ss(s,1):ss(s,2)),head(ss(s,1):ss(s,2))));
        hotTurns.stabilization.angVel(s) = abs(max(head(ss(s,1):ss(s,2))));
    end

    % Volitional descriptive stats
    for s = 1:length(vv)
        hotTurns.volitional.amplitude(s) = abs(trapz(time(vv(s,1):vv(s,2)),head(vv(s,1):vv(s,2))));
        hotTurns.volitional.angVel(s) = abs(max(head(vv(s,1):vv(s,2))));
    end

    hotTurns.count = count;
    hotTurns.stabilization.count = stabilizationCount;
    hotTurns.volitional.count = volitionalCount;
end