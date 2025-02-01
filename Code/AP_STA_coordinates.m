function [AP_matrix, STA_matrix] = AP_STA_coordinates(AP_number, STA_number, scenario_type, grid_value)
    %%% Computes the matrices with the coordinates of the devices (AP_matrix and STA_matrix)


    % Average number of STAs associated to each AP
    STAs_per_AP = STA_number/AP_number;
     
    %%% Max Distance between AP and STA (used only in 'grid')
    AP_STA_max_distance = 10;  % in meters
    if AP_STA_max_distance > grid_value/4      % Forcing the STAs to be in the corresponding subarea 
        AP_STA_max_distance = grid_value/4;
    end


    %%% Stop the while loop
    stopwhile = 0;

    while stopwhile == 0
        %%% Initializing matrices
        AP_matrix = zeros(AP_number, 2);
        STA_matrix = zeros(STA_number,2);

        switch scenario_type
            case 'grid'
                %%%%%%%%%   APs are manually placed and each STA is placed at most 
                %%%%%%%%%   "max_distance" away from its corresponding AP

                %%% APs manually placed
                AP_matrix = [grid_value/4,grid_value/4;
                    grid_value/4,3*grid_value/4;
                    3*grid_value/4,grid_value/4;
                    3*grid_value/4,3*grid_value/4];

                for j = 1:AP_number
                    %%% STA placement
                    for kk = 1:STAs_per_AP

                        %%% Polar coordinates with the constraint impossed by the pathloss model (distance > 1 meter)
                        N = 1;
                        t = AP_STA_max_distance * pi * rand(N,1);
                        g = 1 + (AP_STA_max_distance-1).*rand(N,1);
                        STA_matrix((j-1)*STAs_per_AP+kk,1) = AP_matrix(j,1) + g.*cos(t);
                        STA_matrix((j-1)*STAs_per_AP+kk,2) = AP_matrix(j,2) + g.*sin(t);     
                    end
                end
        end

        
        % Check if some stations are located at the same coordinates
        [u,~,~] = unique(STA_matrix, 'rows', 'first');   
        if size(u,1) == STA_number && sum(ismember(AP_matrix, STA_matrix, 'rows'),1) == 0
            stopwhile = 1;
        end  
    
    end
    
    %%% Validations
    if size(AP_matrix,1) ~= AP_number 
        error('AP_number does not match with AP_matrix dimension')
    end
    if size(STA_matrix,1) ~= STA_number 
        error('STA_number does not match with STA_matrix dimension')
    end

end