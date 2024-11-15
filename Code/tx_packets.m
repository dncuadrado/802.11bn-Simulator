function agg_packets = tx_packets(Nsc, N_bps, Rc, Nss, data_tx_time)
    % Returns the A-MPDU length
    
    T_DFT = 12.8e-6;            % OFDM symbol duration
    T_GI = 0.8e-6;              % Guard interval duration  
    
    % time_preamble_data = 100e-6;        % Legacy preamble + data
    % TBACK = 100E-6;
    % TSIFS = 16e-6;                      % Shortest Interframe spacing (SIFS time)
    % DIFS = 34e-6;                       % DCF Interframe spacing (DIFS time)
    % Te = 9e-6;                          % Duration of an empty slot
    
    Lsf = 16;                           % Length of service field (bits)
    Lmh = 240;                          % MAC header (bits)
    Ld = 12e3;                          % Frame size (bits)
    Ltail = 18;                         % Tail (bits)
    % Lack = 112;                         % ACK length (bits)
    
    Lmd = 32;                       % MPDU Delimiter (bits) used only in A-MPDU scenarios
    
        
    
    
    
    %%% Calculates the number of packets that can be tx for a given time
    agg_packets = fix((1/(Lmd + Lmh + Ld))*((((data_tx_time)*(Nsc*N_bps*Rc*Nss))/...
                (T_DFT + T_GI))- Lsf - Ltail));
            
end