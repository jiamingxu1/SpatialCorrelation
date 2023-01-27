function fixCrossFrame = makeFixationCrossTexture(crossLen,bgCol,crossCol)
% MAKEFIXATIONCROSSTEXTURE


% Defaults:
if nargin < 2
    crossCol = 255; % White coloured cross
    if nargin < 2
        bgCol = 127; % default to mid grey background
        if nargin < 1
            crossLen = 8; % Half length of fixation cross segments in pixels
        end
    end
end

% Blank frame:
sizeTex = crossLen*2+1;

fixCrossFrame = bgCol * ones(sizeTex);

% Add fixation cross:
hbar_h = 1:sizeTex;
hbar_v = repmat(crossLen+1,sizeTex,1);
vbar_h = hbar_v;
vbar_v = hbar_h;
fixCrossFrame(hbar_h, hbar_v) = crossCol;
fixCrossFrame(vbar_h, vbar_v) = crossCol;

end