%% Figure 7d and bootstrap analysis code
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
AUCvals = [];
figure; hold on;
noSubjects = 42;

for b = 1:B
    % Randomly subsample from the pool of 100
    order = randperm(100);
    subjs = order(1:42); %subsampling 42
    data = dataExp1(subjs,:); %reading out the data for this iteration
    
    % Compute ROC for the HP test
    rocHP = [];
    for i = 1:length(passRate)
        HPHp = find(round(data(:,1)) >= passRate(i));
        HPSp = find(round(data(:,2)) >= passRate(i));
        rocHP = [rocHP; length(HPSp)/noSubjects, length(HPHp)/noSubjects];
    end
    rocHP = [rocHP; 0,0];
    
    plot(rocHP(:,1),rocHP(:,2),'.-','color',[0.8 0.8 0.8]);

    % computing areas under the curve: 
    AUCHP = trapz(sort(rocHP(:,1)), sort(rocHP(:,2)));
    AUCvals = [AUCvals AUCHP];

end

% Plot the ROC curve for HP test
dataExp3 = xlsread('keyResult_HPBeat.xlsx');
noSubjects  = size(dataExp3,1);
rocHP = [];

% Computing ROc for the HP test
for i=1:length(passRate)
    HPHp = find(round(dataExp3(:,1))>=passRate(i));
    HPSp = find(round(dataExp3(:,2))>=passRate(i));
    rocHP = [rocHP; length(HPSp)/noSubjects, length(HPHp)/noSubjects];
end
rocHP =[rocHP; 0,0];

% Calculate AUC for actual HP data
AUC = trapz(sort(rocHP(:,1)), sort(rocHP(:,2)));

xlim([0 1]);
ylim([0 1]);
plot(rocHP(:,1), rocHP(:,2),'o-r');
xlabel("Speakers"); xticks([0:0.2:1]);
ylabel("Headphones"); yticks([0:0.2:1]); grid on; set(gca,'DataAspectRatio',[1 1 1])
legend("HP")

p = length(find(AUCvals<AUC))/B %thats the p stats for difference (single sided p value) 
figure;
histogram(AUCvals,'BinWidth',0.01);
ylim([0 150]); xlim([0.7 0.95]); 
xline(AUC,'r--')
title(['p value = ',num2str(p)]); ylabel('resamplings'); xlabel('AUC')