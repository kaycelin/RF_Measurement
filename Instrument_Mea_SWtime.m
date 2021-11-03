%% PA1, 2021-10-02, TDD switching time measurement
clear all
clc

%% input: instrument IP
INSTR = Instrument_VNA_SG_SA_NF({'TCPIP0';'TCPIP0';'TCPIP0'},{'10.163.247.23';'10.163.247.37';'10.163.247.12'},{'VNA';'SG';'SA'});

%% input: setup SG
sg_offset1 = -5.9
sg_offset2 = -5.9
sg_PoutdBm1 = [-20]
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
sa_freqSpan = 0
sa_ampLevel = 10
sa_ampLevelOffset = []
sa_ampRFAtt = 25
sa_ampPreAmp = []
sa_bwRBW = 10e6
sa_bwSwpTime = 10e-6
sa_Trigger.source = 'EXT' % 'IMM:freeRun'/'EXT'/'IFP'/'RFP'
sa_Trigger.level = 1.4
sa_Trigger.offset = '-3us'
sa_Trigger.slope = 'Rising' % 1:Rising, 0:Falling


%% Initialize SG
INSTR.SG_Init(sg_port, [sg_offset1 sg_offset2], 'INTernal', {'OFF', 'ON'});

%% Initialize SA
INSTR.SA_Init(sa_MODE, sa_MEAS, sa_MEASConfig, ...
    sa_freqC, sa_freqSpan, sa_ampLevel, ...
    sa_ampLevelOffset, sa_ampRFAtt, sa_ampPreAmp,...
    sa_bwRBW, sa_bwSwpTime, sa_Trigger);

%% setup SA and Switching time measurement
ampPeak = INSTR.SA_Marker([], 1, []);
ampSpec = INSTR.SA_Marker([], 2, '0.5us');
if cell2mat(amp_spec(2))>cell2mat(ampPeak(2))
    disp('PASS!')
end

%% export
% DataOutput

% close INSTR
fclose(INSTR.VNA)
fclose(INSTR.SG)
fclose(INSTR.SA)
delete(INSTR);
clear INSTR

