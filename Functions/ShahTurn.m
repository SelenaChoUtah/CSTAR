function turnInfo = ShahTurn(filtVertGyro,rawVertGyro,threshold,minima,m)

    % Step 3: Find Valid Minima: To ensure the algorithm does
    % not include shallow, local minima that may result from a brief
    % slowing or hesitations during a turn, we only retain minima that
    % are at least some amount, eta, below candidate maxima. We only
    % consider maxima that are above our velocity threshold and may
    % represent turns. min=40deg/s, start=stop=15deg/s  

    % Find indexs of valid minima
    [~, ploc] = findpeaks(filtVertGyro,'MinPeakHeight',minima);
    [~, nloc] = findpeaks(-filtVertGyro,'MinPeakHeight',minima);

    % Step 4: Verify Maxima is Sufficiently Large: Detect the maximum 
    % between each pair of adjacent minima. If the maximum is
    % above a turn velocity threshold vd, declare the period between
    % the minima as a detected turn.  
    % Left (Positive) turns
    validMaxLoc = [];
    j = 1;
    for i = 1:length(ploc)-1
        if max(filtVertGyro(ploc(i):ploc(i+1))) > threshold
            [~,vm] = max(filtVertGyro(ploc(i):ploc(i+1)));
            validMaxLoc(j,1) = vm+ploc(i)-1;
            j = j+1;
        end
    end

    data = ShahFilter(rawVertGyro,27);

    % find where it crosses minimum threshold
    ss = zeros(length(validMaxLoc),2);
    for i = 1:length(validMaxLoc)
        % take index of peak and find start
        t = validMaxLoc(i);
        while data(t) > minima 
            if t == 1
                break
            else
                t = t-1;
            end
        end
        ss(i,1) = t;

        % find stop
        t = validMaxLoc(i);
        while data(t) > minima 
            if t == length(data)
                break
            else
                t = t+1;
            end
        end
        ss(i,2) = t;
    end

    lstartstop = unique(ss,"rows");

    time = (0:(1/100):(60*60*24))';
    lamplitude = zeros(length(lstartstop),1);
    lmaxAngVel = zeros(length(lstartstop),1);
    equal2zero = find(lstartstop(:,1)-lstartstop(:,2)==0);
    lstartstop(equal2zero,:) = [];
    [m,~] = size(lstartstop);
    for k = 1:m        
        lamplitude(k,1) = abs(trapz(time(lstartstop(k,1):lstartstop(k,2)),data(lstartstop(k,1):lstartstop(k,2))));
        lmaxAngVel(k,1) = abs(max(data(lstartstop(k,1):lstartstop(k,2))));
    end 

    lindx = find(lamplitude>10);
    lvalidAmp = lamplitude(lindx);
    lvalidAngVel = lmaxAngVel(lindx);
    lstsp = lstartstop(lindx,:);

    % figure
    % plot(filtVertGyro,LineWidth=2)
    % hold on
    % plot(validMaxLoc,filtVertGyro(validMaxLoc),'k*') 
    % axis tight

    % Right (negative) turns
    validMaxLoc = [];
    j = 1;
    for i = 1:length(nloc)-1
        if max(-filtVertGyro(nloc(i):nloc(i+1))) > threshold
            [~,vm] = max(-filtVertGyro(nloc(i):nloc(i+1)));
            validMaxLoc(j,1) = vm+nloc(i)-1;
            j = j+1;
        end
    end

    data = -1*(ShahFilter(rawVertGyro,27));
    % find where it crosses minimum threshold
    ss = zeros(length(validMaxLoc),2);
    for i = 1:length(validMaxLoc)
        % take index of peak and find start
        t = validMaxLoc(i);
        while data(t) > minima 
            if t == 1
                break
            else
                t = t-1;
            end
        end
        ss(i,1) = t;

        % find stop of turn
        t = validMaxLoc(i);
        while data(t) > minima 
            if t == length(data)
                break
            else
                t = t+1;
            end
        end
        ss(i,2) = t;
    end

    startstop = [];
    startstop = unique(ss,"rows");
    time = (0:(1/100):(60*60*24))';
    amplitude = zeros(length(startstop),1);
    maxAngVel = zeros(length(startstop),1);
    equal2zero = find(startstop(:,1)-startstop(:,2)==0);
    startstop(equal2zero,:) = [];
    [m,~] = size(startstop);
    for k = 1:m        
        amplitude(k) = abs(trapz(time(startstop(k,1):startstop(k,2)),data(startstop(k,1):startstop(k,2))));
        maxAngVel(k) = abs(max(data(startstop(k,1):startstop(k,2))));
    end 

    rindx = find(amplitude>10);
    rvalidAmp = amplitude(rindx);
    rvalidAngVel = maxAngVel(rindx);
    rstsp = startstop(rindx,:);

    turnInfo.amplitude = [lvalidAmp;rvalidAmp];
    turnInfo.angVelocity = [lvalidAngVel;rvalidAngVel];
    turnInfo.startstop = [lstsp;rstsp];

    turnInfo.Lamplitude = lvalidAmp;
    turnInfo.LangVelocity = lvalidAngVel;
    turnInfo.Lstartstop = lstsp;

    turnInfo.Ramplitude = rvalidAmp;
    turnInfo.RangVelocity = rvalidAngVel;
    turnInfo.Rstartstop = rstsp;

    allTurns = [lstsp;rstsp];
    turnDuration = (allTurns(:,2)-allTurns(:,1))./100; % turn duration (s)
    turnInfo.turnDuration = turnDuration;
    
    % ******* Maybe come back to this one on merging
    % Step 7: Merge Close Turns: This merging step identifies all
    % of the cases where one turn ends, and another begins in a period
    % less than some specified interval, ts, and where the turn angle of
    % the merged turns would be closer to the fixed, prescribed turn
    % angle than the turn angle would be if the turns were not merged.
    

    % timebetweenturns = 500; % 500 samples = 5sec
    % newSS = [];
    % j = 1;
    % for i = 1:length(startstop)-1
    %     if startstop(i+1,1) - startstop(i,2) < timebetweenturns
    %         newSS(j,:) = [startstop(i,1) startstop(i+1,2)];
    %         j = j+1;
    %         i = i+1;
    %     end
    % end


    % Step 6: Eliminate Small Turns: Once the edges of a potential
    % turn are detected, the turn angle can be estimated by numerical
    % integration of the vertical rotational rate. The final step of the
    % algorithm eliminates turns with turn angles that are less than a
    % threshold of θ = 40°. Turns with angles less than this amount
    % would typically not be judged as a complete turn in clinical
    % studies, and might comprise curved walking rather than a turn.
    % time = (0:(1/100):(60*60*24))';
    % amplitude = [];
    % maxAngVel = [];
    % equal2zero = find(startstop(:,1)-startstop(:,2)==0);
    % startstop(equal2zero,:) = [];
    % [m,~] = size(startstop);
    % for k = 1:m        
    %     amplitude(k,1) = abs(trapz(time(startstop(k,1):startstop(k,2)),data(startstop(k,1):startstop(k,2))));
    %     maxAngVel(k,1) = abs(max(data(startstop(k,1):startstop(k,2))));
    % end 
    % 
    % rindx = find(amplitude>10);
    % validAmp = amplitude(rindx);
    % validAngVel = maxAngVel(rindx);
    % stsp = startstop(rindx,:);
    % 
    % turnInfo.amplitude = validAmp;
    % turnInfo.angVelocity = validAngVel;
    % turnInfo.startstop = stsp;

end