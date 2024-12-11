function [preTX_overheadsDCF,preTX_overheadsCSR, DCFoverheads, CSRoverheads] = OverheadsCalc(EDCAaccessCategory)
    %%%% Computes the needed overheads
    time_preamble_data = 100e-6;

    
    TRTS = 56E-6;
    TCTS = 48E-6;
    TSIFS = 16e-6;                      % Shortest Interframe spacing (SIFS time)
    
    % DIFS = 34e-6;                       % DCF Interframe spacing (DIFS time)
    Te = 9e-6;                          % Duration of a single backoff slot
    TBACK = 100E-6;
    
    TMAPC_ICF = 74.4E-6;
    TMAPC_ICR = 88E-6;
    TMAPC_TF = 74.4E-6;

    switch EDCAaccessCategory
        case 'VI'
            AIFSN = 2;
        otherwise
            AIFSN = 3;
    end
    
    AIFS = AIFSN*9e-6 + 16e-6;  % AIFSN*slotTime + SIFS

    %%% DCF Overheads
    preTX_overheadsDCF = TRTS + TSIFS + TCTS + TSIFS + time_preamble_data;
    DCFoverheads = TRTS + TSIFS + TCTS + TSIFS + time_preamble_data + TSIFS + TBACK + AIFS + Te;
    

    %%% CSR overheads
    % CSRoverheads = 500E-06;       % Fixing the overheads value to 0.5 ms (above they are around 0.4 ms)
    preTX_overheadsCSR = TMAPC_ICF + TSIFS + TMAPC_ICR + TSIFS + TMAPC_TF + TSIFS + time_preamble_data;
    CSRoverheads = TMAPC_ICF + TSIFS + TMAPC_ICR + TSIFS +  TMAPC_TF + TSIFS + time_preamble_data + TSIFS + TBACK + AIFS + Te;
    

end