function [CGs_STAs, comb_ok] = CG_creation(AP_number, STA_number, DCFoverheads, CSRoverheads, ...
             Pn_dBm, Nsc, Nss, RSSI_dB_vector_to_export, association, TXOP_duration)

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
    txted_packets = zeros(size(map_matrix,1),size(map_matrix,2));
    %%%% For verifying the DL
    for i = 1:size(map_matrix,1)

        [~, APs] = find(map_matrix(i,:)~=0);
        STAs = map_matrix(i,APs);
    
        for k = 1:length(STAs)     
            if length(STAs) == 1
                SINR_db = RSSI_dB_vector_to_export(STAs(k),APs(k)) - 10*log10(10^(Pn_dBm/10));
                [MCS(k,1), N_bps(k,1), Rc(k,1)] = MCS_cal_PER_001(SINR_db);   
                if MCS(k,1) == -1
                    txted_packets(i,APs(k)) = 0;
                    discarded_comb(i) = 1; 
                else
                    txted_packets(i,APs(k)) = floor((1-1E-2)*tx_packets(Nsc, N_bps(k,1), Rc(k,1), Nss, TXOP_duration-DCFoverheads));
                end
                AP_ok = 1;
            else
                AP_other_vector = setdiff(APs,APs(k),'stable');
                intf = 0;
                for l = 1:length(AP_other_vector)
                    intf = intf + 10^(RSSI_dB_vector_to_export(STAs(k),AP_other_vector(l))/10);
                end    
                SINR_db = RSSI_dB_vector_to_export(STAs(k),APs(k)) - 10*log10(intf + 10^(Pn_dBm/10));
                [MCS(k,1), N_bps(k,1), Rc(k,1)] = MCS_cal_PER_001(SINR_db);   
                if MCS(k,1) == -1
                    txted_packets(i,APs(k)) = 0;
                    discarded_comb(i) = 1; 
                else
                    txted_packets(i,APs(k)) = floor((1-1E-2)*tx_packets(Nsc, N_bps(k,1), Rc(k,1), Nss, TXOP_duration-CSRoverheads));                                                                 
                end
                                      
                if length(STAs)*txted_packets(i,APs(k)) >= txted_packets(STAs(k),APs(k))
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
    % disp(sum(comb_ok));

    CGs_STAs = map_matrix;  % Final subsets of STAs
end