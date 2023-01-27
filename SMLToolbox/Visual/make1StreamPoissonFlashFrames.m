function frames = make1StreamPoissonFlashFrames(sizeTex,SD,fixCrossTex,fixCrossLoc)

% Get blob texture:
blob = quick_makeGausBlob(sizeTex,SD);

% Blank frame:
ff = 127 * ones(size(blob)); % Blank midgrey texture

% Add fixation cross:
lFCT = size(fixCrossTex,1);
tex_hPos = ((sizeTex-1)/2 - (lFCT-1)/2) : ((sizeTex-1)/2 + (lFCT-1)/2);
tex_vPos = fixCrossLoc : (fixCrossLoc - 1 + lFCT);
% ff(tex_vPos,tex_hPos) = max(fixCrossTex,ff(tex_hPos,tex_vPos));

% Save no event frame:
frames{1} = ff;

% Make and save event frame:
ff = blob;
% ff(tex_vPos,tex_hPos) = max(fixCrossTex,ff(tex_hPos,tex_vPos));
frames{2} = ff;

end