%MEDIANC Median combining classifier
% 
% 	W = MEDIANC(V)
% 	W = V*MEDIANC
% 
% INPUT
%    V     Set of classifiers
%		
% OUTPUT
%    W     Median combining classifier on V
%
% DESCRIPTION
% If V = [V1,V2,V3, ... ] is a set of classifiers trained on the same
% classes, then W is the median combiner: it selects the class with
% the median of the outputs of the input classifiers. This might also
% be used as A*[V1,V2,V3]*MEDIANC, in which A is a dataset to be
% classified.
% 
% If it is desired to operate on posterior probabilities then the input 
% classifiers should be extended to output these, as V = V*CLASSC.
% 
% SEE ALSO
% MAPPINGS, DATASETS, VOTEC, MAXC, MINC, PRODC, MEANC, AVERAGEC, STACKED, 
% PARALLEL, FIXEDCC
%
% EXAMPLES
% See PREX_COMBINING.

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands 

% $Id: medianc.m,v 1.7 2003/10/09 09:31:08 bob Exp $

function w = medianc (p1)

	prtrace (mfilename);

	% The median combiner is constructed as a fixed combiner (FIXEDCC) of
	% type 'median'.
	
	type = 'median'; name = 'Median combiner';   
                   
  % Possible calls: MEDIANC, MEDIANC(W) or MEDIANC(A,W).
 	        
	if (nargin == 0)
		w = mapping('fixedcc','combiner',{[],type,name});
	else
		w = fixedcc(p1,[],type,name);
	end

	if (isa(w,'mapping'))
		w = setname(w,name);
	end

return
