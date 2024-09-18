function [RSSI_dB_vector_to_export, association, NumberOfWallsAP_STA_Matrix] = RSSI_database(tx_power, Cca, AP_matrix, STA_matrix, scenario_type, walls)

    %%% This function returns a matrix with the RSSI seen from all stations and also a cell array with a list of STAs by AP                     
                       
    RSSI_dB_vector_to_export = zeros(size(STA_matrix,1),size(AP_matrix,1));
    
    NumberOfWallsAP_STA_Matrix = zeros(size(STA_matrix,1),size(AP_matrix,1));  % Matrix that contains the number of walls between APs and STAs
    NumberOfWallsAP_AP_Matrix = zeros(size(AP_matrix,1),size(AP_matrix,1));   % Matrix that contains the number of walls between APs 

    AP_to_AP_RSSI_matrix = zeros(size(AP_matrix,1),size(AP_matrix,1));
    
    for k = 1:size(AP_matrix,1)            
        for kk = 1:size(STA_matrix,1)      
            for kkk = 1:size(walls,1) % Verifying the number of walls between AP_k and STA_kk 
                isIntersecting = checkSegmentIntersection([AP_matrix(k,1), STA_matrix(kk,1), AP_matrix(k,2), STA_matrix(kk,2)], walls(kkk,:));
                if isIntersecting
                    NumberOfWallsAP_STA_Matrix(kk,k) = NumberOfWallsAP_STA_Matrix(kk,k) + 1;
                end
            end
            RSSI_dB_vector_to_export(kk,k) = tx_power - Getloss(AP_matrix(k,:), STA_matrix(kk,:), NumberOfWallsAP_STA_Matrix(kk,k));
        end 
        AP_other_vector = setdiff(1:size(AP_matrix,1),k);
        for i = 1:length(AP_other_vector)
            for ii = 1:size(walls,1) % Verifying the number of walls between AP_k and AP_i
                isIntersecting = checkSegmentIntersection([AP_matrix(k,1), AP_matrix(AP_other_vector(i),1), AP_matrix(k,2), AP_matrix(AP_other_vector(i),2)], walls(ii,:));
                if isIntersecting
                    NumberOfWallsAP_AP_Matrix(k,AP_other_vector(i)) = NumberOfWallsAP_AP_Matrix(k,AP_other_vector(i)) + 1;
                end
            end
            switch scenario_type
                case 'random'
                    AP_to_AP_RSSI_matrix(k,AP_other_vector(i)) = tx_power - Getloss(AP_matrix(k,:), AP_matrix(AP_other_vector(i),:),  NumberOfWallsAP_AP_Matrix(k,AP_other_vector(i)));
                case 'grid'
                    AP_to_AP_RSSI_matrix(k,AP_other_vector(i)) = tx_power - Getloss(AP_matrix(k,:), AP_matrix(AP_other_vector(i),:),  1); % Considering only 1 wall between APs
            end
        end
    end

    %%% Validation
    if min(AP_to_AP_RSSI_matrix, [], 'all') < Cca
        error('Scenario constraint: RSSI between APs is under the Cca threshold. All APs should be in the coverage area of the others')
    end

    %%% Association process
    association = cell(size(AP_matrix,1),1);
    
    [~,idx] = max(RSSI_dB_vector_to_export,[],2);
    for j = 1:size(AP_matrix,1)
        association{j,1} = find(idx==j);

        %%% Validation
        if isempty(association{j,1})
            error(['Scenario constraint: APs without any associated STAs is not allowed. ...' ...
                    'Check the AP and STAs positions and try again'])
        end
    end

end