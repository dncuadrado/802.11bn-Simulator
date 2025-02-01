function loss = Getloss(a_position, b_position, m_NumberOfWalls, std_dev)
    % Calculates the pathloss between 2 devices using the Enterprise model 
    % defined for 802.11ax. 
    
    loss = 0.0;            
    
    m_dBP = 10.0;           % Breaking point distance from which an additional loss factor is added 
    m_frequency = 6;     % Frequency in GHz; 6-GHz band

    distance = norm(a_position - b_position);

    %%% Aditional loss (when distance is greater than the breaking point)
    addLoss = 0.0;

    if distance >= m_dBP
        addLoss = 35*log10(distance/m_dBP);
    end
    
    shadowing = std_dev*randn; % in dB

    loss = 40.05 + 20*log10(m_frequency/2.4) + 20*log10(min(distance,m_dBP)) + addLoss + 7*m_NumberOfWalls + shadowing;

end