function [DL_throughput_CSR_bianchi, prob_col_bianchi] = Throughput_CSR_bianchi(AP_number, STA_number, CGs_STAs, TxPowerMatrix, ...
                                        channelMatrix, Pn_dBm, Nsc, Nss, TXOP_duration, CSRoverheads, EDCAaccessCategory)
    
    noise_power = 10^(Pn_dBm/10);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% MAPC overheads
    
    TSIFS = 16e-6;             % Shortest Interframe spacing (SIFS time)
    % TDIFS = 34E-6;
    % TRTS = 56E-6;
    % TCTS = 48E-6;

    TMAPC_ICF = 74.4E-6;
    TMAPC_ICR = 88E-6;

    Te = 9e-6;

    rx_packets = zeros(size(CGs_STAs,1),size(CGs_STAs,2));
    
    %%%%% This array stores the combiantions where each STA appears
    per_STA_rx_packets = cell(STA_number,1);

    for i = 1:size(CGs_STAs,1)
    
        [~, APs] = find(CGs_STAs(i,:)~=0);
        STAs = CGs_STAs(i,APs);

        H = channelMatrix(STAs, APs);
    
        MCS = NaN(length(STAs),1);
        N_bps = NaN(length(STAs),1);
        Rc = NaN(length(STAs),1);
        
        P = TxPowerMatrix(i,APs)';
        SINR_db = 10*log10((P .* diag(H)) ./ (noise_power + sum(H .* P', 2) - diag(H) .* P));

        for k = 1:length(STAs)
            [MCS(k,1), N_bps(k,1), Rc(k,1)] = MCS_cal_PER_001(SINR_db(k,1));

            if isnan(MCS(k,1))
                rx_packets(i,APs(k)) = 0;
            else
                rx_packets(i,APs(k)) = tx_packets(Nsc, N_bps(k,1), Rc(k,1), Nss, TXOP_duration-CSRoverheads);
            end
    
            if rx_packets(i,APs(k))> 1024
                error('Imposible to tx more than 1024 MSDUs')
            end
    
            per_STA_rx_packets{STAs(k)}(end+1,1)= rx_packets(i,APs(k));
    
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Bianchi section %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    L = 12e3;
      
    % m = 6;                  %%% maximum number of backoff stages
    
    %%%%%%% DL calculation %%%%%%%%%%%%%%%%%%%%%% 
    [tau_DL, ~, prob_col_bianchi ] = SimpleDCF_modelWithBEB(AP_number, EDCAaccessCategory);
    
    pe_DL = (1-tau_DL)^AP_number;
    ps_DL = AP_number*tau_DL*(1-tau_DL)^(AP_number-1); 
    pc_DL = 1-pe_DL-ps_DL;

    switch EDCAaccessCategory
        case 'VI'
            AIFSN = 2;
        case 'BE'
            AIFSN = 3;
    end

    AIFS = AIFSN*Te + TSIFS;  % AIFSN*slotTime + SIFS
    Tcoll = TMAPC_ICF + TSIFS + TMAPC_ICR + AIFS + Te;       % Collision duration

    p_comb = 1/(size(CGs_STAs,1));   %%% all groups with the same tx prob (round robin)
    
    DL_throughput_CSR_bianchi = zeros(1,STA_number);
    for kk=1:STA_number
        
        DL_throughput_CSR_bianchi(kk) = p_comb*ps_DL*L*sum(per_STA_rx_packets{kk})/(1e6*(pe_DL*Te + ps_DL*TXOP_duration + pc_DL*Tcoll));
        if DL_throughput_CSR_bianchi(kk)==0
            error('Throughput = 0 is not allowed');
        end
    end  
end