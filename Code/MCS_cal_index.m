function [MCS, N_bps, Rc] = MCS_cal_index(SINR_db)
    % Calculates the MCS and related parameters (N_bps, Rc) for a given value
    % of SINR. 
    % In the case SINR_db <= 5.72, MCS = -1 (it's only a flag to be used for 
    % the throughput function) and the throughput will be equal 0, consequently. 
    % (it means insuficient level to detect the received signal).  
    
    
    % Throughput=0
    if(SINR_db <= 5.72)     % 5.72
        MCS = -1;
        N_bps = 1;
        Rc = 1/2;
    
    % MCS0
    elseif (5.72 < SINR_db) && (SINR_db <= 8.72)                    
        MCS = 0;
        N_bps = 1;                      % Number of coded bits per subcarrier per stream
        Rc = 1/2;                       % Rate of coding
    
    % MCS1
    elseif (8.72 < SINR_db) && (SINR_db <= 11.72)    
        MCS = 1;
        N_bps = 2;
        Rc = 1/2;
    
    % MCS2
    elseif (11.72 < SINR_db) && (SINR_db <= 15.43)        
        MCS = 2;
        N_bps = 2;
        Rc = 3/4;
    
    % MCS3
    elseif (15.43 < SINR_db) && (SINR_db <= 18.48)      
        MCS = 3;
        N_bps = 4;
        Rc = 1/2;
    
    % MCS4
    elseif (18.48 < SINR_db) && (SINR_db <= 23.32)       
        MCS = 4;
        N_bps = 4;
        Rc = 3/4;
    
    % MCS5
    elseif (23.32 < SINR_db) && (SINR_db <= 24.61)        
        MCS = 5;
        N_bps = 6;
        Rc = 2/3;
    
    % MCS6
    elseif (24.61 < SINR_db) && (SINR_db <= 25.79)        
        MCS = 6;
        N_bps = 6;
        Rc = 3/4;
    
    % MCS7
    elseif (25.79 < SINR_db) && (SINR_db <= 30.59)       
        MCS = 7;
        N_bps = 6;
        Rc = 5/6;
    
    % MCS8 
    elseif (30.59 < SINR_db) && (SINR_db <= 31.71)       
        MCS = 8;
        N_bps = 8;
        Rc = 3/4;
    
    % MCS9
    elseif (31.71 < SINR_db) && (SINR_db <= 36.0)       
        MCS = 9;
        N_bps = 8;
        Rc = 5/6;
    
    % MCS10
    elseif (36.0 < SINR_db) && (SINR_db <= 37.90)         
        MCS = 10;
        N_bps = 10;
        Rc = 3/4;
    
    % MCS11
    elseif (37.90 < SINR_db)                              
        MCS = 11;
        N_bps = 10;
        Rc = 5/6;
    end 
end