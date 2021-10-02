%% PA1, InstrCtrl, 2021-08-19
%% PA2, support intrumentL VNA, SG, SA, NF

classdef Instrument_VNA_SG_SA_NF < handle
    properties
        Name; % instrument
        VNA
        SG
        SA
        NF
        delay=1e-1;
    end
    
    methods
        function instr = Instrument_VNA_SG_SA_NF(interface, visaAddress, instrName, delay)
            vendor = 'agilent';
            
            if all([iscell(interface),iscell(instrName),iscell(visaAddress)])
                flag_cell = 1;
            elseif all([~iscell(interface),~iscell(instrName),~iscell(visaAddress)])
                flag_cell = 0;
            else
                error('input format should the same!')
            end
            
            Ninstr = size(instrName,1);
            for i = 1:Ninstr
                if flag_cell
                    visaInterface = sprintf('%s::%s::INSTR', cell2mat(interface(i)),cell2mat(visaAddress(i)));
                    INSTR = cell2mat(instrName(i));
                else
                    visaInterface = sprintf('%s::%s::INSTR', interface(i,:),visaAddress(i,:));
                    INSTR = instrName(i,:);
                end
                switch INSTR
                    case 'VNA'
                        instr.VNA = visa(vendor, visaInterface);
                        instr.VNA.InputBufferSize = 4096;
                    case 'SG'
                        instr.SG = visa(vendor, visaInterface);
                        instr.SG.InputBufferSize = 4096;
                    case 'SA'
                        instr.SA = visa(vendor, visaInterface);
                        instr.SA.InputBufferSize = 4096;
                    case 'NF'
                        instr.NF = visa(vendor, visaInterface);
                        instr.NF.InputBufferSize = 4096;
                end
                instr.Name = [instr.Name,INSTR];
            end
            
            if exist('delay','var')&&~isempty(delay)
                instr.delay = delay;
            end
            pause(instr.delay)
        end
    end
    
    methods % VNA
        function VNA_SaveSNP(instr, path, filename, type, ports)
            % open
            VNA = instr.VNA;
            try
                fopen(VNA);
            catch
                fclose(VNA);
                fopen(VNA);
            end
            fprintf(VNA, '*IDN?');
            fscanf(VNA);
            
            % procedure
            pathfolder = ['"',path,'"'];
            savePath = sprintf(':MMEM:MDIR %s', pathfolder);
            fprintf(VNA, savePath);
            
            saveSNP = sprintf (':MMEM:STOR:SNP:TYPE:%s %s', type, ports);
            fprintf(VNA, saveSNP);
            
            data = ['"',path,'/',filename,'.',type,'"'];
            saveData = sprintf(':MMEM:STOR:SNP:DATA %s', data);
            fprintf(VNA, saveData);
            
            % close
            fclose(VNA)
            pause(instr.delay)
            
        end
    end
    
    methods % SG
        function SG_Init(instr, ports, offset, REFCLK)
            % open
            SG = instr.SG;
            try
                fopen(SG);
            catch
                fclose(SG);
                fopen(SG);
            end
            fprintf(SG, '*IDN?');
            fscanf(SG);
            
            % procedure
            if exist('ports','var')&&~isempty(ports)&&exist('offset','var')&&~isempty(offset)
                Nports = numel(ports);
                for i = 1: Nports
                    SetOffset = sprintf('SOURce%d:POWer:%s %d',ports(i),'OFFSET',0+offset(i));
                    fprintf(SG, SetOffset)
                    fprintf(SG, 'SOURce%d:POWer:OFFSET?', ports(i))
                    ofs = str2num(fscanf(SG));
                    SetPwr = sprintf('SOURce%d:POWer:Power %d', ports(i), -30-ofs);
                    fprintf(SG, SetPwr)
                end
            end
            
            % REFCLK: 'INTernal'/ EXTernal{10MHZ| VARiable| 5MHZ| 13MHZ}
            SetREFCLK_internal = sprintf('SOURce%d:ROSCillator:SOURce %s',1, 'INTernal');
            fprintf(SG, SetREFCLK_internal)
            if exist('REFCLK','var')&&~isempty(REFCLK)&&~strcmp(REFCLK, 'INTernal')
                SetREFCLK_external = sprintf('SOURce%d:ROSCillator:SOURce %s',1, 'EXTernal');
                fprintf(SG, SetREFCLK_external)
                SetREFCLK_external = sprintf('SOURce%d:ROSCillator:EXTernal:FREQuency %s', 1,REFCLK);%10MHZ| VARiable| 5MHZ| 13MHZ
                fprintf(SG, SetREFCLK_external)
            end
            
            % close
            fclose(SG)
            pause(instr.delay)
        end
        
        function [XY, dispXY] = SG_Set(instr, ON, ports, SOURCE, freq,pwr)
            % open
            SG = instr.SG;
            try
                fopen(SG);
            catch
                fclose(SG);
                fopen(SG);
            end
            fprintf(SG, '*IDN?');
            fscanf(SG);
            
            % procedure
            fprintf(SG, 'OUTPut1 OFF')
            fprintf(SG, 'OUTPut2 OFF')
            
            if ~exist('SOURCE','var')||isempty(SOURCE)
                SOURCE = 'CW';
            end
            if exist('ports','var')&&~isempty(ports)
                Nports = numel(ports);
                for i = 1: Nports
                    if exist('freq','var')&&~isempty(freq)
                        SetFreq = sprintf('SOURce%d:FREQuency:%s %d', ports(i), SOURCE, freq(i));
                        fprintf(SG, SetFreq)
                        fprintf(SG, 'SOURce1:FREQuency?')
                        XY(i,1) = {str2num(fscanf(SG))};
                        pause(instr.delay)
                        dispXY(i,1) = {sprintf('RF%d',i)};
                        
                        fprintf(SG, 'SOURce%d:POWer:OFFSET?', ports(i))
                        ofs = str2num(fscanf(SG));
                        SetPwr = sprintf('SOURce%d:POWer:Power %d', ports(i), pwr(i)-ofs);
                        fprintf(SG, SetPwr)
                        fprintf(SG, 'SOURce1:POWer?')
                        XY(i,2) = {str2num(fscanf(SG))};
                        dispXY(i,2) = {sprintf('dBm')};
                    end
                end
            end
            
            if exist('ON','var')&&~isempty(ON)
                if iscell(ON)
                    SetON_1 = cell2mat(ON(1));
                    if ~isempty(SetON_1)&&strcmp(SetON_1,'ON')
                        fprintf(SG, 'OUTPut1 ON')
                    end
                    
                    SetON_2 = cell2mat(ON(2));
                    if ~isempty(SetON_2)&&strcmp(SetON_2,'ON')
                        fprintf(SG, 'OUTPut2 ON')
                    end
                else
                    error('ON format is cell!')
                end
            end
            
            % close
            fclose(SG)
            pause(instr.delay)
        end
    end
    methods % SA
        function [XY, dsip_XY] = SA_Init(instr, MODE, MEAS, MEASConfig, ...
                freqCent, freqSpan, ampLevel, ampLevelOffset, ampRFAtt, ampPreAmp,...
                bwRBW, bwSwpTime, Trigger)
            % open
            SA = instr.SA;
            try
                fopen(SA);
            catch
                fclose(SA);
                fopen(SA);
            end
            fprintf(SA, '*IDN?');
            fscanf(SA);
            
            % procedure
            if ~exist('MODE','var')||isempty(MODE)
                MODE = 'Spectrum';
            else
                %                 CALC:MARK:FUNC:TOI ON
                SetMOD = sprintf('CALC:MARK:FUNC:%s ON', MODE);
                fprintf(SA, SetMOD)
            end
            if ~exist('MEAS','var')||isempty(MEAS)
                MEAS = 'FreqSwep';
            else
                %                 CALC:MARK:FUNC:TOI ON
                SetMEAS = sprintf('CALC:MARK:FUNC:%s ON', MEAS);
                fprintf(SA, SetMEAS)
            end
            if exist('freqCent','var')&&~isempty(freqCent)
                SetFreqCent = sprintf('FREQ:CENT %d Hz', mean(freqCent));
                fprintf(SA, SetFreqCent)
                if numel(freqCent)==2 % [start stop]freq.
                    freqSpan1 = diff(freqCent);
                    SetFreqSpan1 = sprintf('FREQ:SPAN %d Hz', freqSpan1);
                    fprintf(SA, SetFreqSpan1)
                end
            end
            if exist('freqSpan','var')&&~isempty(freqSpan)
                SetFreqSpan = sprintf('FREQ:SPAN %d Hz', freqSpan);
                fprintf(SA, SetFreqSpan)
                %                 fprintf(SA, 'FREQ:SPAN?')
                %                 fscanf(SA)
            end
            
            % ampLevel, ampLevelOffset, ampRFAtt
            flag_ampRFAtt_updated = 0;
            if exist('ampLevel','var')&&~isempty(ampLevel)
                % Ref Level setup
                SetAmpRefLev = sprintf('DISP:TRAC:Y:RLEV %ddBm', ampLevel);
                fprintf(SA, SetAmpRefLev)
                % Ref Level read
                fprintf(SA, 'DISP:TRAC:Y:RLEV?')
                ampLevel_read = str2num(fscanf(SA));
                while ampLevel_read~=ampLevel
                    % RF Att read/setup
                    fprintf(SA, 'INP:ATT?');
                    ampRFAtt_write = str2num(fscanf(SA))+2;
                    fprintf(SA, 'INP:ATT %ddB', ampRFAtt_write)
                    flag_ampRFAtt_updated = 1;
                    % Ref Level setup
                    SetAmpRefLev = sprintf('DISP:TRAC:Y:RLEV %ddBm', ampLevel);
                    fprintf(SA, SetAmpRefLev)
                    fprintf(SA, 'DISP:TRAC:Y:RLEV?')
                    ampLevel_read = str2num(fscanf(SA));
                end
            end
            if exist('ampRFAtt','var')&&~isempty(ampRFAtt)&&~flag_ampRFAtt_updated
                SetAmpRFAtt = sprintf('INP:ATT %ddB', ampRFAtt);
                fprintf(SA, SetAmpRFAtt)
            end
            if exist('ampLevelOffset','var')&&~isempty(ampLevelOffset)
                SetAmpRefLevOffset = sprintf('DISP:TRAC:Y:RLEV:OFFS %ddB', -ampLevelOffset);
                fprintf(SA, SetAmpRefLevOffset)
            end
            
            % bwRBW, bwSwpTime
            if exist('bwRBW','var')&&~isempty(bwRBW)
                SetBwRbw = sprintf('BAND:RES %d', bwRBW);
                fprintf(SA, SetBwRbw)
            end
            if exist('bwSwpTime','var')&&~isempty(bwSwpTime)
                SetBwSwptime = sprintf('SWE:TIME %ds', bwSwpTime);
                fprintf(SA, SetBwSwptime)
            end
            
            % Trigger
            if exist('Trigger','var')&&~isempty(Trigger)
                if isfield(Trigger,'source')
                    fprintf(SA, 'TRIG:SOUR %s',Trigger.source)
                end
                if isfield(Trigger,'level')
                    fprintf(SA, 'TRIG:SOUR %s',Trigger.source)
                end
                fclose(SA);
                
                
                SetBwSwptime = sprintf('SWE:TIME %ds', bwSwpTime);
                fprintf(SA, SetBwSwptime)
            end
            
            if nargout>=1
                fprintf(SA, 'CALC:MARK:AOFF');
                pause(0.2) % 0.2 is experienced setting
                fprintf(SA, 'CALC:MARK1 ON');
                fprintf(SA, 'CALC:MARK%d:X?', 1)
                XY(1,1+0) = {str2num(fscanf(SA))};
                pause(instr.delay)
                fprintf(SA, 'CALC:MARK%d:Y?', 1)
                XY(1,2+0) = {str2num(fscanf(SA))};
                pause(instr.delay)
                dsip_XY(1:1,1) = [{'Peak'}];
                dsip_XY(1:1,2) = [{'dBm'}];
            end
            % close
            fclose(SA)
            pause(instr.delay)
        end
        
        function [XY, dsip_XY] = SA_Marker(instr, FUNC, Markers, Freqs)
            SA = instr.SA;
            try
                fopen(SA);
            catch
                fclose(SA);
                fopen(SA);
            end
            fprintf(SA, '*IDN?');
            fscanf(SA);
            XYshfit = 0;
            
            if exist('FUNC','var')&&~isempty(FUNC)
                if strcmpi(FUNC,'OP1dB')%1 markers
                    fprintf(SA, 'INST:SEL SAN')
                    fprintf(SA, 'CALC:MARK:AOFF');
                    fprintf(SA, 'CALC:MARK1 ON');
                    Nmarks = 1;
                    dsip_XY(1:Nmarks,1) = [{'Pout1'}];
                    dsip_XY(1:Nmarks,2) = [{'dBm'}];
                elseif strcmpi(FUNC,'TOI')%4 markers
                    fprintf(SA, 'CALC:MARK:FUNC:%s ON', FUNC)
                    Nmarks = 4;
                    dsip_XY(1:Nmarks,1) = [{'Pout1'};{'Pout2'};{'Pim3L'};{'Pim3H'}];
                    dsip_XY(1:Nmarks,2) = [{'dBm'};{'dBm'};{'dBm'};{'dBm'}];
                else
                    Nmarks = 1;
                    dsip_XY(1:Nmarks,1) = [{'Pout1'}];
                    dsip_XY(1:Nmarks,2) = [{'dBm'}];
                end
                
                for k = 1:Nmarks
                    fprintf(SA, 'CALC:MARK%d:X?', k)
                    XY(k,1+XYshfit) = {str2num(fscanf(SA))};
                    %                     pause(0.5)
                    fprintf(SA, 'CALC:MARK%d:Y?', k)
                    XY(k,2+XYshfit) = {str2num(fscanf(SA))};
                    %                     pause(0.5)
                end
                XYshfit = 2;
            end
            
            % procedure
            Nmarks = numel(Markers);
            for k = 1:Nmarks
                if isempty(Freqs)
                    fprintf(SA, 'CALC:MARK:AOFF');
                    pause(0.2) % 0.2 is experienced setting
                    fprintf(SA, 'CALC:MARK1 ON');
                    pause(instr.delay)
                    SetMarkFreq = sprintf('CALC:MARK%d:X?', 1);
                elseif isnumeric(Freqs(k))
                    SetMarkFreq = sprintf('CALC:MARK%d:X %dMHz', Markers(k), Freqs(k));
                elseif ischar(Freqs(k))
                    SetMarkFreq = sprintf('CALC:MARK%d:%s', Markers(k), Freqs(k,:));
                elseif iscell(Freqs(k))
                    if isnumeric(cell2mat(Freqs(k)))
                        SetMarkFreq = sprintf('CALC:MARK%d:X %dMHz', Markers(k), cell2mat(Freqs(k)));
                    elseif ischar(cell2mat(Freqs(k)))
                        SetMarkFreq = sprintf('CALC:MARK%d:%s', Markers(k), cell2mat(Freqs(k)));
                    end
                else
                    error('check Freqs format?')
                end
                fprintf(SA, SetMarkFreq);
                XY(k,1+XYshfit) = {str2num(fscanf(SA))};
                dsip_XY(k,1+XYshfit) = {sprintf('Mark%d',k)};
                pause(instr.delay)
                fprintf(SA, 'CALC:MARK%d:Y?', k);
                XY(k,2+XYshfit) = {str2num(fscanf(SA))};
                dsip_XY(k,2+XYshfit) = {sprintf('dBm')};
            end
            % close
            fclose(SA)
            pause(instr.delay)
        end
    end
    
    
    methods % NF
        function [nf, gain, freqs] = NF_read(instr, MODE, fnum, fnum_marker, fnum_axis, fnum_save)
            NF = instr.NF;
            try
                fopen(NF);
            catch
                fclose(NF);
                fopen(NF);
            end
            try
                fprintf(NF, '*IDN?');
                fscanf(NF)
            end
            
            % procedure
            if ~exist('fnum','var')||isempty(fnum)
                flag_fnum = 0;
            else
                flag_fnum = 1;
            end
            if ~exist('fnum_marker','var')||isempty(fnum_marker)
                flag_fnum_marker = 0;
                fnum_marker = [];
            else
                flag_fnum_marker = 1;
            end
            if ~exist('fnum_axis','var')||isempty(fnum_axis)
                flag_fnum_axis = 0;
                fnum_axis = [];
            else
                flag_fnum_axis = 1;
            end
            if ~exist('fnum_save','var')||isempty(fnum_save)
                flag_fnum_save = 0;
                fnum_save = [];
            else
                flag_fnum_save = 1;
            end
            
            flag_AVERage = 0;
            if flag_AVERage
                fprintf(NF, 'SENSe:AVERage:STATe ON')
                fprintf(NF, 'SENSe:AVERage:STATe OFF')
                fprintf(NF, 'SENSe:AVERage:STATe?')
                fprintf(NF, 'SENSe:AVERage:MODE?')
                fprintf(NF, 'SENSe:AVERage:COUNt 4')
                fprintf(NF, 'SENSe:AVERage:COUNt?')
                Navg = str2num(fscanf(NF))
                pause(instr.delay)
            end
            
            flag_POINts = 0;
            if flag_POINts
                fprintf(NF, 'SENSe:SWEep:POINts 201')
            else
                fprintf(NF, 'SENSe:SWEep:POINts?')
                Npts = str2num(fscanf(NF))
                pause(instr.delay)
                
                fprintf(NF, 'SENSe:FREQuency:SPAN?')
                freq_span = str2num(fscanf(NF))
                pause(instr.delay)
                fprintf(NF, 'SENSe:FREQuency:STARt?')
                freq_start = str2num(fscanf(NF))
                pause(instr.delay)
                fprintf(NF, 'SENSe:FREQuency:STOP?')
                freq_stop = str2num(fscanf(NF))
                pause(instr.delay)
                freqs = freq_start:freq_span/(Npts-1):freq_stop;
            end
            
            flag_RST = 0;
            if flag_RST
                fprintf(NF, 'RST')
                fprintf(NF, 'CLS')
            end
            flag_FREQ = 0;
            if flag_FREQ
                fprintf(NF, 'SENSe:FREQuency:MODE?')
                fprintf(NF, 'SENSe:FREQuency:FIXed?')
                fprintf(NF, 'SENSe:FREQuency:LIST:DATA?')
                fprintf(NF, 'SENSe:FREQuency:LIST:COUNt?')
                fprintf(NF, 'SENSe:FREQuency:LIST:COUNt 201')
                ff = fscanf(NF)
            end
            
            fprintf(NF, '%s:CORR:GAIN? DB', MODE)
            gain_list = fscanf(NF);
            pause(instr.delay)
            ind_g = find(gain_list==',');
            
            fprintf(NF, '%s:CORR:NFIG? DB', MODE)
            nf_list = fscanf(NF);
            pause(instr.delay)
            ind_nf = find(gain_list==',');
            
            gain_tmp = gain_list;
            if all(diff(diff(ind_g))==0)
                gain_tmp(ind_g)=[];
                gain_tmp2=reshape(gain_tmp.',12,[]).';
                gain=str2num(gain_tmp2);
                nf = [];
            else
                gain = zeros(Npts,1);
                nf = zeros(Npts,1);
                ind_1 = 1;
                ind_1_nf = 1;
                
                for k=1:Npts
                    if k<Npts
                        ind_end = ind_g(k)-1;
                        gain(k) = str2num( gain_list([ind_1:ind_end]) );
                        ind_1 = ind_end + 1;
                        
                        ind_nf_end = ind_nf(k)-1;
                        nf(k) = str2num( nf_list([ind_1_nf:ind_nf_end]) );
                        ind_1_nf = ind_nf_end + 1;
                        
                    else
                        gain(k) = str2num( gain_list([ind_1:end]) );
                        nf(k) = str2num( nf_list([ind_1_nf:end]) );
                    end
                end
            end
            
            if isempty(nf)
                nf_tmp = nf_list;
                if all(diff(diff(ind_g))==0)
                    nf_tmp(ind_g)=[];
                    nf_tmp2=reshape(nf_tmp.',12,[]).';
                    nf=str2num(nf_tmp2);
                end
            end
            
            if flag_fnum
                fnum = ['NF'];
                fnum_subplt = [ [2,1,1];[2,1,2] ];
                fnum_title_cell = {'NoiseFigure';'Gain'};
                fnum_label_cell = {'NF(dB)','Freqs(MHz)';'Gain(dB)','Freqs(MHz)'};
                fnum_axis(:,1:2) = fnum_axis(:,1:2)/1e6;
                [nf_mk, gain_mk] = instr.fnum_Plt(freqs/1e6,nf,freqs/1e6,gain,['NF'], fnum_subplt, ...
                    fnum_title_cell, fnum_label_cell, fnum_marker/1e6, fnum_axis, fnum_save)
            end
            
            if flag_fnum_marker % export vs marker
                nf = nf_mk;
                gain = gain_mk;
            end
            
            % close
            fclose(NF)
            pause(instr.delay)
        end
        
        function [y1Mk y2Mk] = fnum_Plt(instr, x1,y1,x2,y2, fnum, fnum_subplt, fnum_title_cell, fnum_label_cell, fnum_marker, fnum_axis, fnum_save_cell)
            % initial
            if ~exist('fnum','var')||isempty(fnum)
                figure
            elseif ischar(fnum)
                figure('Name',fnum)
            elseif isnumeric(fnum)
                figure(fnum)
            end
            if ~exist('fnum_subplt','var')||isempty(fnum_subplt)
                flag_fnum_subplt = 0;
            else
                flag_fnum_subplt = 1;
            end
            if ~exist('fnum_title_cell','var')||isempty(fnum_title_cell)
                flag_fnum_title = 0;
            else
                flag_fnum_title = 1;
            end
            if ~exist('fnum_label_cell','var')||isempty(fnum_label_cell)
                flag_fnum_label = 0;
            else
                flag_fnum_label = 1;
            end
            if ~exist('fnum_marker','var')||isempty(fnum_marker)
                flag_fnum_marker = 0;
            else
                flag_fnum_marker = 1;
                Nmarker = numel(fnum_marker(1,:));
                x1Mk=[];
                y1Mk=[];
                ind_x1Mk=[];
                for k=1:Nmarker
                    [~, ind_mkTmp] = min(abs(x1-fnum_marker(1,k)));
                    x1Mk = [x1Mk, x1(ind_mkTmp)];
                    y1Mk = [y1Mk, y1(ind_mkTmp)];
                    ind_x1Mk = [ind_x1Mk, ind_mkTmp];
                end
                if size(fnum_marker,1)>1
                    Nmarker = numel(fnum_marker(2,:));
                    x2Mk=[];
                    y2Mk=[];
                    for k=1:Nmarker
                        [~, ind_mkTmp] = min(abs(x2-fnum_marker(2,k)));
                        x2Mk = [x2Mk, x2(ind_mkTmp)];
                        y2Mk = [y2Mk, y2(ind_mkTmp)];
                    end
                else
                    x2Mk = [x1Mk];
                    y2Mk = reshape([y2(ind_x1Mk)], 1,[]);
                end
            end
            if ~exist('fnum_axis','var')||isempty(fnum_axis)
                flag_fnum_axis = 0;
                y1max = max(y1);
                y1min = min(y1);
                try
                    dispYrpl= [ 'Ripple: [',num2str(round([y1max, y1min],2)),']' ];
                catch
                    dispYrpl= [ 'Ripple: [',num2str(round([y1max, y1min])),']' ];
                end
                try
                    y2max = max(y2);
                    y2min = min(y2);
                    try
                        dispYrp2= [ 'Ripple: [',num2str(round([y2max, y2min],2)),']' ];
                    catch
                        dispYrp2= [ 'Ripple: [',num2str(round([y2max, y2min])),']' ];
                    end
                end
            else
                flag_fnum_axis = 1;
                
                [~,ind_axis1] = min(abs(fnum_axis(1,1)-x1));
                xAxis1_1 = x1(ind_axis1);
                [~,ind_axis1End] = min(abs(fnum_axis(1,2)-x1));
                xAxis1_end = x1(ind_axis1End);
                y1max = max(y1(ind_axis1:1:ind_axis1End));
                y1min = min(y1(ind_axis1:1:ind_axis1End));
                try
                    dispYrpl= [ 'Ripple: [',num2str(round([y1max, y1min],2)),']' ];
                catch
                    dispYrpl= [ 'Ripple: [',num2str(round([y1max, y1min])),']' ];
                end
                if size(fnum_axis,2)>2
                    yAxis1_1 = fnum_axis(1,3);
                    yAxis1_end = fnum_axis(1,4);
                else
                    yAxis1_1 = min(y1);
                    yAxis1_end = max(y1);
                end
                if size(fnum_axis,1)>1
                    [~,ind_axis2] = min(abs(fnum_axis(2,1)-x1));
                    xAxis2_1 = x1(ind_axis2);
                    [~,ind_axis2End] = min(abs(fnum_axis(2,2)-x1));
                    xAxis2_end = x1(ind_axis2End);
                    y2max = max(y2(ind_axis2:1:ind_axis2End));
                    y2min = min(y2(ind_axis2:1:ind_axis2End));
                    try
                        dispYrp2= [ 'Ripple: [',num2str(round([y2max, y2min],2)),']' ];
                    catch
                        dispYrp2= [ 'Ripple: [',num2str(round([y2max, y2min])),']' ];
                    end
                    if size(fnum_axis,2)>2
                        yAxis2_1 = fnum_axis(2,3);
                        yAxis2_end = fnum_axis(2,4);
                    else
                        yAxis2_1 = min(y2);
                        yAxis2_end = max(y2);
                    end
                else
                    xAxis2_1 = xAxis1_1;
                    xAxis2_end = xAxis1_end;
                    yAxis2_1 = yAxis1_1;
                    yAxis2_end = yAxis1_end;
                end
            end
            if ~exist('fnum_save_cell','var')||isempty(fnum_save_cell)
                flag_fnum_save = 0;
            elseif iscell(fnum_save_cell)&&size(fnum_save_cell,1)==2
                flag_fnum_save = 1;
                FolderName = fnum_save_cell{1};
                InputName = fnum_save_cell{2};
            end
            
            % plot
            if ~isempty(y1)&&~isempty(x1) % plot y1, x1
                if flag_fnum_subplt
                    subplot(fnum_subplt(1,1), fnum_subplt(1,2), fnum_subplt(1,3))
                end
                plt1 = plot(x1,y1)
                try
                    title(fnum_title_cell{1,1});
                end
                try
                    y1_label = fnum_label_cell{1,1};
                    x1_label = fnum_label_cell{1,2};
                    xlabel(x1_label);
                    ylabel(y1_label);
                catch
                    x1_label = [];
                    y1_label = [];
                end
                try
                    axis([xAxis1_1, xAxis1_end, yAxis1_1, yAxis1_end])
                end
                if flag_fnum_marker
                    try
                        plt1.DisplayName = [y1_label,': ', num2str(round(y1Mk,2)), ', ', dispYrpl];
                    catch
                        plt1.DisplayName = [y1_label,': ', num2str(round(y1Mk)), ', ', dispYrpl];
                    end
                else
                    plt1.DisplayName = [y1_label,': ', dispYrpl];
                end
                legend
                
            end
            
            if ~isempty(y2)&&~isempty(x1) % plot y2, x2
                if flag_fnum_subplt
                    subplot(fnum_subplt(2,1), fnum_subplt(2,2), fnum_subplt(2,3))
                end
                plt2 = plot(x2,y2)
                try
                    title(fnum_title_cell{2});
                end
                try
                    x2_label = fnum_label_cell{2,2};
                    y2_label = fnum_label_cell{2,1};
                    xlabel(x2_label);
                    ylabel(y2_label);
                catch
                    x2_label = [];
                    y2_label = [];
                end
                try
                    axis([xAxis2_1, xAxis2_end, yAxis2_1, yAxis2_end])
                end
                if flag_fnum_marker
                    try
                        plt2.DisplayName = [y2_label,': ', num2str(round(y2Mk,2)), ', ', dispYrp2];
                    catch
                        plt2.DisplayName = [y2_label,': ', num2str(round(y2Mk)), ', ', dispYrp2];
                    end
                else
                    plt2.DisplayName = [y2_label,': ', dispYrp2];
                end
                legend
            end
            
            if flag_fnum_save
                FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
                for iFig = 1:length(FigList)
                    FigHandle = FigList(iFig);
                    FigName   = [InputName,'_',get(FigHandle, 'Name'),'.fig'];
                    mkdir([FolderName,'\',date]);
                    savefig(FigHandle, fullfile(FolderName, date, FigName));
                end
            end
        end
    end
end









