function [CGs_STAs]  = CG_creation_per_STA_heuristic_local(AP_number, STA_number, DCFoverheads, CSRoverheads, ...
                                Pn_dBm, Nsc, Nss, RSSI_dB_vector_to_export, capture_effect, association, TXOP_duration)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    one_STA_per_tx = zeros(STA_number,AP_number);
    for k = 1:STA_number
        idx_col = find(cellfun(@(x) ismember(k, x), association), 1);
        one_STA_per_tx(k,idx_col) = k;
    end
    
    u = cell(1,AP_number);
    for i = 1:AP_number
         u{:,i} = unique(one_STA_per_tx(:,i))';
    end
    map_matrix = combvec(u{:})';
    map_matrix(sum(map_matrix(:,:)==0,2)== AP_number,:) = [];
    
    idx_row = sum(map_matrix~=0,2);
    
    map_matrix(idx_row>AP_number,:) = [];
    
    %%%% Reordering the matrix, starting by the rows that have only one non-zero element
    u = sum(map_matrix~=0,2);
    map_matrix(u==1,:)=[];
    map_matrix = [one_STA_per_tx;map_matrix];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    alpha_coeff = zeros(size(map_matrix,1),1);
    txted_packets = zeros(size(map_matrix,1),size(map_matrix,2));
    discarded_comb = zeros(size(map_matrix,1),1);
        
    for i = 1:size(map_matrix,1)

        [~, APs] = find(map_matrix(i,:)~=0);
    
        STAs = map_matrix(i,APs);
        for k = 1:length(STAs)     
            if length(STAs) == 1
                SINR_db = RSSI_dB_vector_to_export(STAs(k),APs(k)) - 10*log10(10^(Pn_dBm/10));
                % [MCS(k,1), N_bps(k,1), Rc(k,1)] = MCS_cal_PER_001(SINR_db);  
                [MCS(k,1), N_bps(k,1), Rc(k,1)] = MCS_selection(RSSI_dB_vector_to_export(STAs(k),APs(k)));
                if MCS(k,1) == -1 || (SINR_db < capture_effect)
                    txted_packets(i,APs(k)) = 0;
                    discarded_comb(i) = 1; 
                else
                    txted_packets(i,APs(k)) = tx_packets(Nsc, N_bps(k,1), Rc(k,1), Nss, TXOP_duration-DCFoverheads);
                end
            else
                AP_other_vector = setdiff(APs,APs(k),'stable');
                intf = 0;
                for l = 1:length(AP_other_vector)
                    intf = intf + 10^(RSSI_dB_vector_to_export(STAs(k),AP_other_vector(l))/10);
                end    
                SINR_db = RSSI_dB_vector_to_export(STAs(k),APs(k)) - 10*log10(intf + 10^(Pn_dBm/10));
                % [MCS(k,1), N_bps(k,1), Rc(k,1)] = MCS_cal_PER_001(SINR_db);   
                [MCS(k,1), N_bps(k,1), Rc(k,1)] = MCS_selection(RSSI_dB_vector_to_export(STAs(k),APs(k)));
                if MCS(k,1) == -1 || (SINR_db < capture_effect)
                    txted_packets(i,APs(k)) = 0;
                    discarded_comb(i) = 1; 
                else
                    txted_packets(i,APs(k)) = tx_packets(Nsc, N_bps(k,1), Rc(k,1), Nss, TXOP_duration-CSRoverheads);                                                                 
                end
            end
        end
        alpha_coeff(i) = sum(txted_packets(i,:));
    end
    alpha_coeff(discarded_comb==1) = [];
    map_matrix(discarded_comb==1,:) = [];
    
    
    % comb_ok = zeros(size(map_matrix,1),1);
    % %%%% For verifying the UL
    % for i = 1:size(map_matrix,1)
    %     [~, APs] = find(map_matrix(i,:)~=0);
    % %     STAs = map_matrix(i,map_matrix(i,:)~=0);
    %     STAs = map_matrix(i,APs);
    %     for k = 1:length(STAs)     
    %         if length(STAs) == 1
    %             SINR_k = RSSI_dB_vector_to_export(STAs(k),APs(k)) - Pn_dBm;
    %             if SINR_k >= capture_effect
    %                 AP_ok = 1;
    %                 continue            
    %             else
    %                 AP_ok = 0;
    %             end
    %         else
    %             STA_other_vector = setdiff(STAs,STAs(k),'stable');
    %             intf = 0;
    %             for l = 1:length(STA_other_vector)
    %                 intf = intf + 10^(RSSI_dB_vector_to_export(STA_other_vector(l),APs(k))/10);
    %             end    
    % 
    %             SINR_k = RSSI_dB_vector_to_export(STAs(k),APs(k)) - 10*log10(intf + 10^(Pn_dBm/10));
    %             if SINR_k >= capture_effect
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
    
    % alpha_coeff(comb_ok==0) = [];
    % map_matrix(comb_ok==0,:) = [];
    
    %%% This line increases the value of each combination based on the number of tx devices
    alpha_coeff = alpha_coeff.*sum(map_matrix~=0,2);

    % Sort the coeff matrix by highest values 
    [b, pos] = maxk(alpha_coeff, size(map_matrix,1));
    
    % vector d returns the first ocurrence row to each STA  
    for r = 1:STA_number
        x = find(sum(map_matrix(pos,:)==r,2)==1);
        d(r,1) = x(1);
    end
    
    % e has the number of the row and p the number of the STA.
    % These values were sorted in a such a way that the first one is the WORST
    % of all.
    [e, p] = mink(d,STA_number);
    
    % stop_counter is used to stop the searching for a given STA when the
    % value of it is equal to number_tx_STA
    
    number_tx_STA = 1;
    stop_counter = zeros(STA_number,1);
    controller = 1;
    for j = 1:STA_number 
            counter = e(j,1);
        while (stop_counter(p(j),1) ~= number_tx_STA) && (counter ~= size(map_matrix,1) + 1)
    
            % if set_controller = 1, the combination will be selected,
            % otherwise not
            set_controller = 1;
    
            for k = 1:AP_number % looks for negative conditions (zero value, and the STA has already achieved its max allowed number of tx)
                if map_matrix(pos(counter,1),k) == 0 % no need to analise zero values
                    continue
                elseif stop_counter(map_matrix(pos(counter,1),k),1) == number_tx_STA % the STA has achieved the max number of tx (number_tx_STA)
                    set_controller = 0;
                end
            end
    
            for kk = 1:AP_number 
                if map_matrix(pos(counter,1),kk) == 0 % no need to analise zero values
                    continue
                elseif  set_controller == 1 % looks for positive conditions (the row will be selected)          
                    stop_counter(map_matrix(pos(counter,1),kk),1) = stop_counter(map_matrix(pos(counter,1),kk),1) + 1;                        
                end
            end
            if set_controller == 1
                index(controller,1) = pos(counter,1);   % Stores the indexes for the selected combinations 
    %             pwr_index(controller,1) = power_comb_index(pos(counter,1),1);
                controller = controller + 1;
            end
    
            counter = counter + 1; 
    %         if counter == size(map_matrix,1) + 1
    %             index = index_ref;           
    %             break
    %         end
    
                
        end   
    end
    
    % Stores the selected rows from the map_matrix     
    CGs_STAs = map_matrix(index,:);

    % %%% Select the best groups between the selected C-SR groups and DCF's
    % if sum(alpha_coeff(index))/length(index) < sum(alpha_coeff(1:STA_number))/STA_number
    %     CGs_STAs = map_matrix(1:STA_number,:);
    % end
    
end