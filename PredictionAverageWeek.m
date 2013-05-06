function [ PredictedWeek1 ] = PredictionAverageWeek(WeeksSequences)
%This function returns a week averaged on all weeks from WeeksSequences.
%Invalid value (2) are dismissed for the average calculation.

PredictedWeek1 = zeros(7,24);

for wds = 1:7
    for hhs = 1:24
        tmpsum = 0;
        tmpnum = 0;
        for wns = 1:size(WeeksSequences,1)
            if WeeksSequences(wns,wds,hhs) ~=2 %Only if not invalid value
                tmpsum = tmpsum + WeeksSequences(wns,wds,hhs);
                tmpnum = tmpnum + 1;
            end
        end
        if tmpnum ~= 0
            PredictedWeek1(wds, hhs) = round(tmpsum/tmpnum);
        else
            PredictedWeek1(wds, hhs) = 2;
        end
    end
end

end