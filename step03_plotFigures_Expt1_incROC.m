%% Plot figures for Expt1
% fig1: distribution of performance for each of the 4 conditions
% fig2: ROC, d prime, speaker and headphone pass rates

% Created: A. Billig, Maria Chiat, Sijia Zhao 14th July 2020

close;
clear;
rng('shuffle');

define_colours;

%% Plot the distribution of performance for each of the 4 conditions (Expt1)
data = xlsread(fullfile('Data','keyResult.xlsx'));
performance =[0 1 2 3 4 5 6]; %possible performance outcomes

% plot of performance by condition
HP_h=[];
HP_s=[];
AP_h=[];
AP_s=[];

for i=1:length(performance)
    HP_h=[HP_h 100*length(find(data(:,1) == performance(i)))/length(data)];
    HP_s=[HP_s 100*length(find(data(:,2) == performance(i)))/length(data)];
    AP_h=[AP_h 100*length(find(data(:,3) == performance(i)))/length(data)];
    AP_s=[AP_s 100*length(find(data(:,4) == performance(i)))/length(data)];    
end

figure(1); clf;

hold on
plot(performance, HP_h,'o-','MarkerSize',10,'Color',colourmap(1,:),'LineWidth',3);
plot(performance, HP_s,'o-','MarkerSize',10,'Color',colourmap(2,:),'LineWidth',3);
plot(performance, AP_h,'o-','MarkerSize',10,'Color',colourmap(3,:),'LineWidth',3);
plot(performance, AP_s,'o-','MarkerSize',10,'Color',colourmap(4,:),'LineWidth',3);
hold off;
set(gca, 'XDir','reverse')
ylim([0 100]);
xlim([-0.5 6.5]);
line([2 2],[0 80],'LineStyle','--','Color','k', 'LineWidth', 1.5);

xlabel("Performance out of 6")
ylabel("% participants")
legend(condlist(1:4),'Location','northeast','Box','Off','FontSize',18)
axis square;
set(gca,'FontSize',15);
set(gca,'LineWidth',1.5);
set(gca, 'FontName', 'Arial');

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 8]);

