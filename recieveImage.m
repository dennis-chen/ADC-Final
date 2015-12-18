close all;
clear;

signal = R.stripZeros(R.readDATFile('demoFace6.dat'));
[packets, c] = R.getPacketNum(signal, 8);
    
allBits = [];
for i = 1:length(packets)
    [freqOffsets, correctedSignal, actual] = R.removeFreqOffsetChunkSized(packets{i},1000);
    pulseWidth = 10;
    sampledBits = R.sigToBits(actual,floor(pulseWidth/2),pulseWidth);
    packetSize = 50000;
    sampledBits = R.cutOrPadPacket(sampledBits,packetSize);
    allBits = [allBits; sampledBits];
end
recoveredBits = R.removeCheckBits(R.flipCheckBits(allBits));

%Convolutional decoder, comment out to disable
genPolys = [[1,1,0,1];[1,0,1,0];[1,0,0,1];[0,1,1,0]];
windowSize = 4;
[trellis,decoded] = C.convDecode(recoveredBits, windowSize, genPolys);

res = decoded';
originalBits = T.imageToBitVector('face.bmp');
disp('Number of incorrect bits: ');
disp(sum(abs(originalBits-res)));

img = T.bitsToImage(res,[100 100]);
imshow(img, [0 255]);