function turnInfo = gaitWithHoriTurns(headGyroYaw,impulseDuration,amplitudeThreshold,velocityThreshold,minima,plotting)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


    gyro = headGyroYaw;
    impulse = 1.476;
    filterData = ShahFilter(gyro,impulse,100);
    turnInfo = absShahTurn(filterData,gyro,minima,amplitudeThreshold,velocityThreshold,impulseDuration);
    disp(append("Turn Amplitude: ", num2str(turnInfo.amplitude(end))))

    % Do we want to plot
    switch plotting
        case 0

        case 1
        nexttile
        hold on
        plot(gyro)
        plot(turnInfo.(id{ii}).startstop,gyro(turnInfo.(id{ii}).startstop),'*')
        title(id{ii})
    end
end