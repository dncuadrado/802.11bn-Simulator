function [MCS, N_bps, Rc] = MCS_cal_PER_001(SINR_db)
% Calculates the 802.11be MCS and related parameters (N_bps, Rc) for a given value
% of SINR and considering a PER lower than 1E-2


%%% interp1(packetErrorRate_MCS,SINRvector,1E-2)   % To interpolate the computed values to estimate the SINR value
                                                   % corresponding to PER = 1E-2 for each MCS

if(SINR_db < 14.2862)   % Not a valid MCS
    MCS = NaN;
    N_bps = NaN;
    Rc = NaN;

    % MCS0
elseif (14.2862 <= SINR_db) && (SINR_db < 19.5154)
    MCS = 0;
    N_bps = 1;                      % Number of coded bits per subcarrier per stream
    Rc = 1/2;                       % Rate of coding

    % MCS1
elseif (19.5154 <= SINR_db) && (SINR_db < 25.5501)
    MCS = 1;
    N_bps = 2;
    Rc = 1/2;

    % MCS2
elseif (25.5501 <= SINR_db) && (SINR_db < 27.9312)
    MCS = 2;
    N_bps = 2;
    Rc = 3/4;

    % MCS3
elseif (27.9312 <= SINR_db) && (SINR_db < 33.7179)
    MCS = 3;
    N_bps = 4;
    Rc = 1/2;

    % MCS4
elseif (33.7179 <= SINR_db) && (SINR_db < 36.6008)
    MCS = 4;
    N_bps = 4;
    Rc = 3/4;

    % MCS5
elseif (36.6008 <= SINR_db) && (SINR_db < 38.8428)
    MCS = 5;
    N_bps = 6;
    Rc = 2/3;

    % MCS6
elseif (38.8428 <= SINR_db) && (SINR_db < 41.9447)
    MCS = 6;
    N_bps = 6;
    Rc = 3/4;

    % MCS7
elseif (41.9447 <= SINR_db) && (SINR_db < 43.9603)
    MCS = 7;
    N_bps = 6;
    Rc = 5/6;

    % MCS8
elseif (43.9603 <= SINR_db) && (SINR_db < 46.5902)
    MCS = 8;
    N_bps = 8;
    Rc = 3/4;

    % MCS9
elseif (46.5902 <= SINR_db) && (SINR_db < 49.1915)
    MCS = 9;
    N_bps = 8;
    Rc = 5/6;

    % MCS10
elseif (49.1915 <= SINR_db) && (SINR_db < 52.3450 )
    MCS = 10;
    N_bps = 10;
    Rc = 3/4;

    % MCS11
elseif (52.3450 <= SINR_db) && (SINR_db < 53.8530)
    MCS = 11;
    N_bps = 10;
    Rc = 5/6;

    % MCS12
elseif (53.8530 <= SINR_db) && (SINR_db < 57.3929 )
    MCS = 12;
    N_bps = 12;
    Rc = 3/4;

    % MCS13
elseif (57.3929 <= SINR_db)
    MCS = 13;
    N_bps = 12;
    Rc = 5/6;
end




end