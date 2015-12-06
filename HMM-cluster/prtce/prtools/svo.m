%SVO Support Vector Optimizer
%
%   [V,J] = SVO(K,NLAB,C)
%
% INPUT
%   K     Similarity matrix
%   NLAB  Label list consisting of -1/+1
%   C     Scalar for weighting the errors (optional; default: 10)
%
% OUTPUT
%   V     Vector of weights for the support vectors
%   J     Index vector pointing to the support vectors
%
% DESCRIPTION
% A low level routine that optimizes the set of support vectors for a 2-class
% classification problem based on the similarity matrix K computed from the
% training set. SVO is called directly from SVC. The labels NLAB should indicate 
% the two classes by +1 and -1. Optimization is done by a quadratic programming. 
% If available, the QLD function is used, otherwise an appropriate Matlab routine.
%
% SEE ALSO
% SVC

% Revisions:
% DR1, 07-05-2003
%      Sign error in calculation of offset

% Copyright: D.M.J. Tax, D. de Ridder, R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: svo.m,v 1.15 2004/10/18 07:42:40 dick Exp $

function [v,J] = svo(K,y,C)

	prtrace(mfilename);
	if (nargin < 3)
		prwarning(3,'Third parameter not specified, assuming 10.');
    C = 10;
	end
	vmin = 1e-9;		% Accuracy to determine when an object becomes the support object.

	% Set up the variables for the optimization.
	n  = size(K,1);
	D  = (y*y').*K;
	f  = -ones(1,n);
	A  = y';
	b  = 0;
	lb = zeros(n,1);
	ub = repmat(C,n,1);
	p  = rand(n,1);

	% Make the kernel matrix K positive definite.
	i = -30;
	while (pd_check (D + (10.0^i) * eye(n)) == 0)
		i = i + 1;
	end
	if (i > -30),
		prwarning(1,'K is not positive definite. The diagonal is regularized by 10.0^(%d)*I',i);
	end
	i = i+2;
	D = D + (10.0^(i)) * eye(n);

	% Minimization procedure initialization:
	% 'qp' minimizes:   0.5 x' K x + f' x
	% subject to:       Ax <= b
	%
	if (exist('qld') == 3)
		v = qld (D, f, -A, b, lb, ub, p, 1);
	elseif (exist('quadprog') == 2)
		prwarning(1,'QLD not found, the Matlab routine QUADPROG is used instead.')
    options = optimset; options.LargeScale = 'off';
		v = quadprog(D, f, [], [], A, b, lb, ub, [], options);
	else 
		prwarning(1,'QLD not found, the Matlab routine QP is used instead.')
		verbos = 0;
		negdef = 0;
		normalize = 1;
		v = qp(D, f, A, b, lb, ub, p, 1, verbos, negdef, normalize);
	end
	
	% Find all the support vectors.
	J = find(v > vmin);

	% First find the SV on the boundary
	I = find((v > vmin) & (v < C-vmin));
	
	if (isempty(v) | isempty(I) )

		prwarning(1,'Quadratic Optimization failed. Pseudo-Fisher is computed instead.');
		v = pinv([K ones(n,1)])*y;
		J = [1:n]';
		return;

	end

	v = y.*v;
	% and now, find the output for these SVs:
	%DR1 out = sum(repmat(v(J)',length(I),1).*K(I,J),2)-y(I);
	out = y(I)-sum(repmat(v(J)',length(I),1).*K(I,J),2);

	v = [v(J); mean(out)];

return;

