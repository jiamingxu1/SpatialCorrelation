function frames = make2StreamPoissonFlashFrames(sizeTex,SD,centDist,crossLen)

if nargin < 4
    crossLen = 8; % Half length of fixation cross segments in pixels
end

assert(centDist > sizeTex/2, 'Texture to big for specified centDist.')

blob = quick_makeGausBlob(sizeTex,SD);
fillFrame = [0 0; 1 0; 0 1; 1 1]; % row: frame#, col: L & R event YN

for ii = 1:4
    ff = 127 * ones(sizeTex,2*centDist+sizeTex+1); % Blank midgrey texture
    if fillFrame(ii,1) == 1 % Put blob on left side
        ff(1:end,1:sizeTex) = blob;
    end
    if fillFrame(ii,2) == 1 % Put blob on right side
        ff(1:end,end-sizeTex+1:end) = blob;
    end
    % Fixation cross:
    ff((sizeTex/2-crossLen):(sizeTex/2+crossLen),repmat((size(ff,2)-1)/2,1,crossLen*2+1)) = 255;
    ff(repmat(size(ff,1)/2,1,crossLen*2+1),((size(ff,2)-1)/2-crossLen):((size(ff,2)-1)/2+crossLen)) = 255;
    frames{ii} = ff;
end

end