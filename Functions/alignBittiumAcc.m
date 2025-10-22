function bittium = alignBittiumAcc(dataAcc)

% ========== ALIGN IMU AXES WITH GLOBAL FRAME ============ %%

        fs = 100;
        fsR = 100;
        acc = dataAcc;
        accR = resample(acc, fsR, fs);
        [acceleration,q] = RotateAcc(accR, fs*2.5);
        bittium = acceleration/10;

end