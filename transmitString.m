close all;
clear;

stringBits = T.stringToBitVector('hello world');
res = stringBits;

%Convolutional encoder section, comment out to disable
% genPolys = [[1,1,1];[1,1,0]];
% windowSize = 3;
% convBits = C.convEncode(stringBits, windowSize, genPolys);
% res = convBits;

checkedBits = T.addCheckBits(res);
encoded = T.encodeBits(checkedBits,1);
pulsed = T.convPulse(encoded,ones(100,1));
datFormat = T.signalToDATFormat(pulsed);
padded = T.padSignal(datFormat);
plot(padded);
T.writeToDATFile(padded,'transmit_hello_world.dat');