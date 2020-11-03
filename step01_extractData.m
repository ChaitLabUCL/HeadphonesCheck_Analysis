
% dbstop if error

%% Analysis output from headphone comparison
% SIJIA ZHAO 2020-06-17
% Editted by AEM 18/6/2020
%1) Now excludes subjects that leave early
%2) Makes additional plots

%Output:
%   Excel sheet:
%     KeyResults = %performance and pass data for all tasks with key
%                   questionnaire information
%   Mat files:
%     results = contains the following structures:
%         info; ID; data; questionnaire; raw


clear; close all; %impotant to make this clear all to prevent issues with xlsread
addpath('Functions');

%% Setting up
% Where is the data and where to save
path_data ='Data\';
path_result = 'Result\'; mkdir(path_result);

file_result = [path_result 'result'];

%Define the name given to the task by Gorilla
info.names.HP_Head = 'task-fhz4';
info.names.HP_Speak = 'task-eczr';
info.names.MD_Head = 'task-8co7';
info.names.MD_Speak = 'task-jkry';
info.names.EarlyExit = 'task-rqb9';
info.names.Debrief = 'questionnaire-jx57';
info.names.Consent = 'questionnaire-zbt5';

%Set up so we can walk through the main tasks we are interested in
taskList = {'HP_headphone','HP_speaker','MD_headphone','MD_speaker'};
taskHeader = {info.names.HP_Head;info.names.HP_Speak;info.names.MD_Head;info.names.MD_Speak}; %work through the four tasks

% Define the name given to each question by Gorilla
info.quest.age = 'response-3';
info.quest.headphone_type = 'response-2';
info.quest.noise_cancel = 'response-5';
info.quest.headphone_quality = 'response-4';
info.quest.headphone_brand = 'response-14';
info.quest.speaker_type = 'response-6';
info.quest.soundcard = 'response-7';
info.quest.background_noise = 'response-8';
info.quest.instructions = 'response-9';
info.quest.commments = 'response-10';

% Queastion responses to recode
recode_vars =[{'age'}; {'headphone_type'}; {'noise_cancel'}; {'headphone_quality'}; {'speaker_type'}]; %Questions with a string answer
likert = [{'background_noise'}; {'instructions'}]; %Likert scales

% Question response options
age = {'18-25','25-35','35-45','45-55','55-65','>65?'};
headphone_type = {'On/over ear wired', 'On/over ear wireless', 'In ear wired', 'In ear wireless'};
noise_cancel = {'yes','no'};
headphone_quality = {'Cheap', 'Mid-range', 'High performance'};
speaker_type = {'In built speaker', 'Standard external computer speaker', 'High performance speaker'};

%version - you usually would probably just analyse one version. If there are multiple versions it will combine into one and resave.
version = [1,2,5];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extract the raw data from gorilla excel files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
consent_ID = [];
exit_ID = [];
ID = [];
OS =[];
browser = [];
Q = [];
R = [];
D_ID =[];
for v = 1:numel(version)
    
    % (1) Consent form
    filename = [path_data 'data_exp_19821-v' num2str(version(v)) '\data_exp_19821-v' num2str(version(v)) '_' info.names.Consent '.xlsx'];
    T = readtable(filename);
    consent_ID = [consent_ID; T.('ParticipantPrivateID')];
    
    %2) Early Exit
    filename = [path_data 'data_exp_19821-v' num2str(version(v)) '\data_exp_19821-v' num2str(version(v)) '_' info.names.EarlyExit '.xlsx'];
    T = readtable(filename);
    exit_ID = [exit_ID; T.('ParticipantPrivateID')];
    
    %3) Debrief
    filename = [path_data 'data_exp_19821-v' num2str(version(v)) '\data_exp_19821-v' num2str(version(v)) '_' info.names.Debrief '.xlsx'];
    T = readtable(filename);
    
    D_ID = [ID; T.('ParticipantPrivateID')];
    Q = [Q; T.('QuestionKey')];
    R = [R; T.('Response')];
    
    %General Information
    ID = [ID; T.('ParticipantPrivateID')];
    OS = [OS; T.('ParticipantOS')];
    browser = [browser; T.('ParticipantBrowser')];
end

