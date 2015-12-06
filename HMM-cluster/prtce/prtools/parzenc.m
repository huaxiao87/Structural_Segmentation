%PARZENC Optimisation of the Parzen classifier
% 
%  [W,H] = PARZENC(A)
%  W = PARZENC(A,H,FID)
% 
% INPUT
%  A    dataset
%  H    smoothing parameter (may be scalar, vector of per-class
%       parameters, or matrix with parameters for each class (rows) and
%       dimension (columns))
%  FID  File ID to write progress to (default [], see PRPROGRESS)
%
% OUTPUT
%  W    trained mapping
%  H    estimated smoothing (scalar value)
%
% DESCRIPTION
% Computation of the optimum smoothing parameter H for the Parzen 
% classifier between the classes in the dataset A. The leave-one-out 
% Lissack & Fu estimate is used for the classification error E. The 
% final classifier is stored as a mapping in W. It may be converted
% into a classifier by W*CLASSC. PARZENC cannot be used for density
% estimation.
% 
% In case smoothing H is specified, no learning is performed, just the
% discriminant W is produced for the given smoothing parameters H.
% Smoothing parameters may be scalar, vector of per-class parameters, or 
% a matrix with individual smoothing for each class (rows) and feature
% directions (columns)
%
% REFERENCES
% T. Lissack and K.S. Fu, Error estimation in pattern recognition via
% L-distance between posterior density functions, IEEE Trans. Inform. 
% Theory, vol. 22, pp. 34-45, 1976.
% 
% SEE ALSO
% DATASETS, MAPPINGS, PARZEN_MAP, PARZENML, PARZENDC, CLASSC, PRPROGRESS
 
% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: parzenc.m,v 1.8 2003/11/23 22:32:12 bob Exp $

function [W,h] = parzenc(a,h,fid)

	prtrace(mfilename);
	
	if nargin < 3, fid = []; end
	if nargin < 2
		h = [];
    prwarning(4,'smoothing parameter not supplied, optimizing');
	end
	
	if nargin == 0 | isempty(a)
		W = mapping(mfilename,h); 
		W = setname(W,'Parzen Classifier');
		return; 
	end

	islabtype(a,'crisp');
	isvaldset(a,2,2); % at least 2 objects per class, 2 classes

	[m,k,c] = getsize(a);
	nlab = getnlab(a);

	if ~isempty(h)       % take user setting for smoothing parameter
		
		if size(h,1) == 1, h = repmat(h,c,1); end
		if size(h,2) == 1, h = repmat(h,1,k); end
		if any(size(h) ~= [c,k])
			error('Array with smoothing parameters has wrong size');
		end
		W = mapping('parzen_map','trained',{a,h},getlablist(a),k,c);
		W = setname(W,'Parzen Classifier');
		return
		
	end

	% compute all object distances
	D = +distm(a) + diag(inf*ones(1,m));
	
	% find object weights q
	q = classsizes(a);
	
	% find for each object its class freqency
	of = q(nlab);
	
	% find object weights q
	p = getprior(a);
	q = p(nlab)./q(nlab);
	
	% initialise
	h = max(std(a)); % for sure a too high value
	L = -inf;
	Ln = 0;
	z = 0.1^(1/k); % initial step size

	% iterate
	
	prprogress(fid,'\nparzenc: Parzen Classifier\n')
	while abs(Ln-L) > 0.001 & z < 1

    % In L we store the best performance estimate found so far.
		% Ln is the actual performance (for the actual h)
		% If Ln > L we improve the bound L, and so we rest it.
		
		if Ln > L, L = Ln; end

		r = -0.5/(h^2);
		F = q(ones(1,m),:)'.*exp(D*r);           % density contributions
		FS = sum(F)*((m-1)/m); IFS = find(FS>0); % joint density distribution
		G = sum(F .* (nlab(:,ones(1,m)) == nlab(:,ones(1,m))'));
		G = G.*(of-1)./of;                       % true-class densities
		
		% performance estimate, neglect zeros
		
		en = max(p)*ones(1,m);
		en(IFS) = (G(IFS))./FS(IFS);
		Ln = exp(sum(log(en))/m);

		prprogress(fid,'  h = %6.4f, Ln = %6.4f, L = %6.4f, z=%f \n',h,Ln,L,z);

		if Ln < L            % compute next estimate
			z = sqrt(z);       % adjust stepsize up (recall: 0 < z < 1)
			h = h / z;         % if we don't improve, increase h (approach h_opt from below)
		else
			h = h * z;         % if we improve, decrease h (approach h_opt from above)
		end
	end
	prprogress(fid,'parzenc finished\n')

	W = mapping('parzen_map','trained',{a,repmat(h,c,k);},getlablist(a),k,c);
	W = setname(W,'Parzen Classifier');
	W = setcost(W,a);

return
