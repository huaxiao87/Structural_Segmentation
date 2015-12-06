fs          = 11025;
B           = 8;
lowFreq     = 62.5;
highFreq    = 16000;

figure
subplot(3,1,1)
x=sin(5000*(0:1/11025:2*pi));
plot(abs(cqt(x, fs, B, lowFreq , highFreq)))

subplot(3,1,2)
x=sin(2000*(0:1/11025:2*pi));
plot(abs(cqt(x, fs, B, lowFreq , highFreq)))

subplot(3,1,3)
x=sin(1000*(0:1/11025:2*pi));
plot(abs(cqt(x, fs, B, lowFreq , highFreq)))

