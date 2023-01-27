function [outCircRect,inCircRect,fixLine1,fixLine2] = makeFixationCross(sCenter,fixCol,bgCol,penWidth,r_out,r_in,drawYN,w)
% drawfix(hardware, VIS)
%     
% Idea based upon Tahler et al. work.
% Created by TS sometime before Sept 2019.
% Edited by SM Sept 2019: updated for my coding style

% Calculate the texture coordinates:
outCircRect = [sCenter(1)-r_out, ...
               sCenter(2)-r_out, ...
               sCenter(1)+r_out, ...
               sCenter(2)+r_out]; % the outer circle
inCircRect = [sCenter(1)-r_in, ...
              sCenter(2)-r_in, ...
              sCenter(1)+r_in, ...
              sCenter(2)+r_in]; % the inner circle
fixLine1 = [sCenter(1)-r_out, sCenter(1)+r_out; sCenter(2), sCenter(2)]; % one fixation arm 
fixLine2 = [sCenter(1), sCenter(1); sCenter(2)-r_out, sCenter(2)+r_out]; % other fixation arm 

if drawYN     
drawFixationCross(w,fixCol,bgCol,penWidth,outCircRect,inCircRect,fixLine1,fixLine2)
end

end
