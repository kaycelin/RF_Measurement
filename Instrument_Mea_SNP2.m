%% PA1, 2021-09-13
% PA1x, 2021-09-15, example:

flag_Instr = 0;
if flag_Instr
    INSTR = Instrument_VNA_SG_SA_NF({'TCPIP0';'TCPIP0';'TCPIP0';'GPIB'},{'10.163.247.23';'10.163.247.117';'10.163.247.43';'8'},{'VNA';'SG';'SA';'NF'});

    %% step1, Save SNP by VNA
    type = 'S4P' % snp ports
    sa_ports = '1,2,3,4' % snp ports
    path = 'D:/2021-10-01' % save to folder
    noData = noData+1; % Update filename !!
    filename_temp = ['_25deg']
    filename=['QV_CH16_RX',filename_temp,'_',num2str(noData)]
    INSTR.VNA_SaveSNP(path, filename, type, sa_ports)
    
    % close INSTR
    fclose(INSTR.VNA)
    delete(INSTR);
    clear INSTR
end

flag_examp = 1;
if flag_examp
    Input = 'QV_CH16_RX_25DEG.S4P' % snp file
    z0 = 50 % impedance
    ports = [1:2;1:2] % snp ports
    freqs = [3.0 4.2]*1e9; % captured freqs
    typeIn2Out = 's' %s/s2z/s2y
    typeStability = 'mu' % stability type
    typeSmithChar = 'zy' % smith chart type
    
    fnum = 1103
    fnum_typePlt = 'ISO' % result: RL/IL/ISO
    fnum_Marker = [3.4e9, 3.6e9, 3.8e9] % marker freqs
    fnum_axis = [3.4e9 3.8e9 -90 0] % plot freqs(freqs > fnum_axis)
    fnum_axis = [3000e6 4200e6 25 40; 3000e6 4200e6 35 50]
    
    fnum_save = 'C:\Users\123\Documents\MATLAB\grant\ISO1001'; % save fnumt to folder
    fnum_save = [];
    fnum_xls = 'LNA_testresults.xls'; % save results to excel
    fnum_xls = [];
    flag_output = 2 % export Output type
    
    %% example:
        [Output, mu] = SNP_g(Input, z0, [1:4;1:4], freqs, typeIn2Out, typeStability, typeSmithChar, fnum, 'ISO', fnum_Marker, fnum_axis, fnum_save, fnum_xls, [], [], flag_output);
    %     [Output, mu] = SNP_g(Input, z0, ports, freqs, typeIn2Out, typeStability, typeSmithChar, fnum, fnum_typePlt);
    %     [Output, mu] = SNP_g(Input, z0, [], freqs, typeIn2Out, typeStability, typeSmithChar, fnum, 'ISO');
    %     [Output, mu] = SNP_g(Input, z0, [1:4;1:4], freqs, typeIn2Out, typeStability, [], fnum, 'ISO', fnum_Marker, fnum_axis, fnum_save, []);
    %     [Output, mu] = SNP_g(Input, z0, [1:4;1:4], freqs, typeIn2Out, typeStability, [], fnum, 'ISO', fnum_Marker, fnum_axis, fnum_save, fnum_xls);
    [Output, mu] = SNP_g(Input, z0, [1:4;1:4], freqs, typeIn2Out, typeStability, [], fnum, 'ISO', fnum_Marker, fnum_axis, fnum_save, fnum_xls, [], [], flag_output);
    %     [Output, mu] = SNP_g(Input, z0, [1:4;1:4], freqs, 's2z', typeStability, typeSmithChar, fnum, 'Z');
    %     [Output, mu] = SNP_g(Input, z0, [1:4;1:4], freqs, typeIn2Out, [], typeSmithChar, fnum, 'RL', fnum_Marker, fnum_axis, fnum_save, []);
    
end

%% A, 2021-10-14
%% A1, 2021-10-15, Stability mea. support 2 channels
%% A2, 2021-10-15, modify export of isolation
%% A3, 2021-10-15, modify export of stability
%% A4, 2021-11-01, flag_output, modify export of output
%% A5, 2021-11-01, flag_mu_lowfreq_ignore, ignore stability measurement error in low freqs.
function [Output, freqsOut, mu] = SNP_g(snpFile, z0, ports, freqs, typeIn2Out, typeStability, typeSmithChar, fnum, fnum_typePlt, fnum_Marker, fnum_axis, fnum_save, fnum_xls, fnum_legend, fnum_subplt, flag_output)
Output = [];
mu = [];
freqsOut =[];

