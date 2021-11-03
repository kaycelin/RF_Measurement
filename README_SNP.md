# Sparameter measurement:
input:
  - type = 'S4P' % snp ports
  - sa_ports = '1,2,3,4' % snp ports
  - path = 'D:/2021-10-01' % save to folder
  - noData = noData+1; % Update filename !!
  - filename=['NP01Ch02_0',num2str(noData)]

input SNP results:
  - Input = 'QV_CH16_RX_25DEG.S4P' % snp file
  - z0 = 50 % impedance
  - ports = [1:2;1:2] % snp ports
  - freqs = [3.0 4.2]*1e9; % captured freqs
  - typeIn2Out = 's' %s/s2z/s2y
  - typeStability = 'mu' % stability type
  - typeSmithChar = 'zy' % smith chart type
    
  - fnum = 1103
  - fnum_typePlt = 'ISO' % result: RL/IL/ISO    
  - fnum_Marker = [3.4e9, 3.6e9, 3.8e9] % marker freqs    
  - fnum_axis = [3.4e9 3.8e9 -90 0] % plot freqs(freqs > fnum_axis)
  - fnum_axis = [3000e6 4200e6 25 40; 3000e6 4200e6 35 50]
  - fnum_save = 'C:\Users\123\Documents\MATLAB\grant\ISO1001'; % save fnumt to folder
  - fnum_xls = 'LNA_testresults.xls'; % save results to excel  
  - flag_output = 2 % export Output type

output SNP results:
 - ISO/IL/RL:
![image](https://user-images.githubusercontent.com/87049112/139970200-3587146f-cf35-434a-9940-819b2f617aef.png)

  - Stability(Mu): 
![image](https://user-images.githubusercontent.com/87049112/139970253-83e0e9c6-ea27-41a1-98fc-a2c909c25587.png)

  - Smith chart:      
![image](https://user-images.githubusercontent.com/87049112/139970476-3ce1bc92-efb5-4afe-b4aa-143fac263419.png)
