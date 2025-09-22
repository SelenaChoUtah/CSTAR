function groupStats = computeGroupStats(allStats)
    conditions = ["stabilization", "volitional"];
    variables = ["amplitude", "angVel"];
    subID = fieldnames(allStats);

    for c = 1:length(conditions)
        cond = conditions(c);

        for v = 1:length(variables)
            varName = variables(v);

            dailyMeansAll = [];
            dailyMediansAll = [];
            dailyP95All = [];
            dailyTurnCountsAll = [];
            cvList = [];

            for ii = 1:length(subID)
                f = allStats.(subID{ii});
                if ~isfield(f, 'headOnTrunk') || ...
                   ~isfield(f.headOnTrunk, cond) || ...
                   ~isfield(f.headOnTrunk.(cond), varName)
                    continue
                end

                g = f.headOnTrunk.(cond).(varName);

                if isfield(g, "dailyMean")
                    dailyMeansAll   = [dailyMeansAll;   g.dailyMean(:)];
                    dailyMediansAll = [dailyMediansAll; g.dailyMedian(:)];
                    dailyP95All     = [dailyP95All;     g.dailyP95(:)];
                    dailyTurnCountsAll = [dailyTurnCountsAll; g.dailyTurnCount(:)];
                end

                if varName == "amplitude" && isfield(g, "interDay") && isfield(g.interDay, "cv")
                    cvList = [cvList; g.interDay.cv];
                end
            end

            groupStats.(cond).(varName).interDay.mean = mean(dailyMeansAll, 'omitnan');
            groupStats.(cond).(varName).interDay.meanSD = std(dailyMeansAll, 'omitnan');
            groupStats.(cond).(varName).interDay.median = mean(dailyMediansAll, 'omitnan');
            groupStats.(cond).(varName).interDay.medianSD = std(dailyMediansAll, 'omitnan');
            groupStats.(cond).(varName).interDay.p95 = mean(dailyP95All, 'omitnan');
            groupStats.(cond).(varName).interDay.p95SD = std(dailyP95All, 'omitnan');
            groupStats.(cond).(varName).interDay.turnCount = sum(dailyTurnCountsAll, 'omitnan');

            if varName == "amplitude"
                groupStats.(cond).(varName).interDay.meanCV = mean(cvList, 'omitnan');
            end
        end
    end
end
