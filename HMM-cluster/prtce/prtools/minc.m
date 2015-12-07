%MINC Minimum combining classifier
% 
% 	W = MINC(V)
% 	W = V*MINC
% 
% INPUT
%   V     Set of classifiers
%
% OUTPUT
%   W    Minimum combining classifier on V
%
% DESCRIPTION
% If V = [V1,V2,V3, ... ] is a set of classifiers trained on the 
% same classes and W is the maximum combiner: it selects the class 
% with the maximum of the outputs of the input classifiers. This 
% might also be used as A*[V1,V2,V3]*MINC in which A is a dataset to 
% be classified. Consequently, if S is a dissimilarity matrix with
% class feature labels (e.g. S = A*PROXM(A,'d')) then S*MINC*LABELD
% is the nearest neighbor classifier.
% 
% If it is desired to operate on posterior probabilities then the 
% input classifiers should be extended like V = V*CLASSC;
%
% The base classifiers may be combined in a stacked way (operating
% in the same feature space by V = [V1,V2,V3, ... ] or in a parallel
% way (operating in different feature spaces) by V = [V1;V2;V3; ... ]
% 
% SEE ALSO
% MAPPINGS, DATASETS, VOTEC, MAXC, MEANC, MEDIANC, PRODC,
% AVERAGEC, STACKED, PARALLEL
%
% EXAMPLES
% See PREX_COMBINING

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands 

% $Id: minc.m,v 1.6 2003/12/19 09:14:38 bob Exp $

function w = minc(p1)

	type = 'min'; % define the operation processed by FIXEDCC.

	% define the name of the combiner. 
	% this is the general procedure for all possible calls of fixed combiners
	% handled by FIXEDCC
	name = 'Minimum combiner'; 

	if nargin == 0
		w = mapping('fixedcc','combiner',{[],type,name});
	else
		w = fixedcc(p1,[],type,name);
	end

	if isa(w,'mapping')
		w = setname(w,name);
	end

return
	