%% Plot ROC analysis
% Import data (alex's style)
dataOrig = xlsread(fullfile('Data','HeadphoneExperiment_Data_100Subjects.xlsx'));
dataTransposed = (dataOrig(:, 1:4))';
% Only keep first four columns, and transpose
% so now each column is a subject (easier indexing for permutation tests)
% Row 1 = HP headphones
% Row 2 = HP speakers
% Row 3 = AP headphones
% Row 4 = AP speakers

% Get number of subjects
[~, NS] = size(dataTransposed);

% Set different pass rates
passRate = [0, 3/6, 4/6, 5/6, 1] * 100; % Running for threshold >chance (note 0 has to stay in there!)

% Do ROC on true data
ROC_HP_true = zeros(length(passRate) + 1, 2);
ROC_AP_true = zeros(length(passRate) + 1, 2);
ROC_BOTH_true = zeros(length(passRate) + 1, 2);
for i = 1:length(passRate)
    ROC_HP_true(i, 1) = sum(round(dataTransposed(2, :)) >= round(passRate(i))) / NS; % Proportion subjects passing HP speaker test
    ROC_HP_true(i, 2) = sum(round(dataTransposed(1, :)) >= round(passRate(i))) / NS; % Proportion subjects passing HP headphone test
    ROC_AP_true(i, 1) = sum(round(dataTransposed(4, :)) >= round(passRate(i))) / NS; % Proportion subjects passing AP speaker test
    ROC_AP_true(i, 2) = sum(round(dataTransposed(3, :)) >= round(passRate(i))) / NS; % Proportion subjects passing AP headphone test
    ROC_BOTH_true(i, 1) = sum(round(dataTransposed(2, :)) >= round(passRate(i)) & round(dataTransposed(4, :)) >= round(passRate(i))) / NS;
    ROC_BOTH_true(i, 2) = sum(round(dataTransposed(1, :)) >= round(passRate(i)) & round(dataTransposed(3, :)) >= round(passRate(i))) / NS;
end

dist = abs(diff(ROC_HP_true(:, 1))); % Distances between points along x-axis (i.e. between speaker test pass proportions)
AUC_HP_true = .5*sum(dist.*(ROC_HP_true(1:length(passRate), 2) + ROC_HP_true(2:end, 2))); %Calculates true area under curve using trapeziums

dist = abs(diff(ROC_AP_true(:, 1))); % Distances between points along x-axis (i.e. between speaker test pass proportions)
AUC_AP_true = .5*sum(dist.*(ROC_AP_true(1:length(passRate), 2) + ROC_AP_true(2:end, 2))); %Calculates true area under curve using trapeziums

dist = abs(diff(ROC_BOTH_true(:, 1))); % Distances between points along x-axis (i.e. between speaker test pass proportions)
AUC_BOTH_true = .5*sum(dist.*(ROC_BOTH_true(1:length(passRate), 2) + ROC_BOTH_true(2:end, 2))); %Calculates true area under curve using trapeziums

% Calculate difference
AUC_HP_minus_AP_true = AUC_HP_true - AUC_AP_true;
AUC_BOTH_minus_HP_true = AUC_BOTH_true - AUC_HP_true;
AUC_BOTH_minus_AP_true = AUC_BOTH_true - AUC_AP_true;

% Do d' at each threshold
dprime_HP_true = norminv(ROC_HP_true(:, 2)) - norminv(ROC_HP_true(:, 1));
dprime_AP_true = norminv(ROC_AP_true(:, 2)) - norminv(ROC_AP_true(:, 1));
dprime_BOTH_true = norminv(ROC_BOTH_true(:, 2)) - norminv(ROC_BOTH_true(:, 1));

% Get d' differences
dprime_HP_minus_AP_true = dprime_HP_true - dprime_AP_true;
dprime_BOTH_minus_HP_true = dprime_BOTH_true - dprime_HP_true;
dprime_BOTH_minus_AP_true = dprime_BOTH_true - dprime_AP_true;

%% Plot ROC
figure(2); clf;

subplot(3,2,[1 2 3 4]);
hold on;
set(0,'DefaultLegendAutoUpdate','off')
plot(ROC_HP_true(:, 1), ROC_HP_true(:, 2), 'o-','LineWidth', 3,'Color',colourmap(1,:));
plot(ROC_AP_true(:, 1), ROC_AP_true(:, 2), 'o-', 'LineWidth', 3,'Color',colourmap(3,:));
plot(ROC_BOTH_true(:, 1), ROC_BOTH_true(:, 2), 'o-', 'LineWidth', 3,'Color',colourmap(5,:));

% add labels for each threshold  adding a small number 6, 5, 4, 3 next to each circle
% from left to right – excluding the points at origin and (1,1).
% This will need to be done for each of the three curves).

labeltxt = {'3','4','5','6'};
x = ROC_BOTH_true(:, 1);
y = ROC_BOTH_true(:, 2);

text(x(1+1),y(1+1)+0.025,labeltxt{1},'Color',[0 0 0],'FontSize',15);
for i = 2:4
    text(x(i+1)-0.03,y(i+1)+0.06,labeltxt{i},'Color',[0 0 0],'FontSize',15);
end

x = ROC_HP_true(:, 1);
y = ROC_HP_true(:, 2);
for i = 1:4
    text(x(i+1),y(i+1)+0.04,labeltxt{i},'Color',colourmap(1,:),'FontSize',15);
end

x = ROC_AP_true(:, 1);
y = ROC_AP_true(:, 2);
for i = 1:4
    text(x(i+1),y(i+1)-0.025,labeltxt{i},'Color',colourmap(3,:),'FontSize',15);
end

hold off;
% legend({'Huggins-Pitch','Anti-Phase','Both'},'Location','East','Box','Off','FontSize',15)
legend({'HP','AP','Both'},'Location','East','Box','Off','FontSize',18)
line([0 1],[0 1],'LineStyle','--','Color','k', 'LineWidth', 1.5);

