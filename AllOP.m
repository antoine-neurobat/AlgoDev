clear all
PredictionError = zeros(5,24); %1st dim = 5 strategies , 2nd dim = 24 prediction times
PredictionErrorDensity = zeros(5, 3); %1st dim = 5 strategies , 2nd dim = 3 horizons (6, 12 and 24 hours)

for i = 1:8
    i
    str = strcat('year200',num2str(i),'.mat')
    load (str)
    OccPred    
end
% PRESENTATION OF RESULTS
figure('Name','PredictionError for the 5 strategies')
plot(PredictionError)
%axis([1 5 0 4500])
figure('Name','PredictionErrorDensity for the 5 strategies')
plot(PredictionErrorDensity, ':*')
legend('6 hours', '12 hours', '24 hours')
%axis([1 5 0 3500])
PredictionErrorMean = cell(5,2);
PredictionErrorMean(:,1) = {'AverageWeek', 'BestWeek', 'Clusters', 'Schedule', 'Random'};
PredictionErrorMean(:,2) = num2cell(mean(PredictionError,2))
PredictionErrorDensities =  cell(6,4);
PredictionErrorDensities(:,1) = {' ','AverageWeek', 'BestWeek', 'Clusters', 'Schedule', 'Random'};
PredictionErrorDensities(1,:) =  {'Predictor', '6 hours', '12 hours', '24 hours'};
PredictionErrorDensities(2:6,2:4) = num2cell(PredictionErrorDensity)




