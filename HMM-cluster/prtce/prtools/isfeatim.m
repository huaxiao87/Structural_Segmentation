%ISFEATIM
%
% N = ISFEATIM(A);
%
% INPUT
%   A   Input dataset
%
% OUTPUT
%   N   1/0 if dataset A does/doesn't contain images
%
% DESCRIPTION
% True if dataset contains features that are images.
%
% SEE ALSO
% ISDATASET, ISMAPPING, ISDATAIM


% $Id: isfeatim.m,v 1.4 2003/10/19 14:41:13 bob Exp $

function n = isfeatim(a)
		prtrace(mfilename);

	% When the field objsize contains a vector instead of a scalar, the
	% features inside the dataset are images:
	n = isa(a,'dataset') & length(a.objsize) > 1;

	if (nargout == 0) & (n == 0)
		error([newline '---- Dataset with feature images expected -----'])
	end

return;
