%ISDATASET Test whether the argument is a dataset
%
% 	N = ISDATASET(A);
%
% INPUT
%		A	 Input argument
%
% OUTPUT
%		N  1/0 if A is/isn't a dataset
%
% DESCRIPTION
% The function ISDATASET test if A is a dataset object.
%
% SEE ALSO
% ISMAPPING, ISDATAIM, ISFEATIM 

% $Id: isdataset.m,v 1.4 2003/08/09 14:44:41 ela Exp $

function n = isdataset(a)
	prtrace(mfilename);
		
	n = isa(a,'dataset');
	if (nargout == 0) & (n == 0)
		error([newline 'Dataset expected.'])
	end
return;
