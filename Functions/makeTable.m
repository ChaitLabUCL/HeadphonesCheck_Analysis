function makeTable(data,path_result,quest)
%Create a table with the key info: 
HP_Headphone = data.correct(:,1);
HP_Speakers = data.correct(:,2);
MD_Headphone = data.correct(:,3); 
MD_Speakers = data.correct(:,4);
HP_H_Pass = data.passRate(:,1); 
HP_S_Pass = data.passRate(:,2); 
MD_H_Pass = data.passRate(:,3); 
MD_S_Pass = data.passRate(:,4); 
Age = quest.age'; 
Headphone_type = quest.headphone_type';
Headphone_quality = quest.headphone_quality';
Speaker_type = quest.speaker_type';
Background_noise = quest.background_noise'; 


result = table(HP_Headphone,HP_Speakers,MD_Headphone,MD_Speakers,HP_H_Pass,HP_S_Pass,MD_H_Pass,MD_S_Pass,Age,Headphone_type,Headphone_quality,Speaker_type,Background_noise);
filename = 'keyResult.xlsx'; 
writetable(result,[path_result filename]);