consent_ID = rNan(unique(consent_ID));
fprintf('Total number of subjects = %d\n',numel(consent_ID));

exit_ID = rNan(unique(exit_ID));
fprintf('Number of early exit = %d\n',numel(exit_ID));

debrief = table(D_ID,OS,browser,Q,R);

for t = 1:length(taskList)
    ID = [];
    eventInfo = [];
    response = [];
    for v = 1:numel(version)
        filename = [path_data 'data_exp_19821-v' num2str(version(v)) '\data_exp_19821-v' num2str(version(v)) '_' taskHeader{t} '.xlsx'];
        T = readtable(filename);
        
        ID = [ID; T.('ParticipantPrivateID')];
        eventInfo = [eventInfo; T.('ZoneType')]; % 'response_button_text' is the actual button
        response = [response; T.('Correct')]; % 1 means correct, 0 means incorrect
    end
    main.(taskList{t}) = table(ID,eventInfo,response);
end


%% Extract the key information from the tasks
task = {};
taskID = [];
subject = [];
correct = [];

for t = 1:length(taskList) %This will scroll through the tasks
    fprintf('Extracting data for %s...\n',taskList{t});
    
    ID = main.(taskList{t}).ID;
    eventInfo = main.(taskList{t}).eventInfo;
    response = main.(taskList{t}).response;
    
    sublist_n =[]; %remake sublist exlcuding exitIDs
    sublist = unique(rNan(ID));
    for s = 1:numel(sublist)
        if (find(exit_ID==sublist(s)) >0); continue; end %If the ID is in the Exit Early group don't use it.
        idx = find(ID ==sublist(s));
        res = response(idx);
        task = [task; taskList{t}];
        taskID = [taskID; t];
        subject = [subject; sublist(s)];
        correct = [correct; sum(res)];
        sublist_n = [sublist_n,sublist(s)];
    end
end

sublist = sublist_n; %replace sublist with sublist-exit_IDs

%% Questionnaire output - saves to structure quest
question = fields(info.quest);
for q = 1: numel(question)
    for s = 1:numel(sublist)
        thisQ = info.quest.(question{q});
        s_idx = find(D_ID ==sublist(s));%Sub ID
        q_idx = find(strcmp(Q,thisQ));%quesiton ID
        r_idx = intersect(s_idx,q_idx); %where they interect
        quest.(question{q}){s} = R(r_idx);
    end
end

%Convert strings to a scale
for r = 1: numel(recode_vars) %for each variable we want to recode
    Var = recode_vars{r};
    for i = 1: length(quest.(Var)) %For the number of labels in that variabel
        Resp =quest.(Var){i};
        if strcmp(Resp, 'Other (please specify)')
            tmp(i)= nan;continue;
        end
        tmp(i) = find(strcmp(eval(Var),Resp));
    end
    clear quest.(Var)
    quest.(Var) = tmp;
    key.(Var) = eval(Var);
end

%Convert Likert scales to matrix
for l = 1: numel(likert)
    Var = quest.(likert{l});
    tmp1 =[];
    tmp2 =[];
    
    for v = 1: numel(Var)
        tmp1 = cell2mat(Var{v});
        tmp2(v) = str2num(tmp1);
    end
    
    clear quest.(likert{l})
    quest.(likert{l}) = tmp2;
end

%Finally calculate pass rate: i
passRate = zeros(numel(correct),1);%create array pass rates
passRate(correct>5,1) =1;
results(:,4) = passRate;
result(:,5) = repelem(sublist,numel(taskList));

clear raw ID data questionnaire

%Organise for output file:
questionnaire = quest;
ID.consent = consent_ID;
ID.exit = exit_ID;
ID.task = sublist; %Excludes exit list.
raw = main;
raw.debrief = debrief;
info.taskList = taskList;
info.key = key;
info.sublist = sublist;
data.subject = subject;
data.correct = correct;
data.passRate = passRate;

%save these variables
save(file_result,'questionnaire','ID','raw','info','data');
fprintf('... Key data has been extracted: %s\n',[path_result filename]);

%reshape for table
data.correct = reshape(correct,numel(sublist),numel(taskList));
data.passRate = reshape(passRate,numel(sublist),numel(taskList));
makeTable(data,path_result,quest)

