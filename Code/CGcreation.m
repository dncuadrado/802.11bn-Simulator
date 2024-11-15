function [CGs_STAs, TxPowerMatrix] =  CGcreation(validationFlag, AP_number, STA_number, CSRoverheads,...
    Pn_dBm, Nsc, Nss, association, channelMatrix, MaxTxPower, TXOP_duration)
    

if strcmp(validationFlag,'yes')
    %%% For validating simulated CSR against CSR bianchi's model
    [CGs_STAs, TxPowerMatrix]  = CG_creationAnalytical_TPC(AP_number, STA_number, CSRoverheads, ...
        Pn_dBm, Nsc, Nss, association, channelMatrix, MaxTxPower, TXOP_duration);
else
    %%% Creating spatial reuse groups and optimizing the TxPower
    [CGs_STAs, TxPowerMatrix] = CG_creationTPC(AP_number, STA_number, CSRoverheads, ...
        Pn_dBm, Nsc, Nss, association, channelMatrix, MaxTxPower, TXOP_duration);
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


