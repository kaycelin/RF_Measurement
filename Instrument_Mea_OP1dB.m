%% PA1, 2021-10-02, OP1dB measurement

clear all
clc

%% input: instrument IP
INSTR = Instrument_VNA_SG_SA_NF({'TCPIP0';'TCPIP0';'TCPIP0'},{'10.163.247.23';'10.163.247.37';'10.163.247.12'},{'VNA';'SG';'SA'});

%% input: setup SG
sg_offset1 = -6.0
sg_offset2 = -6.4
sg_PoutdBm1 = [-30:1:-10]
sg_PoutdBm2 = 0
sg_freqC = [3.4e9 3.6e9 3.8e9]
sg_freqOfs1 = -2.5e6
sg_freqOfs2 = 2.5e6

sg_port = [1]
sg_sigType = 'CW'

%% input: setup SA
sa_MODE = []
sa_MEAS = []
sa_MEASConfig = []
sa_freqC = mean(sg_freqC)
sa_freqSpan = 20e6
sa_ampLevel = 10
sa_ampLevelOffset = -3.42
sa_ampRFAtt = 15
sa_ampPreAmp = []
sa_bwRBW = 200e3
sa_bwSwpTime = []

%% Initialize SG
INSTR.SG_Init(sg_port, [sg_offset1 sg_offset2], 'INTernal');

%% Initialize SA
INSTR.SA_Init(sa_MODE, sa_MEAS, sa_MEASConfig, ...
    sa_freqC, sa_freqSpan, sa_ampLevel, ...
    sa_ampLevelOffset, sa_ampRFAtt, sa_ampPreAmp,...
    sa_bwRBW, sa_bwSwpTime);

N_freq = length(sg_freqC);
N_pout = length(sg_PoutdBm1);
DataOutput = [];

%% OP1dB measurement
for i=1:N_freq
    sg_freqs = sg_freqC(i)+[0 0];
    shift_i = (i-1)*(N_pout+1);
    GainLdB = 0;
    
    % setup SA
    sa_freqC = sg_freqC(i)
    ampPeak = INSTR.SA_Init([], [], [], ...
        sa_freqC, [], sa_ampLevel, ...
        [], sa_ampRFAtt, [],...
        [], []);
    sa_ampLevel_w = sa_ampLevel;
    for j=1:N_pout
        % setup SG
        sg_PoutdBm = [sg_PoutdBm1(j)];
        [sg_data, sg_disp] = INSTR.SG_Set({'ON','OFF'}, sg_port, sg_sigType, sg_freqs, sg_PoutdBm);
        
        ampPeak = INSTR.SA_Marker([], 1, []);
        sa_ampLevel_tolerance = 15;
        if cell2mat(ampPeak(2))>sa_ampLevel_w-sa_ampLevel_tolerance
            sa_ampLevel_w = fix(cell2mat(ampPeak(2)))+sa_ampLevel_tolerance;
            ampPeak = INSTR.SA_Init([], [], [], ...
                [], [], sa_ampLevel_w, ...
                [], [], [],...
                [], []);
        end
        
        % read SA
        sa_FUNC = 'OP1dB';
        sa_ports = [];
        sa_Freqs = [];
        [sa_data, sa_disp] = INSTR.SA_Marker(sa_FUNC, sa_ports);
        
        % SG off
        INSTR.SG_Set({'OFF','OFF'})
        
        % calculation and record
        FreqC = sa_freqC;
        Pi1dBm = cell2mat(sg_data(1,2));
        Po1dBm = cell2mat(sa_data(1,2));
        
        GainLdB_pre = GainLdB;
        GainLdB = Po1dBm - Pi1dBm;
        
        %head
        DataOutput{1,1} = 'OP1dB';
        %description
        DataOutput{2+shift_i,1} = 'Freqs(MHz)';
        DataOutput{2+shift_i,2} = 'Pin1(dBm)';
        DataOutput{2+shift_i,3} = 'Pout1(dBm)';
        DataOutput{2+shift_i,4} = 'GainL(dB)';
        DataOutput{2+shift_i,5} = 'Delta(dB)';
        
        %value
        DataOutput{2+j+shift_i,1} = FreqC;
        DataOutput{2+j+shift_i,2} = Pi1dBm;
        DataOutput{2+j+shift_i,3} = Po1dBm;
        DataOutput{2+j+shift_i,4} = GainLdB;
        DataOutput{2+j+shift_i,5} = GainLdB-DataOutput{2+1+shift_i,4};

    end
    %     figure(101)
    %     x_plt = [DataOutput{3:2+N_pout,2}]
    %     y_plt = [DataOutput{3:2+N_pout,3}]
    %     plot(x_plt,y_plt)
end

%% export
DataOutput

x1 = cell2mat(DataOutput(3:23,2));
y1 = cell2mat(DataOutput(3:23,4));
freq1MHz = cell2mat(DataOutput(3,1))/1e6;
x2 = cell2mat(DataOutput(25:45,2));
y2 = cell2mat(DataOutput(25:45,4));
freq2MHz = cell2mat(DataOutput(25,1))/1e6;
x3 = cell2mat(DataOutput(47:67,2));
y3 = cell2mat(DataOutput(47:67,4));
freq3MHz = cell2mat(DataOutput(47,1))/1e6;

figure(1014)
plot(x1, y1, 'DisplayName',[num2str(freq1MHz),'MHz']), hold on, legend
plot(x2, y2, 'DisplayName',[num2str(freq2MHz),'MHz']), hold on, legend
plot(x3, y3, 'DisplayName',[num2str(freq3MHz),'MHz']), hold on, legend
title('IP1dB compression')

% close INSTR
fclose(INSTR.VNA)
fclose(INSTR.SG)
fclose(INSTR.SA)
delete(INSTR);
clear INSTR

