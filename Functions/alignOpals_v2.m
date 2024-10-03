function data = alignOpals_v2(data,fsR)
global fs;

% ========== ALIGN IMU AXES WITH GLOBAL FRAME ============ %%
        
    iSamples = 1:length(data.time);
    
    nDevices = length(data.sensor);
    offsetV = zeros(nDevices,3);
    offsetA = zeros(nDevices,3);
    cIndex = 1;
    fs = data.sampleRate;
    
    for cDevice = 1:nDevices
        try
        acc = [data.sensor(cDevice).acc.x' data.sensor(cDevice).acc.y' data.sensor(cDevice).acc.z'];
        g = [data.sensor(cDevice).gyro.x' data.sensor(cDevice).gyro.y' data.sensor(cDevice).gyro.z'];
        accR = resample(acc, fsR, fs);
        gR = resample(g .* 180/pi, fsR, fs);
        [data.sensor(cDevice).acceleration,q] = RotateAcc(accR, fs*2.5);
        data.sensor(cDevice).rotation = RotateVector(gR, q);
        data.sensor(cDevice).accR.x = accR(:,1);
        data.sensor(cDevice).gyroR.x = gR(:,1);
        data.sensor(cDevice).accR.y = accR(:,2);
        data.sensor(cDevice).gyroR.y = gR(:,2);
        data.sensor(cDevice).accR.z = accR(:,3);
        data.sensor(cDevice).gyroR.z = gR(:,3);
        
        data.sensor(cDevice).accA.x = data.sensor(cDevice).acceleration(:,1)' .*9.807;
        data.sensor(cDevice).gyroA.x = data.sensor(cDevice).rotation(:,1)' .*pi/180;
        data.sensor(cDevice).accA.y = data.sensor(cDevice).acceleration(:,2)' .*9.807;
        data.sensor(cDevice).gyroA.y = data.sensor(cDevice).rotation(:,2)' .*pi/180;
        data.sensor(cDevice).accA.z = data.sensor(cDevice).acceleration(:,3)' .*9.807;
        data.sensor(cDevice).gyroA.z = data.sensor(cDevice).rotation(:,3)' .*pi/180;
        catch
        end
    end
end