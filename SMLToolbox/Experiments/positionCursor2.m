function [] = positionCursor2(w,hardware,dotSize_pix,mouseSensitivityFactor)
%
% 
% Created by SML sometime in 2019???

% defaults:
if nargin < 3
    mouseSensitivityFactor = 1; 
end


maxDistFromCenter = 3; % tolerance value for centering dot, in pixels
distCursorFromCenter = maxDistFromCenter + 1; % Dummy value to start with

while distCursorFromCenter > maxDistFromCenter
    [mouse_x, mouse_y] = GetMouse();
    mouse_x = mouse_x * mouseSensitivityFactor;
    mouse_y = mouse_y * mouseSensitivityFactor;
    Screen('DrawDots', w, [0, 0], dotSize_pix, [150 0 0], hardware.sCenter, 2); % Red center dot
    Screen('DrawDots', w, [mouse_x mouse_y], dotSize_pix/2, [0 0 0], [0, 0], 2);
    Screen('Flip', w);
    distCursorFromCenter = sqrt(sum(([mouse_x mouse_y] - hardware.sCenter).^2));
end

end