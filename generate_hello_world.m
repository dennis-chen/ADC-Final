f1 = fopen('transmit_hello_world_less_repeat.dat', 'w');
bytes = uint8('hello world'); %the char function will convert back
bits = zeros(length(bytes)*10,1);
for i = 1:length(bytes)
    bits(10*(i-1)+1:10*(i-1)+2) = [1, 0];
    bits(10*(i-1)+3:10*(i-1)+10) = fliplr(de2bi(bytes(i),8)); 
end

repeat_no = 25;
temp = zeros(length(bits)*repeat_no, 1);
for i = 1:length(bits)
    if bits(i) == 1
        temp(repeat_no*(i-1)+1:repeat_no*(i-1)+repeat_no) = ones(repeat_no, 1);
    end
    if bits(i) == 0
        temp(repeat_no*(i-1)+1:repeat_no*(i-1)+repeat_no) = -ones(repeat_no, 1);
    end
end

res = zeros(length(temp)*2, 1);
res(1:2:end) = temp;
res = [zeros(1e5, 1); res; zeros(1e5,1)];
figure;
plot(res);
fwrite(f1, res, 'float32');
fclose(f1);