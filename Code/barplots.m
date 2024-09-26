%%
clear all

linestyle = {'-', ':'};
linewidth = [1.5, 1.5];
A = [1 2 3 4  6 7 8 9  11 12 13 14];

% sim_sim = {'20metros-8STAs' '20metros-16STAs' '30metros-16STAs'};
sim_sim = {'20metros-8STAs'};
traffic_type_sim = {'Poisson' 'Bursty'};
traffic_load_sim = {'low' 'medium' 'high'};



for j = 1:length(sim_sim)
    sim = sim_sim{j}; 

    for jj = 1:length(traffic_type_sim)
        traffic_type = traffic_type_sim{jj};

        delay_values = [];
        for jjj = 1:length(traffic_load_sim)
            traffic_load = traffic_load_sim{jjj};

            % Initialize an empty cell array to store the vectors
            allDCFdelayVectors = cell(100, 1);
            allCSRNumPkdelayVectors = cell(100, 1);
            allCSROldPkdelayVectors = cell(100, 1);
            allCSRWeighteddelayVectors = cell(100, 1);


            % Load each vector and store it in the cell array
            for jjjj = 86
               
                Resultsfilepath = horzcat('simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj));
                DCFfilename = horzcat(Resultsfilepath,'/DCFdelay.mat');
                CSRNumPkfilename = horzcat(Resultsfilepath,'/CSRNumPkdelay.mat');
                CSROldPkfilename = horzcat(Resultsfilepath,'/CSROldPkdelay.mat');
                CSRWeightedfilename = horzcat(Resultsfilepath,'/CSRWeighteddelay.mat');

                allDCFdelayVectors{jjjj} = load(DCFfilename).DCFdelay;
                allCSRNumPkdelayVectors{jjjj} = load(CSRNumPkfilename).CSRNumPkdelay;
                allCSROldPkdelayVectors{jjjj} = load(CSROldPkfilename).CSROldPkdelay;
                allCSRWeighteddelayVectors{jjjj} = load(CSRWeightedfilename).CSRWeighteddelay;

            end
            DCFdelay = vertcat(allDCFdelayVectors{:});
            CSRNumPkdelay = vertcat(allCSRNumPkdelayVectors{:});
            CSROldPkdelay = vertcat(allCSROldPkdelayVectors{:});
            CSRWeighteddelay = vertcat(allCSRWeighteddelayVectors{:});


            B = [[prctile(DCFdelay,99)*1000, prctile(CSRNumPkdelay,99)*1000, prctile(CSROldPkdelay,99)*1000, prctile(CSRWeighteddelay,99)*1000];
                [prctile(DCFdelay,50)*1000, prctile(CSRNumPkdelay,50)*1000, prctile(CSROldPkdelay,50)*1000, prctile(CSRWeighteddelay,50)*1000]];
            delay_values = [delay_values B];

        end
        yvalues = sprintfc('%.2f',delay_values(1,:));
        figure('pos', [400,400,700,500])
        for i = 1:2
            b = bar(A, delay_values(i,:));
            b.LineStyle = linestyle(i);
            b.LineWidth = linewidth(i);

            if i == 1
                b.FaceColor = 'flat';
                b.CData(1,:) = [0.7020    0.5059    0.5059];        % #B38181
                b.CData(2,:) = [0.5059    0.6235    0.7020];        % #819EB3
                b.CData(3,:) = [0.3686    0.2745    0.2745];        % #5E4646
                b.CData(4,:) = [0.7020    0.6980    0.5059];        % #B3B281
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
                switch traffic_type
                    case 'Poisson'
                        ylim([0 160]);
                        yticks(0:20:160);
                    case 'Bursty'
                        ylim([0 80]);
                        yticks(0:20:80);
                end

                ylabel('$99^{}\%$-tile of Packet Delay [ms]', 'interpreter','latex', 'FontSize', 16)
                ax = gca;
                ax.XAxis.LineWidth = 1.5;
                ax.YAxis.LineWidth = 1.5;
                set(gca, 'TickLabelInterpreter','latex', 'FontSize', 14);
                grid on
                hold on
                text(A,delay_values(1,:),yvalues,'vert','bottom','horiz','center', 'interpreter','latex', 'FontSize', 11);
                box off
            else
                b.FaceColor = 'none';
            end
        end
    end

end








%%
%%%%%% legend


clear all

delay_values = [11.7399 10.8998 5.6802 5.1610];

colordatabase = [[0.7020    0.5059    0.5059];
    [0.5059    0.6235    0.7020];
    [0.3686    0.2745    0.2745];
    [0.7020    0.6980    0.5059]];
names = {'DCF' 'NumPk' 'OldPk' 'Weighted' '50$^{th}$-percentile'};    


figure
for i=1:length(delay_values)
    b = bar(1,delay_values(i));
    b.FaceColor = 'flat';
    b.CData(1,:) = colordatabase(i,:);
    hold on
end
ylim([0 50]);
plot(1,5,':', 'Color','k');
legend(names, 'Interpreter','latex', 'location', 'north', 'Orientation', 'horizontal'  , 'FontSize', 14);