function [preTX_overheadsDCF,preTX_overheadsCSR, DCFoverheads, CSRoverheads] = OverheadsCalc()
    %%%% Computes the needed overheads
    time_preamble_data = 100e-6;

    
    % TRTS = 56E-6;
    % TCTS = 48E-6;
    TRTS = 42E-6;
    TCTS = 36E-6;
    TSIFS = 16e-6;                      % Shortest Interframe spacing (SIFS time)
    
    DIFS = 34e-6;                       % DCF Interframe spacing (DIFS time)
    Te = 9e-6;                          % Duration of a single backoff slot
    TBACK = 100E-6;
    
    T_MAPC_RTS = 160E-6;
    T_MAPC_TXOP = 160E-6;

    %%% DCF Overheads
    preTX_overheadsDCF = TRTS + TSIFS + TCTS + TSIFS + time_preamble_data;
    DCFoverheads = TRTS + TSIFS + TCTS + TSIFS + time_preamble_data + TSIFS + TBACK + DIFS + Te;
    

    %%% CSR overheads
    % CSRoverheads = 500E-06;       % Fixing the overheads value to 0.5 ms (above they are around 0.4 ms)
    preTX_overheadsCSR = TRTS + TSIFS + TCTS + TSIFS + T_MAPC_TXOP + TSIFS + time_preamble_data;
    CSRoverheads = TRTS + TSIFS + TCTS + TSIFS +  T_MAPC_TXOP + TSIFS + time_preamble_data + TSIFS + TBACK + DIFS + Te;
    

end