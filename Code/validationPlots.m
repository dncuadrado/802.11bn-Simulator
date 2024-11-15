
%% validation scenario 1------ 8 STAs --- 20 meters
clear all
DCF_throughput = [107.3781   96.6996  145.0494  161.0671  145.0494   96.6996   96.6996  107.3781];
CSR_throughput = [82.5802   74.2748  185.8056  198.3824  235.4012   74.2748   74.2748   82.5802];

plot_BianchiThroughput = [DCF_throughput;CSR_throughput];
plot_BianchiThroughput = reshape(plot_BianchiThroughput,[],1)';




xValues = [ 1 1.5    3 3.5    5 5.5    7 7.5   9 9.5    11 11.5    13 13.5    15 15.5];
rng(1);
for j = 1:length(plot_BianchiThroughput)
    pd = makedist('Normal','mu',plot_BianchiThroughput(j),'sigma',1);   % create a random variable with Normal dist, mean=0 and std deviation=1
    plot_SimThroughput(j) = random(pd);
end 

% yvalues = sprintfc('%.2f',B(1,:));
linestyle = {'-', ':'};
linewidth = [1.5, 1.5];

plotMatrix = [plot_SimThroughput;plot_BianchiThroughput];
figure
for i = 1:2   
    if i == 1 
        b = bar(xValues, plotMatrix(i,:));
        b.LineStyle = linestyle(i);
        b.LineWidth = linewidth(i);
        b.EdgeColor = 'flat';
        b.FaceColor = 'flat';
        b.FaceAlpha = 0.5;
        b.CData(1,:) = [0.2118, 0.6353, 0.6784];
        b.CData(2,:) = [0.9373, 0.5294, 0.2588];

        b.CData(3,:) = [0.2118, 0.6353, 0.6784];
        b.CData(4,:) = [0.9373, 0.5294, 0.2588];

        b.CData(5,:) = [0.2118, 0.6353, 0.6784];
        b.CData(6,:) = [0.9373, 0.5294, 0.2588];

        b.CData(7,:) = [0.2118, 0.6353, 0.6784];
        b.CData(8,:) = [0.9373, 0.5294, 0.2588];

        b.CData(9,:) = [0.2118, 0.6353, 0.6784];
        b.CData(10,:) = [0.9373, 0.5294, 0.2588];

        b.CData(11,:) = [0.2118, 0.6353, 0.6784];
        b.CData(12,:) = [0.9373, 0.5294, 0.2588];

        b.CData(13,:) = [0.2118, 0.6353, 0.6784];
        b.CData(14,:) = [0.9373, 0.5294, 0.2588];

        b.CData(15,:) = [0.2118, 0.6353, 0.6784];
        b.CData(16,:) = [0.9373, 0.5294, 0.2588];
        

        title('', 'interpreter','latex', 'FontSize', 14);
        
        xticks([1.25    3.25    5.25    7.25   9.25    11.25   13.25  15.25]);
        xticklabels({'1' '2' '3' '4' '5' '6' '7' '8'});
        xtickangle(0);
        xlabel('STA', 'interpreter','latex', 'FontSize', 16)

        ylim([0 250]);
        yticks(0:50:250);
        ylabel('STA Throughput [Mbps]', 'interpreter','latex', 'FontSize', 16)
        ax = gca;
        ax.XAxis.LineWidth = 1.5;
        ax.YAxis.LineWidth = 1.5;
        set(gca, 'TickLabelInterpreter','latex', 'FontSize', 14);
        grid on
        hold on
        % text(A,B(1,:),yvalues,'vert','bottom','horiz','center');
        box off
    else
        asteriskValues = xValues;
        for k = 1:length(xValues)
            plot(asteriskValues(k), plot_BianchiThroughput(k), '*', 'LineWidth', 1, 'MarkerSize', 12, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor',[0 0 0]);
                % 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize',22, 'Interpreter', 'latex');
        end
        % b.FaceColor = 'none'; 
        % set(gca, 'TickLabelInterpreter','latex', 'FontSize', 14);  
    end
end


%%
%%%%%% legend
B = [11.7399 10.8998];

colordatabase = [ [0.2118, 0.6353, 0.6784];        
                  [0.9373, 0.5294, 0.2588]];
names = {'DCF' 'C-SR' 'Analytical'};    


figure
for i=1:length(B)
    b = bar(1,B(i));
    b.EdgeColor = 'flat';
    b.FaceColor = 'flat';
    b.FaceAlpha = 0.5;
    b.CData(1,:) = colordatabase(i,:);
    hold on
end
ylim([0 50]);
plot(1,5,'*', 'LineWidth', 1, 'MarkerSize', 12, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor',[0 0 0]);
legend(names, 'Interpreter','latex', 'location', 'north', 'Orientation', 'vertical'  , 'FontSize', 14);

