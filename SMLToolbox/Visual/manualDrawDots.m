function [dotText] = manualDrawDots(posX, posY, dotSize)
% [dotText] = manualDrawDots(posX,posY,dotSize) was written to produce dot
% textures similar to the function to drawDots.m, that will work on the
% ancient lab computer.
%
% Created by SML Aug 2016
 
% Get general texture details:
nTextures = size(posX,1); % number of textures
nDots = size(posX,2); % number of dots
pixDotSize = 2 * ceil(dotSize/2) + 1 + 4; % find number of pixels needed to represent dot
 
% Determine texture dimensions, minimising size while assuming centering:
textureHeight = 2 * (max(abs(posY)) + (pixDotSize + 1)/2) + 1;
textureWidth = 2 * (max(abs(posX)) + (pixDotSize + 1)/2) + 1;
dotText = zeros(textureHeight, textureWidth, nTextures);

% Adjust dot position coordinates accordingly:
midpointW = (textureWidth - 1) / 2;
midpointH = (textureHeight - 1) / 2;
posX = round(posX) + midpointW;
posY = round(posY) + midpointY;

% Make dot template:
dotCentre = (pixDotSize-1)/2 + 1;
SD = dotSize/4;
blob = makeGausBlob(pixDotSize,pixDotSize,dotCentre,dotCentre,SD,1);
blur = makeGausBlob(pixDotSize,pixDotSize,dotCentre,dotCentre,0.175*SD,1);
blob = conv2(blob,blur,'same');
blob(blob > 1) = 1;
imshow(blob)

% Place dots in texture array:
for ii = 1:nTextures
    for jj = 1:nDots
        idx_x = (PosX-(pixDotSize-1)/2):1:(PosX+(pixDotSize-1)/2);
        idx_y = (PosY-(pixDotSize-1)/2):1:(PosY+(pixDotSize-1)/2);
        dotText(idx_x,idx_y,ii) = blob;
        imshow(squeeze(dotText(:,:,ii)))
    end
end

% Make background midgrey and dots white:
dotText = 255 * dotText + 255/2;

end