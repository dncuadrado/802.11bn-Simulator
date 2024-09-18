function [per_STA_DCF_throughput_bianchi, prob_col_bianchi] = Throughput_DCF_bianchi(AP_number, STA_number, association, RSSI_dB_vector_to_export, ...
                                            Pn_dBm, Nsc, Nss, TXOP_duration, DCFoverheads)
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    TSIFS = 16e-6;      % Shortest Interframe spacing (SIFS time)
    TDIFS = 34E-6;      % DCF Interframe spacing (DIFS time)
    % TRTS = 56E-6;       % RTS duration
    % TCTS = 48E-6;       % CTS duration
    TRTS = 42E-6;
    TCTS = 36E-6;
    
    L = 12e3;           % Single frame length
    % CWmin=15;           % minimum contention window
    Te = 9e-6;          % Duration of a single backoff slot
    Tcoll = TRTS + TSIFS + TCTS + TDIFS + Te;       % Collision duration
    
    % m = 6;                  %%% number of backoff stages
    
    %%% Computing bianchi's parameters
    [tau, ~, prob_col_bianchi] = SimpleDCF_modelWithBEB(AP_number);
    pe = (1-tau)^AP_number;
    ps = AP_number*tau*(1-tau)^(AP_number-1);
    pc = 1-pe-ps;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    rx_packets = zeros(STA_number,1);
    per_STA_DCF_throughput_bianchi = zeros(STA_number,1);
    
    %%% Initializing tx parameters
    MCS = zeros(STA_number,1);
    N_bps = zeros(STA_number,1);
    Rc = zeros(STA_number,1);
    
    for kk = 1:STA_number
        % Find the AP to which the STA_kk is associated
        ix = find(cellfun(@(x) ismember(kk, x), association), 1);
    
        p_STA = 1/(AP_number*length([association{ix}]));               % Probability of STA_kk being selected
        

        SINR_db = RSSI_dB_vector_to_export(kk,ix) - Pn_dBm;             % SINR calculation
        [MCS(kk), N_bps(kk), Rc(kk)] = MCS_cal_PER_001(SINR_db);          % MCS calculation
    
        %%%% Validation
        if MCS(kk) == -1
            error('Not valid MCS');
        end
    
        rx_packets(kk) = tx_packets(Nsc, N_bps(kk), Rc(kk), Nss, TXOP_duration-DCFoverheads);
        if rx_packets(kk) > 1024
            error('Imposible to tx more than 1024 MSDUs')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        %%% Throughput calculation following bianchi's model
        % DL_throughput_CSR_bianchi(kk) = p_comb*ps_DL*L*sum(per_STA_rx_packets{kk})/(1e6*(pe_DL*Te + ps_DL*(fullOverheads+elapsed_time(ix)) + pc_DL*Tcoll));
        % per_STA_DCF_throughput_bianchi(kk,1) = p_STA*ps*rx_packets(kk)*L/(1e6*(pe*Te + ps*elapsed_time(kk) + pc*Tcoll));
        per_STA_DCF_throughput_bianchi(kk,1) = p_STA*ps*rx_packets(kk)*L/(1e6*(pe*Te + ps*TXOP_duration + pc*Tcoll));
    end
            
end

