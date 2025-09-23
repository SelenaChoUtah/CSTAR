function hotTurns = headOnTrunk(headMinusTrunk,startstop,head,waist)
% Looks if there is a difference between head and trunk signal
%   Detailed explanation goes here
    count = 0;    
    [m,~] = size(startstop);

    % Using previous calculate startstops, check if head is turning without
    % trunk    
    for i = 1:m
        if startstop(i,2)>length(headMinusTrunk)
            break 
        % sees if hot signal >15degs, else 
        elseif any(headMinusTrunk(startstop(i,1):startstop(i,2))>15)
            count = count+1;
        end
    end

    % check for stabilization vs volitional head turns
    absHot = abs(headMinusTrunk);
    [~,ll] = findpeaks(absHot,'MinPeakHeight',15,'MinPeakDistance',30,'MinPeakWidth',30);

    % figure
    % plot(headMinusTrunk)
    % hold on
    % plot(ll,headMinusTrunk(ll),'*')    

    stabilizationCount = length(find(headMinusTrunk(ll)<0));
    volitionalCount = length(find(headMinusTrunk(ll)>0));

    % Stabilization Turn
    stableLoc = find(headMinusTrunk(ll)<0);
    sl = ll(stableLoc);

    % figure
    % plot(head)
    % hold on
    % plot(sl,head(sl),'*')

    ve = 5; % 5 deg/s as the start/end of turn
    % find where it crosses minimum threshold
    ss = 0;
    for vt = 1:length(sl)
        t = sl(vt);
        % Find start of turn
        while head(t) > ve
        while absHot(t) > ve
            if t == 1
                break
            else
                t = t-1;
            end
        end
        ss(vt,1) = t;

        % Find end of turn
        t = sl(vt);
        while head(t) > ve
            if t == length(head)
        while absHot(t) > ve
            if t == length(absHot)
                break
            else
                t = t+1;
            end
        end
        ss(vt,2) = t;
    end

    stableSS = unique(ss,"rows");
    % stableSS = ss;

    % Volitional Turn
    voLoc = find(headMinusTrunk(ll)>0);
    sl = ll(voLoc);

    ve = 5; % 5 deg/s as the start/end of turn
    % find where it crosses minimum threshold
    ss = 0;
    for vt = 1:length(sl)
        t = sl(vt);
        % Find start of turn
        while head(t) > ve
        while absHot(t) > ve
            if t == 1
                break
            else
                t = t-1;
            end
        end
        ss(vt,1) = t;

        % Find end of turn
        t = sl(vt);
        while head(t) > ve
            if t == length(head)
        while absHot(t) > ve
            if t == length(absHot)
                break
            else
                t = t+1;
            end
        end
        ss(vt,2) = t;
    end

    voSS = unique(ss,"rows");
    % voSS = ss;

    % Stabilization descriptive stats
    cc = 1;
    time = (0:(1/100):(60*60*24))';
    for s = 1:length(stableSS)
        if (stableSS(s,2) - stableSS(s,1)) ~= 0 && abs(trapz(time(stableSS(s,1):stableSS(s,2)),head(stableSS(s,1):stableSS(s,2)))) < 360
            hotTurns.stabilization.amplitude(cc) = abs(trapz(time(stableSS(s,1):stableSS(s,2)),head(stableSS(s,1):stableSS(s,2))));
            hotTurns.stabilization.angVel(cc) = abs(max(head(stableSS(s,1):stableSS(s,2))));

        elseif (stableSS(s,2) - stableSS(s,1)) ~= 0 && abs(trapz(time(stableSS(s,1):stableSS(s,2)),absHot(stableSS(s,1):stableSS(s,2)))) < 360

        if (stableSS(s,2) - stableSS(s,1)) ~= 0 && abs(trapz(time(stableSS(s,1):stableSS(s,2)),absHot(stableSS(s,1):stableSS(s,2)))) < 360

            hotTurns.stabilization.amplitudeB(cc) = abs(trapz(time(stableSS(s,1):stableSS(s,2)),absHot(stableSS(s,1):stableSS(s,2))));
            hotTurns.stabilization.amplitudeS(cc) = abs(trapz(time(stableSS(s,1):stableSS(s,2)),head(stableSS(s,1):stableSS(s,2))));
            hotTurns.stabilization.angVelB(cc) = abs(max(absHot(stableSS(s,1):stableSS(s,2))));
            hotTurns.stabilization.angVelS(cc) = abs(max(head(stableSS(s,1):stableSS(s,2))));
            cc = cc+1;
        else
            hotTurns.stabilization.amplitude(cc) = 0;
            hotTurns.stabilization.angVel(cc) = abs(max(head(stableSS(s,1):stableSS(s,2))));
            hotTurns.stabilization.amplitudeB(cc) = 0;
            hotTurns.stabilization.amplitudeS(cc) = 0;
            hotTurns.stabilization.angVelB(cc) = abs(max(absHot(stableSS(s,1):stableSS(s,2))));
            hotTurns.stabilization.angVelS(cc) = abs(max(head(stableSS(s,1):stableSS(s,2))));
            cc = cc+1;
        end
    end

    % Volitional descriptive stats
    cc = 1;
    for s = 1:length(voSS)
        if abs(trapz(time(voSS(s,1):voSS(s,2)),head(voSS(s,1):voSS(s,2)))) < 360 
            hotTurns.volitional.amplitude(cc) = abs(trapz(time(voSS(s,1):voSS(s,2)),head(voSS(s,1):voSS(s,2))));
            hotTurns.volitional.angVel(cc) = abs(max(head(voSS(s,1):voSS(s,2))));
