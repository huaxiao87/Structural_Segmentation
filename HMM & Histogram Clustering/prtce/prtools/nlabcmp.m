%NLABCMP Compare two label lists and count the differences
% 
%   [N,C] = NLABCMP(LAB1,LAB2)
% 
% INPUT
%   LAB1, 
%   LAB2  Label lists
%
% OUTPUT
%   C     A 0/1 vector pointing to different/equal labels
%   N     Number of differences in LAB1 and LAB2
%
% DESCRIPTION  
%  Compares two label lists and counts the disagreements between them.

%  Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
%  Faculty of Applied Sciences, Delft University of Technology
%  P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: nlabcmp.m,v 1.4 2003/08/18 12:48:23 pavel Exp $

function [N,C] = nlabcmp(S1,S2)

	prtrace(mfilename);

	[m,k] = size(S1);
	[n,l] = size(S2);
	if (m ~= n) | (k ~= l)
		error('Label list sizes do not match.')
	end
	if (iscell(S1) ~= iscell(S2))
		error('Label lists should be both cells, strings or numeric.')
	end

	if (iscell(S1))
		C = strcmp(S1,S2);
	elseif (all(size(S1) == size(S2)))
		C = all(S1'==S2',1)';
	else
		C = strcmp(cellstr(S1),cellstr(S2));
	end

	N = m - sum(C);

	return
