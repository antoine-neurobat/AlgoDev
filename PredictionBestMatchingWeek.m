function [ PredictedWeek1 ] = PredictionBestMatchingWeek(WeeksSequences, LastWeek, weekday, hourofday)
%This function returns the best matching week from the given
%WeeksSequences compared to the LastWeek (with a given starting point 
%weekday and hourofday)

% if size(WeeksSequences,1) > 50
%     debug =1 ;
% end

%INITIALISATION
PredictedWeek1 = zeros(7,24);
Similarity = zeros(size(WeeksSequences,1)-1,1);

%HIGHEST SIMILARITY DETERMINATION
for wns = 1:size(WeeksSequences,1)-1 % -1 to not take into account current week which is of zero difference of course
    Similarity(wns) = WeekSimilarity(LastWeek, WeeksSequences, wns, weekday, hourofday);
end
[Val, BestWeekInd] = max(Similarity); % BestWeekInd is the best matching week index

%RESULTS
%Fill in the predicted week data
for wds = 1:7
    for hhs = 1:24
        if wds > weekday || (wds == weekday && hhs > hourofday) % hours (future in the week "BestWeekInd") corresponding to current week
            PredictedWeek1(wds,hhs)=WeeksSequences( BestWeekInd, wds, hhs);
        else % hours (past in the week "BestWeekInd") that should be filled with data of next week ("BestWeekInd + 1")
            PredictedWeek1(wds,hhs)=WeeksSequences( BestWeekInd + 1, wds, hhs);
        end
    end
end
end