set(gcf, 'Color', 'w')
xlabel('Speakers pass rate')
ylabel('Headphones pass rate')
box('off')
grid('on')
set(gca,'XTick',0:.2:1)
set(gca,'YTick',0:.2:1)
xlim([0 1]);
ylim([0 1]);
axis square
set(gca,'FontSize',14);
set(gca,'LineWidth',1.5)
set(gca, 'FontName', 'Arial')

%% Plot d prime
% Compute the errorbar (bootstrap) for d' data
dataOrig = xlsread('Data\keyResult.xlsx');
passRate=[6,5,4,3];

B=10000; %number of iterations
[NS,t]=size(dataOrig);
p=repmat(1:NS,B,1);
p=p(reshape(randperm(B*NS),B,NS));
dHP=[];
dMD=[];
dBOTH=[];
erHP=[];
erMD=[];
erBOTH=[];

for i=1:length(passRate)
    
    for b=1:B
        data = dataOrig(p(b,:),:);        
        
        HPHp=find(round(data(:,1))>=round(passRate(i)));
        HPSp=find(round(data(:,2))>=round(passRate(i)));
        hit=length(HPHp)/length(dataOrig);
        fp=length(HPSp)/length(dataOrig);
        if (hit== 1)
            hit=0.999;
        end
        if (fp==0)
            fp=0.001;
        end
        dprimeHP=norminv(hit)-norminv(fp);
                
        MDHp=find(round(data(:,3))>=round(passRate(i)));
        MDSp=find(round(data(:,4))>=round(passRate(i)));
        hit=length(MDHp)/length(dataOrig);
        fp=length(MDSp)/length(dataOrig);
        if (hit== 1)
            hit=0.999;
        end
        if (fp==0)
            fp=0.001;
        end
        dprimeMD=norminv(hit)-norminv(fp);
        
        
        
        BOTHHp=find(round(data(:,1))>=round(passRate(i)) & round(data(:,3))>=round(passRate(i)));
        BOTHSp=find(round(data(:,2))>=round(passRate(i)) & round(data(:,4))>=round(passRate(i)));
        hit=length(BOTHHp)/length(dataOrig);
        fp=length(BOTHSp)/length(dataOrig);
        if (hit== 1)
            hit=0.999;
        end
        if (fp==0)
            fp=0.001;
        end
        dprimeBOTH=norminv(hit)-norminv(fp);
        
        dHP=[dHP  dprimeHP];
        dMD=[dMD dprimeMD];
        dBOTH=[dBOTH dprimeBOTH];
    end
    erHP=[erHP std(dHP)];  % error bar for HP
    erMD=[erMD std(dMD)];  % error bar for MD
    erBOTH=[erBOTH std(dBOTH)]; % error bar for BOTH
end

