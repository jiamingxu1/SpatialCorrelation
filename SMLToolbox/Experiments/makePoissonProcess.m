function [events] = makePoissonProcess(lambda,discreteYN,dur,tStep,N)
% MAKEPOISSONPROCESS creates a Poisson process either by speficing which
% time steps have an event, or when each event will occur in
% continuous time.
%
% [Y] = makePoissonProces(LAMBDA,DISCRETEYN,DUR,TSTEP,N) 
%
% LAMBDA: ...
% 
% Created by SML March 2015

% Defaults:
if nargin < 5
   N = 1;
   if nargin < 4
       tStep = [];
   end
end

switch discreteYN
    %----%
    case 1 % At each time step, event or no event?
        
        if isempty(tStep)
            error('Please enter value for tStep or change discreteYN to 0')
        end
        
        nSteps = round(dur/tStep);
        events = rand(nSteps,N);
   
%         decBound = exp(-lambda*tStep); % P(no event), doesn't work...
        decBound = 1 - lambda*tStep; % P(no event)
        if length(lambda) == 1
            decBound = repmat(decBound,nSteps,N);
        elseif length(lambda) == N
            decBound = repmat(decBound,nSteps,1);
        elseif (lambda > 1) && (length(lambda) ~= N)
            error('Please enter either 1 or N lambda values.')
        end
        
        events(events>decBound) = 1;
        events(events<=decBound) = 0;
    
    %----%
    case 2 % Time of each event?
        
end     

end