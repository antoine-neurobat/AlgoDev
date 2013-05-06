% PRESENTATION OF RESULTS
figure('Name','PredictionError for the 7 strategies per strategy')
plot(PredictionErrorAvg)
figure('Name','PredictionError for the 7 strategies per horizon of prediction')
plot(PredictionErrorAvg(:,:)')
legend('AverageWeek', 'BestWeek', 'Clusters', 'Schedule', 'Random','past24hours','alwaysCurrent')
%axis([1 5 0 4500])
% figure('Name','PredictionErrorDensity for the 7 strategies')
% plot(PredictionErrorDensity, ':*')
% legend('6 hours', '12 hours', '24 hours')
%axis([1 5 0 3500])

PredictionErrorMean = cell(7,2);
PredictionErrorMean(:,1) = {'AverageWeek', 'BestWeek', 'Clusters', 'Schedule', 'Random', 'past24hours','alwaysCurrent'};
PredictionErrorMean(:,2) = num2cell(mean(PredictionErrorAvg,2))
% PredictionErrorDensities =  cell(8,4);
% PredictionErrorDensities(:,1) = {' ','AverageWeek', 'BestWeek', 'Clusters', 'Schedule', 'Random','past24hours','alwaysCurrent'};
% PredictionErrorDensities(1,:) =  {'Predictor', '6 hours', '12 hours', '24 hours'};
% PredictionErrorDensities(2:8,2:4) = num2cell(PredictionErrorDensity)

% Evolution hour after hour
Evhh = zeros(7,24,52*7*24+1);%7 strategies, 24 horizon,
step=1;
for wn=1:52
    for wd=1:7
        for hh=1:24
          step = step+1;
            Evhh(:,:,step)=Evhh(:,:,step-1)+squeeze(FullPredError(:,wn,wd,hh,:));
        end
    end
end
figure('Name','Example of evolution on 1h prediction for the 7 strategies')
plot(squeeze(Evhh(:,1,:))') 
legend('AverageWeek', 'BestWeek', 'Clusters', 'Schedule', 'Random','past24hours','alwaysCurrent')

% Plot Error per hour of day dor the 7 strategies
temp=squeeze(sum(FullPredError,2));%sum over all weeks
errorhod=squeeze(sum(temp,2))./(7*52);%sum over all weekdays
figure('Name','Example of error per hour of day on 1h prediction for the 7 strategies')
plot(squeeze(errorhod(:,:,1))') 
legend('AverageWeek', 'BestWeek', 'Clusters', 'Schedule', 'Random','past24hours','alwaysCurrent')
