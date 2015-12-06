%MCLASSC Computation of a combined, multi-class based mapping
%
%  W = MCLASSM(A,MAPPING,MODE,PAR)
%
% INPUT
%   A       Dataset
%   MAPPING Untrained mapping	
%   MODE    Combining mode (optional; default: 'weight')
%   PAR     Parameter needed for the 
%
% OUTPUT
%   W       Combined mapping
%
% DESCRIPTION
% If A is a unlabeled dataset or double matrix, it is converted to a 
% one-class dataset. For one-class datasets A, the mapping is computed,
% calling the untrained MAPPING using the labeled samples of A only. 
% For multi-class datasets separate mappings are determined for each class
% in A. They are combined as defined by MODE and PAR. The following
% combining rules are supported:
% 'weight': weight the mapping outcome for class j by PAR(j) and sum
%           over the classes. This is useful for densities in which case
%           PAR is typically the set of class priors (these are in fact
%           the defaults if MODE = 'weight').
% 'mean'  : combine by averaging.
% 'min'   : combine by the minimum rule.
% 'max'   : combine by the maximum rule.
%
% SEE ALSO
% DATASETS, MAPPINGS

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function w = mclassm(a,mapp,mode,par);
	prtrace(mfilename);
	if nargin < 4, par = []; end
	if nargin < 3, mode = 'weight'; end
	if nargin < 2, mapp = []; end
	if nargin < 1 | isempty(a)
		w = mapping(mfilename,{classf,mode});
		return
	end
	
	if ~isa(mapp,'mapping') | ~isuntrained(mapp)
		error('Second parameter should be untrained mapping')
	end

	[a,c,lablist,p] = cdats(a);
	
	if c == 1
		w = a*mapp;
	else
		w = [];
		for j=1:c
			b = seldat(a,j);
			w = [w,b*mapp];
		end
		if ismapping(mode)
			w = w*mode
		elseif isstr(mode)
			switch mode
			case 'sum'
				w = w*meanc;
			case 'min'
				w = w*minc;
			case 'max'
				w = w*maxc;
			case 'weight'
				if size(w{1},2) ~= 1
					error('Weighted combining only implemented for K to 1 mappings')
				end
				if isempty(par)
					par = p;
				end
				lenw = length(w.data);
				if length(par) ~= lenw
					error(['Wrong number of weights. It should be ' num2str(lenw)])
				end
				w = w*affine(par(:));
			otherwise
				error('Unknown combining mode')
			end
		end
		
		w = setsize(w,[size(a,2),1]);
		w = setlabels(w,lablist);
		
	end
	
return
	
