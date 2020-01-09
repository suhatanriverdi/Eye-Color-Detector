% Image Processing Project
% Eye Color Detection
% Süha Tanriverdi

I = imread('1.png');
I_cut = imread('1.png');

% These are the sample images, uncomment to use!
% I = imread('2.png');
% I_cut = imread('2.png');

% I = imread('3.png');
% I_cut = imread('3.png');

% I = imread('4.png');
% I_cut = imread('4.png');

% I = imread('5.png');
% I_cut = imread('5.png');

% figure
% imshow(I);
I = rgb2gray(I);

% pupil extraction
% histogram generation
[img_hist, img_bins] = hist(double(I(:)), 5);
% threshold determination
T = img_bins(1);
% image binarization/thresholding
b = I < T;
% visualizing the result
% figure
% imshow(b);

% connected component labeling
labeled = bwlabel(b, 8);
rgb = label2rgb(labeled, 'spring', [0 0 0]);
% figure, imshow(rgb);
% getting pupil candidates
candidate_pupil = regionprops(labeled, 'Area', ...
  'Eccentricity', 'Centroid', 'BoundingBox');
maxArea = 0;
for i = 1 : length(candidate_pupil)
    if (candidate_pupil(i).Area > maxArea) && ...
          (candidate_pupil(i).Eccentricity <= 0.7)
        maxArea = candidate_pupil(i).Area;
        m = i;
    end
end
% getting the centroid and radius of the pupil
Pupil.Cx = round(candidate_pupil(m).Centroid(1));
Pupil.Cy = round(candidate_pupil(m).Centroid(2));
Pupil.R = round(max(candidate_pupil(m).BoundingBox(3) / 2, candidate_pupil(m).BoundingBox(4) / 2));

% Increase The Radius of Circle
Pupil.Rbig = Pupil.R * 2.7;

nPoints = 500;
theta = linspace(0, 2 * pi, nPoints);
rho = ones(1, nPoints) * Pupil.R;
[X, Y] = pol2cart(theta, rho);
X = X + Pupil.Cx;
Y = Y + Pupil.Cy;
% figure, imshow(I);
hold on
% plot(X,Y,'r','LineWidth',3);

% Iris Boundary Extraction, We cut the red circle range
imageSize = size(I_cut);
ci = [Pupil.Cy, Pupil.Cx, Pupil.R]; % center and radius of circle ([c_row, c_col, r])
[xx, yy] = ndgrid((1:imageSize(1)) - ci(1), (1:imageSize(2)) - ci(2));
mask = uint8((xx .^ 2 + yy .^ 2) < ci(3) ^ 2);
cropPupil = uint8(zeros(size(I_cut)));
cropPupil(:, :, 1) = I_cut(:, :, 1) .* mask;
cropPupil(:, :, 2) = I_cut(:, :, 2) .* mask;
cropPupil(:, :, 3) = I_cut(:, :, 3) .* mask;
% figure, imshow(cropPupil);

% Intersection
imageSize = size(I_cut);
ci = [Pupil.Cy, Pupil.Cx, Pupil.Rbig]; % center and radius of circle ([c_row, c_col, r])
[xx, yy] = ndgrid((1:imageSize(1)) - ci(1), (1:imageSize(2)) - ci(2));
mask = uint8((xx .^ 2 + yy .^ 2) < ci(3) ^ 2);
cropBig = uint8(zeros(size(I_cut)));
cropBig(:, :, 1) = I_cut(:, :, 1) .* mask;
cropBig(:, :, 2) = I_cut(:, :, 2) .* mask;
cropBig(:, :, 3) = I_cut(:, :, 3) .* mask;
% figure, imshow(cropBig);

% Extract
cropBig = cropBig - cropPupil;
figure, imshow(cropBig);

% Get Means of RGB
RValue = round(mean2(nonzeros(cropBig(:, :, 1))));
GValue = round(mean2(nonzeros(cropBig(:, :, 2))));
BValue = round(mean2(nonzeros(cropBig(:, :, 3))));
rgbImage(1, 1, :) = [RValue, GValue, BValue]; % r, g, b are uint8 values

% % % % % % % % % % % % % % % % % % % % % % % % % %
% Finding Dominant Color
r = RValue;
g = GValue;
b = BValue;
disp(r);
disp(g);
disp(b);

%     COLOR R     G      B
%     Blue 0-30  0-60  60-255
blueLowThreshold = 85;
blueHighThreshold = 200;
blueMask = (b > blueLowThreshold & b < blueHighThreshold);
y = (blueMask);
if y == 1
    disp("BLUE");
    return
end

%     COLOR        R     G      B
%     Brown 140-170  40-80  0-25
redLowThreshold = 140;
redHighThreshold = 170;
redMask = (r >= redLowThreshold & r < redHighThreshold);
y = (redMask);
if y == 1
    disp("BROWN");
    return
end

%     COLOR   R     G      B
%     Green 0-30  130-255  0-60
greenLowThreshold = 130;
greenHighThreshold = 255;
greenMask = (g > greenLowThreshold & g < greenHighThreshold);
y = (greenMask);
if y == 1
    disp("GREEN");
    return
    %     COLOR   R     G      B
    %     Hazel  31-100  130-255  60-90
else
    disp("HAZEL");
    return
end

disp("Color Not Found!");