function CGs_STAs = CG_creation_per_STA(AP_number, STA_number, gamma_value, ...
                                Pn_dBm, RSSI_dB_vector_to_export, association)
    %%%%%%% This function returns the groups of STAs that are SR-compatible if  SINR > gamma
    %%%%%%% It's assumed that ACKs are sent using OFDMA so it does not verify the uplink. 
    %%%%%%% The last part of the code verifies the uplink, uncomment it if needed

    CG_size = AP_number; % Establishing the max number of AP per group

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Creating a 2D matrix with all possible AP-STA combinations 
    one_STA_per_tx = zeros(STA_number,AP_number);

    for k = 1:AP_number
        one_STA_per_tx([association{k}],k) = [association{k}];
    end
    
    u = cell(1,AP_number);
    for i = 1:AP_number
         u{:,i} = unique(one_STA_per_tx(:,i))';
    end
    map_matrix = combvec(u{:})';
    map_matrix(sum(map_matrix(:,:)==0,2)== AP_number,:) = [];
    
    idx_row = sum(map_matrix~=0,2);
    
    map_matrix(idx_row>CG_size,:) = [];
    
    %%%% Reordering the matrix, starting by the rows that have only one non-zero element
    u = sum(map_matrix~=0,2);
    map_matrix(u==1,:)=[];
    map_matrix = [one_STA_per_tx;map_matrix];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    comb_ok = zeros(size(map_matrix,1),1);
    
    %%%% For verifying the DL
    for i = 1:size(map_matrix,1)

        [~, APs] = find(map_matrix(i,:)~=0);
        STAs = map_matrix(i,APs);
    
        for k = 1:length(STAs)     
            if length(STAs) == 1
                AP_ok = 1;
                continue  
            else
                AP_other_vector = setdiff(APs,APs(k),'stable');
                intf = 0;
                for l = 1:length(AP_other_vector)
                    intf = intf + 10^(RSSI_dB_vector_to_export(STAs(k),AP_other_vector(l))/10);
                end    
                SINR_k = RSSI_dB_vector_to_export(STAs(k),APs(k)) - 10*log10(intf + 10^(Pn_dBm/10));
                                      
                if SINR_k > gamma_value
                    AP_ok = 1;
                    continue            
                else
                    AP_ok = 0;
                    break
                end
            end
        end
        if AP_ok == 1
            comb_ok(i) = 1; 
        end
    end
    
    map_matrix(comb_ok==0,:) = []; 


    % %%%% For verifying the UL
    % comb_ok = zeros(size(map_matrix,1),1);
    % 
    % for i = 1:size(map_matrix,1)
    % 
    %     [~, APs] = find(map_matrix(i,:)~=0);
    %     STAs = map_matrix(i,APs);
    %     for k = 1:length(STAs)     
    %         if length(STAs) == 1
    %             AP_ok = 1;
    %             continue  
    %         else
    %             STA_other_vector = setdiff(STAs,STAs(k),'stable');
    %             intf = 0;
    %             for l = 1:length(STA_other_vector)
    %                 intf = intf + 10^(RSSI_dB_vector_to_export(STA_other_vector(l),APs(k))/10);
    %             end    
    % 
    %             SINR_k = RSSI_dB_vector_to_export(STAs(k),APs(k)) - 10*log10(intf + 10^(Pn_dBm/10));
    %             if SINR_k > gamma_value
    %                 AP_ok = 1;
    %                 continue            
    %             else
    %                 AP_ok = 0;
    %                 break
    %             end
    %         end
    %     end
    %     if AP_ok == 1
    %         comb_ok(i) = 1; 
    %     end
    % end
    % 
    % 
    % CGs_STAs = map_matrix(comb_ok==1,:);          % Final subsets of STAs

    CGs_STAs = map_matrix;  % Final subsets of STAs
end