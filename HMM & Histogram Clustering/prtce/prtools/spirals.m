%SPIRALS 194 objects with 2 features in 2 classes
%
%	A = SPIRALS
%	A = SPIRALS(M,N)
%
% Load the dataset in A, select the objects and features according to the
% index vectors M and N.
%
% See also DATASETS, PRDATASETS

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: spirals.m,v 1.1.1.1 2003/05/16 11:20:36 bob Exp $

function a = spirals(M,N);
if nargin < 2, N = []; end
if nargin < 1, M = []; end
a = prdataset('spirals',M,N);
a = setname(a,'Spirals');
