%ISMAPPING Test whether the argument is a mapping
%
% 	N = ISMAPPING(W);
%
% INPUT
% 	W   Input argument
%
% OUTPUT
% 	N   1/0 if W is/isn't a mapping object
%
% DESCRIPTION
% True (1) if W is a mapping object and false (0), otherwise.
%
% SEE ALSO
% ISDATASET, ISFEATIM, ISDATAIM


% $Id: ismapping.m,v 1.4 2003/08/09 14:58:17 ela Exp $

function n = ismapping(w)
	prtrace(mfilename);
	n = isa(w,'mapping');

	if (nargout == 0) & (n == 0)
		error([newline 'Mapping expected.'])
	end
return;
