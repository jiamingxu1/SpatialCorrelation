function [] = clearLeaderboard(expName)
%
%
% Created by SML July 2016

fname = ['leaderboard_', expName];
leaderboard_init = {'BLANK', 'BLANK', 'BLANK'};
leaderboard_score = [0, 0, 0];
save(fname,'leaderboard_init','leaderboard_score')

end


