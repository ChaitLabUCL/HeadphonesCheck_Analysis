%% Figure 7c and bootstrap analysis code
% Code written by M. Chait, edited by K.C. Poole
%% Set up parameters
rng('shuffle');

% Read in data from experiment 1
dataExp1 = xlsread('keyResult.xlsx');
% Each row is a subject
% Column 1 = HP over headphone test with number of trials correct
% Column 2 = HP over speaker test with number of trials correct
% Column 3 = BT over headphone test with number of trials correct
% Column 4 = BT over speaker test with number of trials correct

% Only looks at thresholds that are greater than 50% (3/6), 0 has to stay
% in for the 1,1 corner
passRate = [0 3 4 5 6];

%% Bootstrap analysis

B = 1000; %number of bootstrap iterations
figure; hold on;
noSubjects = 42;
AUCvals = [];

for b = 1:B
    % Randomly subsample from the pool of 100
    order = randperm(100);
    subjs = order(1:42); %subsampling 42
    data = dataExp1(subjs,:); %reading out the data for this iteration
    
    % Compute ROC for the AP test
    rocAP = [];
    for i = 1:length(passRate) %computing ROC for MD
        APHp = find(round(data(:,3)) >= passRate(i));
        APSp = find(round(data(:,4)) >= passRate(i));
        rocAP = [rocAP; length(APSp)/noSubjects, length(APHp)/noSubjects];
    end 
    rocAP = [rocAP; 0,0];

    plot(rocAP(:,1),rocAP(:,2),'.-','color',[0.8 0.8 0.8]);
    
    % computing areas under the curve: 
    AUCHP = trapz(sort(rocAP(:,1)), sort(rocAP(:,2)));
    AUCvals = [AUCvals AUCHP];
    
end

% Plot the ROC curve for BT test
dataExp3 = xlsread('keyResult_HPBeat.xlsx');
noSubjects = size(dataExp3,1);
rocBT = [];

%Computing the ROC for the BT test
for i = 1:length(passRate) 
    APHp = find(round(dataExp3(:,3)) >= passRate(i));
    APSp = find(round(dataExp3(:,4)) >= passRate(i));
    rocBT = [rocBT; length(APSp)/noSubjects, length(APHp)/noSubjects];
end
rocBT = [rocBT; 0,0];

% calculate AUC for actual BT data
AUC = trapz(sort(rocBT(:,1)), sort(rocBT(:,2)));

xlim([0 1]);
ylim([0 1]);
plot(rocBT(:,1), rocBT(:,2),'o-b');
xlabel("Speakers"); xticks([0:0.2:1]);
ylabel("Headphones"); yticks([0:0.2:1]); grid on; set(gca,'DataAspectRatio',[1 1 1])
legend("BT")

p = length(find(AUCvals<AUC))/B %thats the p stats for difference (single sided p value) 
figure;
histogram(AUCvals,'BinWidth',0.01);
ylim([0 150]); xlim([0.6 0.9]); 
xline(AUC,'r--')
title(['p value = ',num2str(p)]); ylabel('resamplings'); xlabel('AUC')