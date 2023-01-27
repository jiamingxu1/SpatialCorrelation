function blob = quick_makeGausBlob(sizeTex,SD)
% QUICK_MAKEGAUSBLOB creates a centered white Gaussian blob on a square 
% texture with midgrey background.
%
% [BLOB] = makeGausBlob(SIZETEX)
%
% INPUTS:
% sizeTex: length/height of square texture.
% SD: standard deviation of Gaussian.
%
% OUTPUT:
% BLOB: Texture with Gaussian mask.
%
% Created by SML March 2015.   

lum = 1;
blob = makeGausBlob(sizeTex,sizeTex,sizeTex/2,sizeTex/2,SD,lum);
blob = 0.5 + 0.5 * blob; % rescale so on midgrey background
blob = 255 * blob; 

if blob((sizeTex-1)/2,1) ~= 0
   disp('WARNING: blob is bigger than the texture!') 
end

end