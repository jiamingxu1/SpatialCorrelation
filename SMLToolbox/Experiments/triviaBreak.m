function [] = triviaBreak(w, breakDur)

% Created by SML May 2016

breakStart = GetSecs; % start timer

% AssertOpenGL;
% screens=Screen('Screens');
% screenID=max(screens);
% w = Screen('OpenWindow', screenID, 127);
% Priority(MaxPriority(w));
% Screen('Flip', w);

% Prepare Questions:
load('triviaQandA');
nQ = size(QandA,1);

while (GetSecs - breakStart) < breakDur

    i = randi(nQ);
    Q = QandA{i,1};
    A = QandA{i,2};
    quickPrintText(w,Q);
    quickPrintText(w,A);

end

% sca

end

