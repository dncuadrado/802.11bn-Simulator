function elapsed_time  = elapsed_time_tx(Nsc, N_bps, Rc, Nss, tx_Packets)
    %%%%%% Returns the real time spent to transmit packet
    
    T_DFT = 12.8e-6;            % OFDM symbol duration
    T_GI = 0.8e-6;              % Guard interval duration 
    
    Lsf = 16;                           % Length of service field (bits)
    Lmh = 240;                          % MAC header (bits)
    Ld = 12e3;                          % Frame size (bits)
    Ltail = 18;                         % Tail (bits)
    
    if tx_Packets == 1 
        Lmd = 0;                        % MPDU Delimiter (bits) used only in A-MPDU scenarios 
    else
        Lmd = 32;                       % MPDU Delimiter (bits) used only in A-MPDU scenarios
    end
    
    % TDATA = (Lsf + tx_Packets*(Lmd + Lmh + Ld) + Ltail)/(Nsc*N_bps*Rc*Nss)*(T_DFT + T_GI);
    TDATA = ceil((Lsf + tx_Packets*(Lmd + Lmh + Ld) + Ltail)/(Nsc*N_bps*Rc*Nss))*(T_DFT + T_GI);

    elapsed_time = TDATA;

end