%NMC Nearest Mean Classifier
% 
%   W = NMC(A)
%
% INPUT
%   A    Dataset
%
% OUTPUT
%   W    Nearest Mean Classifier   
%
% DESCRIPTION
% Computation of the nearest mean classifier between the classes in the
% dataset A.  The use of soft labels is supported.
%
% SEE ALSO
% DATASETS, MAPPINGS, NMSC, LDC, FISHERC, QDC, UDC 

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: nmc.m,v 1.9 2004/12/06 07:46:39 duin Exp $

function W = nmc(a)
	
	prtrace(mfilename);
	
	if nargin < 1 | isempty(a)
		W = mapping(mfilename);
		W = setname(W,'Nearest Mean');
		return
	end
	
	islabtype(a,'crisp','soft');
	isvaldset(a,1,2); % at least 1 object per class, 2 classes

	[m,k,c] = getsize(a);
	u = meancov(a);

	if c == 2      % 2-class case: store linear classifier
		u1 = +u(1,:);
		u2 = +u(2,:);
		R = [u1-u2]';
		offset =(u2*u2' - u1*u1')/2;
		W = affine([R -R],[offset -offset],a,getlablist(a));
		W = cnormc(W,a);
		W = setname(W,'Nearest Mean');
	else           % multiclass case, store as 1-nn classifier, best thing to do?
		W = knnc(u,1);
		W = setname(W,'Nearest Mean');
	end
	W = setcost(W,a); 
	
	return

