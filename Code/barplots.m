

%%%%%% 1st example scenario
%%
%%% Poisson
% delay_values = [[62.1728    7.0324    5.2994    5.3819     69.5307   10.6364    8.6090    8.3071        262.2875   24.2355   19.2020   16.2128]
%                 [2.6263    2.0959    2.4483    2.5101      4.0844    3.6312    4.0791    3.8271         8.1045    8.5317    9.4104    7.4241]];

%%% Bursty
delay_values = [[6.5903    6.4550    5.1037    5.1857       15.5849   17.1410   14.4143   14.1023       60.7909   47.4644   41.8858   34.1742]
                [0.8956    1.0205    1.2986    1.3569       2.4716    2.3364    3.5631    3.8627        6.7790    6.4405   10.7416   10.3309]];
    
yvalues = sprintfc('%.2f',delay_values(1,:));
linestyle = {'-', ':'};
linewidth = [1.5, 1.5];

figure('pos', [400,400,700,400])

A = [1 2 3 4  6 7 8 9  11 12 13 14];
for i = 1:2
    b = bar(A, delay_values(i,:));
    b.LineStyle = linestyle(i);
    b.LineWidth = linewidth(i);
     
    if i == 1 
        b.FaceColor = 'flat';
        b.CData(1,:) = [0.7020    0.5059    0.5059];
        b.CData(2,:) = [0.5059    0.6235    0.7020];
        b.CData(3,:) = [0.3686    0.2745    0.2745];
        b.CData(4,:) = [0.7020    0.6980    0.5059];
        b.CData(5,:) = [0.7020    0.5059    0.5059];
        b.CData(6,:) = [0.5059    0.6235    0.7020];
        b.CData(7,:) = [0.3686    0.2745    0.2745];
        b.CData(8,:) = [0.7020    0.6980    0.5059];
        b.CData(9,:) = [0.7020    0.5059    0.5059];
        b.CData(10,:) = [0.5059    0.6235    0.7020];
        b.CData(11,:) = [0.3686    0.2745    0.2745];
        b.CData(12,:) = [0.7020    0.6980    0.5059];

        title('', 'interpreter','latex', 'FontSize', 14);
        xticks([1 2 2.5 3 4 5 6 7 7.5 8 9 10 11 12 12.5 13 14]);
        xticklabels({[] [] 'low' [] [] [] [] [] 'medium' [] [] [] [] [] 'high' [] []});
        xtickangle(0);
        xlabel('Traffic load', 'interpreter','latex', 'FontSize', 16)

        % ylim([0 100]);
        % yticks(0:20:100);
        ylabel('$99^{}\%$-tile of Packet Delay [ms]', 'interpreter','latex', 'FontSize', 16)
        ax = gca;
        ax.XAxis.LineWidth = 1.5;
        ax.YAxis.LineWidth = 1.5;
        set(gca, 'TickLabelInterpreter','latex', 'FontSize', 14);
        grid on
        hold on
        text(A,delay_values(1,:),yvalues,'vert','bottom','horiz','center', 'interpreter','latex', 'FontSize', 10);
        box off

        % names = {'DCF' 'C-SR, NumPk' 'C-SR, OldPk', 'C-SR, Weighted'};
        % legend(b.YEndPoints, names, 'Interpreter','latex', 'location', 'northwest', 'FontSize', 14);
    else
        b.FaceColor = 'none';   
    end



end

%%

clear all
%%%%%% 1st example scenario
% B = [[11.7399, 10.8998, 5.6802, 5.1610, 16.6615, 16.0395, 8.1967, 7.4913];
%     [5.6294, 5.6939, 2.1198, 2.3176, 8.4348, 8.4772, 3.0782, 3.3800]];

delay_values = [[11.5296, 10.7682, 5.6776, 5.5146, 16.1591, 15.6787, 7.4981, 7.3679];
    [5.5094, 5.6133, 2.7059, 2.7297, 8.1643, 8.2960, 3.7305, 3.8201]];

yvalues = sprintfc('%.2f',delay_values(1,:));
linestyle = {'-', ':'};
linewidth = [1.5, 1.5];
figure

A = [1 2 3 4  6 7 8 9];
for i = 1:2
    b = bar(A, delay_values(i,:));
    b.LineStyle = linestyle(i);
    b.LineWidth = linewidth(i);

    if i == 1
        b.FaceColor = 'flat';
        b.CData(1,:) = [0.07,0.23,0.19];
        b.CData(2,:) = [0.02,0.48,0.36];
        b.CData(3,:) = [0.95,0.42,0.25];
        b.CData(4,:) = [0.7 0.7 .5];
        b.CData(5,:) = [0.07,0.23,0.19];
        b.CData(6,:) = [0.02,0.48,0.36];
        b.CData(7,:) = [0.95,0.42,0.25];
        b.CData(8,:) = [0.7 0.7 .5];
        
        title('', 'interpreter','latex', 'FontSize', 14);
        xticks([1 2 2.5 3 4 5 6 7 7.5 8 9]);
        xticklabels({[] [] 'medium' [] [] [] [] [] 'high' [] []});
        xtickangle(0);
        xlabel('Traffic load', 'interpreter','latex', 'FontSize', 16)
        ylim([0 25]);
        yticks(0:5:25);
        ylabel('$99^{}\%$-tile of Packet Delay [ms]', 'interpreter','latex', 'FontSize', 16)
        ax = gca;
        ax.XAxis.LineWidth = 1.5;
        ax.YAxis.LineWidth = 1.5;
        set(gca, 'TickLabelInterpreter','latex', 'FontSize', 14);
        grid on
        hold on
        text(A,delay_values(1,:),yvalues,'vert','bottom','horiz','center'); 
        box off
    else 
        b.FaceColor = 'none';
    end
end



%%
%%%%%% legend
% B = [11.7399 10.8998 5.6802];
% 
% colordatabase = [[0.7020,0.5059,0.5059];
%     [0.5059,0.6157,0.7020];
%     [0.7 0.7 .5]];
% names = {'DCF' 'C-SR, Rnd' 'C-SR, OldPk' '50$^{th}$-percentile'};



delay_values = [11.7399 10.8998 5.6802 5.1610];

colordatabase = [[0.07,0.23,0.19];
    [0.02,0.48,0.36];
    [0.95,0.42,0.25];
    [0.7 0.7 .5]];
names = {'ST, NumPk' 'ST, OldPk' 'C-SR, NumPk' 'C-SR, OldPk' '50$^{th}$-percentile'};    


figure
for i=1:length(delay_values)
    b = bar(1,delay_values(i));
    b.FaceColor = 'flat';
    b.CData(1,:) = colordatabase(i,:);
    hold on
end
ylim([0 50]);
plot(1,5,':', 'Color','k');
legend(names, 'Interpreter','latex', 'location', 'north', 'Orientation', 'vertical'  , 'FontSize', 14);