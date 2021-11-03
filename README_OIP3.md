# OIP3 measurement:
input SG: 
  - sg_freqC = [3.4e9 3.6e9 3.8e9] % fix freqs
  - sg_freqOfs1 = -1e6 % tone1 offset
  - sg_freqOfs2 = 1e6 % tone2 offset
  - sg_offset1 = -6.0 % sg level offset
  - sg_offset2 = -6.0
  - sg_PoutdBm1 = -35 % sg input power
  - sg_PoutdBm2 = -35

![image](https://user-images.githubusercontent.com/87049112/139813979-c80fcaea-6316-4af9-9340-36920b4c5093.png)

input SA:
  - sa_MODE = []
  - sa_MEAS = []
  - sa_MEASConfig = []
  - sa_freqC = sg_freqC
  - sa_freqSpan = 20e6
  - sa_ampLevel = 10
  - sa_ampLevelOffset = -3 % sa level offset
  - sa_ampRFAtt = 15
  - sa_ampPreAmp = []
  - sa_bwRBW = 200e3
  - sa_bwSwpTime = 500e-3;

![image](https://user-images.githubusercontent.com/87049112/139814056-2a8f3d7d-ea63-4a38-acae-98bc7c20fcc1.png)

output results:           
![image](https://user-images.githubusercontent.com/87049112/139814690-043daf4e-194f-416b-a451-1d28cd12b191.png)
