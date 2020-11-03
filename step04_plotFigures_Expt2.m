clear; close all;

define_colours;

% Count of trusted subjects scoring 0-6 (columns) for
% HP headphones, HP speakers, AP headphones, AP speakers (rows)
trusted = [...
    1 4 3 2 5 4 81;
    4 17 24 19 6 10 20;
    3 2 3 3 3 16 70;
    15 15 5 13 10 11 31];

% Count of online subjects scoring 0-6 (columns) for HP, AP (rows)
online = [...
    3 8 15 8 5 9 52;
    11 0 5 6 5 12 61];

ssq = nan(1, 101);

% Loop over proportions
for pCount = 1:101
    
    % Proportions increment by .01 from 0 to 1
    p = (pCount - 1) * .01;
    
    % Combine the trusted headphone and speaker Performance out of 6s using proportion p
    % and (1-p) respectively, first for HP (top row) then AP (bottom row)
    modelled = [...
        p * trusted(1, :) + (1-p) * trusted(2, :);
        p * trusted(3, :) + (1-p) * trusted(4, :)];
    
    % Get the sum of squared differences between the observed and modelled
    % online Performance out of 6s.
    ssq(pCount) = sum(sum((online - modelled) .^2));
    
    ssqHP(pCount) = sum(sum((online(1, :) - modelled(1, :)) .^2));
    ssqAP(pCount) = sum(sum((online(2, :) - modelled(2, :)) .^2));
    
end

% Find the pCount that gives the minimum sum of squares and convert it to
% its corresponding p
[a, b] = min(ssq);
bestP = (b - 1) * .01;
bestError = a;
bestModelled = [...
    bestP * trusted(1, :) + (1 - bestP) * trusted(2, :);
    bestP * trusted(3, :) + (1 - bestP) * trusted(4, :)];

% Find the pCount that gives the minimum sum of squares for HP only
% and convert it to its corresponding p
[aHP, bHP] = min(ssqHP);
bestPHP = (bHP - 1) * .01;
bestErrorHP = aHP;
bestModelledHP = bestPHP * trusted(1, :) + (1 - bestPHP) * trusted(2, :);

% Find the pCount that gives the minimum sum of squares for AP only
% and convert it to its corresponding p
[aAP, bAP] = min(ssqAP);
bestPAP = (bAP - 1) * .01;
bestErrorAP = aAP;
bestModelledAP = bestPAP * trusted(3, :) + (1 - bestPAP) * trusted(4, :);

% Plot observed and modelled distributions for bestP, and ssq as function
% of p - separately for combined and HP/AP-specific models
figure(1); clf;

subplot(1,2,1);
hold on;

x = 0:6;
data = [0.6*trusted(1, :);0.4*trusted(2, :)];
h = bar(x,data,'stacked','FaceAlpha',0.6);
set(h,{'FaceColor'},{colourmap(1,:);colourmap(2,:)});

myline = 0.6*trusted(1, :)+0.4*trusted(2, :);
plot(0:6, myline, 'LineWidth', 3, 'Color', [1 0 0]);

grayline = online(1,:);
plot(0:6, grayline, 'LineWidth', 3, 'Color', [0 0 0]);

legend({'Trusted group: headphones x 0.6';'Trusted group: speakers x 0.4'; 'Trusted group: modelled';'Unknown group'}, 'Box', 'Off', 'Location', 'NorthEast',...
    'FontSize',10);
set(gca, 'XDir','reverse');
xticks(x);
xlabel('Performance out of 6')
ylabel('% participants')
ylim([0 70])
xlim([-0.5 6.5]);
% title(sprintf('HP (combined model, prop=%.2f)', bestP), 'Color', [0 .447 .741])

title('HP');

axis square;
set(gca,'FontSize',14);
set(gca,'LineWidth',1.5);
set(gca, 'FontName', 'Arial');


subplot(1,2,2);
hold on;
x = 0:6;
data = [0.6*trusted(3, :);0.4*trusted(4, :)];
h = bar(x,data,'stacked','FaceAlpha',0.6);
set(h,{'FaceColor'},{colourmap(3,:);colourmap(4,:)});

myline = 0.6*trusted(3, :)+0.4*trusted(4, :);
plot(0:6, myline, 'LineWidth', 3, 'Color', [0 0 1]);

grayline = online(2,:);
plot(0:6, grayline, 'LineWidth', 3, 'Color', [0 0 0]);

legend({'Trusted group: headphones x 0.6';'Trusted group: speakers x 0.4'; 'Trusted group: modelled';'Unknown group'}, 'Box', 'Off', 'Location', 'NorthEast',...
    'FontSize',10);
set(gca, 'XDir','reverse');
xlabel('Performance out of 6')
ylabel('% participants')

title('AP');

ylim([0 70])
xlim([-0.5 6.5]);
xticks(x);

axis square;
set(gca,'FontSize',14);
set(gca,'LineWidth',1.5);
set(gca, 'FontName', 'Arial');

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 10 5]);
saveas(gcf,'Figure/fig05_Expt1&2_compare.svg');
saveas(gcf,'Figure/fig05_Expt1&2_compare.png');
