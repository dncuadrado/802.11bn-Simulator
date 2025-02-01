function [per_STA_EDCA_throughput_bianchi, prob_col_bianchi] = Throughput_EDCA_bianchi(AP_number, STA_number, association, RSSI_dB_vector_to_export, ...
                                            Pn_dBm, Nsc, Nss, TXOP_duration, EDCAoverheads, EDCAaccessCategory)
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    TSIFS = 16e-6;      % Shortest Interframe spacing (SIFS time)
    TRTS = 56E-6;       % RTS duration
    TCTS = 48E-6;       % CTS duration

    
    L = 12e3;           % Single frame length
    Te = 9e-6;          % Duration of a single backoff slot

    switch EDCAaccessCategory
        case 'VI'
            AIFSN = 2;
        case 'BE'
            AIFSN = 3;
    end

    AIFS = AIFSN*Te + TSIFS;  % AIFSN*slotTime + SIFS
    Tcoll = TRTS + TSIFS + TCTS + AIFS + Te;       % Collision duration
    
    %%% Computing bianchi's parameters
    [tau, ~, prob_col_bianchi] = SimpleEDCA_modelWithBEB(AP_number, EDCAaccessCategory);
    pe = (1-tau)^AP_number;
    ps = AP_number*tau*(1-tau)^(AP_number-1);
    pc = 1-pe-ps;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    rx_packets = zeros(STA_number,1);
    per_STA_EDCA_throughput_bianchi = zeros(STA_number,1);
    
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
        if isnan(MCS(kk))
            error('Not valid MCS');
        end
    
        rx_packets(kk) = tx_packets(Nsc, N_bps(kk), Rc(kk), Nss, TXOP_duration-EDCAoverheads);
        if rx_packets(kk) > 1024
            error('Imposible to tx more than 1024 MPDUs')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        %%% Throughput calculation following bianchi's model
        per_STA_EDCA_throughput_bianchi(kk,1) = p_STA*ps*rx_packets(kk)*L/(1e6*(pe*Te + ps*TXOP_duration + pc*Tcoll));
    end
            
end

