
clear all
clc
Te = 9E-6;
SIFS = 16E-6;
DIFS = 34E-6;

T_DFT = 12.8e-6;            % OFDM symbol duration
T_GI = 0.8e-6;              % Guard interval duration  

PHY_SU = 164E-6;
PHY_Legacy = 20E-6;

RTS = 160;      
CTS = 112;

MAPCRTS = 48*8;  % 48 Bytes
MAPCCTS = 62*8;  % 48 Bytes
MAPCTF = 48*8;   % 28+5*AP_number  = {33, 38, 43, 48}

MH = 320;
SF = 16;
TB = 18;
MD = 32;

% BA = 240; % compressed version
BA = 432; % Per 256;

% -----------Transmission Rate -------------------
Ts = T_DFT+T_GI;
Ts_legacy = 4E-6;

% Lowest rate
BitsOFDMLegacyRate = 48*1*(1/2); %    Nsc*Nbps*Rc

% % Control frames 
T_RTS_legacy = PHY_Legacy + ceil((SF+RTS+TB)/BitsOFDMLegacyRate)*Ts_legacy;
T_CTS_legacy = PHY_Legacy + ceil((SF+CTS+TB)/BitsOFDMLegacyRate)*Ts_legacy;
T_BA_legacy = PHY_Legacy + ceil((SF+BA+TB)/BitsOFDMLegacyRate)*Ts_legacy;

T_MAPC_RTS_legacy = PHY_Legacy + ceil((SF+MAPCRTS+TB)/BitsOFDMLegacyRate)*Ts_legacy;
T_MAPC_CTS_legacy = PHY_Legacy + ceil((SF+MAPCCTS+TB)/BitsOFDMLegacyRate)*Ts_legacy;
T_MAPC_TF_legacy = PHY_Legacy + ceil((SF+MAPCTF+TB)/BitsOFDMLegacyRate)*Ts_legacy;


% % 20 MHz bandwidth
BitsOFDM = 234*1*(1/2); %    Nsc*Nbps*Rc

% % Control frames 

T_MAPC_RTS = PHY_Legacy + ceil((SF+MAPCRTS+TB)/BitsOFDM)*Ts;
T_MAPC_CTS = PHY_Legacy + ceil((SF+MAPCCTS+TB)/BitsOFDM)*Ts;
T_MAPC_TF = PHY_Legacy + ceil((SF+MAPCTF+TB)/BitsOFDM)*Ts;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('T_RTS legacy duration = %d \n',T_RTS_legacy);
fprintf('T_CTS legacy duration = %d \n',T_CTS_legacy);


fprintf('T_MAPC_RTS legacy duration = %d \n',T_MAPC_RTS_legacy);
fprintf('T_MAPC_CTS legacy duration = %d \n',T_MAPC_CTS_legacy);
fprintf('T_MAPC_TF legacy duration = %d \n',T_MAPC_TF_legacy);

fprintf('Total legacy duration = %d \n', T_MAPC_RTS_legacy + T_MAPC_CTS_legacy + T_MAPC_TF_legacy);

disp("---------------------------------------------------------")

fprintf('T_MAPC_RTS duration = %d \n',T_MAPC_RTS);
fprintf('T_MAPC_CTS duration = %d \n',T_MAPC_CTS);
fprintf('T_MAPC_TF duration = %d \n',T_MAPC_TF);

fprintf('Total duration = %d \n', T_MAPC_RTS + T_MAPC_CTS + T_MAPC_TF);

disp("---------------------------------------------------------")
disp("---------------------------------------------------------")
disp("---------------------------------------------------------")


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data frames
% T_DATA = PHY_SU + ceil((SF+(MH+L)+TB)/BitsOFDM)*Ts;




