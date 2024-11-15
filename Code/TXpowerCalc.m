function [tx_power_ss, Nsc] = TXpowerCalc(BW, Nss)
    %%%  Compute the number of subcarriers, Nsc, as well as the total power used depending on the bandwidth and the number of spatial streams
    switch BW
        case 20 
            Nsc = 234;
        case 40
            Nsc = 468;
        case 80
            Nsc = 980;
        case 160
            Nsc = 1960;
    end

    PSdensity = 5; % power spectral density in dBm/MHz (it cannot exceed 10 dBm/MHz by regulation, and the EIRP is even limited to 23 dBm in Europe)
    EIRP = PSdensity + 10*log10(BW);  % EIRP is constant by regulation in the 6Gz band

    % if EIRP > 23     % By ETSI constraint EIRP cannot exceed 23 dBm in Europe
    %     EIRP = 23;
    % end
    EIRP = 18;
    tx_power_ss = EIRP - 10*log10(Nss);     % transmission power per spatial stream


end