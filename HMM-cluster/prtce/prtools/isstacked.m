%ISSTACKED Test on stacked mapping
%
%   N = ISSTACKED(W)
%   ISSTACKED(W)
%
% INPUT
%   W  Mapping
%
% OUTPUT
%   N  Scalar, 1 if W is a stacked mapping, 0 otherwise
%
% DESCRIPTION
% Returns 1 for stacked mappings. If no output is requested, false outputs
% are turned into errors. This may be used for assertion.
%
% SEE ALSO
% ISMAPPING, ISPARALLEL

% $Id: isstacked.m,v 1.4 2003/08/18 15:51:54 dick Exp $

function n = isstacked(w)

	prtrace(mfilename);

	if (isa(w,'mapping')) & (strcmp(w.mapping_file,'stacked'))
		n = 1;
	else
		n = 0;
	end

	% Generate an error if the input is not a stacked mapping and no output 
	% is requested (assertion).

	if (nargout == 0) & (n == 0)
		error([newline '---- Stacked mapping expected -----'])
	end

return
