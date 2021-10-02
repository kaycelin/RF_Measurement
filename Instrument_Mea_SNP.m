%% PA1, 2021-10-01, VNA SNP save
%% PA1, 2021-10-02, SNP plot

% clear all
% clc

% input: instrument IP
interface = {'TCPIP0';'TCPIP0';'TCPIP0';'GPIB'}
visaAddress = {'10.163.247.23';'10.163.247.117';'10.163.247.43';'8'}
instrName = {'VNA';'SG';'SA';'NF'}

interface = interface(1)
visaAddress = visaAddress(1)
instrName = instrName(1)

INSTR = Instrument_VNA_SG_SA_NF(interface, visaAddress, instrName);

% input: VNA
path = 'D:/grant2/2021-10-01'
% update filename !!
noData = 2
noData = noData+1;
% filename=['QV_0',num2str(noData),'_C1C21NA']
% filename=['TEST_0',num2str(noData)]
filename=['NP01Ch02_0',num2str(noData)]
filename=['QV01Ch16_0',num2str(noData)]
type = 'S4P'
sa_ports = '1,2,3,4'
INSTR.VNA_SaveSNP(path, filename, type, sa_ports)

% close INSTR
fclose(INSTR.VNA)
delete(INSTR);
clear INSTR


%% SNP plot
flag_snpPlt = 1;
if flag_snpPlt
    close all
    %     Input = 'RA_B04.S4P'
    %     Input = 'LNA_RX_0614A_14G.S2P'
    Input = [filename,'.',type]
    z0 = 50
    ports = [1:4;1:4]
    freqs = [3.0 4.0]*1e9;
    freqs = [3.2 4.0]*1e9;
    typeIn2Out = 's' %s/s2z/s2y
    typeStability = 'mu'
    typeSmithChar = 'zy'
    fnum = 101
    fnum_typePlt = 'RL'
    fnum_Marker = [3.4e9, 3.6e9, 3.8e9]
    fnum_axis = [3.4e9 3.8e9 -90 0]
    %     fnum_Marker = [3.2e9, 3.6e9, 4.0e9]
    fnum_axis = [3200e6 4000e6 -10 40; 3200e6 4000e6 25 45]
    %     fnum_axis = [3200e6 3800e6 -50 0]
    
    fnum_save = 'C:\Users\123\Documents\MATLAB\grant\SNP\ISO1001';
    fnum_xls = 'ISO_1001.xls';
    
%     [Output, mu] = SNP_g(Input, z0, ports, freqs, typeIn2Out, typeStability, typeSmithChar, fnum, fnum_typePlt);%     [Output, mu] = SNP_g(Input, z0, [2;1], freqs, typeIn2Out, typeStability, typeSmithChar, fnum, 'IL');
%     [Output, mu] = SNP_g(Input, z0, [], freqs, typeIn2Out, typeStability, typeSmithChar, fnum, 'ISO');
%     [Output, mu] = SNP_g(Input, z0, [1:4;1:4], freqs, typeIn2Out, typeStability, [], fnum, 'ISO', fnum_Marker, fnum_axis, fnum_save, []);
    [Output, mu] = SNP(Input, z0, [1:4;1:4], freqs, typeIn2Out, typeStability, [], fnum, 'ISO', fnum_Marker, fnum_axis, fnum_save, fnum_xls);
%     [Output, mu] = SNP_g(Input, z0, [1:4;1:4], freqs, 's2z', typeStability, typeSmithChar, fnum, 'Z');
%     [Output, mu] = SNP_g(Input, z0, [1:4;1:4], freqs, typeIn2Out, [], typeSmithChar, fnum, 'RL', fnum_Marker, fnum_axis, fnum_save, []);
end
