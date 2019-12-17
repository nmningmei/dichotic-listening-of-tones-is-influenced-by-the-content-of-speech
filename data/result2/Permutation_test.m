function result = Permutation_test(condition,sample_size,trials,flag)

clear all; close all; clc
cd('C:\Users\ning\Dropbox\NYU\MA thesis\result2')
pool = [11:26,28,29];
file = dir(sprintf('Dichotic%sClassic*.mat',condition));
for ii = 1:length(file)
    load(file(ii).name)
    [~,Dichotic]=DichoticErrorTone_toneExcluded(Output,0,9,[]);
    
    result(ii,:) = [Dichotic.LEA,Dichotic.REA];
end
%
cd('C:\Users\ning\Dropbox\NYU\MA thesis\result')
pool = 1:24;
Takes = ones(1,24);
Takes([4,5,19,20]) = 0;% excluded
pool = nonzeros(pool(:) .* Takes(:));
%pool = [0;pool]';
for ii = 1:length(pool)
    file = dir((sprintf('Dichotic%sClassic_%d.mat',condition,pool(ii))));
    load(file.name)
    [~,Dichotic]=DichoticErrorTone_toneExcluded(Output,0,9,[]);
    
    result(ii+18,:) = [Dichotic(1).LEA,Dichotic(1).REA];
end
cd('C:\Users\ning\Dropbox\NYU\MA thesis\result2')
Current_difference = mean(result(:,1) - result(:,2));
% permutation test

for ii = 2:sample_size
    for samplingTimes = 1:trials
        samplingTimes;
        subset_pick = randsample([1:length(result)],ii,'true');
        subset_result = result(subset_pick,:);
        % (LEA - REA) / std
        differences(samplingTimes,ii-1) = ...
            mean(subset_result(:,1)-subset_result(:,2));
        
    end
    mean_sampleSize(ii-1) = mean(differences(:,ii-1));
    
end
if flag == 1
    alpha = 0.05;
    CI = prctile(mean_sampleSize,[100*alpha/2,100*(1-alpha/2)]);
    figure(14)
    hist(mean_sampleSize,60);hold on
    ylim= get(gca,'ylim');
    h1=plot(Current_difference*[1,1],ylim,'y-','LineWidth',3,'color',[.3 .6 .9]);
    h2=plot(CI(1)*[1,1],ylim,'r-','LineWidth',1);
    plot(CI(2)*[1,1],ylim,'r-','LineWidth',1);
    set(gca,'tickdir','out')
    legend('distribution of difference','95% confidence interval','current difference')
    xlabel('difference = LEA - REA')
    ylabel('frequency')
    title(sprintf('Boostrapping - %s \nsample size from 2 to 1000\n10000 times simulation each trial',condition))
    
    box off
end
    
    
    
    
    
    
end