if ~exist('z0','var')||isempty(z0)
    z0 = 50;
end
if ~exist('ports','var')||isempty(ports)
    %     ports = [1 1];
    flag_ports = 0;
else
    flag_ports = 1;
end
if ~exist('freqs','var')||isempty(freqs)
    flag_freqs = 0;
else
    flag_freqs = 1;
end
if ~exist('typeIn2Out','var')||isempty(typeIn2Out)
    typeIn2Out = 's';
end
if ~exist('typeStability','var')||isempty(typeStability)
    flag_Stability = 0;
else
    flag_Stability = 1;
end
if ~exist('typeSmithChar','var')||isempty(typeSmithChar)
    flag_SmithChar = 0;
else
    flag_SmithChar = 1;
end
if ~exist('fnum','var')||isempty(fnum)
    flag_fnum = 0;
else
    flag_fnum = 1;
end
if ~exist('fnum_typePlt','var')||isempty(fnum_typePlt)
    flag_fnum_typePlt = 0;
else
    flag_fnum_typePlt = 1;
end
if ~exist('fnum_Marker','var')||isempty(fnum_Marker)
    flag_fnum_Marker = 0;
else
    flag_fnum_Marker = 1;
end
if ~exist('fnum_axis','var')||isempty(fnum_axis)
    flag_fnum_axis = 0;
else
    flag_fnum_axis = 1;
end
if ~exist('fnum_save','var')||isempty(fnum_save)
    flag_fnum_save = 0;
else
    flag_fnum_save = 1;
end
if ~exist('fnum_xls','var')||isempty(fnum_xls)
    flag_fnum_xls = 0;
else
    flag_fnum_xls = 1;
    FileInput = (string(snpFile));
    FileInput = table(FileInput);
    xls_col = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    xls_col_no = [1 1];
    %     try
    %         xls_col_no = xls_col_no(end)+[1, numel([ISO1dB, ISO2dB, iso1Min, iso2Min])]
    %     catch
    %         xls_col_no = [1, numel([ISO1dB, ISO2dB, iso1Min, iso2Min])]
    %     end
    global xls_row_no
    try
        if isempty(xls_row_no)
            xls_row_no = [2;3];
        else
            xls_row_no = 2+xls_row_no
        end
    catch
        xls_row_no = [2;3];
    end
    xls_rag_File = [xls_col(xls_col_no(1)),num2str(xls_row_no(1)),':',xls_col(xls_col_no(2)),num2str(xls_row_no(2))];
    writetable([FileInput],fnum_xls,'Sheet',fnum_typePlt, 'Range',xls_rag_File);
end
if ~exist('fnum_legend','var')||isempty(fnum_legend)
    disp_legend = [];
else
    disp_legend = fnum_legend;
end
if ~exist('fnum_subplt','var')||isempty(fnum_subplt)
    flag_fnum_subplt = 0;
else
    flag_fnum_subplt = 1;
    noRow = 1;
end
if ~exist('flag_output','var')||isempty(flag_output) %% A4, 2021-11-01, modify export of output
    flag_output = 1;
else
    flag_output = 2;
end

if exist('snpFile','var')&&~isempty(snpFile)
    if ischar(snpFile)
        snp = sparameters(snpFile);
        input = snp.Parameters;
        freqslist = snp.Frequencies;
    elseif isnumeric(snpFile)
        input = snpFile;
        ind_f = [1:length(input)].';
    else
        error('check Input format!')
    end
end

if flag_freqs
    if exist('freqslist','var')&&~isempty(freqslist)&&numel(freqs)<=2
        [~ ,ind_fstart_fstop] =  min(abs(freqslist-freqs));
        fstart = freqslist(ind_fstart_fstop(1));
        fstop = freqslist(ind_fstart_fstop(end));
        ind_f = ind_fstart_fstop(1):ind_fstart_fstop(end);
        freqsPlt = freqslist(ind_f);
    elseif exist('freqslist','var')&&~isempty(freqslist)&&numel(freqs)>2
        error('numel(freqs)>2 is NOT support!')
    end
else
    ind_f = [1:size(input,3)];
    freqsPlt = ind_f;
end
InputAll = input;
input = input(:,:,ind_f);

if flag_ports
    jj = ports(1,:);
    ii = ports(2,:);
