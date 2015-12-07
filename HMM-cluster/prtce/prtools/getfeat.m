%GETFEAT Get feature labels of a dataset or a mapping
%
%	  LABELS = GETFEAT(A)
%	  LABELS = GETFEAT(W)
%
% INPUT
%   A,W    Dataset or mapping
%
% OUTPUT
%   LABELS Label vector with feature labels
%
% DESCRIPTION
% Returns the labels of the features in the dataset A or the labels
% assigned by the mapping W.
%
% Note that for a mapping W, getfeat(W) is effectively the same as GETLAB(W).
%
% SEE ALSO 
% DATASETS, MAPPINGS, GETLAB

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: getfeat.m,v 1.4 2003/08/09 14:46:37 ela Exp $

function labels = getfeat(par)

	if isa(par,'dataset')
		labels = getfeatlab(par);
	elseif isa(par,'mapping')
		labels = getlabels(par);
	else
		error([newline 'Dataset or mapping expected.'])
	end
return;
