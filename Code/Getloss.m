function loss = Getloss(a_position, b_position, m_NumberOfWalls)
    % Calculates the pathloss between 2 devices using the Enterprise model 
    % defined for 802.11ax. 
    
    loss = 0.0;            
    
    m_dBP = 5.0;           % Breaking point distance from which an additional loss factor is added 

    % m_frequency = 5.2;     % Frequency in GHz; 5-GHz band
    m_frequency = 6;     % Frequency in GHz; 6-GHz band
    % m_NumberOfWalls = 1;   % Number of walls (default = 3)

    distance = norm(a_position - b_position);
    % distance = 10;

    %%% Aditional loss (when distance is greater than the breaking point)
    addLoss = 0.0;

    if distance >= m_dBP
        addLoss = 35*log10(distance/m_dBP);
    end

    loss = 40.05 + 20*log10(m_frequency/2.4) + 20*log10(min(distance,m_dBP)) + addLoss + 7*m_NumberOfWalls;



    % %%% Francesc's pathloss
    % 
    % obstacles = 20;         % 30
    % shadowing = 9.5;        % 9.5
    % path_loss_factor = 5;
    % alpha = 4.4;
    % walls_frequency = 5;        % One wall each 5 meters on average
    % shadowing_at_wlan = shadowing/2; 
    % obstacles_at_wlan = obstacles/2;
	% loss = path_loss_factor + 10*alpha*log10(distance) + shadowing_at_wlan + (distance/walls_frequency)*obstacles_at_wlan;



end