else
    jj = (1:size(input,1));
    ii = (1:size(input,2));
end
switch typeIn2Out
    case 's'
        s = input;
        Input = s(jj,ii,:);
    case 's2z'
        % Allocate memory for the Z-parameters
        z = zeros(size(input));
        
        % Calc the Z-parameters: Z = Z0 * (I + S) * inv(I - S)
        len = size(input,3);
        I = eye(size(input, 1));
        for k = 1:len
            z(:,:,k) = (z0 * (I + input(:,:,k))) /(I - input(:,:,k));
        end
        
        % export
        Input = z(jj,ii,:);
    case 's2y'
        % Allocate memory for the Y-parameters
        y = zeros(size(input));
        
        % Calculate the Y-parameters:  Y = (I - S) * inv(Z0 + Z0 * S)
        len = size(input,3);
        I = eye(size(input, 1));
        for k = 1:len
            y(:,:,k) = (I - input(:,:,k)) / (z0 * (I + input(:,:,k)));
        end
        
        % export
        Input = y(jj,ii,:);
end
sizeOutput = size(Input);

if flag_fnum && flag_fnum_typePlt && strcmpi(typeIn2Out,'s')
    %     figure(fnum)
    switch fnum_typePlt
        case 'RL'
            if flag_fnum_subplt
                subplot(fnum_subplt(noRow,1),fnum_subplt(noRow,2),fnum_subplt(noRow,3))
                noRow = noRow + 1;
            else
                figure('Name',fnum_typePlt);
            end
            yMin = [];
            yMax = [];
            for kk=1:size(ports,2)
                [sPlt] = rfplot(snp,ports(1,kk),ports(2,kk),'db'); hold on; grid on; title('Return Loss (dB)'),
                
                if flag_fnum_Marker
                    [~, ind_Marker] = min(abs(freqslist-fnum_Marker));
                    sPlt.DisplayName = ['S',num2str(ports(2,kk)),num2str(ports(1,kk)),'dB: ', num2str(round(sPlt.YData(ind_Marker),1))];
                    yMin = [yMin; min(sPlt.YData)];
                    yMax = [yMax; max(sPlt.YData)];
                end
            end
        case 'IL'
            if flag_fnum_subplt
                subplot(fnum_subplt(noRow,1),fnum_subplt(noRow,2),fnum_subplt(noRow,3))
                noRow = noRow + 1;
            else
                figure('Name',fnum_typePlt);
            end
            yMin = [];
            yMax = [];
            for kk=1:size(ports,2) %% output
                for ll=1:size(ports,2) %% input
                    [sPlt] = rfplot(snp,ports(2,kk),ports(1,ll),'db'); hold on; grid on; title('Insetion Loss (dB)'),
                    
                    if flag_fnum_Marker
                        [~, ind_Marker] = min(abs(freqslist-fnum_Marker));
                        sPlt.DisplayName = ['S',num2str(ports(2,kk)),num2str(ports(1,ll)),'dB: ', num2str(round(sPlt.YData(ind_Marker),1))];
                        yMin = [yMin; min(sPlt.YData)];
                        yMax = [yMax; max(sPlt.YData)];
                    end
                end
            end
            %     axis([3.4 3.6 0 -20])
        case 'PHS'
            for kk=1:size(ports,2)
                rfplot(snp,ports(1,kk),ports(2,kk),'angle'); hold on; grid on; title('Phase (deg)'),
            end
            
            yMin = [];
            yMax = [];
            if flag_fnum_subplt
                subplot(fnum_subplt(noRow,1),fnum_subplt(noRow,2),fnum_subplt(noRow,3))
                noRow = noRow + 1;
            else
                figure('Name',fnum_typePlt);
            end
            for kk=1:size(ports,2) %% output
                for ll=1:size(ports,2) %% input
                    [sPlt] = rfplot(snp,ports(2,kk),ports(1,ll),'angle'); hold on; title('Phase (deg)'),
                    
                    if flag_fnum_Marker
                        [~, ind_Marker] = min(abs(freqslist-fnum_Marker));
                        sPlt.DisplayName = ['S',num2str(ports(2,kk)),num2str(ports(1,ll)),'deg: ', num2str(round(sPlt.YData(ind_Marker),1))];
                        yMin = [yMin; min(sPlt.YData)];
                        yMax = [yMax; max(sPlt.YData)];
                    end
                end
            end
            
        case 'ISO'
            if all(sizeOutput(1:2)==[4 4])
                flag_ISO_ISO = 1;
                flag_ISO_IL = 1;
                flag_ISO_RL = 1;
                
                if flag_ISO_IL
                    s21 = Input(2,1,:);
                    s41 = Input(4,1,:);
                    s43 = Input(4,3,:);
                    s23 = Input(2,3,:);
                    s21dB = 20*log10(abs(s21(:)));
                    s41dB = 20*log10(abs(s41(:)));
                    s43dB = 20*log10(abs(s43(:)));
                    s23dB = 20*log10(abs(s23(:)));
                    if flag_fnum_subplt
                        subplot(fnum_subplt(noRow,1),fnum_subplt(noRow,2),fnum_subplt(noRow,3))
                        noRow = noRow + 1;
                    else
                        figure('Name','ISO');
                        subplot(1,flag_ISO_ISO+flag_ISO_IL+flag_ISO_RL,flag_ISO_ISO+flag_ISO_IL)
                    end
                    hold on, grid on, legend
                    pltS21 = plot(freqsPlt/1e6, s21dB,'DisplayName','dB(S21)','LineWidth',1);
                    pltS41 = plot(freqsPlt/1e6, s41dB,'DisplayName','dB(S41)','LineWidth',1);
                    pltS43 = plot(freqsPlt/1e6, s43dB,'DisplayName','dB(S43)','LineWidth',1);
                    pltS23 = plot(freqsPlt/1e6, s23dB,'DisplayName','dB(S23)','LineWidth',1);
                    %                     hold on
                    %                     grid on
                    %                     legend
                    xlabel('Frequency(MHz)')
                    ylabel('Gain(dB)')
                    title('IL')
                    if flag_fnum_axis
                        axis([fnum_axis(1,1)/1e6 fnum_axis(1,2)/1e6 fnum_axis(1,3) fnum_axis(1,4)])
                    end
                    if flag_fnum_Marker
                        [~, ind_Marker] = min(abs(freqsPlt-fnum_Marker));
                        IL1dB = round(pltS21.YData(ind_Marker(:)),2);
                        IL2dB = round(pltS43.YData(ind_Marker(:)),2);
                        pltS21.DisplayName = ['S21dB: ', num2str(IL1dB)];
                        pltS43.DisplayName = ['S43dB: ', num2str(IL2dB)];
                        pltS41.DisplayName = ['S41dB: ', num2str(round(pltS41.YData(ind_Marker),1))];
                        pltS23.DisplayName = ['S23dB: ', num2str(round(pltS23.YData(ind_Marker),1))];
                        
                        if flag_fnum_xls
                            IL = table(IL1dB, IL2dB);
                            xls_col = 'ABCDEFGHIJKLMNOPQRSTUV';
                            try
                                xls_col_no = xls_col_no(end)+[1, numel([IL1dB, IL2dB])];
                            catch
                                xls_col_no = [1, numel([IL1dB, IL2dB])];
                            end
                            xls_rag_IL = [xls_col(xls_col_no(1)),num2str(xls_row_no(1)),':',xls_col(xls_col_no(2)),num2str(xls_row_no(2))];
                            writetable([IL],fnum_xls,'Sheet',fnum_typePlt, 'Range',xls_rag_IL);
                        end
                        
                        % [y x]
                        [IL1Min, ind_Mk_IL1min] = min(pltS21.YData);
                        [IL2Min, ind_Mk_IL2min] = min(pltS43.YData);
                        %                         pltIsoMk1 = plot(pltIso1.XData(ind_Mk_ILmin1), pltIso1.YData(ind_Mk_ILmin1), 'r*', 'MarkerSize', 10);
                        %                         pltIsoMk2 = plot(pltIso2.XData(ind_Mk_min2), pltIso2.YData(ind_Mk_min2), 'r>', 'MarkerSize', 10);
                        %                         pltIsoMk1.DisplayName = ['ISO1dB min: ', num2str(round(iso1Min,1))];;
                        %                         pltIsoMk2.DisplayName = ['ISO2dB min: ', num2str(round(iso2Min,1))];
                    end
                end
                
                if flag_ISO_RL
                    s11 = Input(1,1,:);
                    s22 = Input(2,2,:);
                    s33 = Input(3,3,:);
                    s44 = Input(4,4,:);
                    s11dB = 20*log10(abs(s11(:)));
                    s22dB = 20*log10(abs(s22(:)));
                    s33dB = 20*log10(abs(s33(:)));
                    s44dB = 20*log10(abs(s44(:)));
                    if flag_fnum_subplt
                        subplot(fnum_subplt(noRow,1),fnum_subplt(noRow,2),fnum_subplt(noRow,3))
                        noRow = noRow + 1;
                    else
                        %                         figure('Name','ISO');
                        subplot(1,flag_ISO_ISO+flag_ISO_IL+flag_ISO_RL,flag_ISO_ISO+flag_ISO_IL+flag_ISO_RL)
                    end
                    hold on, grid on, legend
                    pltS11 = plot(freqsPlt/1e6, s11dB,'DisplayName','dB(S11)','LineWidth',1);
                    pltS22 = plot(freqsPlt/1e6, s22dB,'DisplayName','dB(S22)','LineWidth',1);
                    pltS33 = plot(freqsPlt/1e6, s33dB,'DisplayName','dB(S33)','LineWidth',1);
                    pltS44 = plot(freqsPlt/1e6, s44dB,'DisplayName','dB(S44)','LineWidth',1);
                    xlabel('Frequency(MHz)')
                    ylabel('RL(dB)')
                    title('RL')
                    if flag_fnum_axis
                        axis([fnum_axis(1,1)/1e6 fnum_axis(1,2)/1e6 -30 0])
                    end
                    if flag_fnum_Marker
                        [~, ind_Marker] = min(abs(freqsPlt-fnum_Marker));
                        RL1dB = round(pltS11.YData(ind_Marker(:)),2);
                        RL2dB = round(pltS22.YData(ind_Marker(:)),2);
                        RL3dB = round(pltS33.YData(ind_Marker(:)),2);
                        RL4dB = round(pltS44.YData(ind_Marker(:)),2);
                        pltS11.DisplayName = ['S11dB: ', num2str(RL1dB)];
                        pltS22.DisplayName = ['S22dB: ', num2str(RL2dB)];
                        pltS33.DisplayName = ['S44dB: ', num2str(RL3dB)];
                        pltS44.DisplayName = ['S44dB: ', num2str(RL4dB)];
                        
                        if flag_fnum_xls
                            RL = table(RL1dB, RL2dB, RL3dB, RL4dB);
                            xls_col = 'ABCDEFGHIJKLMNOPQRSTUV';
                            try
                                xls_col_no = xls_col_no(end)+[1, numel([RL1dB, RL2dB, RL3dB, RL4dB])];
                            catch
                                xls_col_no = [1, numel([RL1dB, RL2dB, RL3dB, RL4dB])];
                            end
                            xls_rag_RL = [xls_col(xls_col_no(1)),num2str(xls_row_no(1)),':',xls_col(xls_col_no(2)),num2str(xls_row_no(2))];
                            writetable([RL],fnum_xls,'Sheet',fnum_typePlt, 'Range',xls_rag_RL);
                        end
                        
                        % [y x]
                        [RL1Min, ind_Mk_RL1min] = min(pltS11.YData);
                        [RL2Min, ind_Mk_RL2min] = min(pltS22.YData);
                        [RL3Min, ind_Mk_RL3min] = min(pltS33.YData);
                        [RL4Min, ind_Mk_RL4min] = min(pltS44.YData);
                        %                         pltIsoMk1 = plot(pltIso1.XData(ind_Mk_ILmin1), pltIso1.YData(ind_Mk_ILmin1), 'r*', 'MarkerSize', 10);
                        %                         pltIsoMk2 = plot(pltIso2.XData(ind_Mk_min2), pltIso2.YData(ind_Mk_min2), 'r>', 'MarkerSize', 10);
                        %                         pltIsoMk1.DisplayName = ['ISO1dB min: ', num2str(round(iso1Min,1))];;
                        %                         pltIsoMk2.DisplayName = ['ISO2dB min: ', num2str(round(iso2Min,1))];
                    end
                end
                
                if flag_ISO_ISO
                    iso1dB = 20*log10(abs(s21./s41));
                    iso2dB = 20*log10(abs(s43./s23));
                    if flag_fnum_subplt
                        subplot(fnum_subplt(noRow,1),fnum_subplt(noRow,2),fnum_subplt(noRow,3))
                        noRow = noRow + 1;
                    else
                        %                         figure('Name','ISO');
                        subplot(1,flag_ISO_ISO+flag_ISO_IL+flag_ISO_RL,flag_ISO_ISO)
                    end
                    hold on
                    grid on
                    legend
                    pltIso1 = plot(freqsPlt/1e6, iso1dB(:),'DisplayName','dB(Iso1)','LineWidth',1);
                    pltIso2 = plot(freqsPlt/1e6, iso2dB(:),'DisplayName','dB(Iso2)','LineWidth',1);
                    xlabel('Frequency(MHz)')
                    ylabel('ISO(dB)')
                    title('ISO')
                    if flag_fnum_axis
                        axis([fnum_axis(2,1)/1e6 fnum_axis(2,2)/1e6 fnum_axis(2,3) fnum_axis(2,4)])
                    end
                    if flag_fnum_Marker
                        [~, ind_Marker] = min(abs(freqsPlt-fnum_Marker));
                        ISO1dB = round(pltIso1.YData(ind_Marker),2);
                        ISO2dB = round(pltIso2.YData(ind_Marker),2);
                        pltIso1.DisplayName = ['ISO1dB: ', num2str(ISO1dB)];
                        pltIso2.DisplayName = ['ISO2dB: ', num2str(ISO2dB)];
                        
                        % [y x] min and max
                        [iso1Max, ind_Mk_max1] = max(pltIso1.YData);
                        [iso1Min, ind_Mk_min1] = min(pltIso1.YData);
                        [iso2Max, ind_Mk_max2] = max(pltIso2.YData);
                        [iso2Min, ind_Mk_min2] = min(pltIso2.YData);
                        pltIsoMk1 = plot(pltIso1.XData(ind_Mk_min1), pltIso1.YData(ind_Mk_min1), 'r*', 'MarkerSize', 10);
                        pltIsoMk2 = plot(pltIso2.XData(ind_Mk_min2), pltIso2.YData(ind_Mk_min2), 'r>', 'MarkerSize', 10);
                        pltIsoMk1.DisplayName = ['ISO1dB min: ', num2str(round(iso1Min,1))];;
                        pltIsoMk2.DisplayName = ['ISO2dB min: ', num2str(round(iso2Min,1))];
                        isoMin = min(iso1Min, iso2Min);
                        
                        if flag_fnum_xls
                            ISO = table(ISO1dB, ISO2dB, isoMin);
                            xls_col = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
                            try
                                xls_col_no = xls_col_no(end)+[1, numel([ISO1dB, ISO2dB, isoMin])];
                            catch
                                xls_col_no = [1, numel([ISO1dB, ISO2dB, isoMin])];
                            end
                            xls_rag_ISO = [xls_col(xls_col_no(1)),num2str(xls_row_no(1)),':',xls_col(xls_col_no(2)),num2str(xls_row_no(2))];
                            writetable([ISO],fnum_xls,'Sheet',fnum_typePlt, 'Range',xls_rag_ISO);
                        end
                    end
                end
                
                % export
                if 0 %% A2, 2021-10-15, modify export of isolation
                    Output(:,1) = iso1dB(:);
                    Output(:,2) = iso2dB(:);
                else
                    switch flag_output
                        case 1
                            Output{1,1} = 'iso1dB';
                            Output{2,1} = iso1dB(:);
                            Output{1,2} = 'iso2dB';
                            Output{2,2} = iso2dB(:);
                            
                            Output{1,3} = 'S21dB';
                            Output{2,3} = 20*log10(abs(s21(:)));
                            Output{1,4} = 'S43dB';
                            Output{2,4} = 20*log10(abs(s43(:)));
                            
                            Output{1,5} = 'S11dB';
                            Output{2,5} = 20*log10(abs(s11(:)));
                            Output{1,6} = 'S22dB';
                            Output{2,6} = 20*log10(abs(s22(:)));
                            Output{1,7} = 'S33dB';
                            Output{2,7} = 20*log10(abs(s33(:)));
                            Output{1,8} = 'S44dB';
                            Output{2,8} = 20*log10(abs(s44(:)));
                        case 2
                            Output{1,1} = 'Sparam:';
                            ch1 = 2; Output{1,ch1} = 'Ch1';
                            ch2 = 3; Output{1,ch2} = 'Ch2';
                            Output{2,1} = 'Gain(dB) min';   Output{2,ch1} = min(s21dB);   Output{2,ch2} = min(s43dB);
                            Output{3,1} = 'Gain(dB) max';   Output{3,ch1} = max(s21dB);   Output{3,ch2} = max(s43dB);
                            Output{4,1} = 'Ripple(dB) max'; Output{4,ch1} = max(s21dB)-min(s21dB); Output{4,ch2} = max(s43dB)-min(s43dB);
                            Output{5,1} = 'StepAtt(dB)';    Output{5,ch1} = []; Output{5,ch2} = [];
                            Output{6,1} = 'RLinput(dB) max';   Output{6,ch1} = max(s11dB);  Output{6,ch2} = max(s33dB);
                            Output{7,1} = 'RLonput(dB) max';   Output{7,ch1} = max(s22dB);  Output{7,ch2} = max(s44dB);
                            Output{8,1} = 'Iso(dB) min';    Output{8,ch1} = min(iso1dB);    Output{8,ch2} = min(iso2dB);
                            row_output = 8;
                    end
                end
                freqsOut = freqsPlt;
            else
                error('ISO, data input should 4x4!')
            end
    end
    
    if flag_fnum_Marker && ~strcmpi(fnum_typePlt,'ISO') % plot Marker horizaontal line
        for m=1:size(fnum_Marker,2)
            if 0
                fnum_Marker = [3.400e9, 3.6e9, 3.8e9];
                [~, ind_Marker] = min(abs(freqslist-fnum_Marker));
                plt = plot(sPlt.XData(ind_Marker), sPlt.YData(ind_Marker), 'r*');
            end
            x = [fnum_Marker(m)/1e0; fnum_Marker(m)/1e0];
            try
                y = [fnum_axis(1,3) fnum_axis(1,4)];
            catch
                y = [min(yMin) max(yMax)];
            end
            line(x,y,'Color','b','LineStyle','--')
        end
        
        if flag_fnum_axis
            axis([fnum_axis(1,1)/1e0 fnum_axis(1,2)/1e0 fnum_axis(1,3) fnum_axis(1,4)])
        end
    end
    
