close all;
clear;

signal = R.stripZeros(R.readDATFile('5e6dogspulse10.dat'));
R.plotComplex(signal);
[freqOffsets, correctedSignal, actual] = R.removeFreqOffsetChunkSized(signal,2000);
pulseWidth = 10;
sampledBits = R.sigToBits(actual,floor(pulseWidth/2),pulseWidth);
recoveredBits = R.removeCheckBits(R.flipCheckBits(sampledBits));
res = recoveredBits;

originalBits = T.stringToBitVector('hello world')';

%Convolutional decoder, comment out to disable
% genPolys = [[1,1,1];[1,1,0]];
% windowSize = 3;
% [trellis,decoded] = C.convDecode(recoveredBits, windowSize, genPolys);
% originalBits = C.convEncode(originalBits, windowSize, genPolys);
% res = decoded;

%disp('Bits incorrect: ');
%sum(abs(res - originalBits));
disp(R.bitsToString(recoveredBits));
  
