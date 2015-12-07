%MATCHLABLIST Match entries of lablist1 with lablist2
%
%    I = MATCHLABLIST(LABLIST1,LABLIST2)
%
% INPUT
%    LABLIST1  list of class names
%    LABLIST2  list of class names
%
% OUTPUT
%    I         indices for LABLIST1 appearing in LABLIST2
%
% DESCRIPTION
% Find the indices of places where the entries of LABLIST1 appear  
% in LABLIST2, i.e.  LABLIST1 = LABLIST2(I).
% Note that this operation is not symmetric, changing the order of
% LABLIST1 and LABLIST2 changes I! 
% I(i) = 0 for labels appearing in LABLIST1 that are not in LABLIST2.
%
% SEE ALSO
% costm, testcost

% Copyright: D.M.J. Tax davidt@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function I = matchlablist(lablist1,lablist2)
	prtrace(mfilename);

n = size(lablist1,1);
I = zeros(n,1); % the resorting vector
for i=1:n
  tmp = strmatch(lablist1(i,:),lablist2);
  if ~isempty(tmp)
		I(i) = tmp;
	else
		I(i) = 0;
  end
end

return
