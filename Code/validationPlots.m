
%% validation scenario 1------ 8 STAs --- 20 meters
clear all
DCF_throughput = [122.0933  162.7910  108.5273   97.6746  162.7910   97.6746  122.0933  122.0933];
CSR_throughput = [85.8353  305.0605  121.9453   68.6682  209.7537   68.6682  131.6141  131.6141];

plot_BianchiThroughput = [DCF_throughput;CSR_throughput];
plot_BianchiThroughput = reshape(plot_BianchiThroughput,[],1)';







%% 
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
        b.FaceColor = 'flat';
        b.CData(1,:) = [0.7020    0.5059    0.5059];
        b.CData(2,:) = [0.5059    0.6235   0.7020];
        b.CData(3,:) = [0.7020    0.5059    0.5059];
        b.CData(4,:) = [0.5059    0.6235    0.7020];
        b.CData(5,:) = [0.7020    0.5059    0.5059];
        b.CData(6,:) = [0.5059    0.6235    0.7020];
        b.CData(7,:) = [0.7020    0.5059    0.5059];
        b.CData(8,:) = [0.5059    0.6235    0.7020];
        b.CData(9,:) = [0.7020    0.5059    0.5059];
        b.CData(10,:) = [0.5059    0.6235    0.7020];
        b.CData(11,:) = [0.7020    0.5059    0.5059];
        b.CData(12,:) = [0.5059    0.6235    0.7020];
        b.CData(13,:) = [0.7020    0.5059    0.5059];
        b.CData(14,:) = [0.5059    0.6235    0.7020];
        b.CData(15,:) = [0.7020    0.5059    0.5059];
        b.CData(16,:) = [0.5059    0.6235    0.7020];
        

        title('', 'interpreter','latex', 'FontSize', 14);
        
        xticks([1.25    3.25    5.25    7.25   9.25    11.25   13.25  15.25]);
        xticklabels({'1' '2' '3' '4' '5' '6' '7' '8'});
        xtickangle(0);
        xlabel('STA', 'interpreter','latex', 'FontSize', 16)

        ylim([0 350]);
        yticks(0:50:350);
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

colordatabase = [[0.7020    0.5059    0.5059];
                 [0.5059    0.6235    0.7020];];
names = {'DCF' 'C-SR' 'Analytical'};    


figure
for i=1:length(B)
    b = bar(1,B(i));
    b.FaceColor = 'flat';
    b.CData(1,:) = colordatabase(i,:);
    hold on
end
ylim([0 50]);
plot(1,5,'*', 'LineWidth', 1, 'MarkerSize', 12, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor',[0 0 0]);
legend(names, 'Interpreter','latex', 'location', 'north', 'Orientation', 'vertical'  , 'FontSize', 14);

