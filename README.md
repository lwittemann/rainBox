Hello! This is my repository for some of the files I created for my rainBox project. The rainBox is a Arduino based box which generates colored noise for sleeping. For this, I used an Arduino nano every to generate the samples, a MCP 4725 DAC to convert the samples to an analog waveform, two TL072 op-amp chips to buffer and filter the audio, and a LM 386 to amplify the signal for a speaker. The files contained are as follows:

1. gaussianSampleGeneration --  MATLAB script where I investigated the generation of Gaussian random varibles using uniformly distributed ones
2. rainNoiseFilter -- MATLAB script where I designed some filters to create synthetic rain noise using white noise as an input
3. rainBoxRandom -- Working sketch for Arduino which contains all of my test code and methods which didn't make the final cut such as the circular FIR buffering code
4. rainBoxFinal -- Final Arduino sketch which generates the white noise samples and filters them using a first order IIR filter
5. 16kHzRain15Sec -- audio clip used in rainNoiseFilter
6. rainBoxAmpFinal -- LTSpice file which holds the circuit for the post-DAC buffer, filter, and amplifier. Requires tl074.sub and LM386 model install. tl074.sub is included in repo and LM386 install instructions can be found here: https://electronics.stackexchange.com/questions/619723/im-trying-to-simulate-an-audio-amplifier-circuit-but-i-couldnt-find-how-to-add
7. tl074.sub -- File needed for TL-074 simulation in rainBoxAmpFinal
8. Lower Box -- .step file for 3D model for lower rainBox enclosure
9. Upper Box -- .step file for 3D model for upper rainBox enclosure
10. Panel -- .step file for 3D model for lower rainBox enclosure access panel
