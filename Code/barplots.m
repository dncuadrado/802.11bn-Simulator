%% for 4 mechanisms
clear all

linestyle = {'-', ':'};
linewidth = [1.5, 1.5];


sim_sim = {'20metros-8STAs' '20metros-16STAs' '30metros-16STAs'};
% sim_sim = {'20metros-8STAs'};
traffic_type_sim = {'Poisson' 'Bursty'};
% traffic_load_sim = {'low' 'medium' 'high'};
traffic_load_sim = {'medium' 'high'};



for j = 1:length(sim_sim)
    sim = sim_sim{j}; 

    for jj = 1:length(traffic_type_sim)
        traffic_type = traffic_type_sim{jj};

        delay_values = [];
        for jjj = 1:length(traffic_load_sim)
            traffic_load = traffic_load_sim{jjj};

            % Initialize an empty cell array to store the vectors
            allDCFdelayVectors = cell(100, 1);
            allMNPdelayVectors = cell(100, 1);
            allOPdelayVectors = cell(100, 1);
            allTATdelayVectors = cell(100, 1);


            % Load each vector and store it in the cell array
            for jjjj = 1:100
               
                Resultsfilepath = horzcat('simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj));
                DCFfilename = horzcat(Resultsfilepath,'/DCFdelay.mat');
                MNPfilename = horzcat(Resultsfilepath,'/MNPdelay.mat');
                OPfilename = horzcat(Resultsfilepath,'/OPdelay.mat');
                TATfilename = horzcat(Resultsfilepath,'/TATdelay.mat');

                allDCFdelayVectors{jjjj} = load(DCFfilename).DCFdelay;
                allMNPdelayVectors{jjjj} = load(MNPfilename).CSRNumPkdelay;
                allOPdelayVectors{jjjj} = load(OPfilename).CSROldPkdelay;
                allTATdelayVectors{jjjj} = load(TATfilename).CSRWeighteddelay;

            end
            DCFdelay = vertcat(allDCFdelayVectors{:});
            MNPdelay = vertcat(allMNPdelayVectors{:});
            OPdelay = vertcat(allOPdelayVectors{:});
            TATdelay = vertcat(allTATdelayVectors{:});


            B = [[prctile(DCFdelay,99)*1000, prctile(MNPdelay,99)*1000, prctile(OPdelay,99)*1000, prctile(TATdelay,99)*1000];
                [prctile(DCFdelay,50)*1000, prctile(MNPdelay,50)*1000, prctile(OPdelay,50)*1000, prctile(TATdelay,50)*1000]];
            delay_values = [delay_values B];

        end
        yvalues = sprintfc('%.2f',delay_values(1,:));
        figure('pos', [400,400,700,500])

        A = 1:(size(B,2)*length(traffic_load_sim)+length(traffic_load_sim)-1);
        A((size(B,2)+1):(size(B,2)+1):(size(B,2)+1)*(length(traffic_load_sim)-1)) = [];

        for i = 1:2
            b = bar(A, delay_values(i,:));
            b.LineStyle = linestyle(i);
            b.LineWidth = linewidth(i);

            if i == 1
                b.EdgeColor = 'flat';
                b.FaceColor = 'flat';
                b.FaceAlpha = 0.5;
                if length(traffic_load_sim) == 2
                    b.CData(1,:) = [0.2118, 0.6353, 0.6784];        
                    b.CData(2,:) = [0.9373, 0.5294, 0.2588];        
                    b.CData(3,:) = [0.5294, 0.3686, 0.7098];       
                    b.CData(4,:) = [0.4588, 0.6863, 0.3137];        
        
                    b.CData(5,:) = [0.2118, 0.6353, 0.6784];
                    b.CData(6,:) = [0.9373, 0.5294, 0.2588];
                    b.CData(7,:) = [0.5294, 0.3686, 0.7098];
                    b.CData(8,:) = [0.4588, 0.6863, 0.3137];
        
                elseif length(traffic_load_sim) == 3
                    b.CData(1,:) = [0.2118, 0.6353, 0.6784];
                    b.CData(2,:) = [0.9373, 0.5294, 0.2588];        
                    b.CData(3,:) = [0.5294, 0.3686, 0.7098];       
                    b.CData(4,:) = [0.4588, 0.6863, 0.3137];        
        
                    b.CData(5,:) = [0.2118, 0.6353, 0.6784];
                    b.CData(6,:) = [0.9373, 0.5294, 0.2588];
                    b.CData(7,:) = [0.5294, 0.3686, 0.7098];
                    b.CData(8,:) = [0.4588, 0.6863, 0.3137];
        
                    b.CData(9,:) = [0.2118, 0.6353, 0.6784];
                    b.CData(10,:) = [0.9373, 0.5294, 0.2588];
                    b.CData(11,:) = [0.5294, 0.3686, 0.7098];
                    b.CData(12,:) = [0.4588, 0.6863, 0.3137];
                end
                

                % b.CData(1,:) = [0.7020    0.5059    0.5059];        % #B38181
                % b.CData(2,:) = [0.5059    0.6235    0.7020];        % #819EB3
                % b.CData(3,:) = [0.3686    0.2745    0.2745];        % #5E4646
                % b.CData(4,:) = [0.7020    0.6980    0.5059];        % #B3B281
                % b.CData(5,:) = [0.7020    0.5059    0.5059];
                % b.CData(6,:) = [0.5059    0.6235    0.7020];
                % b.CData(7,:) = [0.3686    0.2745    0.2745];
                % b.CData(8,:) = [0.7020    0.6980    0.5059];
                % b.CData(9,:) = [0.7020    0.5059    0.5059];
                % b.CData(10,:) = [0.5059    0.6235    0.7020];
                % b.CData(11,:) = [0.3686    0.2745    0.2745];
                % b.CData(12,:) = [0.7020    0.6980    0.5059];

                title('', 'interpreter','latex', 'FontSize', 14);

                % xticks([1 2 2.5 3 4 5 6 7 7.5 8 9 10 11 12 12.5 13 14]);
                % xticklabels({[] [] 'low' [] [] [] [] [] 'medium' [] [] [] [] [] 'high' [] []});
                if length(traffic_load_sim) == 2
                    xticks([1 2 2.5 3 4 5 6 7 7.5 8 9]);
                    xticklabels({[] [] 'medium' [] [] [] [] [] 'high' [] []});
                elseif length(traffic_load_sim) == 3
                    xticks([1 2 2.5 3 4 5 6 7 7.5 8 9 10 11 12 12.5 13 14]);
                    xticklabels({[] [] 'low' [] [] [] [] [] 'medium' [] [] [] [] [] 'high' [] []});
                end
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

                ylabel('$99^\mathrm{th}$ percentile delay [ms]', 'interpreter','latex', 'FontSize', 16)
                ax = gca;
                ax.XAxis.LineWidth = 1.5;
                ax.YAxis.LineWidth = 1.5;
                set(gca, 'TickLabelInterpreter','latex', 'FontSize', 14);
                grid on
                hold on
                text(A,delay_values(1,:),yvalues,'vert','bottom','horiz','center', 'interpreter','latex', 'FontSize', 14);
                % plot([7.5], ylim, 'w', 'LineWidth', 2);
                box off
            else
                b.FaceColor = 'none';  
            end
        end
    end

end


%% For 5 mechanisms
clear all

linestyle = {'-', ':'};
linewidth = [1.5, 1.5];


sim_sim = {'20metros-8STAs' '20metros-16STAs' '30metros-16STAs'};
% sim_sim = {'30metros-16STAs'};
% sim_sim = {'30metros-16STAs'};
traffic_type_sim = {'Bursty'};
% traffic_load_sim = {'low' 'medium' 'high'};
traffic_load_sim = {'high'};


% for jjjjj = 1:50
for j = 1:length(sim_sim)
    sim = sim_sim{j}; 

    for jj = 1:length(traffic_type_sim)
        traffic_type = traffic_type_sim{jj};

        delay_values = [];
        for jjj = 1:length(traffic_load_sim)
            traffic_load = traffic_load_sim{jjj};

            % Initialize an empty cell array to store the vectors
            allDCFdelayVectors = cell(100, 1);
            allMNPdelayVectors = cell(100, 1);
            allOPdelayVectors = cell(100, 1);
            allTATdelayVectors = cell(100, 1);
            allTATdelayVectors7 = cell(100, 1);


            % Load each vector and store it in the cell array
            for jjjj = 1:100
                %%% jjjj = 36 for example scenario
               
                Resultsfilepath = horzcat('simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj));
                DCFfilename = horzcat(Resultsfilepath,'/DCFdelay.mat');
                MNPfilename = horzcat(Resultsfilepath,'/MNPdelay.mat');
                OPfilename = horzcat(Resultsfilepath,'/OPdelay.mat');
                TATfilename = horzcat(Resultsfilepath,'/TATdelay.mat');
                TATfilename7 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/7/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay7.mat');

                allDCFdelayVectors{jjjj} = load(DCFfilename).DCFdelay;
                allMNPdelayVectors{jjjj} = load(MNPfilename).CSRNumPkdelay;
                allOPdelayVectors{jjjj} = load(OPfilename).CSROldPkdelay;
                allTATdelayVectors{jjjj} = load(TATfilename).CSRWeighteddelay;
                allTATdelayVectors7{jjjj} = load(TATfilename7).CSRWeighteddelay7;

            end
            DCFdelay = vertcat(allDCFdelayVectors{:});
            MNPdelay = vertcat(allMNPdelayVectors{:});
            OPdelay = vertcat(allOPdelayVectors{:});
            TATdelay = vertcat(allTATdelayVectors{:});
            TATdelay7 = vertcat(allTATdelayVectors7{:});


            B = [[prctile(DCFdelay,99)*1000, prctile(MNPdelay,99)*1000, prctile(OPdelay,99)*1000, prctile(TATdelay,99)*1000, prctile(TATdelay7,99)*1000];
                [prctile(DCFdelay,50)*1000, prctile(MNPdelay,50)*1000, prctile(OPdelay,50)*1000, prctile(TATdelay,50)*1000, prctile(TATdelay7,50)*1000]];
            delay_values = [delay_values B];

        end
        yvalues = sprintfc('%.2f',delay_values(1,:));
        figure('pos', [400,400,700,600])

        A = 1:(size(B,2)*length(traffic_load_sim)+length(traffic_load_sim)-1);
        A((size(B,2)+1):(size(B,2)+1):(size(B,2)+1)*(length(traffic_load_sim)-1)) = [];

        for i = 1:2
            b = bar(A, delay_values(i,:));
            b.LineStyle = linestyle(i);
            b.LineWidth = linewidth(i);

            if i == 1
                b.EdgeColor = 'flat';
                b.FaceColor = 'flat';
                b.FaceAlpha = 0.5;
                if length(traffic_load_sim) == 1
                    b.CData(1,:) = [0.2118, 0.6353, 0.6784];        
                    b.CData(2,:) = [0.9373, 0.5294, 0.2588];        
                    b.CData(3,:) = [0.5294, 0.3686, 0.7098];       
                    b.CData(4,:) = [0.4588, 0.6863, 0.3137];
                    b.CData(5,:) = [0.9608, 0.7725, 0.2588];

                elseif length(traffic_load_sim) == 2
                    b.CData(1,:) = [0.2118, 0.6353, 0.6784];        
                    b.CData(2,:) = [0.9373, 0.5294, 0.2588];        
                    b.CData(3,:) = [0.5294, 0.3686, 0.7098];       
                    b.CData(4,:) = [0.4588, 0.6863, 0.3137];
                    b.CData(5,:) = [0.9608, 0.7725, 0.2588];
                    
                    b.CData(6,:) = [0.2118, 0.6353, 0.6784];
                    b.CData(7,:) = [0.9373, 0.5294, 0.2588];
                    b.CData(8,:) = [0.5294, 0.3686, 0.7098];
                    b.CData(9,:) = [0.4588, 0.6863, 0.3137];
                    b.CData(10,:) = [0.9608, 0.7725, 0.2588];
        
                elseif length(traffic_load_sim) == 3
                    b.CData(1,:) = [0.2118, 0.6353, 0.6784];        
                    b.CData(2,:) = [0.9373, 0.5294, 0.2588];        
                    b.CData(3,:) = [0.5294, 0.3686, 0.7098];       
                    b.CData(4,:) = [0.4588, 0.6863, 0.3137];
                    b.CData(5,:) = [0.9608, 0.7725, 0.2588];
                    
                    b.CData(6,:) = [0.2118, 0.6353, 0.6784];
                    b.CData(7,:) = [0.9373, 0.5294, 0.2588];
                    b.CData(8,:) = [0.5294, 0.3686, 0.7098];
                    b.CData(9,:) = [0.4588, 0.6863, 0.3137];
                    b.CData(10,:) = [0.9608, 0.7725, 0.2588];

                    b.CData(11,:) = [0.2118, 0.6353, 0.6784];
                    b.CData(12,:) = [0.9373, 0.5294, 0.2588];
                    b.CData(13,:) = [0.5294, 0.3686, 0.7098];
                    b.CData(14,:) = [0.4588, 0.6863, 0.3137];
                    b.CData(15,:) = [0.9608, 0.7725, 0.2588];
                end

                title('', 'interpreter','latex', 'FontSize', 14);
                xticks(1:17);
                xticklabels({[] [] 'low' [] []  []  [] [] 'medium' [] [] [] [] [] 'high' [] []});
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

                ylabel('$99^\mathrm{th}$ percentile delay [ms]', 'interpreter','latex', 'FontSize', 16)
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

% end



%% For the 12 TAT settings
clear all

linestyle = {'-', ':'};
linewidth = [1.5, 1.5];
A = [1 2 3 4 5  7 8 9 10 11  13 14 15 16 17];
colors = { 
    [0.2, 0.6, 0.8],    % Light blue
    [0.8, 0.4, 0.2],    % Warm orange
    [0.3, 0.7, 0.3],    % Soft green
    [0.6, 0.2, 0.4],    % Muted purple
    [0.9, 0.6, 0.1],    % Amber
    [0.4, 0.2, 0.6],    % Deep violet
    [0.2, 0.4, 0.8],    % Medium blue
    [0.8, 0.2, 0.2],    % Brick red
    [0.4, 0.7, 0.5],    % Teal
    [0.7, 0.4, 0.2],    % Burnt orange
    [0.5, 0.5, 0.7],    % Slate blue
    [0.8, 0.5, 0.4]     % Peach
};

sim_sim = {'20metros-8STAs' '20metros-16STAs' '30metros-16STAs'};
% sim_sim = {'20metros-8STAs'};
% sim_sim = {'20metros-16STAs'};
traffic_type_sim = {'Bursty'};
% traffic_load_sim = {'low' 'medium' 'high'};
traffic_load_sim = {'high'};



for j = 1:length(sim_sim)
    sim = sim_sim{j}; 

    for jj = 1:length(traffic_type_sim)
        traffic_type = traffic_type_sim{jj};

        delay_values = [];
        for jjj = 1:length(traffic_load_sim)
            traffic_load = traffic_load_sim{jjj};

            % Initialize an empty cell array to store the vectors
            allTATdelayVectors1 = cell(100, 1);
            allTATdelayVectors2 = cell(100, 1);
            allTATdelayVectors3 = cell(100, 1);
            allTATdelayVectors4 = cell(100, 1);
            allTATdelayVectors5 = cell(100, 1);
            allTATdelayVectors6 = cell(100, 1);
            allTATdelayVectors7 = cell(100, 1);
            allTATdelayVectors8 = cell(100, 1);
            allTATdelayVectors9 = cell(100, 1);
            allTATdelayVectors10 = cell(100, 1);
            allTATdelayVectors11 = cell(100, 1);
            allTATdelayVectors12 = cell(100, 1);


            % Load each vector and store it in the cell array
            for jjjj = 1:100
                %%% jjjj = 36 for example scenario
               

                TATfilename1 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/10/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay10.mat');
                TATfilename2 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/11/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay11.mat');
                TATfilename3 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/12/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay12.mat');
                TATfilename4 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/1/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay1.mat');
                TATfilename5 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/2/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay2.mat');
                TATfilename6 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/3/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay3.mat');
                TATfilename7 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/4/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay4.mat');
                TATfilename8 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/5/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay.mat');
                TATfilename9 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/6/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay6.mat');
                TATfilename10 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/7/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay7.mat');
                TATfilename11 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/8/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay8.mat');
                TATfilename12 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/9/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay9.mat');


                allTATdelayVectors1{jjjj} = load(TATfilename1).CSRWeighteddelay10;
                allTATdelayVectors2{jjjj} = load(TATfilename2).CSRWeighteddelay11;
                allTATdelayVectors3{jjjj} = load(TATfilename3).CSRWeighteddelay12;
                allTATdelayVectors4{jjjj} = load(TATfilename4).CSRWeighteddelay1;
                allTATdelayVectors5{jjjj} = load(TATfilename5).CSRWeighteddelay2;
                allTATdelayVectors6{jjjj} = load(TATfilename6).CSRWeighteddelay3;
                allTATdelayVectors7{jjjj} = load(TATfilename7).CSRWeighteddelay4;
                allTATdelayVectors8{jjjj} = load(TATfilename8).CSRWeighteddelay;
                allTATdelayVectors9{jjjj} = load(TATfilename9).CSRWeighteddelay6;
                allTATdelayVectors10{jjjj} = load(TATfilename10).CSRWeighteddelay7;
                allTATdelayVectors11{jjjj} = load(TATfilename11).CSRWeighteddelay8;
                allTATdelayVectors12{jjjj} = load(TATfilename12).CSRWeighteddelay9;

            end

            TATdelay1 = vertcat(allTATdelayVectors1{:});
            TATdelay2 = vertcat(allTATdelayVectors2{:});
            TATdelay3 = vertcat(allTATdelayVectors3{:});
            TATdelay4 = vertcat(allTATdelayVectors4{:});
            TATdelay5 = vertcat(allTATdelayVectors5{:});
            TATdelay6 = vertcat(allTATdelayVectors6{:});
            TATdelay7 = vertcat(allTATdelayVectors7{:});
            TATdelay8 = vertcat(allTATdelayVectors8{:});
            TATdelay9 = vertcat(allTATdelayVectors9{:});
            TATdelay10 = vertcat(allTATdelayVectors10{:});
            TATdelay11 = vertcat(allTATdelayVectors11{:});
            TATdelay12 = vertcat(allTATdelayVectors12{:});

            % Create the figure and set up the boxchart environment
            figure('pos', [400,400,750,650])
            hold on;

            % Initialize an empty cell array for x-axis labels
            xticks_labels = cell(1, 12);  % Preallocate for 9 labels

            % % Define colors or patterns for alternating background shading
            % shading_colors = [0.9 0.9 0.9; 0.7 0.7 0.7];  % Two shades of gray for alternate areas
            % 
            % % Add background shading (alternating shades) between vertical lines
            % alpha_groups = [0.5, 3.5; 3.5, 6.5; 6.5, 9.5; 9.5, 12.5];  % Ranges for alpha groups
            % for i = 1:length(alpha_groups)
            %     fill([alpha_groups(i,1) alpha_groups(i,2) alpha_groups(i,2) alpha_groups(i,1)], ...
            %         [-5 -5 60 60], shading_colors(mod(i,2)+1,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3);  % Semi-transparent shading
            % end

            % Plot data incrementally
            for i = 1:12
                % Load each delay vector one at a time
                switch i
                    case 1
                        current_delay = prctile(TATdelay1,99)*1000;
                        x_value = 1;
                        xticks_labels{i} = '$\beta=\frac{1}{4}$';
                    case 2
                        current_delay = prctile(TATdelay2,99)*1000;
                        x_value = 2;
                        xticks_labels{i} = '$\beta=\frac{1}{2}$';
                    case 3
                        current_delay = prctile(TATdelay3,99)*1000;
                        x_value = 3;
                        xticks_labels{i} = '$\beta=\frac{3}{4}$';
                    case 4
                        current_delay = prctile(TATdelay4,99)*1000;
                        x_value = 4;
                        xticks_labels{i} = '$\beta=\frac{1}{4}$';
                    case 5
                        current_delay = prctile(TATdelay5,99)*1000;
                        x_value = 5;
                        xticks_labels{i} = '$\beta=\frac{1}{2}$';
                    case 6
                        current_delay = prctile(TATdelay6,99)*1000;
                        x_value = 6;
                        xticks_labels{i} = '$\beta=\frac{3}{4}$';
                    case 7
                        current_delay = prctile(TATdelay7,99)*1000;
                        x_value = 7;
                        xticks_labels{i} = '$\beta=\frac{1}{4}$';
                    case 8
                        current_delay = prctile(TATdelay8,99)*1000;
                        x_value = 8;
                        xticks_labels{i} = '$\beta=\frac{1}{2}$';
                    case 9
                        current_delay = prctile(TATdelay9,99)*1000;
                        x_value = 9;
                        xticks_labels{i} = '$\beta=\frac{3}{4}$';
                    case 10
                        current_delay = prctile(TATdelay10,99)*1000;
                        x_value = 10;
                        xticks_labels{i} = '$\beta=\frac{1}{4}$';
                    case 11
                        current_delay = prctile(TATdelay11,99)*1000;
                        x_value = 11;
                        xticks_labels{i} = '$\beta=\frac{1}{2}$';
                    case 12
                        current_delay = prctile(TATdelay12,99)*1000;
                        x_value = 12;
                        xticks_labels{i} = '$\beta=\frac{3}{4}$';
                end

                % % Plot the current delay vector
                % boxchart(repmat(x_value, length(current_delay), 1), current_delay, 'MarkerStyle', 'none');
                b = bar(i, current_delay);
                b.EdgeColor = 'flat';
                b.FaceColor = 'flat';
                b.FaceAlpha = 0.5;
                b.CData = colors{i};
                b.BarWidth = 0.5;

                % Update the figure without holding all data in memory
                drawnow;
            end

            % Set xticks and xticklabels for beta
            xticks(1:12);
            xticklabels(xticks_labels);
            % xtickangle(15);

            % Add vertical lines to separate groups of alpha
            for k = [3.5, 6.5, 9.5]  % Positions to separate groups of alpha
                xline(k, '--k', 'LineWidth', 1.5);  % Dashed black line to separate alpha groups
            end

            % Customize axis labels and title
            ylabel('$99^\mathrm{th}$ percentile delay [ms]', 'Interpreter', 'latex', 'FontSize', 16);
            title('', 'Interpreter', 'latex');

            % Adjust the axis limits for better visibility
            xlim([0.5 12.5]);
            switch traffic_load
                case 'low'
                    y1 = 0;
                    y2 = 10;
                    ylim([y1 y2])
                    yticks(y1:(y2-y1)/5:y2);
                    y_offset = y1-(y2-y1)/8;  % Adjust vertical position for alpha labels
                case 'medium'
                    y1 = 16;
                    y2 = 20;
                    ylim([y1 y2])
                    yticks(y1:(y2-y1)/5:y2);
                    y_offset = y1-(y2-y1)/8;  % Adjust vertical position for alpha labels
                case 'high'
                    y1 = 30;
                    y2 = 50;
                    ylim([y1 y2])
                    yticks(y1:(y2-y1)/5:y2);
                    y_offset = y1-(y2-y1)/8;  % Adjust vertical position for alpha labels
            end

            % Add second level of x-axis labels (for alpha) manually above the beta values
            alpha_labels = {'$\alpha= 0$', '$\alpha=\frac{1}{4}$', '$\alpha=\frac{1}{2}$', '$\alpha=\frac{3}{4}$'};
            alpha_positions = [2, 5, 8, 11];  % Middle positions for alpha labels

            
            for i = 1:length(alpha_labels)
                text(alpha_positions(i), y_offset, alpha_labels{i}, 'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'top', 'Interpreter', 'latex', 'FontSize', 16, 'Units', 'data');
            end

            hold off;
            grid on;

            % Customize the axis appearance
            ax = gca;
            ax.XAxis.LineWidth = 1.5;
            ax.YAxis.LineWidth = 1.5;
            ax.Position = [0.1, 0.21, 0.8, 0.9];  % [left, bottom, width, height]
            ax.InnerPosition = [0.1, 0.21, 0.8, 0.7];
            ax.OuterPosition = [0, 0.1, 1, 0.9];
            set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 14);

        end

    end

end


%% %% Figure with 2 subplots for TAT settings
clear all

linestyle = {'-', ':'};
linewidth = [1.5, 1.5];
A = [1 2 3 4 5  7 8 9 10 11  13 14 15 16 17];
colors = { 
    [0.2, 0.6, 0.8],    % Light blue
    [0.8, 0.4, 0.2],    % Warm orange
    [0.3, 0.7, 0.3],    % Soft green
    [0.6, 0.2, 0.4],    % Muted purple
    [0.9, 0.6, 0.1],    % Amber
    [0.4, 0.2, 0.6],    % Deep violet
    [0.2, 0.4, 0.8],    % Medium blue
    [0.8, 0.2, 0.2],    % Brick red
    [0.4, 0.7, 0.5],    % Teal
    [0.7, 0.4, 0.2],    % Burnt orange
    [0.5, 0.5, 0.7],    % Slate blue
    [0.8, 0.5, 0.4]     % Peach
};

% sim_sim = {'20metros-8STAs' '20metros-16STAs' '30metros-16STAs'};
% sim_sim = {'20metros-8STAs'};
sim_sim = {'30metros-16STAs' '20metros-16STAs'};
traffic_type_sim = {'Poisson' 'Bursty'};
% traffic_load_sim = {'low' 'medium' 'high'};
traffic_load_sim = {'low'};


% Create the figure and set up the boxchart environment
figure('pos', [400,400,750,650])
hold on;

% Initialize an empty cell array for x-axis labels
xticks_labels = cell(1, 12);  % Preallocate for 9 labels

for j = 1:length(sim_sim)
    sim = sim_sim{j};

    subplot(2, 1, j);
    hold on;

    switch sim
        case '30metros-16STAs'
            traffic_load =  'low';
        case '20metros-16STAs'
            traffic_load =  'high';
    end

    delay_values = [];

    traffic_type = 'Bursty';
    % traffic_load = traffic_load_sim{jjj};

    % Initialize an empty cell array to store the vectors
    allTATdelayVectors1 = cell(100, 1);
    allTATdelayVectors2 = cell(100, 1);
    allTATdelayVectors3 = cell(100, 1);
    allTATdelayVectors4 = cell(100, 1);
    allTATdelayVectors5 = cell(100, 1);
    allTATdelayVectors6 = cell(100, 1);
    allTATdelayVectors7 = cell(100, 1);
    allTATdelayVectors8 = cell(100, 1);
    allTATdelayVectors9 = cell(100, 1);
    allTATdelayVectors10 = cell(100, 1);
    allTATdelayVectors11 = cell(100, 1);
    allTATdelayVectors12 = cell(100, 1);


    % Load each vector and store it in the cell array
    for jjjj = 1:100
        %%% jjjj = 36 for example scenario


        TATfilename1 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/10/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay10.mat');
        TATfilename2 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/11/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay11.mat');
        TATfilename3 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/12/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay12.mat');
        TATfilename4 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/1/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay1.mat');
        TATfilename5 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/2/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay2.mat');
        TATfilename6 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/3/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay3.mat');
        TATfilename7 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/4/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay4.mat');
        TATfilename8 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/5/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay.mat');
        TATfilename9 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/6/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay6.mat');
        TATfilename10 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/7/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay7.mat');
        TATfilename11 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/8/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay8.mat');
        TATfilename12 = horzcat('/home/david/Documents/Papers/journal_CSR_scheduling/save/simulations saves --- TAT sweep/9/simulation saves/',sim, '/', traffic_type, '/', traffic_load, ' load/Deployment', int2str(jjjj),'/TATdelay9.mat');


        allTATdelayVectors1{jjjj} = load(TATfilename1).CSRWeighteddelay10;
        allTATdelayVectors2{jjjj} = load(TATfilename2).CSRWeighteddelay11;
        allTATdelayVectors3{jjjj} = load(TATfilename3).CSRWeighteddelay12;
        allTATdelayVectors4{jjjj} = load(TATfilename4).CSRWeighteddelay1;
        allTATdelayVectors5{jjjj} = load(TATfilename5).CSRWeighteddelay2;
        allTATdelayVectors6{jjjj} = load(TATfilename6).CSRWeighteddelay3;
        allTATdelayVectors7{jjjj} = load(TATfilename7).CSRWeighteddelay4;
        allTATdelayVectors8{jjjj} = load(TATfilename8).CSRWeighteddelay;
        allTATdelayVectors9{jjjj} = load(TATfilename9).CSRWeighteddelay6;
        allTATdelayVectors10{jjjj} = load(TATfilename10).CSRWeighteddelay7;
        allTATdelayVectors11{jjjj} = load(TATfilename11).CSRWeighteddelay8;
        allTATdelayVectors12{jjjj} = load(TATfilename12).CSRWeighteddelay9;

    end

    TATdelay1 = vertcat(allTATdelayVectors1{:});
    TATdelay2 = vertcat(allTATdelayVectors2{:});
    TATdelay3 = vertcat(allTATdelayVectors3{:});
    TATdelay4 = vertcat(allTATdelayVectors4{:});
    TATdelay5 = vertcat(allTATdelayVectors5{:});
    TATdelay6 = vertcat(allTATdelayVectors6{:});
    TATdelay7 = vertcat(allTATdelayVectors7{:});
    TATdelay8 = vertcat(allTATdelayVectors8{:});
    TATdelay9 = vertcat(allTATdelayVectors9{:});
    TATdelay10 = vertcat(allTATdelayVectors10{:});
    TATdelay11 = vertcat(allTATdelayVectors11{:});
    TATdelay12 = vertcat(allTATdelayVectors12{:});

    % Plot data incrementally
    for i = 1:12
        % Load each delay vector one at a time
        switch i
            case 1
                current_delay = prctile(TATdelay1,99)*1000;
                x_value = 1;
                xticks_labels{i} = '$\beta=\frac{1}{4}$';
            case 2
                current_delay = prctile(TATdelay2,99)*1000;
                x_value = 2;
                xticks_labels{i} = '$\beta=\frac{1}{2}$';
            case 3
                current_delay = prctile(TATdelay3,99)*1000;
                x_value = 3;
                xticks_labels{i} = '$\beta=\frac{3}{4}$';
            case 4
                current_delay = prctile(TATdelay4,99)*1000;
                x_value = 4;
                xticks_labels{i} = '$\beta=\frac{1}{4}$';
            case 5
                current_delay = prctile(TATdelay5,99)*1000;
                x_value = 5;
                xticks_labels{i} = '$\beta=\frac{1}{2}$';
            case 6
                current_delay = prctile(TATdelay6,99)*1000;
                x_value = 6;
                xticks_labels{i} = '$\beta=\frac{3}{4}$';
            case 7
                current_delay = prctile(TATdelay7,99)*1000;
                x_value = 7;
                xticks_labels{i} = '$\beta=\frac{1}{4}$';
            case 8
                current_delay = prctile(TATdelay8,99)*1000;
                x_value = 8;
                xticks_labels{i} = '$\beta=\frac{1}{2}$';
            case 9
                current_delay = prctile(TATdelay9,99)*1000;
                x_value = 9;
                xticks_labels{i} = '$\beta=\frac{3}{4}$';
            case 10
                current_delay = prctile(TATdelay10,99)*1000;
                x_value = 10;
                xticks_labels{i} = '$\beta=\frac{1}{4}$';
            case 11
                current_delay = prctile(TATdelay11,99)*1000;
                x_value = 11;
                xticks_labels{i} = '$\beta=\frac{1}{2}$';
            case 12
                current_delay = prctile(TATdelay12,99)*1000;
                x_value = 12;
                xticks_labels{i} = '$\beta=\frac{3}{4}$';
        end

        % % Plot the current delay vector
        % boxchart(repmat(x_value, length(current_delay), 1), current_delay, 'MarkerStyle', 'none');
        b = bar(i, current_delay);
        b.EdgeColor = 'flat';
        b.FaceColor = 'flat';
        b.FaceAlpha = 0.5;
        b.CData = colors{i};
        b.BarWidth = 0.5;

        % Update the figure without holding all data in memory
        drawnow;
    end

    switch sim
        case '30metros-16STAs'
            % % Set xticks and xticklabels for beta
            xticks(1:12);
            xticklabels({''});
            % xtickangle(15);

            % Define colors or patterns for alternating background shading
            shading_colors = [0.9 0.9 0.9; 0.7 0.7 0.7];  % Two shades of gray for alternate areas

            % % Add background shading (alternating shades) between vertical lines
            % alpha_groups = [0.5, 3.5; 3.5, 6.5; 6.5, 9.5; 9.5, 12.5];  % Ranges for alpha groups
            % for i = 1:length(alpha_groups)
            %     fill([alpha_groups(i,1) alpha_groups(i,2) alpha_groups(i,2) alpha_groups(i,1)], ...
            %         [-5 -5 60 60], shading_colors(mod(i,2)+1,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3);  % Semi-transparent shading
            % end

            % Add vertical lines to separate groups of alpha
            for k = [3.5, 6.5, 9.5]  % Positions to separate groups of alpha
                xline(k, '--k', 'LineWidth', 1.5);  % Dashed black line to separate alpha groups
            end

            % Customize axis labels and title
            ylabel('$99^\mathrm{th}$ percentile delay [ms]', 'Interpreter', 'latex', 'FontSize', 16);
            title('', 'Interpreter', 'latex');

            % Adjust the axis limits for better visibility
            xlim([0.5 12.5]);
            switch traffic_load
                case 'low'
                    y1 = 4;
                    y2 = 8;
                    ylim([y1 y2])
                    yticks(y1:y2);
                    y_offset = y1-(y2-y1)/8;  % Adjust vertical position for alpha labels
                case 'medium'
                    y1 = 10;
                    y2 = 20;
                    ylim([y1 y2])
                    yticks(y1:(y2-y1)/5:y2);
                    y_offset = y1-(y2-y1)/8;  % Adjust vertical position for alpha labels
                case 'high'
                    y1 = 40;
                    y2 = 50;
                    ylim([y1 y2])
                    yticks(y1:(y2-y1)/5:y2);
                    y_offset = y1-(y2-y1)/8;  % Adjust vertical position for alpha labels
            end

            hold off;
            grid on;

            % Customize the axis appearance
            ax = gca;
            ax.XAxis.LineWidth = 1.5;
            ax.YAxis.LineWidth = 1.5;
            set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 14);
        case '20metros-16STAs'
            % Set xticks and xticklabels for beta
            xticks(1:12);
            xticklabels(xticks_labels);
            % xtickangle(15);
            % 
            % Define colors or patterns for alternating background shading
            shading_colors = [0.9 0.9 0.9; 0.7 0.7 0.7];  % Two shades of gray for alternate areas

            % % Add background shading (alternating shades) between vertical lines
            % alpha_groups = [0.5, 3.5; 3.5, 6.5; 6.5, 9.5; 9.5, 12.5];  % Ranges for alpha groups
            % for i = 1:length(alpha_groups)
            %     fill([alpha_groups(i,1) alpha_groups(i,2) alpha_groups(i,2) alpha_groups(i,1)], ...
            %         [-5 -5 60 60], shading_colors(mod(i,2)+1,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3);  % Semi-transparent shading
            % end

            % Add vertical lines to separate groups of alpha
            for k = [3.5, 6.5, 9.5]  % Positions to separate groups of alpha
                xline(k, '--k', 'LineWidth', 1.5);  % Dashed black line to separate alpha groups
            end

            % Customize axis labels and title
            ylabel('$99^\mathrm{th}$ percentile delay [ms]', 'Interpreter', 'latex', 'FontSize', 16);
            title('', 'Interpreter', 'latex');

            % Adjust the axis limits for better visibility
            xlim([0.5 12.5]);
            switch traffic_load
                case 'low'
                    y1 = 4;
                    y2 = 8;
                    ylim([y1 y2])
                    yticks(y1:(y2-y1)/5:y2);
                    y_offset = y1-(y2-y1)/8;  % Adjust vertical position for alpha labels
                case 'medium'
                    y1 = 10;
                    y2 = 20;
                    ylim([y1 y2])
                    yticks(y1:(y2-y1)/5:y2);
                    y_offset = y1-(y2-y1)/8;  % Adjust vertical position for alpha labels
                case 'high'
                    y1 = 40;
                    y2 = 50;
                    ylim([y1 y2])
                    yticks(y1:(y2-y1)/5:y2);
                    y_offset = y1-(y2-y1)/5;  % Adjust vertical position for alpha labels
            end

            % Add second level of x-axis labels (for alpha) manually above the beta values
            alpha_labels = {'$\alpha= 0$', '$\alpha=\frac{1}{4}$', '$\alpha=\frac{1}{2}$', '$\alpha=\frac{3}{4}$'};
            alpha_positions = [2, 5, 8, 11];  % Middle positions for alpha labels


            for i = 1:length(alpha_labels)
                text(alpha_positions(i), y_offset, alpha_labels{i}, 'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'top', 'Interpreter', 'latex', 'FontSize', 16, 'Units', 'data');
            end

            hold off;
            grid on;

            % Customize the axis appearance
            ax = gca;
            ax.XAxis.LineWidth = 1.5;
            ax.YAxis.LineWidth = 1.5;
            % ax.Position = [0.1, 0.21, 0.8, 0.9];  % [left, bottom, width, height]
            % ax.InnerPosition = [0.1, 0.21, 0.8, 0.7];
            % ax.OuterPosition = [0, 0.1, 1, 0.9];
            set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 14);
    end
end



%%
%%%%%% legend


clear all

delay_values = [11.7399 10.8998 5.6802 5.1610];

colordatabase = [ [0.2118, 0.6353, 0.6784];        
                  [0.9373, 0.5294, 0.2588];        
                  [0.5294, 0.3686, 0.7098];       
                  [0.4588, 0.6863, 0.3137]];
names = {'DCF' 'MNP' 'OP' 'TAT' '50$^{th}$-percentile'};    


figure
for i=1:length(delay_values)
    b = bar(1,delay_values(i));
    b.EdgeColor = 'flat';
    b.FaceColor = 'flat';
    b.FaceAlpha = 0.5;
    b.CData(1,:) = colordatabase(i,:);
    hold on
end
ylim([0 50]);
plot(1,5,':', 'Color','k', 'LineWidth',1.5);
legend(names, 'Interpreter','latex', 'location', 'north', 'Orientation', 'horizontal'  , 'FontSize', 18);