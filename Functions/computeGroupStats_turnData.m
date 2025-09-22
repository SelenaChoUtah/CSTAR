function groupStats = computeGroupStats_turnData(allStats)
    subID = fieldnames(allStats);
    variables = ["amplitude", "angVelocity"];
    sensorList = fieldnames(allStats.(subID{1}));

    for v = 1:length(variables)
        varName = variables(v);

        for s = 1:length(sensorList)
            thisSensor = sensorList{s};

            hourlyMeanAll = [];
            hourlyMedianAll = [];
            hourlyP95All = [];
            dailyMeanAll = [];
            dailyMedianAll = [];
            dailyP95All = [];
            dailyTurnsAll = [];
            intraDayCVsAll = [];

            for ii = 1:length(subID)
                if isfield(allStats.(subID{ii}), thisSensor) && ...
                   isfield(allStats.(subID{ii}).(thisSensor), varName)

                    f = allStats.(subID{ii}).(thisSensor).(varName);

                    if isfield(f, "hourlyMean")
                        hourlyMeanAll   = [hourlyMeanAll;   f.hourlyMean];
                        hourlyMedianAll = [hourlyMedianAll; f.hourlyMedian];
                        hourlyP95All    = [hourlyP95All;    f.hourlyP95];
                    end

                    if isfield(f, "dailyMean")
                        dailyMeanAll   = [dailyMeanAll;   f.dailyMean(:)];
                        dailyMedianAll = [dailyMedianAll; f.dailyMedian(:)];
                        dailyP95All    = [dailyP95All;    f.dailyP95(:)];
                        dailyTurnsAll  = [dailyTurnsAll;  f.dailyTurnCount(:)];
                    end

                    if isfield(f, "intraDayCV")
                        intraDayCVsAll = [intraDayCVsAll; f.intraDayCV(:)];
                    end
                end
            end

            groupStats.(thisSensor).(varName).hourly.mean     = mean(hourlyMeanAll, 1, 'omitnan');
            groupStats.(thisSensor).(varName).hourly.meanSD   = std(hourlyMeanAll, 0, 1, 'omitnan');
            groupStats.(thisSensor).(varName).hourly.median   = mean(hourlyMedianAll, 1, 'omitnan');
            groupStats.(thisSensor).(varName).hourly.medianSD = std(hourlyMedianAll, 0, 1, 'omitnan');
            groupStats.(thisSensor).(varName).hourly.p95      = mean(hourlyP95All, 1, 'omitnan');
            groupStats.(thisSensor).(varName).hourly.p95SD    = std(hourlyP95All, 0, 1, 'omitnan');

            groupStats.(thisSensor).(varName).interDay.mean     = mean(dailyMeanAll, 'omitnan');
            groupStats.(thisSensor).(varName).interDay.meanSD   = std(dailyMeanAll, 'omitnan');
            groupStats.(thisSensor).(varName).interDay.median   = mean(dailyMedianAll, 'omitnan');
            groupStats.(thisSensor).(varName).interDay.medianSD = std(dailyMedianAll, 'omitnan');
            groupStats.(thisSensor).(varName).interDay.p95      = mean(dailyP95All, 'omitnan');
            groupStats.(thisSensor).(varName).interDay.p95SD    = std(dailyP95All, 'omitnan');
            groupStats.(thisSensor).(varName).interDay.turnCount = sum(dailyTurnsAll, 'omitnan');

            groupStats.(thisSensor).(varName).intraDay.meanCV = mean(intraDayCVsAll, 'omitnan');
        end
    end
end
