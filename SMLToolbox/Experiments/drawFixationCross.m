function  drawFixationCross(w,fixCol,bgCol,penWidth,outCircRect,inCircRect,fixLine1,fixLine2)
% drawFixationCross(w,outCircRect,inCircRect,fixLine1,fixLine2)
%     
% Idea based upon Tahler et al. work.
% Created by TS sometime before Sept 2019.
% Edited by SM Sept 2019: updated for my coding style
   
Screen('FillOval', w, fixCol, outCircRect);
Screen('DrawLines', w, fixLine1, penWidth, bgCol);
Screen('DrawLines', w, fixLine2, penWidth, bgCol);
Screen('FillOval', w, fixCol, inCircRect);

end
