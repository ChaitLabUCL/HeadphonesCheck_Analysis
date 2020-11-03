clear; close all; %impotant to make this clear all to prevent issues with xlsread
addpath(genpath('Functions'));

% Step2_plotData
loadFiles = 1;

if loadFiles ==1
    %if you want to load just for this.
    clc; clear; close all;
    path_result = 'Result\';
    filename = 'result';
    load([path_result,filename])
    
    %Get varables you need for this
    correct = data.correct;
    passRate = data.passRate;
    subject = data.subject;
    taskList = info.taskList;
    taskID = ID.task;
    age = questionnaire.age;
    sublist = info.sublist;
end

% %create place to save figures
% path_figure = 'Figure\'; mkdir(path_figure);


%% 1) Some basic analysis starts here!
nTrial = 6;

% 1)Distribution of scores for each task
S ={};
figure(1);clf;
for t = 1:numel(taskList)
    idx = find(taskID == t);
    S{t} = subject(idx);
    
    subplot(2,2,t);
    histogram(correct(idx));
    title(sprintf('%s (n=%d)',strrep(taskList{t},'_',' '),numel(subject(idx))));
    ylim([0,50]);
    ylabel('# of subject');
    xlabel('# of correct');
end

% saveas(gcf,[path_figure 'fig1_distribution.png']);

%2) Distribution of ages
ageLabel = info.key.age;
figure(2);clf;
histogram(age);
xticks([1:length(ageLabel)])
xticklabels(ageLabel);
title(sprintf('All Ages(n=%d)',length(sublist)))
% saveas(gcf,[path_figure 'fig2_Ages.png']);

%3)Pass rates by age

figure(3);clf;
for t = 1:numel(taskList)
    PR = reshape(passRate,numel(sublist),numel(taskList));
    idx = PR(:,t)==1;
    
    subplot(2,2,t);
    histogram(age(idx));
    title(sprintf('%s Pass',strrep(taskList{t},'_',' ')));
    xticks([1:length(ageLabel)])
    xticklabels(ageLabel);
    ylim([0,20]);
    xlim ([0,length(ageLabel)])
end
% saveas(gcf,[path_figure 'fig3_passByAge.png']);

%4)Fail rates by age
idx_p = find(correct>5);
passRate = zeros(numel(correct),1);%create array pass rates
passRate(idx_p,1) =1;

figure(4);clf;
PR = reshape(passRate,numel(sublist),numel(taskList));
for t = 1:numel(taskList)
    idx = PR(:,t)==0;
    subplot(2,2,t);
    histogram(age(idx));
    title(sprintf('%s Fail',strrep(taskList{t},'_',' ')));
    xticks([1:length(ageLabel)])
    xticklabels(ageLabel);
    ylim([0,20]);
    xlim ([0,length(ageLabel)])
end

% saveas(gcf,[path_figure 'fig4_FailbyAge.png']);
%5) Mean performance
Perc_Correct = correct/6*100;
Perc_Correct = reshape(Perc_Correct,numel(sublist),numel(taskList));
semPerf = sem(Perc_Correct);

figure(5);clf;
subplot(3,1,1);
bar(mean(Perc_Correct), 'c')
hold on
er = errorbar(mean(Perc_Correct) ,semPerf);
er.Color = [0 0 0];
er.LineStyle = 'none';
plotSpread(Perc_Correct)
title('Mean Performance')
xticklabels({'HP head','HP speak','HP head','MD speak'})
ylabel('% correct')
ylim([0,100])

%Median
subplot(3,1,2);
bar(median(Perc_Correct), 'c')
title('Median Performance')
xticklabels({'HP head','HP speak','HP head','MD speak'})
ylabel('% correct')
plotSpread(Perc_Correct)

%pass rate
subplot(3,1,3);
bar(mean(PR)*100, 'c')
hold on
title('Percent pass')
plotSpread(Perc_Correct)
xticklabels({'HP head','HP speak','HP head','MD speak'})
ylabel('% pass (5/6')


% saveas(gcf,[path_figure 'fig5_descriptives.png']);