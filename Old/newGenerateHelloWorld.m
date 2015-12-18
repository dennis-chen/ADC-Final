close all;

stringBits = T.stringToBitVector('hello world');
checkedBits = T.addCheckBits(stringBits);
encoded = T.encodeBits(checkedBits,1);
pulsed = T.convPulse(encoded,ones(100,1));
datFormat = T.signalToDATFormat(pulsed);
padded = T.padSignal(datFormat);
plot(padded);
T.writeToDATFile(padded,'transmit_hello_world.dat');