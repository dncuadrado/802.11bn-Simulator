classdef MyPlots
    properties (Access = 'private')
        mechanisms % Cell array to store mechanism names
        numberOfmechanisms
        colors = {'#36A2AD', '#EF8742', '#875EB5', '#75AF50', '#F5C542'};
        
        markers = {'o', '^', 'square', 'pentagram', 'x'};

        EDCA
        MNP
        OP
        TAT

        %%% System-related
        n_APs
        n_STAs
    end

    methods
        function self = MyPlots(varargin)
            % Initialize object (constructor)
            self.numberOfmechanisms = length(varargin);
            self.mechanisms = {}; % Initialize mechanisms cell array

            % Store mechanisms and corresponding objects
            for i = 1:self.numberOfmechanisms
                switch class(varargin{i})
                    case 'MAPCsim'
                        % Check which specific mechanism is being passed
                        if contains(varargin{i}.simulation_system, 'EDCA')
                            self.mechanisms{end + 1} = 'EDCA';
                            self.EDCA = varargin{i};
                        elseif contains(varargin{i}.scheduler, 'MNP')
                            self.mechanisms{end + 1} = 'MNP';
                            self.MNP = varargin{i};
                        elseif contains(varargin{i}.scheduler, 'OP')
                            self.mechanisms{end + 1} = 'OP';
                            self.OP = varargin{i};
                        elseif contains(varargin{i}.scheduler, 'TAT')
                            self.mechanisms{end + 1} = 'TAT';
                            self.TAT = varargin{i};
                        end
                end
            end
            A = horzcat('self.',self.mechanisms{1});
            simSystem = eval(A);

            self.n_STAs = simSystem.n_STAs;
            self.n_APs = simSystem.n_APs;
   
        end
    end

    methods ( Access = 'private' )
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function CustomizeScatterPlot(self, actors, parameter, titletag, ylabeltag)
            % Plotting using scatter plot for each active mechanism
             
            figure('pos', [400,400,700,500]);
            hold on;

            % Scatter plot each mechanism without skipping based on data checks
            for j = 1:self.numberOfmechanisms
                scatter(1:actors, parameter(:, j), 100, 'filled', ...
                    'Marker', self.markers{j}, 'MarkerEdgeColor', self.colors{j}, 'MarkerFaceColor', self.colors{j}, ...
                    'DisplayName', self.mechanisms{j});
            end

            % Adding vertical lines to separate each STA without adding them to the legend
            for jjj = 1.5:1:(actors-0.5)
                xline(jjj, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.8, 'HandleVisibility', 'off');
            end

            % Customize plot
            title(titletag, 'interpreter','latex', 'FontSize', 14);
            xticks(1:actors);
            xticklabels(string(1:actors));
            xlim([0.5, actors+0.5]);  % Adding margin before the first STA and after the last one
            xlabel('STA', 'interpreter', 'latex', 'FontSize', 14);
            ylabel(ylabeltag, 'interpreter', 'latex', 'FontSize', 16);
            ax = gca;
            ax.XAxis.LineWidth = 1.5;
            ax.YAxis.LineWidth = 1.5;
            set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 14);
            grid on;
            legend('Location', 'best', 'Interpreter', 'latex', 'Orientation', 'vertical', 'FontSize', 14);
            hold off;

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end

    methods ( Access = 'public' )

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function PlotCDFdelayTotal(self)
            % Method to plot the cumulative distribution function (CDF) of total delay (all packets sent)

            figure
            for i = 1:length(self.mechanisms)
                A = horzcat('self.',self.mechanisms{i});
                simSystem = eval(A);

                cdf = cdfplot(simSystem.delayvector*1000);
                set(cdf, 'LineWidth', 2, ...
                    'color', self.colors{i}, ...
                    'Marker', self.markers{i}, ...
                    'MarkerIndices', 1:floor(length(simSystem.delayvector)/10):(2*length(simSystem.delayvector)-floor(length(simSystem.delayvector)/10)), ...
                    'DisplayName', self.mechanisms{i});
                hold on
            end
            title('CDF of packet delay', 'interpreter','latex', 'FontSize', 14)
            xlabel('Delay [ms]', 'interpreter','latex', 'FontSize', 14)
            ylabel('F(x)', 'interpreter','latex', 'FontSize', 14)
            set(gca, 'TickLabelInterpreter','latex');
            legend(self.mechanisms, 'Interpreter','latex', 'location', 'southeast', 'Orientation', 'vertical'  , 'FontSize', 14)
            grid on
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function PlotCDFdelayPerSTA(self)
            % Method to plot the cumulative distribution function (CDF) of the delay per STA
            
            
            for i = 1:length(self.mechanisms)
                A = horzcat('self.',self.mechanisms{i});
                simSystem = eval(A);

                figure
                for j = 1:self.n_STAs
                    cdf = cdfplot([simSystem.delay_per_STA{j}]*1000);
                    set(cdf, 'LineWidth', 2, ...
                        'color', rand(1,3), ...
                        'Marker', self.markers{i}, ...
                        'MarkerIndices', 1:floor(length(simSystem.delay_per_STA{j})/10):(2*length(simSystem.delay_per_STA{j})-floor(length(simSystem.delay_per_STA{j})/10)), ...
                        'DisplayName', self.mechanisms{i});
                    hold on
                end
                title(horzcat('CDF of the delay per STA---', self.mechanisms{i}), 'interpreter','latex', 'FontSize', 14)
                xlabel('Delay [ms]', 'interpreter','latex', 'FontSize', 14)
                ylabel('F(x)', 'interpreter','latex', 'FontSize', 14)
                set(gca, 'TickLabelInterpreter','latex');
                legend(string(1:self.n_STAs), 'Interpreter','latex', 'location', 'southeast', 'Orientation', 'vertical'  , 'FontSize', 14)
                grid on
            end



        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function PlotPrctileDelayPerSTA(self, pctile)
            % Initialize a matrix to store the percentile delay values.
            percentile = NaN(self.n_STAs, self.numberOfmechanisms);  %STAs, number of mechanisms introduced
            
            % Iterate over each mechanism and compute the percentile delay for each STA.
            for j = 1:self.n_STAs
                for i = 1:self.numberOfmechanisms
                    A = horzcat('self.',self.mechanisms{i});
                    simSystem = eval(A);
                    percentile(j, i) = prctile(simSystem.delay_per_STA{j}, pctile)*1000;
                end
            end
            
            titletag = '';
            ylabeltag = horzcat(num2str(pctile),'$^\mathrm{th}$ percentile delay [ms]');
            self.CustomizeScatterPlot(self.n_STAs, percentile, titletag, ylabeltag);


        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function PlotTXOPwinNumber(self)
            % Method to plot the number of times that each AP wins the contention

            % Initialize a matrix to store the number of TXOPs won by each AP
            perAP_TXOPwinNumber = NaN(self.n_APs, self.numberOfmechanisms);  %STAs, number of mechanisms introduced

            % Iterate over each mechanism and compute perAP_TXOPwinNumber
            for j = 1:self.n_APs
                for i = 1:self.numberOfmechanisms
                    A = horzcat('self.',self.mechanisms{i});
                    simSystem = eval(A);
                    perAP_TXOPwinNumber(j, i) = simSystem.TXOPwinNumber(j);
                end
            end
            titletag = 'Number of TXOPs per AP';
            ylabeltag = 'Occurrences';
            self.CustomizeScatterPlot(self.n_APs, perAP_TXOPwinNumber, titletag, ylabeltag);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function PlotAPcollisionProb(self)
            % Method to plot the collision probability of each AP

            % Initialize a matrix to store the collision probability of each AP
            APcollision_prob = NaN(self.n_APs, self.numberOfmechanisms);  %STAs, number of mechanisms introduced

            % Iterate over each mechanism and compute perAP_TXOPwinNumber
            for j = 1:self.n_APs
                for i = 1:self.numberOfmechanisms
                    A = horzcat('self.',self.mechanisms{i});
                    simSystem = eval(A);
                    APcollision_prob(j, i) = simSystem.APcollision_prob(j);
                end
            end

            % Plotting using scatter plot for each active mechanism
            figure;
            hold on;

            % Scatter plot each mechanism without skipping based on data checks
            for j = 1:self.numberOfmechanisms
                scatter(1:self.n_APs, APcollision_prob(:, j), 100, 'filled', ...
                    'Marker', self.markers{j}, 'MarkerEdgeColor', self.colors{j}, 'MarkerFaceColor', self.colors{j}, ...
                    'DisplayName', self.mechanisms{j});
            end

            % Adding vertical lines to separate each AP without adding them to the legend
            for jjj = 1.5:1:(self.n_APs-0.5)
                xline(jjj, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.8, 'HandleVisibility', 'off');
            end

            % Customize plot
            title('Collision probability', 'interpreter','latex', 'FontSize', 14)
            xticks(1:self.n_APs);
            xticklabels(string(1:self.n_APs));
            xlim([0.5, self.n_APs+0.5]);  % Adding margin before the first STA and after the last one
            xlabel('STA', 'interpreter', 'latex', 'FontSize', 14);
            ylabel('Probability', 'interpreter', 'latex', 'FontSize', 16);
            ax = gca;
            ax.XAxis.LineWidth = 1.5;
            ax.YAxis.LineWidth = 1.5;
            set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 14);
            grid on;
            legend('Location', 'best', 'Interpreter', 'latex', 'Orientation', 'vertical', 'FontSize', 14);
            hold off;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function PlotSTAselectionCounter(self)
            % Method to plot the STA selection counter

            % Initialize a matrix to store the counter of selection times for each STA.
            STAselectionCounter = NaN(self.n_STAs, self.numberOfmechanisms);  %STAs, number of mechanisms introduced
            
            % Iterate over each mechanism and compute the percentile delay for each STA.
            for j = 1:self.n_STAs
                for i = 1:self.numberOfmechanisms
                    A = horzcat('self.',self.mechanisms{i});
                    simSystem = eval(A);
                    STAselectionCounter(j, i) = simSystem.STAselectionCounter(j);
                end
            end
            titletag = 'STA selection occurrences';
            ylabeltag = 'Occurrences';
            self.CustomizeScatterPlot(self.n_STAs, STAselectionCounter, titletag, ylabeltag);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function PlotPercentileVerbose(self, varargin)

            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('------------------------------------------------------------------------ \n');
            fprintf('Deployment %d  \n',varargin{1});
            
            % Iterate over each mechanism and compute the percentile delay for each STA.

            for i = 1:self.numberOfmechanisms
                for j = 1:length(varargin)-1
                    A = horzcat('self.',self.mechanisms{i});
                    simSystem = eval(A);
                    percentile = prctile(simSystem.delayvector, varargin{j+1})*1000;
                    texttag = horzcat(self.mechanisms{i}, ' ',num2str(varargin{j+1}), 'th-percentile delay = %f ms \n');
                    fprintf(texttag,percentile);
                end
            end

            fprintf('------------------------------------------------------------------------ \n');

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
end
