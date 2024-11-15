function SinrThreshold = SINRstimation(rate, Nsc, Nss)

T_DFT = 12.8e-6;            % OFDM symbol duration
T_GI = 0.8e-6;              % Guard interval duration 

N_bps_list = [1 2 2 4 4 6 6 6 8 8 10 10 12 12];
Rc_list = [1/2 1/2 3/4 1/2 3/4 2/3 3/4 5/6 3/4 5/6 3/4 5/6 3/4 5/6];

SinrThreshold = NaN(size(rate));
for i = 1:length(rate)
    for j = 1:length(N_bps_list)
        datarate = Nsc*N_bps_list(j)*Rc_list(j)*Nss/(T_DFT + T_GI);
        if datarate >= rate(i)
            MCS_index = i - 1;
            switch MCS_index
                case 0
                    SinrThreshold(i) = 14.2862;
                case 1
                    SinrThreshold(i) = 19.5154;
                case 2
                    SinrThreshold(i) = 25.5501;
                case 3
                    SinrThreshold(i) = 27.9312;
                case 4
                    SinrThreshold(i) = 33.7179;
                case 5
                    SinrThreshold(i) = 36.6008;
                case 6
                    SinrThreshold(i) = 38.8428;
                case 7
                    SinrThreshold(i) = 41.9447;
                case 8
                    SinrThreshold(i) = 43.9603;
                case 9
                    SinrThreshold(i) = 46.5902;
                case 10
                    SinrThreshold(i) = 49.1915;
                case 11
                    SinrThreshold(i) = 52.3450;
                case 12
                    SinrThreshold(i) = 53.8530;
                case 13
                    SinrThreshold(i) = 57.3929;
                otherwise 
                    SinrThreshold(i) = 14.2862;
            end
        end
    end
end
  
end