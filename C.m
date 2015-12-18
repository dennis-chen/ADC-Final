classdef C
    
    methods(Static)
        
    function encoded = convEncode(bitVec, windowSize, genPolys)
    %bitVec- vector of bits to be encoded, as a row ex [1 0 1 1 ....]
    %windowSize= aka constraint length. genPolys must be same width as window
    %size
    %genPolys = 2D array of generator polynomials. ex if windowSize = 3, then
    %gen polys can be [[1,1,1];[1,1,0]]. Each row is a gen poly.
        [numPolys, polyLen] = size(genPolys);
        assert(polyLen == windowSize, 'Generator polynomial must be same length as window size!');
        convPolys = zeros(numPolys,length(bitVec));
        for i = 1:numPolys
            convolved = conv(genPolys(i,:),bitVec);
            convPolys(i,:) = convolved(1:length(bitVec));
        end
        parities = mod(convPolys,2);
        encoded = reshape(parities,numPolys*length(bitVec),1);
    end

    function shifted = shiftLeftOne(vector)
        shifted = zeros(size(vector));
        for i = 2:length(vector)
            shifted(i-1) = vector(i);
        end
    end

    function [prevOneIndices,prevZeroIndices,prevOneEmissions,prevZeroEmissions] = getStateMachine(windowSize, genPolys)
       [numPolys, polyLen] = size(genPolys);
       bitStateCount = 2^(windowSize-1);
       prevOneIndices = zeros(bitStateCount,1);
       prevZeroIndices = zeros(bitStateCount,1);
       prevOneEmissions = zeros(bitStateCount, numPolys);
       prevZeroEmissions = zeros(bitStateCount, numPolys);
       for i = 1:bitStateCount
          registers = de2bi(i-1,windowSize-1,'left-msb');
          bitShiftedIn = registers(1);
          prevOne = C.shiftLeftOne(registers);
          prevOne(end) = 1;
          prevOneIndex = bi2de(prevOne,'left-msb')+1;
          prevOneIndices(i) = prevOneIndex;
          prevOneRegs = [bitShiftedIn prevOne];
          prevOneEmit = zeros(1,numPolys);
          for j = 1:numPolys
              prevOneEmit(j) = mod(sum(genPolys(j,:) & prevOneRegs),2);
          end
          prevOneEmissions(i,:) = prevOneEmit;
          
          prevZero = C.shiftLeftOne(registers);
          prevZeroIndex = bi2de(prevZero,'left-msb')+1;
          prevZeroIndices(i) = prevZeroIndex;
          prevZeroRegs = [bitShiftedIn prevZero];
          prevZeroEmit = zeros(1,numPolys);
          for k = 1:numPolys
              prevZeroEmit(k) = mod(sum(genPolys(k,:) & prevZeroRegs),2);
          end
          prevZeroEmissions(i,:) = prevZeroEmit;
       end
    end

    function dist = hammingDist(vec1, vec2)
       %get hamming distance of two vectors
       assert(length(vec1) == length(vec2));
       dist = sum(xor(vec1,vec2));
    end

    function [trellis, decoded] = convDecode(encodeVec, windowSize, genPolys)
        [numPolys, polyLen] = size(genPolys);
        origMsgLen = length(encodeVec)/numPolys;
        bitStateCount = 2^(windowSize-1); 
        %initialize trellis and place infinities and zeros
        trellis = zeros(bitStateCount,origMsgLen+1);
        trellis(:,1) = Inf;
        trellis(1,1) = 0;
        prevNodePath = zeros(bitStateCount,origMsgLen+1); %stores index of node that points to the one in trellis
        [prevOneIndices,prevZeroIndices,prevOneEmissions,prevZeroEmissions] = C.getStateMachine(windowSize, genPolys);
        for col = 2:(origMsgLen+1)
           bitsObserved = encodeVec((col-2)*numPolys+1:(col-2)*numPolys+1+(numPolys-1))'; %I'm so sorry
           for row = 1:bitStateCount
               prevOneIndex = prevOneIndices(row);
               onePathMetric = trellis(prevOneIndex,col-1);
               prevOneEmission = prevOneEmissions(row,:);
               oneDist = C.hammingDist(bitsObserved,prevOneEmission);
               
               prevZeroIndex = prevZeroIndices(row);
               zeroPathMetric = trellis(prevZeroIndex,col-1);
               prevZeroEmission = prevZeroEmissions(row,:);
               zeroDist = C.hammingDist(bitsObserved,prevZeroEmission);
               
               if(onePathMetric+oneDist > zeroPathMetric+zeroDist)
                   pathMetric = zeroPathMetric+zeroDist;
                   prevNodePath(row,col) = prevZeroIndex;
               else
                   pathMetric = onePathMetric+oneDist;
                   prevNodePath(row,col) = prevOneIndex;
               end
               trellis(row,col) = pathMetric;
           end
        end
        [temp,prevNodeIndex] = min(trellis(:,end));
        decoded = zeros(1,origMsgLen);
        for col = origMsgLen+1:-1:2
            binary = de2bi(prevNodeIndex-1,windowSize-1,'left-msb');
            decoded(col-1) = binary(1);
            prevNodeIndex = prevNodePath(prevNodeIndex,col);
        end
    end

    function void = testConvCode(msg, genPolys, windowSize)
        encoded = C.convEncode(msg, windowSize, genPolys);
        [trellis,decoded] = C.convDecode(encoded, windowSize, genPolys);
        disp('Original msg:');
        disp(msg);
        disp(encoded');
        disp('After encoding and decoding: ');
        disp(decoded);
%         disp('Trellis: ');
%         disp(trellis);
    end
    
    end
end