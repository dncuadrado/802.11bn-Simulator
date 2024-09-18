clear all
clc
tic
%% 802.11be Packet Error Rate Simulation for an EHT MU Single-User Packet Format
% This example shows how to measure the packet error rate of an IEEE(R)
% 802.11be(TM) Extremely High Throughput multi-user (EHT MU) packet format
% link with a single user.

% Copyright 2021-2022 The MathWorks, Inc.

%% Introduction
% This example determines the packet error rate for an 802.11be [ <#10 1> ]
% single-user (SU) link by using an end-to-end simulation for a selection
% of signal-to-noise ratio (SNR) points. At each SNR point, the example
% simulates the transmission of multiple packets through a noisy TGax
% indoor channel, then demodulates the received packets and recovers the
% PSDUs. The example then compares the transmitted and received packets to
% determine the packet error rate. This diagram shows the processing steps
% for each packet.
%
% <<../EHTSUExampleDiagram.png>>

%% Waveform Configuration
% An EHT MU SU packet is a full-band transmission to a single user.
% Configure the transmission parameters for an SU packet format by using
% the <docid:wlan_ref#mw_5a68a358-7446-437d-8a8d-3c695ca59cbc wlanEHTMUConfig> object. The properties of the object contain the
% physical layer (PHY) configuration.
%
% Create a configuration object for an EHT MU transmission, setting a
% channel bandwidth of 20 MHz, an APEP length of 1000 bytes, two transmit
% antennas, two space-time streams, and a modulation and coding scheme
% (MCS) value of 13, which specifies 4096-point quadrature amplitude
% modulation (4096-QAM) and a coding rate of 5/6. If you specify |mcs| as a
% vector, the example performs the simulation for each MCS index value.
chanBW = 'CBW80';                           % Channel bandwidth
cfgEHT = wlanEHTMUConfig(chanBW);
cfgEHT.User{1}.APEPLength = 1.5e3;           % APEP length (bytes)
numTx = 2;                                  % Number of transmit antennas
numRx = 2;                                  % Number of receive antennas
cfgEHT.NumTransmitAntennas = numTx;
cfgEHT.User{1}.NumSpaceTimeStreams = 2; % Number of space-time streams
% mcs = 0:1:13;                                   % MCS index
mcs = 0:1:10;                                   % MCS index

%% Channel Configuration
% This example uses a TGax non-line-of-sight (NLOS) indoor channel model
% with delay profile Model-B. Model-B is considered NLOS when the distance
% between transmitter and receiver is greater than or equal to 5 meters.
% For more information about the TGax channel model, see
% <docid:wlan_ref#mw_43b5900e-69e1-4636-b084-1e72dbd46293 wlanTGaxChannel>.

% Create and configure a 2x2 MIMO channel.
tgaxChannel = wlanTGaxChannel;
tgaxChannel.DelayProfile = 'Model-B';
tgaxChannel.NumTransmitAntennas = cfgEHT.NumTransmitAntennas;
tgaxChannel.NumReceiveAntennas = numRx;
tgaxChannel.TransmitReceiveDistance = 5; % Distance in meters for NLOS
tgaxChannel.ChannelBandwidth = chanBW;
tgaxChannel.LargeScaleFadingEffect = 'None';
fs = wlanSampleRate(chanBW);
tgaxChannel.SampleRate = fs;

%% Simulation Parameters
% For each SNR point in |snrRange|, the example generates the specified
% number of packets, passes the packets through a channel, then demodulates
% the received signal to determine the packet error rate. Set the SNR
% values in the |snrRange| parameter to simulate the transition from all
% packets being decoded in error to all packets being decoded successfully
% as the SNR value increases for MCS 13. If you specify |snrRange| as a
% matrix, each row represents the SNR points for the corresponding MCS
% index, defined in |mcs|.

% snrRange = 4:2:16; % Set the range of SNR values


% Further Exploration
% The |maxNumErrors| and |maxNumPackets| parameters control the number of
% packets tested for each SNR point. For meaningful results, increase these
% values. For example, this figure shows results for a channel bandwidth of
% 320 MHz, an APEP length of 16000 bytes, MCS values of 0-13, a
% |maxNumErrors| value of 100, and a |maxNumPackets| value of 1000. The
% corresponding SNR values for MCS between 0 and 13 are:

snrRange = [4:2:16;  % MCS 0
            8:2:20;  % MCS 1
            14:2:26  % MCS 2
            16:2:28;  % MCS 3
            22:2:34;  % MCS 4
            25:2:37;  % MCS 5
            27:2:39;  % MCS 6
            30:2:42;  % MCS 7
            32:2:44;  % MCS 8
            35:2:47;  % MCS 9
            38:2:50;  % MCS 10
            41:2:53;  % MCS 11
            42:2:54;  % MCS 12
            46:2:58]; % MCS 13

%%
% These parameters control the number of packets tested for each SNR
% point.
%
% # |maxNumErrors|: the maximum number of packet errors simulated for
% each SNR point. When the number of packet errors reaches this limit, the
% simulation at this SNR point is complete.
% # |maxNumPackets|: the maximum number of packets simulated for each SNR
% point, which limits the length of the simulation if the simulation does
% not reach the packet error limit.
%
% The default parameter values lead to a very short simulation. For
% meaningful results, increase these values.

maxNumErrors = 500;
maxNumPackets = 50000;

%% Processing SNR Points
% This section measures the packet error rate for each SNR point by
% performing these processing steps for the specified number of packets.
%
% # Create a PSDU and encode to generate a single-packet waveform.
% # Pass the waveform through an indoor TGax channel model, using different
%   channel realizations for each packet.
% # Add AWGN to the received waveform to create the desired
%   average SNR per subcarrier after OFDM demodulation. The
%   configuration accounts for the normalization within the channel by the
%   number of receive antennas and the noise energy in unused subcarriers.
%   The example removes the unused subcarriers during OFDM demodulation.
% # Detect the packet
% # Estimate and correct coarse carrier frequency offset (CFO)
% # Perform fine timing synchronization by using L-STF, L-LTF, and L-SIG
%   samples. This synchronization enables packet detection at the start or
%   end of the L-STF.
% # Estimate and correct fine CFO
% # Extract the EHT-LTF from the synchronized received waveform
% # OFDM demodulate the EHT-LTF and perform channel estimation
% # Extract the data field from the synchronized received waveform and
% perform OFDM demodulation
% # Track any residual CFO by performing common phase error pilot tracking
% # Perform noise estimation by using the demodulated data field pilots
%   and single-stream channel estimation at pilot subcarriers
% # Equalize the phase corrected OFDM symbols by using channel
%   estimation
% # Recover the PSDU by demodulating and decoding the equalized symbols
%
% This example also demonstrates how to speed up simulations by using a
% |parfor| loop instead of a |for| loop when simulating each SNR point. The
% <docid:matlab_ref#f71-813245 parfor> function executes processing for
% each SNR in parallel to reduce the total simulation time. Use a |parfor|
% loop to parallelize processing of the SNR points. To use parallel
% computing for increased speed, comment out the |for| statement and
% uncomment the |parfor| statement in this code.

numSNR = size(snrRange,2); % Number of SNR points
numMCS = numel(mcs); % Number of MCS
packetErrorRate = zeros(numMCS,numSNR);

for imcs = 1:numel(mcs)
    cfgEHT.User{1}.MCS = mcs(imcs);
    ofdmInfo = wlanEHTOFDMInfo('EHT-Data',cfgEHT);
    % SNR points to simulate from MCS
    snr = snrRange(imcs,:);
    ind = wlanFieldIndices(cfgEHT);

    %parfor isnr = 1:numSNR % Use parfor to speed up the simulation
    % updateWaitbar = waitbarParfor(numSNR, "Calculation in progress...");
    parfor isnr = 1:numSNR % Use for to debug the simulation
        % Set random substream index per iteration to ensure that each
        % iteration uses a repeatable set of random numbers
        stream = RandStream('combRecursive','Seed',99);
        stream.Substream = isnr;
        RandStream.setGlobalStream(stream);

        % Define the SNR per active subcarrier to account for noise energy
        % in nulls
        snrValue = snr(isnr)-10*log10(ofdmInfo.FFTLength/ofdmInfo.NumTones);

        % Loop to simulate multiple packets
        numPacketErrors = 0;
        numPkt = 1; % Index of packet transmitted
        while numPacketErrors<=maxNumErrors && numPkt<=maxNumPackets
            % Generate waveform
            txPSDU = randi([0 1],psduLength(cfgEHT)*8,1); % PSDULength (bytes)
            tx = wlanWaveformGenerator(txPSDU,cfgEHT);

            % Add trailing zeros to allow for channel delay
            txPad = [tx; zeros(50,cfgEHT.NumTransmitAntennas)];

            % Pass through fading indoor TGax channel
            reset(tgaxChannel); % Reset channel for different realization
            rx = tgaxChannel(txPad);

            % Pass waveform through an AWGN channel
            rx = awgn(rx,snrValue);

            % Detect packet and determine coarse packet offset
            coarsePktOffset = wlanPacketDetect(rx,chanBW);
            if isempty(coarsePktOffset) % If empty no L-STF detected, packet error
                numPacketErrors = numPacketErrors+1;
                numPkt = numPkt+1;
                continue; % Go to next loop iteration
            end

            % Extract L-STF and perform coarse frequency offset correction
            lstf = rx(coarsePktOffset+(ind.LSTF(1):ind.LSTF(2)),:);
            coarseFreqOff = wlanCoarseCFOEstimate(lstf,chanBW);
            rx = frequencyOffset(rx,fs,-coarseFreqOff);

            % Extract the non-HT fields and determine fine packet offset
            nonhtfields = rx(coarsePktOffset+(ind.LSTF(1):ind.LSIG(2)),:);
            finePktOffset = wlanSymbolTimingEstimate(nonhtfields,chanBW);

            % Determine final packet offset
            pktOffset = coarsePktOffset+finePktOffset;

            % If packet detected outwith range of expected delays from
            % the channel modeling, packet error
            if pktOffset>50
                numPacketErrors = numPacketErrors+1;
                numPkt = numPkt+1;
                continue; % Go to next loop iteration
            end

            % Extract L-LTF and perform fine frequency offset correction
            rxLLTF = rx(pktOffset+(ind.LLTF(1):ind.LLTF(2)),:);
            fineFreqOff = wlanFineCFOEstimate(rxLLTF,chanBW);
            rx = frequencyOffset(rx,fs,-fineFreqOff);

            % EHT-LTF demodulation and channel estimation
            rxHELTF = rx(pktOffset+(ind.EHTLTF(1):ind.EHTLTF(2)),:);
            heltfDemod = wlanEHTDemodulate(rxHELTF,'EHT-LTF',cfgEHT);
            [chanEst,pilotEst] = wlanEHTLTFChannelEstimate(heltfDemod,cfgEHT);

            % Demodulate the Data field
            rxData = rx(pktOffset+(ind.EHTData(1):ind.EHTData(2)),:);
            demodSym = wlanEHTDemodulate(rxData,'EHT-Data',cfgEHT);

            % Perform pilot phase tracking
            demodSym = wlanEHTTrackPilotError(demodSym,chanEst,cfgEHT,'EHT-Data');

            % Estimate noise power in EHT fields
            nVarEst = ehtNoiseEstimate(demodSym(ofdmInfo.PilotIndices,:,:),pilotEst,cfgEHT);

            % Extract data subcarriers from demodulated symbols and channel
            % estimate
            demodDataSym = demodSym(ofdmInfo.DataIndices,:,:);
            chanEstData = chanEst(ofdmInfo.DataIndices,:,:);

            % Equalization
            [eqSym,csi] = ehtEqualizeCombine(demodDataSym,chanEstData,nVarEst,cfgEHT);

            % Recover data field bits
            rxPSDU = wlanEHTDataBitRecover(eqSym,nVarEst,csi,cfgEHT);

            % Determine if any bits are in error
            packetError = any(biterr(txPSDU,rxPSDU));
            numPacketErrors = numPacketErrors+packetError;
            numPkt = numPkt+1;
        end

        % Calculate PER at SNR point
        packetErrorRate(imcs,isnr) = numPacketErrors/(numPkt-1);
        disp(['MCS ' num2str(mcs(imcs)) ','...
              ' SNR ' num2str(snr(isnr)) ...
              ' completed after ' num2str(numPkt-1) ' packets,'...
              ' PER:' num2str(packetErrorRate(imcs,isnr))]);

        % updateWaitbar();
    end

    % path = '/home/david/Documents/MATLAB/Papers/journal_CSR_scheduling/MCS_simulations';
    % savename = horzcat('MCS_',int2str(mcs(imcs)));
    % packetErrorRate_MCS = packetErrorRate(imcs,:);
    % save(fullfile(path, savename), "packetErrorRate_MCS");
end

%% Plot Packet Error Rate vs SNR
markers = 'ox*sd^v><ph+ox*sd^v><ph+';
color = 'bmcrgbrkymcrbmcrgbrkymcr';
figure;
for imcs = 1:numMCS
    semilogy(snrRange(imcs,:),packetErrorRate(imcs,:).',['-' markers(imcs) color(imcs)]);
    hold on;
end
grid on;
xlabel('SNR (dB)');
ylabel('PER');
dataStr = arrayfun(@(x)sprintf('MCS %d',x),mcs,'UniformOutput',false);
legend(dataStr,'Location','NorthEastOutside');
title(['PER (EHT MU), ' num2str(cfgEHT.ChannelBandwidth) ', Model-B, ' num2str(numTx) '-by-' num2str(numRx)]);


%%
% <<../EHTExamplePER.png>>

%% Selected Bibliography
% # IEEE Std 802.11be(TM)/D2.0 Draft Standard for Information
% technology - Telecommunications and information exchange between systems
% Local and metropolitan area networks - Specific requirements - Part 11:
% Wireless LAN Medium Access Control (MAC) and Physical Layer (PHY)
% Specifications. Amendment 8: Enhancements for Extremely High
% Throughput (EHT).

toc