%SVC Support Vector Classifier
% 
% 	[W,J] = SVC(A,TYPE,PAR,C)
%
% INPUT
%   A	    Dataset
%   TYPE  Type of the kernel (optional; default: 'p')
%   PAR   Kernel parameter (optional; default: 1)
%   C     Regularization parameter (optional; default: 1)
%
% OUTPUT
%   W     Mapping: Support Vector Classifier
%   J     Object identifiers of support objects		
%
% DESCRIPTION
% Optimizes a support vector classifier for the dataset A by 
% quadratic programming. The classifier can be of one of the types 
% as defined by PROXM. Default is linear (TYPE = 'p', PAR = 1). In J 
% the identifiers of the support objects in A are returned. C < 1 allows
% for more class overlap. Default C = 1.
% 
% See also MAPPINGS, DATASETS, PROXM

% Copyright: D. de Ridder, D. Tax, R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands
  
% $Id: svc.m,v 1.11 2003/12/14 22:05:39 bob Exp $

function [W,J] = svc(a,type,par,C)
		prtrace(mfilename);
if nargin < 4 | isempty(C)
	C = 1;
	prwarning(3,'Regularization parameter C set to 1\n');
end
if nargin < 3 | isempty(par)
	par = 1;
	prwarning(3,'Kernel parameter par set to 1\n');
end
if nargin < 2 | isempty(type)
	type = 'p';
	prwarning(3,'Polynomial kernel type is used\n');
end
if nargin < 1 | isempty(a)
	W = mapping(mfilename,{type,par,C});
	W = setname(W,'Support Vector Classifier');
	return;
end

if ~isa(type,'mapping') % training
	
	islabtype(a,'crisp');
	isvaldset(a,1,2); % at least 1 object per class, 2 classes
	[m,k,c] = getsize(a);
	nlab = getnlab(a);
	
	% The SVC is basically a 2-class classifier. More classes are
	% handled by mclassc.
	if c == 2   % two-class classifier
	
		% Compute the parameters for the optimization:
		y = 3 - 2*nlab;
		u = mean(a);
		a = a -ones(m,1)*u;
		K = a*proxm(a,type,par);
		% Perform the optimization:
		[v,J] = svo(+K,y,C);
		% Store the results:
		W = mapping(mfilename,'trained',{u,a(J,:),v,type,par},getlablist(a),k,2);
		%W = cnormc(W,a);
		W = setname(W,'Support Vector Classifier');
		W = setcost(W,a);
		J = a.ident(J);
		
	else   % multi-class classifier:
		
		[W,J] = mclassc(a,mapping(mfilename,{type,par,C}));
		
	end

else % execution

	w = +type;
	m = size(a,1);
	
	% The first parameter w{1} stores the mean of the dataset. When it
	% is supplied, remove it from the dataset to improve the numerical
	% precision. Then compute the kernel matrix using proxm:
	if isempty(w{1})
		d = a*proxm(w{2},w{4},w{5});
	else
		d = (a-ones(m,1)*w{1})*proxm(w{2},w{4},w{5});
	end
	% Data is mapped by the kernel, now we just have a linear
	% classifier  w*x+b:

	d = [d ones(m,1)] * w{3};
   d = sigm([d -d]);
	W = setdat(a,d,type);
	
end
	
return;
