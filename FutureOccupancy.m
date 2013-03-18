function [ FutureOcc ] = FutureOccupancy(WeeksSequences,wn, wd, hh, futurehours)
%This function returns the future occupancy in "futurehours" hours from
%the sequence of weeks "WeeksSequences". wn, wd and hh are the week number,
%the week day and the current hour respectively, from which the futurehours
%has to be determined.
%If futurehours is further than the given WeeksSequences limit, the function 
%considers the WeeksSequences as a loop and restarts from the beginning of
%the weeks sequences.

if wn == 0 %Check that could be useful if algorithm is called before one week has passed
    wn = size(WeeksSequences,1); %WeeksSequences considered as a loop: element before the first one is the last one
end
%Check if current time + future hours is not in the current day
while hh+futurehours > 24
    futurehours = futurehours - 24;
    %Go to next week day (1=Sunday, 7 = Saturday)
    if wd + 1 > 7 % Check if end of the week
        wd = 1;
        %Go to next week number
        if wn + 1 > size(WeeksSequences,1) % Check if end of weekssequences
            wn = 1; 
        else % not the end of weekssequences
            wn = wn + 1;
        end
    else % not the end of the week
        wd = wd + 1; 
    end
end
hh = hh+futurehours;

FutureOcc = WeeksSequences(wn, wd, hh);
end