Z
        elseif abs(trapz(time(voSS(s,1):voSS(s,2)),absHot(voSS(s,1):voSS(s,2)))) < 360 

        if abs(trapz(time(voSS(s,1):voSS(s,2)),absHot(voSS(s,1):voSS(s,2)))) < 360 

            hotTurns.volitional.amplitudeB(cc) = abs(trapz(time(voSS(s,1):voSS(s,2)),absHot(voSS(s,1):voSS(s,2))));
            hotTurns.volitional.angVelB(cc) = abs(max(absHot(voSS(s,1):voSS(s,2))));
            hotTurns.volitional.amplitudeS(cc) = abs(trapz(time(voSS(s,1):voSS(s,2)),head(voSS(s,1):voSS(s,2))));
            hotTurns.volitional.angVelS(cc) = abs(max(head(voSS(s,1):voSS(s,2))));
            cc = cc+1;
        end
    end

    hotTurns.headOnly = count;
    hotTurns.headAll = length(startstop);
    hotTurns.stabilization.count = stabilizationCount;
    hotTurns.volitional.count = volitionalCount;
    % 
    % %%
    % fprintf("Head on Trunk Count: %f\n", length(hotTurns.stabilization.amplitudeB)+length(hotTurns.volitional.amplitudeB));
    % fprintf("Volitional-Stable Angvel: %f\n", mean(hotTurns.volitional.angVelB)-mean(hotTurns.stabilization.angVelB));
    % fprintf("Volitional-Stable Amp: %f\n", mean(hotTurns.volitional.amplitudeB)-mean(hotTurns.stabilization.amplitudeB));
    % % fprintf("Volitional-Stable Count: %f\n", length(hotTurns.volitional.amplitudeB)-length(hotTurns.stabilization.amplitudeB));
    % fprintf("Vol-Stable Space AngVel: %f\n", mean(hotTurns.volitional.angVelS)-mean(hotTurns.stabilization.angVelS));
    % fprintf("Vol Space Amplitude: %f\n", mean(hotTurns.volitional.amplitudeS));
    % fprintf("Stable Space Amplitude: %f\n", mean(hotTurns.stabilization.amplitudeS));