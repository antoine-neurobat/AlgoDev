% MAIN SCRIPT FOR PRESENCE PREDICTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script simulates a full year of usage of the Presence predictor.
% It compares the performance of seven different predictors, starting
% from scratch for each of them:
% a.Calculate an average week from all seen weeks
% b.Find the best matching week from all seen weeks and use it for
%   prediction
% c.Classify the weeks seen in clusters and use the average week of the
%   best matching cluster for prediction
% d.Usual fixed office schedule (9-18h)
% e.Uniform random crisp values (0 or 1)
% f.Assume today is the same as yesterday
% g.Assume future presence is keeping at current value
% Predictors a-e deliver a predicted future week.


% INITIALISATION
%clearvars
% Load the OccYear matrix containing a whole year of presence on an hourly basis.
% Data have been aggregated using PrepareOccTestData.m
%load year2005.mat 
%Allocate memory for the last 100 weeks seen.
WeeksSeen = ones(100,7,24)*2; % 100 is arbitrary, should depend on memory available.
WSCurrent = 1; %Current WeeksSeen
LastWeek = ones(7,24)*2; % Last seen week. Values for "future week days" or "future hours" are from the previous week.
PredictedWeek = ones(7,7,24); % Weeks used for prediction. 7 prediction strategies. Updated each night.
PredictionErrorAvg = zeros(7,24);
PredictionErrorChecksum = zeros(1,24);
FullPredError = zeros(7,52,7,24,24);
%Initialisation of strategy d -- Fixed Schedule
for wds = 1:7
    for hhs = 1:24
        if hhs < 9 || hhs > 18 || wds == 1 || wds == 7 % Standard office hour (at least for this office room! ;) )
            PredictedWeek(4,wds,hhs) = 0;
        end
    end
end
%PredictionError is simply the cumulated difference between the actual
%future presence and the predicted presence, one value for each future 24 hours
PredictionError = zeros(7,24); %1st dim = 7 strategies , 2nd dim = 24 prediction times
%PredicitionErrorDensity is the error on the average presence on 3 different
%horizons (6, 12 and 24 hours). It maybe better indicates if a predictor is
%likely to have a positive effect on heat control.
PredictionErrorDensity = zeros(7, 3); %1st dim = 7 strategies , 2nd dim = 3 horizons (6, 12 and 24 hours)


% START OF THE MAIN LOOP -- SIMULATE HOURLY EVENT
for wn = 1:size(OccYear,1) % for each week of OccYear matrix
    %wn
    for wd = 1:7 % for each weekday 
        for hh = 1:24 % for each hour 
            
            %%%Update matrices%%%
            WeeksSeen(WSCurrent,wd,hh) = OccYear(wn, wd, hh);
            LastWeek(wd, hh) = OccYear(wn, wd, hh);
            
            %%%Update simple predictors every hour%%%
            
            %f. next 24h = past 24h
            if (hh==24) 
                PredictedWeek(6,mod(wd,7)+1,1:24) = OccYear(wn, wd, 1:24);
            else
                PredictedWeek(6,wd,hh+1:24) = OccYear(wn, mod(wd-2,7)+1, hh+1:24);
                PredictedWeek(6,mod(wd,7)+1,1:hh) = OccYear(wn, wd, 1:hh);
            end
           
            
            %g. next 24h  = current presence
            PredictedWeek(7,:,:)= ones(7,24)*OccYear(wn, wd, hh);
            
            
            %%%Prediction and error calculation%%%
            if wn > 3 %predicts only after 3 weeks (1 week after start of prediction modelling)
                for strategies = 1:7
                    tmpsum1 = zeros(3,1);
                    tmpsum2 = zeros(3,1);
                    tmpnum = ones(3,1); %to avoid division per zero
                    for i = 1:24 % prediction for each hour
                        if (FutureOccupancy(OccYear,wn,wd,hh,i) ~= 2 && FutureOccupancy(PredictedWeek(strategies,:,:),1,wd,hh,i) ~= 2)
                            PredictionError(strategies,i) = PredictionError(strategies,i) + abs(FutureOccupancy(OccYear,wn,wd,hh,i)-FutureOccupancy(PredictedWeek(strategies,:,:),1,wd,hh,i));
                            FullPredError(strategies,wn,wd,hh,i) = abs(FutureOccupancy(OccYear,wn,wd,hh,i)-FutureOccupancy(PredictedWeek(strategies,:,:),1,wd,hh,i));
                            PredictionErrorChecksum(i) = PredictionErrorChecksum(i)+1;
                            if i < 7 % Average over next 6 hours
                                tmpsum1(1) = tmpsum1(1) + FutureOccupancy(OccYear,wn,wd,hh,i);
                                tmpsum2(1) = tmpsum2(1) + FutureOccupancy(PredictedWeek(strategies,:,:),1,wd,hh,i);
                                tmpnum(1) = tmpnum(1) + 1;
                            end
                            if i < 13 % Average over next 12 hours
                                tmpsum1(2) = tmpsum1(2) + FutureOccupancy(OccYear,wn,wd,hh,i);
                                tmpsum2(2) = tmpsum2(2) + FutureOccupancy(PredictedWeek(strategies,:,:),1,wd,hh,i);
                                tmpnum(2) = tmpnum(2) + 1;
                            end
                            % Average over next 24 hours
                            tmpsum1(3) = tmpsum1(3) + FutureOccupancy(OccYear,wn,wd,hh,i);
                            tmpsum2(3) = tmpsum2(3) + FutureOccupancy(PredictedWeek(strategies,:,:),1,wd,hh,i);
                            tmpnum(3) = tmpnum(3) + 1;
                        elseif FutureOccupancy(OccYear,wn,wd,hh,i) ~= 2 % if predictedWeek contains invalid value (2) --> counts as full error
                            PredictionError(strategies,i) = PredictionError(strategies,i) + 1;
                            PredictionErrorChecksum(i) = PredictionErrorChecksum(i)+1;
                        else
                            %FutureOccupancy(OccYear,wn,wd,hh,i) == 2, actual
                            %future value is invalid, so no error.
                        end
                    end
                    PredictionErrorDensity(strategies,:) = PredictionErrorDensity(strategies,:) + abs(tmpsum1-tmpsum2)'./tmpnum'; %divide by sums
                end
            end
            
            %%%Update Predicted weeks each night at 24%%%
            if hh == 24 && wn > 2 %starts prediction modelling only after 2 weeks (to have data for model)
                %a. Average week
                PredictedWeek(1,:,:) = PredictionAverageWeek(WeeksSeen(1:WSCurrent-1,:,:));

                %b. Best matching week 
                PredictedWeek(2,:,:) = PredictionBestMatchingWeek(WeeksSeen(1:WSCurrent-1,:,:), LastWeek, wd, hh); 
                
                %c. Clusters
                PredictedWeek(3,:,:) = PredictionBestCluster(WeeksSeen(1:WSCurrent-1,:,:),LastWeek, 11, 0);
                
                %d. Fixed Schedule
                % already defined at start of script
                
                %e. Random
                PredictedWeek(5,:,:) = randi(2,7,24)-1;
                
            end
            
        end
    end
    WSCurrent = WSCurrent + 1; % Go to next WeeksSeen
end
for i = 1:24
    PredictionErrorAvg(:,i) = PredictionError(:,i)./PredictionErrorChecksum(i)*7;% *7 since it is called 1 for each startegy
end
%Original old idea:
%Algo: per weekday
%At which time user wakes up (first seen event)
%At which time user goes to sleep (last seen event)
%Impossible because no real time and user can go beyond midnight to bed

    