elseif flag_fnum && flag_fnum_typePlt && ( strcmpi(typeIn2Out,'s2z')||strcmpi(typeIn2Out,'s2y') )
    if flag_fnum_subplt
        subplot(fnum_subplt(noRow,1),fnum_subplt(noRow,2),fnum_subplt(noRow,3))
        noRow = noRow + 1;
    else
        figure('Name', fnum_typePlt)
    end
    switch fnum_typePlt
        case 'Z'
            for kk=jj
                for ll=ii
                    Z_magdB = 20*log10(abs(Input(kk,ll,:)));
                    plot(freqsPlt/1e6, Z_magdB(:),'DisplayName',['dB(Z',[num2str(kk),num2str(ll)],')']); hold on, grid on
                    legend;
                end
            end
        case 'Y'
            for kk=jj
                for ll=ii
                    Y_magdB = 20*log10(abs(Input(kk,ll,:)));
                    plot(freqsPlt/1e6, Y_magdB(:),'DisplayName',['dB(Y',[num2str(kk),num2str(ll)],')']); hold on, grid on
                    legend;
                end
            end
    end
end

if flag_Stability && strcmpi(typeIn2Out,'s') && all(sizeOutput(1:2)>=[2 2])
    if all(sizeOutput(1:2)==[2 2]) %% A1, 2021-10-15, Stability mea. support 2 channels
        Nch = 1;
    elseif all(sizeOutput(1:2)==[4 4])
        Nch = 2;
    else
        error('check the Input ports?!')
    end
    for k = 1:Nch
        if k==1
            s11 = InputAll(1,1,:);
            s12 = InputAll(1,2,:);
            s21 = InputAll(2,1,:);
            s22 = InputAll(2,2,:);
        elseif k==2
            s11 = InputAll(1+2,1+2,:);
            s12 = InputAll(1+2,2+2,:);
            s21 = InputAll(2+2,1+2,:);
            s22 = InputAll(2+2,2+2,:);
        end
        s11Pwr = abs(s11.*s11);
        s22Pwr = abs(s22.*s22);
        s12s21Pwr = abs(s12.*s21);
        delta = s11.*s22 - s12.*s21;
        mu1 = (1-s11Pwr)./ ( abs(s22-conj(s11).*delta) + s12s21Pwr );
        mu2 = (1-s22Pwr)./ ( abs(s11-conj(s22).*delta) + s12s21Pwr );
        if 0 %% A3, 2021-10-15, modify export of stability
            mu = min([mu1(:);mu2(:)]);
        else
            mu{1,1+(k-1)*2} = ['mu1, ch',num2str(k)];
            mu{1,2+(k-1)*2} = ['mu2, ch',num2str(k)];
            mu{2,1+(k-1)*2} = mu1(:);
            mu{2,2+(k-1)*2} = mu2(:);
            %             mu{1,3} = ['mu1, ch',num2str(k)]
            %             mu{1,4} = ['mu2, ch',num2str(k)]
        end
        
        flag_mu_freqLow_ignore = 1; %% A5, 2021-11-01, flag_mu_lowfreq_ignore, ignore stability measurement error in low freqs.
        if flag_mu_freqLow_ignore
            freqLow_ignore = 200e6; % freqs ignore
            [~, ind_freq_ignore] = min(abs(freqLow_ignore-freqslist));
            freqslist_mu = freqslist(ind_freq_ignore+1:end);
            mu1 = mu1(ind_freq_ignore+1:end);
            mu2 = mu2(ind_freq_ignore+1:end);
        end
        
        if flag_fnum
            if flag_fnum_subplt
                subplot(fnum_subplt(noRow,1),fnum_subplt(noRow,2),fnum_subplt(noRow,3))
                noRow = noRow + 1;
            else
                if k==1
                    figure('Name', 'Stability')
                end
                subplot(Nch,1,k)
            end
            try
                %                 plot(freqsPlt/1e6, mu1(:), 'DisplayName','mu1'), hold on, grid on
                %                 plot(freqsPlt/1e6, mu2(:), 'DisplayName','mu2'), legend
                plot(freqslist_mu/1e6, mu1(:), 'DisplayName','mu1'), hold on, grid on
                plot(freqslist_mu/1e6, mu2(:), 'DisplayName','mu2'), legend
                xlabel('Frequency(MHz)')
                ylabel('mu')
            catch
                plot(mu1(:), 'DisplayName','mu1'), hold on, grid on
                plot(mu2(:), 'DisplayName','mu2'), legend
            end
            if Nch == 1
                title('Stability')
            else
                title(['Stability, ch',num2str(k)])
            end
        end
        
        % export
        switch flag_output
            case 2
                Output{row_output+1,1} = 'Mu min';    Output{row_output+1,k+1} = min(mu1);
        end
    end
    row_output = row_output+1;
