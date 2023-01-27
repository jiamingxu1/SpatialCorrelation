function [key] = prepKeyboard(keysRequired)
%
% Created by SML Nov 2020

KbName('UnifyKeyNames');
nKeys = length(keysRequired);
key = NaN([1,nKeys]);
for kk = 1:nKeys
    switch keysRequired{kk}
        case 'leftarrow'
            key(kk) = KbName('leftarrow');
        case 'rightarrow'
            key(kk) = KbName('rightarrow');
        case 'uparrow'
            key(kk) = KbName('uparrow');
        case 'downarrow'
            key(kk) = KbName('downarrow');
    end
end

end