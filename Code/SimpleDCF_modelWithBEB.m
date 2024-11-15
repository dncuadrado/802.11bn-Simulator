function [tau_, EB_, p_] = SimpleDCF_modelWithBEB(N, EDCAaccessCategory)
    
    MaxIter=100;
    
    switch EDCAaccessCategory
        case 'BE' 
            % AC_BE
            CWmin = 15;
            m=6; % CWmax = 1023
        case 'VI'
            % AC_VI
            CWmin = 7;
            m=1; % CWmax = 15
    end
    
    % Initial Values;
    tau(1)=2/(CWmin+2);
    p(1)=0;
    EB(1)=0;
    
    % Fixed-point iterative approach to obtain tau and p
    for i=1:MaxIter-1
        % Collision Probability
        p(i+1) = 1-(1-tau(i))^(N-1);
    
        % Expected Backoff Duration (Ret. max = oo)
        
        % Single BO stage
        %EB(i+1) = CWmin/2; % Single backoff stage
        
        % BEB
        A=(1-(2*p(i+1))^m)/(1-2*p(i+1));
        B=(2*p(i+1))^m/(1-p(i+1));
        EB(i+1) = ((CWmin+1)/2)*(1-p(i+1))*(A+B)-1/2;
    
        % Transmission Probability  
        tau(i+1) = 1 /(EB(i+1)+1);
    
        % Average to improve convergence
        if i>4
            tau(i+1)=(1/4)*(tau(i+1)+tau(i)+tau(i-1)+tau(i-2));
        end
    
    end
    
    % disp('tau | EB | p');
    % disp([tau(MaxIter) EB(MaxIter) p(MaxIter)]);
    
    tau_= tau(MaxIter);
    % tau_ = 2/(CWmin+2);

    EB_ = EB(MaxIter);
    p_ = p(MaxIter);
    
    
    % figure
    % plot(tau);
    
    % % Channel Probs
    % pe = (1-tau_)^N;
    % ps = N*tau_*(1-tau_)^(N-1);
    % pc = 1-pe-ps;
    % 
    % % Throughput
    % L= 10000;
    % Ts = 1E-3;
    % Te = 9E-6;
    % Tc = 100E-6;
    % 
    % S= ps*L/(pe*Te+ps*Ts+pc*Tc);
    
    % disp('Throughput');
    % disp(S);
end