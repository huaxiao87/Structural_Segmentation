%GENCIRC Generation of a one-class circular dataset
% 
%   A = GENCIRC(N,S)
%
%  INPUT
%    N  Size of dataset (optional; default: 50)
%    S  Standard deviation (optional; default: 0.1)
%
%  OUTPUT
%    A  Dataset
%  
% DESCRIPTION
% Generation of a uniformly distributed one-class 2D circular 
% dataset with radius 1 superimposed with 1D normally distributed
% radial noise with standard deviation S. N points are generated.
% Defaults: N = 50, S = 0.1.
% 
% SEE ALSO
% DATASETS, PRDATASETS

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: gencirc.m,v 1.4 2004/01/29 14:35:00 bob Exp $

function a = gencirc(n,s)

	prtrace(mfilename);
	
	if nargin < 1, n =  50; end
	if nargin < 2, s = 0.1; end
	if (ength(s) > 1)
		error('Standard deviation should be scalar')
	end
	alf = rand(n,1)*2*pi;
	r = ones(n,1) + randn(n,1)*s;
	a = [r.*sin(alf),r.*cos(alf)];
	a = dataset(a);
	
	return;
