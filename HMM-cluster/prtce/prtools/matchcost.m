% Matchcost

% Copyright: D.M.J. Tax, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: matchcost.m,v 1.1 2004/02/26 20:55:00 davidt Exp $

function [cost,lablist] = matchcost(orglablist,cost,lablist)
   prtrace(mfilename,2);

   k = size(orglablist,1);
	if (size(cost,1) ~= k)
		error([newline 'The number of rows in the cost matrix should match the number' ...
		newline 'of features'])
	end
   k = size(lablist,1);
	if (size(cost,2) ~= k)
		error([newline 'The number of columns in the cost matrix should match the length' ...
		newline 'of the lablist'])
	end
	if size(cost,2) < size(cost,1)
		error([newline 'Number of columns in cost matrix should be at least number of rows'])
	end

   if (nargin > 2) & (~isempty(lablist))
      if size(lablist,1) ~= size(cost,2)
			error('Wrong number of labels supplied')
      end
      I = matchlablist(orglablist,lablist);  %DXD that was a bug.
		if any(I==0)
			error('Supplied label list should match feature labels')
		end
      J = [1:size(lablist,1)];
      J(I) = []; % find label in lablist not in dataset
      cost = [cost(I,I) cost(:,J)];
      lablist = lablist([I;J],:);
   end

return
