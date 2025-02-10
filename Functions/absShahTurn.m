function turnInfo = absShahTurn(filtVertGyro,rawVertGyro,minima,amplitudeThreshold,velocityThreshold,impulseDuration)

    % Step 3: Find Valid Minima: To ensure the algorithm does
    % not include shallow, local minima (10 deg/s) that may result from a brief
    % slowing or hesitations during a turn, we only retain minima that
    % are at least some amount, eta, below candidate maxima. We only
    % consider maxima that are above our velocity threshold and may
    % represent turns.

    % Find indexs of valid minima - filtVertGyro is abs signal
    filtVertGyro = abs(filtVertGyro);
    [~, loc] = findpeaks(-filtVertGyro,'MinPeakHeight',-minima);    

    % Step 4: Verify Maxima is Sufficiently Large: Detect the maximum 
    % between each pair of adjacent minima. If the maximum is
    % above a turn velocity threshold vd (15 deg/s), declare the period between
    % the minima as a detected turn.
    validTurn = [];
    vd = velocityThreshold; % 15 deg/s peak velocity to quantify as turn
    vv = 1;
    for ll = 1:length(loc)-1
        if max(filtVertGyro(loc(ll):loc(ll+1))) > vd  
            [~,I] = max(filtVertGyro(loc(ll):loc(ll+1)));
            validTurn(vv,1) = loc(ll)+I;
            vv = vv+1;
        end
    end

    %% Step 5: Find Turn Start and End: The smoothing used to detect
    % the turn smooths the signal too much to determine the edges that
    % demarcate the start and end of a turn. Turns can begin and end
    % abruptly, relative to the duration of the turn. To account for this
    % we apply a second smoothing filter to the vertical rotational rate
    % and calculate the absolute value. We chose the M for this filter
    % such that the impulse response duration for this edge filter was
    % 0.383 s and the cutoff frequency was 3.0 Hz.
    % impulseDuration = 0.3831;
    absFiltData = abs(ShahFilter(rawVertGyro,impulseDuration,100));
    filtData = ShahFilter(rawVertGyro,impulseDuration,100);

    ve = 5; % 5 deg/s as the start/end of turn
    % find where it crosses minimum threshold
    for vt = 1:length(validTurn)
        t = validTurn(vt);
        % Find start of turn
        while absFiltData(t) > ve
            if t == 1
                break
            else
                t = t-1;
            end
        end
        ss(vt,1) = t;

        % Find end of turn
        t = validTurn(vt);
        while absFiltData(t) > ve
            if t == length(absFiltData)
                break
            else
                t = t+1;
            end
        end
        ss(vt,2) = t;
    end

    startstop = unique(ss,"rows");

    % Merge Close Turns within 1/3s in same direction
    hh = 1;
    mergeStartStop = [];
    while hh < height(startstop)
        if sign(max(filtData(startstop(hh,1):startstop(hh,2)))) == sign(max(filtData(startstop(hh+1,1):startstop(hh+1,2))))
            if (startstop(hh+1,1) - startstop(hh,2))/100 < 0.33 && (startstop(hh+1,2) - startstop(hh,1))/100 < 5
                mergeStartStop(end+1,:) = [startstop(hh,1), startstop(hh+1,2)];
                hh = hh + 2;
            end
            mergeStartStop(end+1,:) = startstop(hh,:);
            hh = hh + 1;
        else
            mergeStartStop(end+1,:) = startstop(hh,:);
            hh = hh + 1;
        end
    end
    mergeStartStop(end+1,:) = startstop(end,:);

    % Calculate Amplitude
    % Create a time array for integration
    time = (0:(1/100):(60*60*24))';
    amplitude = zeros(length(mergeStartStop),1);
    maxAngVel = zeros(length(mergeStartStop),1);
    equal2zero = find(mergeStartStop(:,1)-mergeStartStop(:,2)==0);
    mergeStartStop(equal2zero,:) = [];
    [m,~] = size(mergeStartStop);
    for k = 1:m        
        amplitude(k) = abs(trapz(time(mergeStartStop(k,1):mergeStartStop(k,2)),absFiltData(mergeStartStop(k,1):mergeStartStop(k,2))));
        maxAngVel(k) = abs(max(absFiltData(mergeStartStop(k,1):mergeStartStop(k,2))));
    end 

    % Get rid of turns below amplitude threshold
    rindx = find(amplitude>amplitudeThreshold & amplitude<400);
    validAmp = amplitude(rindx);
    validAngVel = maxAngVel(rindx);
    stsp = mergeStartStop(rindx,:);

    turnInfo.amplitude = validAmp;
    turnInfo.angVelocity = validAngVel;
    turnInfo.startstop = stsp;

    % figure
    % hold on    
    % plot(absFiltData)
    % plot(mergeStartStop,absFiltData(mergeStartStop),'*')
    % plot(filtData)
    % 
    % t = 0:1/100:(6203380-6203270)/100;
    % figure 
    % hold on
    % plot(t,abs(rawVertGyro(6203270:6203380)))
    % plot(t,absFiltData(6203270:6203380))
    % yline(5)
    % legend('unfilt','filt','s','s','threshold')
    % ylabel('Angular Velocity (deg/s)')
    % xlabel('Time (sec)')
    % axis tight
    % % plot(mergeStartStop,absFiltData(mergeStartStop),'*')

end
