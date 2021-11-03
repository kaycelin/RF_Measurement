# OP1dB measurement:
input sg:
  - sg_offset1 = -6.0
  - sg_offset2 = -6.4
  - sg_PoutdBm1 = [-30:1:-10] % sa input sweep
  - sg_freqC = [3.4e9 3.6e9 3.8e9]
  - sg_port = [1]
  - sg_sigType = 'CW'

input sa:
  - sa_MODE = []
  - sa_MEAS = []
  - sa_MEASConfig = []
  - sa_freqC = mean(sg_freqC)
  - sa_freqSpan = 20e6
  - sa_ampLevel = 10
  - sa_ampLevelOffset = -3
  - sa_ampRFAtt = 15
  - sa_ampPreAmp = []
  - sa_bwRBW = 200e3
  - sa_bwSwpTime = []

output results:                 
![image](https://user-images.githubusercontent.com/87049112/139816127-8c9c58a9-0978-4f36-8fde-bcc1c137e567.png)
![image](https://user-images.githubusercontent.com/87049112/139815898-23d02e9b-4736-46f7-8bfc-339b79c60f07.png)
