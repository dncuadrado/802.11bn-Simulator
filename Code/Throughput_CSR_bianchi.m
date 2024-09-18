function [DL_throughput_CSR_bianchi, prob_col_bianchi] = Throughput_CSR_bianchi(AP_number, STA_number, association, CGs_STAs, ...
                        RSSI_dB_vector_to_export, Pn_dBm, Nsc, Nss, TXOP_duration, DCFoverheads, CSRoverheads)
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% MAPC overheads

    % T_MAPC_RTS = 160E-6;
    % T_CTS = 36E-6; 
    % T_MAPC_ReportPoll = 160E-6;
    % T_BSRPoll = 160E-6;
    % T_BSRReport = 250E-6; 
    % T_BACK = 80E-6;
    % T_MAPC_TXOP = 160E-6; 
    % T_BasicTF = 160E-6;
    
    T_SIFS = 16e-6;             % Shortest Interframe spacing (SIFS time)
    T_DIFS = 34E-6;
    T_RTS = 42E-6;
    T_CTS = 36E-6;
    Te = 9e-6;

    rx_packets = zeros(size(CGs_STAs,1),size(CGs_STAs,2));
    
    %%%%% This array stores the combiantions where each STA appears
    per_STA_rx_packets = cell(STA_number,ones(1,1));
    check_MAPC = zeros(size(RSSI_dB_vector_to_export,1),1);
    for i = 1:size(CGs_STAs,1)
    
        [~, APs] = find(CGs_STAs(i,:)~=0);
        STAs = CGs_STAs(i,APs);
    
        MCS = zeros(length(STAs),1);
        N_bps = zeros(length(STAs),1);
        Rc = zeros(length(STAs),1);
    
        for k = 1:length(STAs)
            if length(STAs) == 1
                check_MAPC(STAs(k)) = 0;
                SINR_db = RSSI_dB_vector_to_export(STAs(k),APs(k)) - 10*log10(10^(Pn_dBm/10));
                [MCS(k,1), N_bps(k,1), Rc(k,1)] = MCS_cal_PER_001(SINR_db);    % MCS index is hidden (~)
                if MCS(k,1) == -1
                    rx_packets(i,APs(k)) = 0;
                else
                    [rx_packets(i,APs(k))] = tx_packets(Nsc, N_bps(k,1), Rc(k,1), Nss, TXOP_duration-CSRoverheads);
                end
            else
                check_MAPC(STAs(k)) = 1;
                AP_other_vector = setdiff(APs,APs(k),'stable');
                intf = 0;
                for l = 1:length(AP_other_vector)
                    intf = intf + 10^(RSSI_dB_vector_to_export(STAs(k),AP_other_vector(l))/10);
                end
    
                SINR_db = RSSI_dB_vector_to_export(STAs(k),APs(k)) - 10*log10(intf + 10^(Pn_dBm/10));
                [MCS(k,1), N_bps(k,1), Rc(k,1)] = MCS_cal_PER_001(SINR_db);    % MCS index is hidden (~)
                if MCS(k,1) == -1
                    rx_packets(i,APs(k)) = 0;
                else
                    [rx_packets(i,APs(k))] = tx_packets(Nsc, N_bps(k,1), Rc(k,1), Nss, TXOP_duration-CSRoverheads);
                end
            end
    
            if rx_packets(i,APs(k))> 1024
                error('Imposible to tx more than 1024 MSDUs')
            end
    
            per_STA_rx_packets{STAs(k)}(end+1,1)= rx_packets(i,APs(k));
    
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Bianchi section %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% overheads  
    % T_MAPC_RTS = 160E-6;
    % T_MAPC_TXOP = 160E-6;
    % T_BasicTF = 160E-6;
    
    % TSIFS = 16e-6;             % Shortest Interframe spacing (SIFS time)
    % TDIFS = 34E-6;
    % TRTS = 56E-6;
    % TCTS = 48E-6;
    % Te = 9e-6;

    L = 12e3;
    % CWmin=15; 
      
    % m = 6;                  %%% maximum number of backoff stages
    
    %%%%%%% DL calculation %%%%%%%%%%%%%%%%%%%%%% 
    [tau_DL, ~, prob_col_bianchi ] = SimpleDCF_modelWithBEB(AP_number);
    
    pe_DL = (1-tau_DL)^AP_number;
    ps_DL = AP_number*tau_DL*(1-tau_DL)^(AP_number-1); 
    pc_DL = 1-pe_DL-ps_DL;
    % Tcoll = TRTS + TSIFS + TCTS + TDIFS + Te;

    % p_comb_vector = zeros(size(CGs_STAs,1),1);
    % 
    % for ii=1:size(CGs_STAs,1)
    %     STAs = CGs_STAs(ii,CGs_STAs(ii,:)~=0);
    % 
    %     probabilityOfBeingSelected = [];
    %     for jj = 1:length(STAs)
    %         idx = find(cellfun(@(x) ismember(STAs(jj), x), association), 1);
    %         % [~,idxcol] = find(association == STAs(jj));
    %         probabilityOfBeingSelected(jj) = 1/(sum(association{idx}~=0));
    %     end
    % 
    %     p_comb_vector(ii) = (1/AP_number)*sum(probabilityOfBeingSelected);
    % 
    % 
    % end 

    p_comb = 1/(size(CGs_STAs,1));   %%% all groups with the same tx prob (round robin)

    for kk=1:STA_number
        [ix_row,~] = find(CGs_STAs ==kk);
        % p_comb = p_comb_vector(ix_row);
        % if check_MAPC(kk) == 1
        %     Tcoll = T_MAPC_RTS + T_SIFS + T_CTS + T_DIFS + Te;
        % else 
        %     Tcoll = T_RTS + T_SIFS + T_CTS + T_DIFS + Te;
        % end
        Tcoll = T_RTS + T_SIFS + T_CTS + T_DIFS + Te;
     
        DL_throughput_CSR_bianchi(kk) = p_comb*ps_DL*L*sum(per_STA_rx_packets{kk})/(1e6*(pe_DL*Te + ps_DL*TXOP_duration + pc_DL*Tcoll));
        if DL_throughput_CSR_bianchi(kk)==0
            error('Throughput = 0 is not allowed');
        end
    end  

end