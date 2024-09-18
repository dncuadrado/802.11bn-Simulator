function PlotDeployment(AP_matrix, STA_matrix, association, grid_value, walls)

    figure('pos',[300 500 400 390])
    
    if size(AP_matrix,1) < 10
        AP_colours = [0.0763082893739572,0.499882500825560,0.931206019689022;...
            0.779918792240115,0.679229996120941,0.0248992275503480;...
            0.438409231440894,0.803739036104376,0.600548917464123;...
            0.723465177830941,0.380941133148538,0.950129500413646;...
            0.977989511996603,0.0659363469059051,0.230302879020965;...
            0.538495870410434,0.288145599307994,0.548489919236030;...
            0.501120463659938,0.909593527719614,0.909128374886731;...
            0.0720511333597615,0.213385353579916,0.133169445759250;...
            0.268438980101871,0.452123961817683,0.523412580673766];
    else
        AP_colours = rand(size(AP_matrix,1),3);
    end

    
    % AP_colours = [0 0 1; ...   % 3
    %               1 1 0; ...   % 4
    %               0 0 1; ...   
    %               1 1 0; ...          
    %               1 0 0; ...   % 1            
    %               0 1 0; ...   % 2                      
    %               1 0 0; ...
    %               0 1 0; ...
    %               0 0 1; ... 
    %               1 1 0; ...  
    %               0 0 1; ...   
    %               1 1 0;
    %               1 0 0; ...              
    %               0 1 0; ...                        
    %               1 0 0; ...
    %               0 1 0;];
    plot1 = [0 0];
        %%% Plotting the APs
    for k = 1:size(AP_matrix,1)
        plot1(1) = plot(AP_matrix(k,1), AP_matrix(k,2));
        text(AP_matrix(k,1), AP_matrix(k,2), sprintf('AP$_{%d}$', k), 'interpreter','latex', 'FontSize', 14, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        set(plot1(1),...
            'DisplayName', horzcat('AP',int2str(k)),...
            'MarkerEdgeColor', AP_colours(k,:), ...
            'MarkerFaceColor', AP_colours(k,:), ...
            'Color', AP_colours(k,:), ...
            'Marker', 'v',...
            'MarkerSize', 6, ...
            'LineWidth', 2);       
        hold on
    end
    
    
    for j = 1:size(STA_matrix,1)
        % Find the position where the current value appears in the association cell array
        idxCol = find(cellfun(@(x) ismember(j, x), association), 1);
        plot1(2) = plot(STA_matrix(j,1), STA_matrix(j,2));
        
        text(STA_matrix(j,1), STA_matrix(j,2), sprintf('STA$_{%d}$', j) , 'interpreter','latex', 'FontSize', 14, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        % text(STA_matrix(j,1), STA_matrix(j,2), int2str(j) , 'interpreter','latex', 'FontSize', 14, ...
        %     'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        set(plot1(2),...
            'DisplayName', horzcat('STA',int2str(j)),...
            'MarkerEdgeColor', AP_colours(idxCol,:), ...
            'MarkerFaceColor', AP_colours(idxCol,:), ...
            'Color', AP_colours(idxCol,:), ...
            'Marker', 's',...
            'MarkerSize', 6, ...
            'LineWidth', 2);     
        hold on
    end
    
    %%% Plotting the walls
    for i=1:size(walls,1)
        plot1(3) = plot([walls(i,1) walls(i,2)],[walls(i,3) walls(i,4)]);
        set(plot1(3),...
            'Color', 'k', ...
            'LineWidth', 2);    
        hold on
    end
    
    
    grid on
    xlabel('X-axis [meters]', 'interpreter','latex', 'FontSize', 16);
    ylabel('Y-axis [meters]', 'interpreter','latex', 'FontSize', 16);
    set(gca, 'TickLabelInterpreter','latex', 'FontSize', 12);
    xticks(0:5:grid_value)
    yticks(0:5:grid_value)
    xlim([0 grid_value]);
    ylim([0 grid_value]);

end