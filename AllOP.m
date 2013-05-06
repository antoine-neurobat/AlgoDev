clear all
PredictionErrorAvgAll = zeros(7,7,24); %first dim is the year
FullPredErrorAll = zeros(7,7,52,7,24,24); %first dim is the year

for ifile = 2:8 %year 2001 has only two weeks , not relevant.
    ifile
    str = strcat('year200',num2str(ifile),'.mat')
    load (str)
    OccPred    
    PredictionErrorAvgAll(ifile-1,:,:)=PredictionErrorAvg;
    FullPredErrorAll(ifile-1,:,:,:,:,:) = FullPredError;
end

PredictionErrorAvg = squeeze(mean(PredictionErrorAvgAll,1));
FullPredError = squeeze(mean(FullPredErrorAll,1));
dispOP




