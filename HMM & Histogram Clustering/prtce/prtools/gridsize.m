%GRIDSIZE Set gridsize used in the plot commands
%
%     O = GRIDSIZE(N)
%
% INPUT
%     N  New grid size (optional, default: display current gridsize)
% 
% OUTPUT
%     O  New grid size (optional)
%		
% DESCRIPTION
% The initial gridsize is 30, enabling fast plotting. This is, however,
% insufficient to obtain accurate graphs, for which a gridsize of at least 
% 100 and preferably 250 is needed. Default: display or return the current 
% gridsize.
%
% EXAMPLES
% See PREX_CONFMAT
%
% SEE ALSO
% PLOTC, PLOTM

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: gridsize.m,v 1.5 2003/12/04 10:12:48 bob Exp $

function out = gridsize(n)

	prtrace(mfilename);

	global GRIDSIZE;

	% If the global variable was not yet initialised, set it to 30 (default).

	if (isempty(GRIDSIZE))
		prwarning(4,'initialising gridsize to 30');
		GRIDSIZE = 30;			
	end

	if (nargin < 1)
		if (nargout == 0)
			disp(['Gridsize is ' num2str(GRIDSIZE) ]);
		end
	else
		if isstr(n)
			n= str2num(n);
		end
		if isempty(n)
			error('Illegal gridsize')
		end
		GRIDSIZE = n;
	end

	if (nargout > 0), out = GRIDSIZE; end

return
