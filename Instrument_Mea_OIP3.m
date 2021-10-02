%% PA1, 2021-10-02, OIP3 measurement
clear all
clc

% input: instrument IP
INSTR = Instrument_VNA_SG_SA_NF({'TCPIP0';'TCPIP0';'TCPIP0'},{'10.163.247.23';'10.163.247.117';'10.163.247.43'},{'VNA';'SG';'SA'},0.1);

% input: setup SG
sg_offset1 = -5.69
sg_offset2 = -5.6
sg_PoutdBm1 = -35+[0 0 0]
sg_PoutdBm2 = -35+[0 0 0]
sg_PoutdBm1 = -35+[-1.6 -1.8 -2.6]
sg_PoutdBm2 = -35+[-1.5 -1.7 -2.6]
sg_freqC = [3.4e9 3.6e9 3.8e9]
sg_freqOfs1 = -2.5e6
sg_freqOfs2 = 2.5e6

sg_port = [1,2]
sg_sigType = 'CW'

% input: setup SA
sa_MODE = []
sa_MEAS = []
sa_MEASConfig = []
sa_freqC = sg_freqC
sa_freqSpan = 20e6
sa_ampLevel = 10
sa_ampLevelOffset = -1.08
sa_ampRFAtt = 15
sa_ampPreAmp = []
sa_bwRBW = 200e3
sa_bwSwpTime = 500e-3;

% Initialize SG
INSTR.SG_Init(sg_port, [sg_offset1 sg_offset2], 'INTernal');

% Initialize SA
INSTR.SA_Init(sa_MODE, sa_MEAS, sa_MEASConfig, ...
    sa_freqC, sa_freqSpan, sa_ampLevel, ...
    sa_ampLevelOffset, sa_ampRFAtt, sa_ampPreAmp,...
    sa_bwRBW, sa_bwSwpTime);

N_freq = length(sg_freqC);
N_pout = size(sg_PoutdBm1,1);
for i=1:N_freq
    sg_freqs = sg_freqC(i)+[sg_freqOfs1 sg_freqOfs2];
    shift_i = i-1;
    
    % setup SA
    sa_freqC = sg_freqC(i)
    ampPeak = INSTR.SA_Init([], [], [], ...
        sa_freqC, [], sa_ampLevel, ...
        [], sa_ampRFAtt, [],...
        [], []);
    sa_ampLevel_w = sa_ampLevel;
    for j=1:N_pout
        
        % setup SG
        sg_freqs = sg_freqC(i)+[sg_freqOfs1 sg_freqOfs2];
        sg_PoutdBm = [sg_PoutdBm1(j,i) sg_PoutdBm2(j,i)] - [0 0];
        [sg_data, sg_disp] = INSTR.SG_Set({'ON','ON'}, sg_port, sg_sigType, sg_freqs, sg_PoutdBm);
        
        % setup SA
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
        sa_FUNC = 'TOI';
        sa_ports = [];
        sa_Freqs = [];
        [sa_data, sa_disp] = INSTR.SA_Marker(sa_FUNC, sa_ports);
        
        % SG off
        INSTR.SG_Set({'OFF','OFF'})
        
        % calculation and record
        FreqC = sa_freqC;
        Po1dBm = cell2mat(sa_data(1,2));
        Po2dBm = cell2mat(sa_data(2,2));
        PoIm3L = cell2mat(sa_data(3,2));
        PoIm3H = cell2mat(sa_data(4,2));
        
        GainLdB = Po1dBm - sg_PoutdBm(1);
        GainHdB = Po2dBm - sg_PoutdBm(2);
        Poip3LdBm = Po1dBm + (Po1dBm-PoIm3L)/2;
        Poip3HdBm = Po2dBm + (Po2dBm-PoIm3H)/2;
        Piip3LdBm = Poip3LdBm - GainLdB;
        Piip3HdBm = Poip3HdBm - GainHdB;
        
        %head
        DataOutput{1,1} = 'IIP3';
        %description
        DataOutput{2,1} = 'Freqs(MHz)';
        DataOutput{2,2} = 'Pout1(dBm)';
        DataOutput{2,3} = 'Pout2(dBm)';
        DataOutput{2,4} = 'PoIm3L(dBm)';
        DataOutput{2,5} = 'PoIm3H(dBm)';
        DataOutput{2,6} = 'Poip3L(dBm)';
        DataOutput{2,7} = 'Poip3H(dBm)';
        DataOutput{2,8} = 'Piip3L(dBm)';
        DataOutput{2,9} = 'Piip3H(dBm)';
        
        %value
        DataOutput{2+j+shift_i,1} = FreqC;
        DataOutput{2+j+shift_i,2} = Po1dBm;
        DataOutput{2+j+shift_i,3} = Po2dBm;
        DataOutput{2+j+shift_i,4} = PoIm3L;
        DataOutput{2+j+shift_i,5} = PoIm3H;
        DataOutput{2+j+shift_i,6} = Poip3LdBm;
        DataOutput{2+j+shift_i,7} = Poip3HdBm;
        DataOutput{2+j+shift_i,8} = Piip3LdBm;
        DataOutput{2+j+shift_i,9} = Piip3HdBm;
    end
end

% export
DataOutput

% close INSTR
delete(INSTR);
clear INSTR

