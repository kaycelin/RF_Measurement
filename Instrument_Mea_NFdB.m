%% PA1, 2021-10-01, NF measurement
%% PA1, 2021-10-02, NF vs SmithChart
%% A1, 2021-10-15, save results

clear all
clc

%% step0, input: instrument IP
INSTR = Instrument_VNA_SG_SA_NF({'TCPIP0';'TCPIP0';'TCPIP0';'GPIB'},{'10.163.247.23';'10.163.247.117';'10.163.247.43';'8'},{'VNA';'SG';'SA';'NF'});

%% step3, Plot Gain and NF
fnum=1102
fnum_marker=[3.4 3.6 3.8]*1e9,
fnum_axis= [[3.4e9 3.85e9 1 2.5];[3.4e9 3.85e9 31 38]]
fnum_save={'C:\Users\123\Documents\MATLAB\grant\SNP\QV_PAINX2';'QV_PAINX_CH16_25deg_AGC0_2'}
close all
[nf, gain, freqs] = INSTR.NF_read('FETC',fnum, fnum_marker, fnum_axis, fnum_save);
% [nf, gain, freqs] = INSTR.NF_read('FETC',fnum, fnum_marker, fnum_axis, []);

if 1 %% A1, 2021-10-15, save results
    save([cell2mat(fnum_save(1)),'\', date,'\', 'NF','_',cell2mat(fnum_save(2)),'.mat'],'nf')
    save([cell2mat(fnum_save(1)),'\', date,'\', 'NF_freqs','_',cell2mat(fnum_save(2)),'.mat'],'freqs')
end

flag_NF_Smithchart = 1
if flag_NF_Smithchart
    %% step1, Save SNP by VNA
    type = 'S2P'
    sa_ports = '1,2'
    path = 'D:/2021-10-04'
    noData = noData+1; % Update filename !!
    filename=['QV_CH16_PAINX_M0',num2str(noData)]
    INSTR.VNA_SaveSNP(path, filename, type, sa_ports)
    
    %% step5, Read SNP as SmithChart
    freqs_sc = [fnum_axis(1,1) fnum_axis(1,2)]
    typeIn2Out = 's' %s/s2z/s2y
    typeStability = 'mu'
    typeSmithChar = 'zy'
    fnum = 101
    fnum_typePlt = 'RL'
    fnum_Marker = fnum_marker
    fnum_axis_sc = [3.4e9 3.8e9 -30 0]
    fnum_save = 'C:\Users\123\Documents\MATLAB\SNP';
    fnum_xls = 'TEST2.xls';
    fnum_suplot = [1 2 1;1 2 2]
    
    %% step2, Move Input from VNA to Local folder
    SNPInput = [filename,'.',type]
    %% step4, Update NF vs Marker
    fnum_legend = [' NF(dB):', num2str(round(nf,2))];
    [Output, mu] = SNP(SNPInput, z0, [3;3], freqs_sc, typeIn2Out, typeStability, typeSmithChar, fnum, fnum_typePlt, fnum_Marker, fnum_axis_sc, fnum_save, [], fnum_legend, fnum_suplot);
%     [Output, mu] = SNP(SNPInput, z0, [1:4;1:4], freqs_sc, typeIn2Out, typeStability, typeSmithChar, fnum, fnum_typePlt, fnum_Marker, fnum_axis_sc, fnum_save, [], fnum_legend, fnum_suplot);
end

% close INSTR
fclose(INSTR.VNA)
fclose(INSTR.SG)
fclose(INSTR.SA)
fclose(INSTR.NF)
delete(INSTR);
clear INSTR

