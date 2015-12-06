%LOGDENS Force density based classifiers to use log-densities
%
%   V = LOGDENS(W)
%   V = W*LOGDENS
%
% INPUT
%   W   Density based trained classifier
%
% OUTPUT
%   V   Log-density based trained classifier
%
% DESCRIPTION
% Density based classifiers suffer from a low numeric accuracy in the tails
% of the distributions. Especially for overtrained or high dimensional
% classifiers this may cause zero-density estimates for many test samples,
% resulting in a bad performance. This can be avoided by computing
% log-densities offered by this routine. This works for all classifiers
% based on normal distributions (e.g. LDC, QDC, MOGC) and Parzen estimates
% (PARZENC, PARZENDC). The computation of log-densities is , in order to be 
% effective, combined with  a normalisation, resulting in posterior
% distributions. As a consequence, the possibility to output densities is
% lost.
%
% SEE ALSO
% MAPPINGS, LDC, UDC, QDC, MOGC, PARZENC, PARZENDC, NORMAL_MAP, PARZEN_MAP

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function v = logdens(w)

	prtrace(mfilename);

	if (nargin < 1 | isempty(w))
		v = mapping(mfilename,'combiner');
		return
	else
		mfile = getmapping_file(w);
		if isuntrained(w)
			v = mapping('sequential','untrained',{w,logdens});
		else
			if (~strcmp(mfile,'normal_map') & ~strcmp(mfile,'parzen_map'))
				error('LOGDENS can only be applied to normal densities and Parzen estimators')
			end
			v = classc(w);
		end
	end
	
return
	
	
