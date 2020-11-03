% sem function
%
% sem = sem(dat,dim);

function sem_out = sem(DATA,dim);

if nargin < 2,
    if size(DATA,1) > size(DATA,2),
        dim = 1;
    else
        dim = 2;
    end
end
sem_out = std(DATA,[],dim)/sqrt(size(DATA,dim));

% function sem_out = sem(DATA);
% sem_out = std(DATA)/sqrt(length(DATA));