% plot d prime with error bar (1 std, bootstrap with 10000 iterations
subplot(3,2,[5 6]);

threshold = [6 5 4 3];
bar_x = 1:4;

hold on;

bar(bar_x-0.2, dprime_HP_true(threshold-1)', 0.2,'EdgeColor','none','FaceColor',colourmap(1,:));
bar(bar_x, dprime_AP_true(threshold-1)',0.2,'EdgeColor','none','FaceColor',colourmap(3,:));
bar(bar_x+0.2, dprime_BOTH_true(threshold-1)', 0.2,'EdgeColor','none','FaceColor',colourmap(5,:));

errorbar(bar_x-0.2,dprime_HP_true(threshold-1)',erHP,'LineStyle','none','CapSize',5,'Color','k','LineWidth',1.5);
errorbar(bar_x,dprime_AP_true(threshold-1)',erMD,'LineStyle','none','CapSize',5,'Color','k','LineWidth',1.5);
errorbar(bar_x+0.2,dprime_BOTH_true(threshold-1)',erBOTH,'LineStyle','none','CapSize',5,'Color','k','LineWidth',1.5);

hold off;

xticks(sort(bar_x));% stupid MATLAB says Value must be a vector of type single or double whose values increase.
xticklabels(threshold);


% set(gca,'XTickLabel',{'6', '5', '4', '3'})
% legend({'HP','AP','Both'},'Location','NorthEast','Box','Off','FontSize',18)
set(gcf, 'Color', 'w')
xlabel('Threshold')
ylabel('Sensitivity to equipment (d’)')
box('off')
% axis square;
set(gca,'FontSize',14);
set(gca,'LineWidth',1.5);
set(gca, 'FontName', 'Arial');

% Show results of true calculation
fprintf('\nTrue AUC values and difference (HP, AP, BOTH, HP-AP, BOTH-HP, BOTH-AP):\n')
[AUC_HP_true, AUC_AP_true, AUC_BOTH_true, AUC_HP_minus_AP_true, AUC_BOTH_minus_HP_true, AUC_BOTH_minus_AP_true]
fprintf('\nTrue d prime values and difference (rows are thresholds 3/6, 4/6, 5/6, 6/6; columns are HP, AP, BOTH, HP-AP, BOTH-HP, BOTH-AP):\n')
[dprime_HP_true(2:5), dprime_AP_true(2:5), dprime_BOTH_true(2:5), dprime_HP_minus_AP_true(2:5), dprime_BOTH_minus_HP_true(2:5), dprime_BOTH_minus_AP_true(2:5)]

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 6 10]);
% print('Figure/fig02_Expt1_ROC_dPrime_passRate','-dpng');
saveas(gcf,'Figure/fig04a_Expt1_ROC_dPrime.svg');
saveas(gcf,'Figure/fig04a_Expt1_ROC_dPrime.png');

%% plot of speaker performance by threshold
figure(3);clf;
threshold = [6 5 4 3];
bar_x = 1:4;

subplot(2,1,1);
HP_pass=[];
AP_pass=[];
Both_pass=[];

for i=1:length(threshold)
    
    HP = length(find(data(:,2)>=threshold(i)));
    AP = length(find(data(:,4)>=threshold(i)));
    either = length(find(data(:,2)>=threshold(i) | data(:,4)>=threshold(i)));
    both = length(find(data(:,2)>=threshold(i) & data(:,4)>=threshold(i)));
    HP_pass = [HP_pass 100*HP/either];
    AP_pass = [AP_pass 100*AP/either];
    Both_pass = [Both_pass 100*both/either];

end

hold on;
bar(bar_x-0.2, HP_pass, 0.2,'EdgeColor','none','FaceColor',colourmap(2,:));
bar(bar_x, AP_pass,0.2,'EdgeColor','none','FaceColor',colourmap(4,:));
bar(bar_x+0.2, Both_pass, 0.2,'EdgeColor','none','FaceColor',colourmap(5,:));
hold off;

xticks(sort(bar_x));% stupid MATLAB says Value must be a vector of type single or double whose values increase.
xticklabels(threshold);

xlim([0.5 4.5]);
ylim([0 100]);

xlabel("Threshold")
ylabel({'% participants who passed','at least one speaker test'})
legend({'Passed HP speaker', 'Passed AP speaker', 'Passed both'},'Location','northoutside','Box','Off','FontSize',14);
% legend({'Passed HP speaker','Passed AP speaker', 'Passed both'},'Location','northwest','Box','Off','FontSize',17);
axis square;
set(gca,'FontSize',14);
set(gca,'LineWidth',1.5);
set(gca, 'FontName', 'Arial');

%% plot of headphone performance by threshold
subplot(2,1,2);
HP_pass=[];
AP_pass=[];
Both_pass=[];

for (i=1:length(threshold))
    
    HP = length(find(data(:,1)>=threshold(i)));
    AP = length(find(data(:,3)>=threshold(i)));
    either = length(find(data(:,1)>=threshold(i) | data(:,3)>=threshold(i)));
    both = length(find(data(:,1)>=threshold(i) & data(:,3)>=threshold(i)));
    HP_pass = [HP_pass 100*HP/either];
    AP_pass = [AP_pass 100*AP/either];
    Both_pass = [Both_pass 100*both/either];

end

hold on;
bar(bar_x-0.2, HP_pass, 0.2,'EdgeColor','none','FaceColor',colourmap(1,:));
bar(bar_x, AP_pass,0.2,'EdgeColor','none','FaceColor',colourmap(3,:));
bar(bar_x+0.2, Both_pass, 0.2,'EdgeColor','none','FaceColor',colourmap(5,:));
hold off;

xticks(sort(bar_x));% stupid MATLAB says Value must be a vector of type single or double whose values increase.
xticklabels(threshold);

xlim([0.5 4.5]);
ylim([0 100]);

xlabel("Threshold")
ylabel({'% participants who passed','at least one headphone test'})
% legend({'Passed HP headphone','Passed AP headphone','Passed both'},'Location','northwest','Box','Off','FontSize',17)
legend({'Passed HP headphone', 'Passed AP headphone', 'Passed both'},'Location','northoutside','Box','Off','FontSize',14)
axis square;
set(gca,'FontSize',14);
set(gca,'LineWidth',1.5);
set(gca, 'FontName', 'Arial');

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 5 10]);
% print('Figure/fig02_Expt1_ROC_dPrime_passRate','-dpng');
saveas(gcf,'Figure/fig04b_Expt1_passRate.svg');
saveas(gcf,'Figure/fig04b_Expt1_passRate.png');

%% Permutation testing
% Set different pass rates
passRate = [0, 3/6, 4/6, 5/6, 1] * 100; % Running for threshold >chance (note 0 has to stay in there!)

% Set number of permutations
B = 1000000; % On AB computer, 10000 takes ~5s, 100000 takes ~40s, 1000000 takes ~420s (have used 1000000 in paper draft)

% Initialise permutations
% Randomly assing within a subject, forcing headphone scores to remain as
% headphone scores, and speaker scores to remain as speaker scores
r = nan(NS*4, B); % Indices into list of scores - WITHIN

% Each column is an allowed set of labels, where 1=HP headphones, 2=HP
% speakers, 3=AP headphones, 4=AP speakers (this fixes headphone scores as
% headphone scores, and speaker scores as speaker scores, but randomly
% permutes HP and AP within each of these)
allowedLabels = [1, 1, 3, 3;
    2, 4, 2, 4;
    3, 3, 1, 1;
    4, 2, 4, 2];

AUC_HP_minus_AP = nan(B, 1); % Initialise AUC difference each permutation

dprime_HP = nan(length(passRate) + 1, B);
dprime_AP = nan(length(passRate) + 1, B);
dprime_BOTH = nan(length(passRate) + 1, B);

% Permutations
for b = 1:B % Loop over permutations
    for s = 1:NS % Loop over subjects
        r((s-1)*4 + (1:4), b) = (s-1)*4 + allowedLabels(:, randi(4)); % Get permuted scores
    end
    data = reshape(dataTransposed(r(:, b)), 4, NS);
    ROC_HP = zeros(length(passRate) + 1, 2);
    ROC_AP = zeros(length(passRate) + 1, 2);
    ROC_BOTH = zeros(length(passRate) + 1, 2);
    for i = 1:length(passRate)
        ROC_HP(i, 1) = sum(round(data(2, :)) >= round(passRate(i))) / NS; % Proportion subjects passing HP speaker test
        ROC_HP(i, 2) = sum(round(data(1, :)) >= round(passRate(i))) / NS; % Proportion subjects passing HP headphone test
        ROC_AP(i, 1) = sum(round(data(4, :)) >= round(passRate(i))) / NS; % Proportion subjects passing AP speaker test
        ROC_AP(i, 2) = sum(round(data(3, :)) >= round(passRate(i))) / NS; % Proportion subjects passing AP headphone test
        ROC_BOTH(i, 1) = sum(round(data(2, :)) >= round(passRate(i)) & round(data(4, :)) >= round(passRate(i))) / NS;
        ROC_BOTH(i, 2) = sum(round(data(1, :)) >= round(passRate(i)) & round(data(3, :)) >= round(passRate(i))) / NS;
    end
    
    % Calculate AUC
    dist = abs(diff(ROC_HP(:, 1))); %Distances between points along x-axis (i.e. between speaker test pass proportions)
    AUC_HP = sum(.5*dist.*ROC_HP(1:length(passRate), 2)) + sum(.5*dist.*ROC_HP(2:end, 2)); %Calculates true area under curve using trapeziums
    % AUC_HP = sum(dist.*ROC_HP(2:end,2)); %Conservative approach that sets far left of ROC curve to zero
    dist = abs(diff(ROC_AP(:, 1))); %Distances between points along x-axis (i.e. between speaker test pass proportions)
    AUC_AP = sum(.5*dist.*ROC_AP(1:length(passRate), 2)) + sum(.5*dist.*ROC_AP(2:end, 2)); %Calculates true area under curve using trapeziums
    % AUC_AP = sum(dist.*ROC_AP(2:end,2)); %Conservative approach that sets far left of ROC curve to zero
    dist = abs(diff(ROC_BOTH_true(:, 1))); % Distances between points along x-axis (i.e. between speaker test pass proportions)
    AUC_BOTH = .5*sum(dist.*(ROC_BOTH(1:length(passRate), 2) + ROC_BOTH(2:end, 2))); %Calculates true area under curve using trapeziumstrapezium
    %AUC_BOTH = sum(dist.*ROC_BOTH(2:end,2)); %Conservative approach that sets far left of ROC curve to zero
    
    % Calculate difference
    AUC_HP_minus_AP(b, 1) = AUC_HP - AUC_AP;
    AUC_BOTH_minus_HP(b, 1) = AUC_BOTH - AUC_HP;
    AUC_BOTH_minus_AP(b, 1) = AUC_BOTH - AUC_AP;
    
    % Do d' at each threshold
    dprime_HP(:, b) = norminv(ROC_HP(:, 2)) - norminv(ROC_HP(:, 1));
    dprime_AP(:, b) = norminv(ROC_AP(:, 2)) - norminv(ROC_AP(:, 1));
    dprime_BOTH(:, b) = norminv(ROC_BOTH(:, 2)) - norminv(ROC_BOTH(:, 1));
    
end

% Get d prime differences
dprime_HP_minus_AP = dprime_HP - dprime_AP;
dprime_BOTH_minus_HP = dprime_BOTH - dprime_HP;
dprime_BOTH_minus_AP = dprime_BOTH - dprime_AP;

% d prime tests
dprime_HP_minus_AP_TestResults = sum(dprime_HP_minus_AP>repmat(dprime_HP_minus_AP_true,1,B),2)/B;
dprime_BOTH_minus_HP_TestResults = sum(dprime_BOTH_minus_HP>repmat(dprime_BOTH_minus_HP_true,1,B),2)/B;
dprime_BOTH_minus_AP_TestResults = sum(dprime_BOTH_minus_AP>repmat(dprime_BOTH_minus_AP_true,1,B),2)/B;

% Show results
fprintf('\nProportion of permutations that beat observed AUC differences (HP-AP, BOTH-HP, BOTH-AP):\n')
[sum(AUC_HP_minus_AP_true<AUC_HP_minus_AP)/B sum(AUC_BOTH_minus_HP_true<AUC_BOTH_minus_HP)/B sum(AUC_BOTH_minus_AP_true<AUC_BOTH_minus_AP)/B]%Proportion of permutations that beat observed AUC difference
fprintf('\nProportion of permutations that beat observed d prime difference for 3/6, 4/6, 5/6, 6/6 thresholds:\n')
[dprime_HP_minus_AP_TestResults(2:5) dprime_BOTH_minus_HP_TestResults(2:5) dprime_BOTH_minus_AP_TestResults(2:5)]