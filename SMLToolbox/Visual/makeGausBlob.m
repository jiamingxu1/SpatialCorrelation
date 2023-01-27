function blob = makeGausBlob(ix,iy,cx,cy,SD,lum)
% MAKEGAUSBLOB creates a Gaussian blob of specified luminance on a black
% background.
%
% [BLOB] = makeGausBlob(IX,IY,CX,CY,SD,LUM)
%
% INPUTS:
% IX, IY: Image size.
% CX, CY: Center of Gaussian.
% SD: standard deviation of Gaussian.
% LUM: Luminance value at center (e.g. 1 or 255).
%
% OUTPUT:
% BLOB: Texture with Gaussian mask.
%
% From Alais Lab, Edited by SML March 2015.   

[x,y] = meshgrid( -(cx-1):(ix-cx), -(cy-1):(iy-cy) );

blob = exp( -(x.^2/(2*SD^2)) -(y.^2/(2*SD^2)) )* lum;

blob(blob<0.001) = 0;

end