end

if flag_SmithChar && strcmpi(typeIn2Out,'s')
    if flag_fnum_subplt
        subplot(fnum_subplt(noRow,1),fnum_subplt(noRow,2),fnum_subplt(noRow,3))
        noRow = noRow + 1;
    else
        figure('Name','Smithchart')
    end
    title('Smith Chart'),
    for kk=1:size(ports,2)
        snp_freqs = sparameters(input,freqslist(ind_f));
        try
            plt_smitchchart = smithplot(snp_freqs,ports(:,kk).','GridType',typeSmithChar); hold on
            plt_smitchchart.LegendLabels(kk) = {['S',num2str(ports(2,kk)),num2str(ports(1,kk)), disp_legend]};
            plt_smitchchart.LineStyle = '-';
            plt_smitchchart.LineWidth = 0.5;
            if flag_fnum_Marker
                [~, ind_Marker] = min(abs(freqsPlt-fnum_Marker));
                if 0
                    gamma_L=(ZL1-Z0)/(ZL1+Z0);
                end
                gamma_L = snp_freqs.Parameters(ports(kk),ports(kk),ind_Marker);
                plt_smitchchart_mk=plot(reshape(real(gamma_L),1,[]),reshape(imag(gamma_L),1,[]),'r>','LineWidth',0.5);
                plt_smitchchart_mk.MarkerSize = 2;
                plt_smitchchart_mk.LineWidth = 2;
                plt_smitchchart_mk.DisplayName = ['freqs(MHz): ',num2str(fnum_Marker/1e6)]
            end
        catch
            close (fnum+flag_fnum+flag_Stability)
        end
    end
end

%% save all figure
if flag_fnum_save
    FolderName  = fnum_save;   % Your destination folder
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    for iFig = 1:length(FigList)
        FigHandle = FigList(iFig);
        InputName = snpFile(1:find(snpFile=='.')-1);
        FigName   = [InputName,'_',get(FigHandle, 'Name'),'.fig'];
        mkdir([FolderName,'\',date]);
        savefig(FigHandle, fullfile(FolderName, date, FigName));
    end
end

end

