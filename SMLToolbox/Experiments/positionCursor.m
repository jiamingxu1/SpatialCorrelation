function [] = positionCursor(w,hardware,VIS)

maxDistFromCenter = 5; % tolerance value for centering dot, in pixels
distCursorFromCenter = maxDistFromCenter + 1; % Dummy value to start with

while distCursorFromCenter > maxDistFromCenter
    [mouse_x, mouse_y] = GetMouse();
    mouse_x = mouse_x * VIS.mouseSensitivityFactor;
    mouse_y = mouse_y * VIS.mouseSensitivityFactor;
    Screen('DrawDots', w, [0, 0], VIS.dotSize_pix, [150 0 0], hardware.sCenter, VIS.dotType); % Red center dot
    Screen('DrawDots', w, [mouse_x mouse_y], VIS.dotSize_pix/2, VIS.cursorCol, [0, 0], VIS.dotType);
    Screen('Flip', w);
    distCursorFromCenter = sqrt(sum(([mouse_x mouse_y] - hardware.sCenter).^2));
end

end