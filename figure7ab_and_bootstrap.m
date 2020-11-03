%% Figure 7a b and bootstrap analysis code
% Code written by M. Chait, edited by K.C. Poole
%% Set parameters
% set random number generator to shuffle
rng('shuffle');

% Read in data from experiment 3 and 1
dataExp3 = xlsread('keyResult_HPBeat.xlsx');
dataExp1 = xlsread('keyResult.xlsx');
% Each row is a subject
% Column 1 = HP over headphone test with number of trials correct
% Column 2 = HP over speaker test with number of trials correct
% Column 3 = BT over headphone test with number of trials correct
% Column 4 = BT over speaker test with number of trials correct

% Only looks at thresholds that are greater than 50% (3/6), 0 has to stay
% in for the 1,1 corner
passRate = [0 3 4 5 6];

%% Plot ROC curve for HP and BT test and both together
subjects  = size(dataExp3,1);
rocHP   = [];

% Computing ROC for the HP test
for i = 1:length(passRate) 
    HPHp = find(round(dataExp3(:,1)) >= passRate(i)); % HP over headphones
    HPSp = find(round(dataExp3(:,2)) >= passRate(i)); % HP over loudspeakers
    % Appends proportion of subjects that passed each test at the current
    % passRate (aka threshold) to the ROC array
    rocHP = [rocHP; length(HPSp)/subjects, length(HPHp)/subjects];
end
rocHP=[rocHP; 0,0];

% Computing ROC for the BT test
rocBT = [];
for i = 1:length(passRate) %computing ROC for MD
    BTHp = find(round(dataExp3(:,3)) >= passRate(i)); % BT over headphones
    BTSp = find(round(dataExp3(:,4)) >= passRate(i)); % BT over loudspeakers
    rocBT = [rocBT; length(BTSp)/subjects, length(BTHp)/subjects];
end
rocBT=[rocBT; 0,0];

% Compute ROC for both the HP and BT test
rocBOTH = [];
for i = 1:length(passRate) %computing ROC for the combined test
    BH = find(round(dataExp3(:,1)) >= passRate(i) & round(dataExp3(:,3)) >= passRate(i)); %have to pass BOTH tests
    BSp = find(round(dataExp3(:,2)) >= passRate(i) & round(dataExp3(:,4)) >= passRate(i));%have to pass BOTH tests
    rocBOTH = [rocBOTH; length(BSp)/subjects, length(BH)/subjects];
end
rocBOTH=[rocBOTH; 0,0];

figure; hold on
xlim([0 1]);
ylim([0 1]);
plot(rocHP(:,1), rocHP(:,2),'o-r');
plot(rocBT(:,1), rocBT(:,2),'o-b');
plot(rocBOTH(:,1), rocBOTH(:,2),'o-g');
xlabel("Speakers"); xticks(0:0.2:1);
ylabel("Headphones"); yticks(0:0.2:1); grid on; set(gca,'DataAspectRatio',[1 1 1])
legend("HP", "BT", 'BOTH');

%% Plot ROC for HP+BT and HP+AP tests
% Compute ROC for both the HP and BT test from experiment 3
rocBothBT = [];
for i = 1:length(passRate) %computing ROC for the combined test
    BH = find(round(dataExp3(:,1)) >= passRate(i) & round(dataExp3(:,3)) >= passRate(i)); %have to pass BOTH tests
    BSp = find(round(dataExp3(:,2)) >= passRate(i) & round(dataExp3(:,4)) >= passRate(i));%have to pass BOTH tests
    rocBothBT = [rocBothBT; length(BSp)/subjects, length(BH)/subjects];
end
rocBothBT=[rocBothBT; 0,0];

% Compute ROC for both the HP and AP test from experiment 1 
subjects = size(dataExp1,1);
rocBothAP = [];
for i = 1:length(passRate) %computing ROC for the combined test
    BH = find(round(dataExp1(:,1)) >= passRate(i) & round(dataExp1(:,3)) >= passRate(i)); %have to pass BOTH tests
    BSp = find(round(dataExp1(:,2)) >= passRate(i) & round(dataExp1(:,4)) >= passRate(i));%have to pass BOTH tests
    rocBothAP = [rocBothAP; length(BSp)/subjects, length(BH)/subjects];
end
rocBothAP = [rocBothAP; 0,0];

figure; hold on
xlim([0 1]);
ylim([0 1]);
plot(rocBothBT(:,1), rocBothBT(:,2),'o-g');
plot(rocBothAP(:,1), rocBothAP(:,2),'o-b')
xlabel("Speakers"); xticks(0:0.2:1);
ylabel("Headphones"); yticks(0:0.2:1); grid on; set(gca,'DataAspectRatio',[1 1 1])
legend('BOTH (HP + BT)','BOTH (HP + AP)');


%% Perform boot strap of the above ROC calculations

B = 10000; %number of bootstrap iterations
subjects = size(dataExp3,1);

%Generating bootstrap matrix (sampling N subjects with replacemendt)
p = repmat(1:subjects,B,1);
p = p(reshape(randperm(B*subjects),B,subjects));

ROCdiff= []; % this variable will contain the AUC difference between HP and BT
for b = 1:B
    % Reading out the data for this iteration
    data = dataExp3(p(b,:),:); 
    rocHP = [];
    % Compute ROC for HP
    for i = 1:length(passRate) %computing ROC for HP
        HPHp = find(round(data(:,1)) >= passRate(i));
        HPSp = find(round(data(:,2)) >= passRate(i));
        rocHP = [rocHP; length(HPSp)/subjects, length(HPHp)/subjects];
    end
    rocHP=[rocHP; 0,0];
    
    % Compute ROC for BT
    rocBT = [];
    for i = 1:length(passRate)
        BTHp = find(round(data(:,3)) >= passRate(i));
        BTSp = find(round(data(:,4)) >= passRate(i));
        rocBT = [rocBT; length(BTSp)/subjects, length(BTHp)/subjects];
    end
    rocBT=[rocBT; 0,0];
    
    % Compute ROC for Both HP and BT
    rocBOTH = [];
    for i=1:length(passRate) %computing ROC for the combined test
        BH = find(round(data(:,1)) >= passRate(i) & round(data(:,3)) >= passRate(i)); %have to pass BOTH tests
        BSp = find(round(data(:,2)) >= passRate(i) & round(data(:,4)) >= passRate(i));%have to pass BOTH tests
        rocBOTH = [rocBOTH; length(BSp)/subjects, length(BH)/subjects];
    end
    rocBOTH = [rocBOTH; 0,0];
    
    % computing areas under the curve:
    AUCHP = trapz(sort(rocHP(:,1)), sort(rocHP(:,2)));
    AUCMD = trapz(sort(rocBT(:,1)), sort(rocBT(:,2)));
    AUCBOTH = trapz(sort(rocBOTH(:,1)), sort(rocBOTH(:,2)));
    ROCdiff = [ROCdiff AUCBOTH-AUCHP];
end

figure; histogram(ROCdiff, 30);
xlabel("ROCHP-ROCMD")
ylabel("# iterations")
title(['p = ',num2str(length(find(ROCdiff<0))/B)]);
p = length(find(ROCdiff<0))/B %thats the p stats for difference (single sided p value)

