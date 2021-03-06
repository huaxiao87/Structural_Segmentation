%CMAPM Compute some special maps
% 
% INPUT
%  Various
%
% OUTPUT
%  W  Mapping
%
% DESCRIPTION
% CMAPM computes some special data-independent maps for scaling, selecting or 
% rotating K-dimensional feature spaces.
% 
%  W = CMAPM(K,N)            Selects the features listed in the vector N
%  W = CMAPM(K,P)            Polynomial feature map. P should be an N*K matrix
%                            in which each row defines the exponents for the
%                            original features in a polynomial term. Note: for
%                            N = 1 and/or K = 1, feature selection is applied!
%  W = CMAPM(K,'EXP')        Exponential, negative exponential and logarithmic 
%  W = CMAPM(K,'NEXP')       mappings.
%  W = CMAPM(K,'LOG')
%  W = CMAPM(K,'RANDROT')    Defines a random K-dimensional rotation.
%  W = CMAPM(F,'ROT')        The N*K matrix F defines N linear combinations 
%                            to be computed by X*F'.
%  W = CMAPM(X,'SHIFT')      Defines a shift of the origin by X.
%  W = CMAPM(S,'SCALE')      Divides the features by the components of the 
%                            vector S.
%  W = CMAPM({X,S},'SCALE')  Shift by X and scale by S.
% 
% EXAMPLES 
% For the polynomial feature map, CMAPM(K,P), P defines exponents for each
% feature. So P = [1 0; 0 1; 1 1; 2 0; 0 2; 3 0; 0 3] defines 7 features,
% the original 2 (e.g. x and y), a mixture (xy) and all powers of the second
% (x^2,y^2) and third (x^3,y^3) order. Another example is P = diag([0.5 0.5
% 0.5]), defining 3 features to be the square roots of the original ones.
%
% SEE ALSO
% MAPPINGS, SCALEM, FEATSELM, KLM

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: cmapm.m,v 1.5 2003/10/19 14:42:30 bob Exp $

function w = cmapm(arg1,arg2,par1,par2,par3)

	prtrace(mfilename);

	if (nargin < 2)
		error('insufficient arguments');
	end

	if (~isa(arg1,'dataset'))						
		% First form: ARG1 is a matrix, construct a mapping.
		data = arg1;
		if (isstr(arg2))								
			type = arg2;
			switch (type)
				case {'exp','nexp','log'}			% Function mappings.
					w = mapping(mfilename,'fixed',{type},[],data,data);
					w = setname(w,type);
				case 'randrot'								% Random rotation matrix.
					[F,V] = eig(covm(randn(100*data,data)));
					w = affine(F,zeros(1,data));
					w = setname(w,'Random Rotation');
				case 'rot'			  						% Rotation by given matrix.
					[n,k] = size(data);
					w = affine(data',zeros(1,n));
					w = setname(w,'Rotation');
				case 'shift'									% Shift by given vector.
					k = length(data);
					w = affine(eye(k),-data);
					w = setname(w,'Shift');
				case 'scale'									% Shift, scale & (optionally) clip.
					if (iscell(data))	
						% Extract and check parameters.
						shift = data{1}; scale = data{2}; 						
						if (length(data) == 3), clip = data{3}; else, clip = 0; end
						k = length(scale);
						if (~isempty(scale)) & (length(shift) ~= k)
							error('shift and scale should have same dimension')
						end
					else
						% Only a scale is specified; set shift and clip to 0.
						scale = data; k = length(scale);
						shift = zeros(1,k); clip = 0;
					end

					% Create mapping
					if (clip)
						w = mapping(mfilename,'fixed',{'normalize',shift,ones(1,k)./scale,clip},[],k,k);
						w = setname(w,'Scaling');
					else
						w = affine(1./scale,-shift./scale);
					end
				otherwise
					error(['unknown option ' arg2])
			end

		else

			% ARG2 is not a string: feature selection or polynomial mapping.

			if (min(size(arg2)) == 1)
				% ARG2 is a vector: feature selection, DATA is input feature size
				prwarning(4,'second input argument is a vector: performing feature selection');
				if (min(arg2) < 1) | (max(arg2) > data)
					error('Selected features out of range')
				end
				w = mapping(mfilename,'fixed',{'featsel',arg2},[],data,length(arg2));
				w = setname(w,'Feature Selection');
			else
				% ARG2 is a matrix: polynomial mapping.
				prwarning(4,'second input argument is a matrix: performing polynomial mapping');

				[n,k] = size(arg2);
				if (data ~= k)
					error('matrix has wrong size')
				else
					w = mapping(mfilename,'fixed',{'polynomial',arg2},[],k,n);
					w = setname(w,'Polynomial');
				end
			end
		end
	
	else 

		% Second form: ARG1 is a dataset, execute some fixed mappings
		a = +arg1; [m,k] = size(a);					% Extract dataset.
		featlist = getfeatlab(arg1);
		type = arg2;

		switch (type)
			case 'exp'
				b = exp(a);
			case 'nexp'
				b = exp(-a);
			case 'log'
				b = log(a);
			case 'normalize'
				b = a - repmat(par1,m,1);				% Subtract mean (par1).

				% Multiply by scale; use different ways of looping for small and P = diag([0.5 0.5
% 0.5])
				% large feature sizes
				if (m > k), for j = 1:k, b(:,j) = b(:,j)*par2(j); end
				else,       for i = 1:m, b(i,:) = b(i,:).*par2;   end 
        end

				% Clip, if necessary (par3 ~= 0, see SCALEM).
				if (exist('par3')) & (par3)
					J = find(b < 0); b(J) = zeros(size(J));		% Set values < 0 to 0...
					J = find(b > 1); b(J) = ones(size(J));		% ...and values > 1 to 1.
				end
			case 'featsel'
				b = a(:,par1);									% Select feature indices (par1).
				featlist = featlist(par1,:);
			case 'polynomial'	
				[n,k] = size(par1);							% Create polynomial features.
				b = zeros(m,n); 
				for i = 1:n
		    	b(:,i) = prod((a .^ (repmat(par1(i,:),m,1))),2);
				end
				featlist = [1:n]';
			otherwise
				error('unknown mapping')
		end

		w = setdata(arg1,b,featlist);

	end
	
return

