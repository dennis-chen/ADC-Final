f1 = fopen('transmit_data.dat', 'w');
x = ones(1e4, 1);
y = -ones(1e4, 1);
temp = [x; y];
% temp = [zeros(1e5, 1); x; y; zeros(1e5, 1)];
res = zeros(length(temp)*2, 1);
res(1:2:end) = temp;
res = [zeros(1e5, 1); res; zeros(1e5,1)];
plot(res);
fwrite(f1, res, 'float32');
fclose(f1);

% f1 = fopen('foo.dat', 'w');

% temp = 0.5*ones(1e4, 1);
% x = zeros(length(temp)*2, 1);
% x(1:2:end) = temp;
% x = ones(1e5,1);
% x = [x; 0.5*ones(1e5, 1); zeros(1e5, 1)];
% x = [x; x];
% plot(x);
% fwrite(f1, x, 'float32');

% fclose(f1);

% RGB = imread('baboon.bmp');
% I = rgb2gray(RGB);
% temp = I((100:299), (100:299));
% imshow(temp)
% x = [];
% for i=1:200
%     x = [x; temp(:,i)];
% end

% f1 = fopen('foo.dat', 'w');
% fwrite(f1, x, 'float32');
% fclose(f1);