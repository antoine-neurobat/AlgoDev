function [ PredictedWeek1 ] = PredictionBestCluster(WeeksSequences, LastWeek, ClustersMaxNb, flag_graphic)
%This function classifies the weeks of WeeksSequences in clusters, calculates
%the average of each cluster and finally returns the best matching cluster 
%average with the given LastWeek.
%ClustersMaxNb is the maximum number of possible clusters. A typical value
%of 11 seems to work well.
%flag_graphic (0-1) enables a graphical visualization of all non-unique clusters.

%CLUSTERS INPUT DATA PREPARATION
ClustData = zeros(size(WeeksSequences,1)-1,7*24+7);

for wn = 1:size(WeeksSequences,1)
    for wd = 1:7
        for hh = 1:24
            ClustData(wn,(wd-1)*24+hh) = WeeksSequences(wn,wd,hh); %Fill in with hourly data
        end
    end
    for wd = 1:7
        for hh = 1:24
            ClustData(wn,7*24+wd) =ClustData(wn,7*24+wd)+ 7*WeeksSequences(wn,wd,hh); %Fill in with daily data
            %*7 is the best so far, in order to have the 168 other points as 1 additional day
        end
    end
end

%MATLAB MAGIC CLUSTERING
T = clusterdata(ClustData,'maxclust',ClustersMaxNb,'distance','euclidean','linkage','average');% best so far
%AGU NOTE: I have seen that a 'complete' linkage will detect extreme behaviour similarities (work at night for instance)

%GRAPHICAL REPRESENTATION OF CLUSTERS
if flag_graphic> 0
    for i=1:ClustersMaxNb
        indices = find(T==i);
        if size(indices,1)> 1
            ip = 1;
            figure(i)
            for j=1:size(indices)
                subplot(4,4,ip);
                if ip <16
                    pcolor(squeeze(WeeksSequences(indices(j),:,:)))
                    ip = ip + 1;
                end
            end
        end
    end
end

%WEEK AVERAGE CALCULATION FO EACH CLUSTER
WeeksClustered = ones(ClustersMaxNb,7,24)*2;
for ClusterInd = 1:ClustersMaxNb
    WeeksClustered(ClusterInd,:,:) = mean(WeeksSequences(T==ClusterInd,:,:),1);
end

%BEST MATCHING CLUSTER DETERMINATION
Similarity = zeros(size(WeeksClustered,1),1);
for wns = 1:size(WeeksClustered,1)
    Similarity(wns) = WeekSimilarity(LastWeek, WeeksClustered(wns,:,:), wns, 7, 24); % 'wns, 7, 24' because weeksimilarity is starting from previous week (cf WeekSimilarity.m)
end
[Val, BestWeekInd] = max(Similarity); % BestWeekInd is the best clusteredweek index
PredictedWeek1 = WeeksClustered(BestWeekInd, :,:);
                
% figure(1);pcolor(squeeze(LastWeek))
% figure(2);pcolor(squeeze(PredictedWeek1))

end

