close all;

imgBits = T.imageToBitVector('face.bmp');

genPolys = [[1,1,0,1];[1,0,1,0]; [1,0,0,1];[0,1,1,0]];
windowSize = 4;
convolved = C.convEncode(imgBits, windowSize, genPolys);

checkedBits = T.addCheckBits(convolved);

encoded = T.encodeBits(checkedBits, 5);

packetized = T.packetizeSignal(encoded, length(encoded)/8, 1e4);

pulsed = T.convPulse(packetized, ones(10,1));

datFormat = T.signalToDATFormat(pulsed);

padded = T.padSignal(datFormat);

figure;
plot(padded);

T.writeToDATFile(padded,'transmitConvfacebmp_packetized8.dat');