%INVSIGM Inverse sigmoid map
% 
% 	W = W*INVSIGM
% 	B = INVSIGM(ARG)
%
% INPUT
%	ARG   Mapping/Dataset
%
% OUTPUT
%	W     Mapping transforming posterior probabilities into distances.
%
% DESCRIPTION
% The inverse sigmoidal transformation to transform a classifier to a
% mapping, transforming posterior probabilities into distances.
%
% SEE ALSO
% MAPPINGS, DATASETS, CLASSC, SIGM

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: invsigm.m,v 1.7 2003/10/07 11:59:36 bob Exp $

function w = invsigm(arg)
		prtrace(mfilename);
if nargin == 0

	% Create an empty mapping:
	w = mapping('invsigm','combiner');
	w = setname(w,'Inverse Sigmoidal Mapping');
	
elseif isa(arg,'mapping')

	% If the mapping requested a SIGM transformation (out_conv=1), it
	% is now removed (out_conv=0):
	if arg.out_conv == 1
		w = set(arg,'out_conv',0);
		if arg.size_out == 2
			w.size_out = 1;
		end
	else
		w_s = setname(mapping('invsigm','fixed'),'Inverse Sigmoidal Mapping');
		w = arg*w_s;
	end
	
else
	
	% The data is really transformed:
	w = log(arg+realmin) - log(1-arg+realmin);
end

return

