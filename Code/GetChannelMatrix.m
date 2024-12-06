function [channelMatrix, RSSI_dB_vector_to_export] = GetChannelMatrix(MaxTxPower, Cca, AP_matrix, STA_matrix, scenario_type, walls)    

% Matrix stores all the AP-STA channel coefficients 
channelMatrix = zeros(size(STA_matrix,1),size(AP_matrix,1));

% Stores the RSSI value considering the channel effect and the maximum TX power allowed
RSSI_dB_vector_to_export = zeros(size(STA_matrix,1),size(AP_matrix,1));

NumberOfWallsAP_STA_Matrix = zeros(size(STA_matrix,1),size(AP_matrix,1));  % Matrix that contains the number of walls between APs and STAs
NumberOfWallsAP_AP_Matrix = zeros(size(AP_matrix,1),size(AP_matrix,1));   % Matrix that contains the number of walls between APs

AP_to_AP_RSSI_matrix = zeros(size(AP_matrix,1),size(AP_matrix,1));

for k = 1:size(AP_matrix,1)
    for kk = 1:size(STA_matrix,1)
        for kkk = 1:size(walls,1) % Verifying the number of walls between AP_k and STA_kk
            isIntersecting = checkSegmentIntersection(AP_matrix(k,1), STA_matrix(kk,1), AP_matrix(k,2), STA_matrix(kk,2), walls(kkk,1), walls(kkk,2), walls(kkk,3), walls(kkk,4));
            if isIntersecting
                NumberOfWallsAP_STA_Matrix(kk,k) = NumberOfWallsAP_STA_Matrix(kk,k) + 1;
            end
        end
        std_dev = 5;  % std deviation for shadowing
        channelCoefficient_dB = Getloss(AP_matrix(k,:), STA_matrix(kk,:), NumberOfWallsAP_STA_Matrix(kk,k), std_dev);
        channelMatrix(kk,k) = 1/10^(channelCoefficient_dB/10);
        RSSI_dB_vector_to_export(kk,k) = MaxTxPower - channelCoefficient_dB;
        
    end
    AP_other_vector = setdiff(1:size(AP_matrix,1),k);
    for i = 1:length(AP_other_vector)
        for ii = 1:size(walls,1) % Verifying the number of walls between AP_k and AP_i
            isIntersecting = checkSegmentIntersection(AP_matrix(k,1), AP_matrix(AP_other_vector(i),1), AP_matrix(k,2), AP_matrix(AP_other_vector(i),2), walls(ii,1), walls(ii,2), walls(ii,3), walls(ii,4));
            if isIntersecting
                NumberOfWallsAP_AP_Matrix(k,AP_other_vector(i)) = NumberOfWallsAP_AP_Matrix(k,AP_other_vector(i)) + 1;
            end
        end
        switch scenario_type
            case 'random'
                std_dev = 0;  % no shadowing between APs
                channelCoefficient_dB = Getloss(AP_matrix(k,:), AP_matrix(AP_other_vector(i),:),  NumberOfWallsAP_AP_Matrix(k,AP_other_vector(i)), std_dev);
                AP_to_AP_RSSI_matrix(k,AP_other_vector(i)) = MaxTxPower - channelCoefficient_dB;
            case 'grid'
                std_dev = 0;  % no shadowing between APs
                channelCoefficient_dB = Getloss(AP_matrix(k,:), AP_matrix(AP_other_vector(i),:),  1, std_dev);
                AP_to_AP_RSSI_matrix(k,AP_other_vector(i)) = MaxTxPower - channelCoefficient_dB; % Considering only 1 wall between APs
        end
    end
end

%%% Validation
if min(AP_to_AP_RSSI_matrix, [], 'all') < Cca
    error('Scenario constraint: RSSI between APs is under the Cca threshold. All APs should be in the coverage area of the others')
end


end