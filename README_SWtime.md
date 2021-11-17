# TR Switch switching time measurement:
input of SG:
- sg_offset1 = -5.9
- sg_offset2 = -5.9
- sg_PoutdBm1 = [-20]
- sg_PoutdBm2 = 0
- sg_freqC = [3.4e9 3.6e9 3.8e9]
- sg_freqOfs1 = -2.5e6
- sg_freqOfs2 = 2.5e6

- sg_port = [1]
- sg_sigType = 'CW' 

input of SA:
- sa_MODE = []
- sa_MEAS = []
- sa_MEASConfig = []
- sa_freqC = mean(sg_freqC)
- sa_freqSpan = 0
- sa_ampLevel = 10
- sa_ampLevelOffset = []
- sa_ampRFAtt = 25
- sa_ampPreAmp = []
- sa_bwRBW = 10e6
- sa_bwSwpTime = 10e-6
- sa_Trigger.source = 'EXT' % 'IMM:freeRun'/'EXT'/'IFP'/'RFP'
- sa_Trigger.level = 1.4
- sa_Trigger.offset = '-3us'
- sa_Trigger.slope = 'Rising' % 1:Rising, 0:Falling

output results: switching time < 500ns
![image](https://user-images.githubusercontent.com/87049112/142162482-42eb6f45-7eae-4091-bcf1-39fa7d9d8883.png)

