function [ similarity ] = WeekSimilarity(LastWeek, WeeksSequences, current_wn, current_wd, current_hh)
%This function returns the "similarity" between:
% -a given week (LastWeek)
% -a running week from a weeksSequences (with a given starting point wn,
% wd, hh)
%The similarity is between 0 (completely different weeks) and 1 (exactly
%same weeks)

%INITIALISATION
similarity = 0;
TotDiff = 0;
NbHours = 0; % counts all hours taking part in the similarity determination
%Forward similiarty calculation, starting from one week behind
wn = current_wn - 1;
wd = current_wd;
hh = current_hh;

%LOOP FOR EACH HOUR
for i = 1:24*7 % for each hour in the past week
    OccWeeksSequences=FutureOccupancy(WeeksSequences, wn, wd, hh, i);
    OccLastWeek=FutureOccupancy(reshape(LastWeek,1,size(LastWeek,1),size(LastWeek,2)), 1, wd, hh, i); % LastWeek reshaped to add a first singleton dimension
    if OccWeeksSequences ~= 2 && OccLastWeek ~= 2 
        TotDiff = TotDiff + abs(OccWeeksSequences - OccLastWeek);
        NbHours = NbHours+1;
    elseif OccWeeksSequences == 2 && OccLastWeek ~= 2 % if week from weeksSequences contains invalid value (2) --> counts as full error
        TotDiff = TotDiff + 1; % to penalize weeks which are not complete
        NbHours = NbHours+1;
    end
end

%RESULT
if NbHours > 0
    similarity = 1 - TotDiff/NbHours;
end
end

