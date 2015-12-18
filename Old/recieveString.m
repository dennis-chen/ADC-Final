close all;
%clear;

%signal = R.stripZeros(R.readDATFile('hello_world_conv.dat'));
%R.plotComplex(signal);
[freqOffsets, correctedSignal, actual] = R.removeFreqOffsetChunkSized(signal,2000);
pulseWidth = 10;
sampledBits = R.sigToBits(actual,9,pulseWidth);
sampledBits = sampledBits(1:200000);
recoveredBits = R.removeCheckBits(R.flipCheckBits(sampledBits));
%recoveredBits = recoveredBits(1:10000);

%originalBits = T.stringToBitVector('My name is Dennis Chen and in the mornings I wake up and suck my roomate Gregs dick and then he pays me for my servicing because I am a cheap prostitute who is making money the only way I know how. I like working the streets. It gives me some kind of perverse satisfaction. i like to suck strangers dicks because I feel like they dont know me and that puts me in a position of power and I am a power hungry dom and I want to eat a cum omelet in the morning that my roommate Greg makes me');

%Convolutional decoder, comment out to disable
genPolys = [[1,1,1];[1,1,0]];
windowSize = 3;
[trellis,decoded] = C.convDecode(recoveredBits, windowSize, genPolys);
%originalBits = C.convEncode(originalBits, windowSize, genPolys);
res = decoded;

%disp('Bits incorrect: ');
%sum(abs(res - originalBits));
%disp(R.bitsToString(res'));
  
