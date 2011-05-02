function list = peerschedule(list, memreq, timreq, cpureq)

% PEERSCHEDULE sorts the list of avaialble peers according to a number of heuristic 
% reules that try to optimize the use of the available resources.
%
% Use as
%   list = peerschedule(list, memreq, timreq, cpureq)

% Copyright (C) 2011, Robert Oostenveld
%
% $Id$

% ensure that all peers meet the minimum requirements
list = list([list.memavail]>memreq);
list = list([list.timavail]>timreq);

% create two vectors with the available memory and time
memavail = [list.memavail];
timavail = [list.timavail];

% the first penalty measure is based on the excess memory
% the ideal available memory is the required memory plus approximately 1GB
mempenalty = abs(memavail - (memreq+1e9));
mempenalty = mempenalty/1e9;  % express it in excess GB compared to the ideal

% the second penalty measure is based on the time requirement
% the ideal available time is slightly more than the required time
timpenalty = abs(timavail - 1.3*timreq + 120);
timpenalty = timpenalty / (15*60);  % express it in chuncks of 15 minutes

% combine the memory and the time penalty
penalty = mempenalty + timpenalty;

% the following is specific to the Donders Centre "mentat" linux cluster
if ~isempty(regexp(getenv('HOSTNAME'), 'mentat'))
  mentat005 = find(~cellfun(@isempty, regexp({list.hostname}, 'mentat005')));
  mentat006 = find(~cellfun(@isempty, regexp({list.hostname}, 'mentat006')));
  % this should be the preferred machine, even if jobs are 60 minutes longer or 4GB larger
  penalty(mentat005) = penalty(mentat005) - 4;
  % this should be the preferred machine, even if jobs are 90 minutes longer or 6GB larger
  penalty(mentat006) = penalty(mentat006) - 6;
end

% select the slave peer that has the best match with the job requirements
% i.e. the one with the lowest penalty
[penalty, indx] = sort(penalty);

% sort the list according to the penalty
list = list(indx);

