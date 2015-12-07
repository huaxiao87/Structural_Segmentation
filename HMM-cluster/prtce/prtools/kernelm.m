%KERNELM Kernel mapping, kernel PCA
% 
%   W = KERNELM(A,TYPE,P,N)
%
% INPUT
%   A     Dataset
%   TYPE  Type of the kernel (optional; default: 'distance')
%   P     Kernel parameter (optional; default: 1)
%   N     Output dimensionality (optional; default: dimensionality of A)
%
% OUTPUT
%   W     Mapping: Kernel PCA
%
% DESCRIPTION
% Computes the kernel mapping W for the representation objects in A. The 
% kernel is defined by TYPE, using the function PROXM. Look in PROXM for 
% details and the meaning of P. The kernel mapping is almost identical 
% to PROXM with some minor differences to increase accuracy.
%
% If N is given, the mapping is afterwords reduced to N dimensions by the 
% principle component analysis (kernel-PCA).
%
% New objects B can be mapped by B*W.
% 
% SEE ALSO
% DATASETS, MAPPINGS, PROXM, PCA.

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: kernelm.m,v 1.7 2004/05/26 21:08:00 duin Exp $

function w = kernelm(a,type,p,n);

	prtrace(mfilename);
	if (nargin < 4) 
		n = []; 
		prwarning(4,'Output dimensionality not specified, the data dimensionality assumed.')
	end
	if (nargin < 3)
		prwarning(3,'P is not specified, assumed 1.')
		p = 1; 
	end
	if (nargin < 2)
		prwarning(3,'Kernel TYPE is not specified, assumed ''DISTANCE''.')
		type = 'd'; 
	end

	if (nargin < 1) | (isempty(a))  
		% Definition: an untrained mapping.
		w = mapping(mfilename,{type,p,n});
		if (isempty(n))
			w = setname(w,'Kernel mapping');
		else
			w = setname(w,'Kernel PCA');
		end	

	elseif ~isa(type,'mapping') 
	
		% Training: W will be the trained mapping.
		[m,k] = size(a);
		some  = char('polynomial','p','sigmoid','s');
		if (any(strcmp(cellstr(some),type)))
			u  = mean(a,1);		
			aa = a - ones(m,1)*u; 	% Shift A such that the mean is at the origin.
		else
			u  = [];
			aa = a;
		end

		w = mapping('kernelm','trained',{u,aa,type,p},getlab(a),k,m);
		w = setname(w,'Kernel Mapping');
		if ~isempty(n)
			w = w*pca(a*w,n);
			w = setname(w,'Kernel PCA');	
		end

	else 

		% Execution of the mapping, W will be a dataset.
		v = +type;
		if (isempty(v{1}))
			d = a*proxm(v{2},v{3},v{4});
		else
			d = (a-ones(m,1)*v{1})*proxm(v{2},v{3},v{4});
		end
%		d = [d ones(m,1)] * v{3};
		w = setdat(a,d,type);
	end

return;
