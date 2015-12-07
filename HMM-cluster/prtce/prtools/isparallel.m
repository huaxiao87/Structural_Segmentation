%ISPARALLEL Test on parallel mapping
%
%  N = ISPARALLEL(W)
%      ISPARALLEL(W)
%
% INPUT
%  W    input mapping
%
% OUTPUT
%  N    logical value
%
% DESCRIPTION
% Returns true for parallel mappings. If no output is required,
% false outputs are turned into errors. This may be used for
% assertion.
%
% SEE ALSO
% ISMAPPING, ISSTACKED


% $Id: isparallel.m,v 1.3 2003/08/08 08:17:06 piotr Exp $

function n = isparallel(w)

	prtrace(mfilename);
	
	if isa(w,'mapping') & strcmp(w.mapping_file,'parallel')
		n = 1;
	else
		n = 0;
	end

	% generate error if input is not a parallel mapping
	% AND no output is requested (assertion)

	if nargout == 0 & n == 0
		error([newline '---- Parallel mapping expected -----'])
	end

return
