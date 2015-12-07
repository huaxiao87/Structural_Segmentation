%PLOTD Plot classifiers, outdated, use PLOTC instead

% $Id: plotd.m,v 1.4 2003/12/14 22:13:21 bob Exp $

function handle = plotd(varargin)

	prtrace(mfilename);

	global PLOTD_REPLACED_BY_PLOTC

	if isempty(PLOTD_REPLACED_BY_PLOTC)
		disp([newline 'PLOTD has been replaced by PLOTC, please use it'])
		PLOTD_REPLACED_BY_PLOTC = 1;
	end

	if nargout > 0
		handle = plotc(varargin{:});
	else
		plotc(varargin{:});
	end

return
