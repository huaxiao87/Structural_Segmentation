%FEATSELM Feature selection map
% 
% W = FEATSELM(A,CRIT,METHOD,K,T,PAR1,...)
% 
% INPUT
% 	A      	Training dataset 
%   CRIT   	Name of criterion: 'maha', 'NN', 'nerr' or 'perr' (see FEATEVAL) 
%							or an untrained classifier V (default: 'NN')
%   METHOD  - 'forward' : selection by featself (default)
% 	        - 'float'   : selection by featselp
% 	        - 'backward': selection by featselb
% 	        - 'b&b'     : branch and bound selection by featselo
% 	        - 'ind'     : individual
%						- 'lr'			: plus-l-takeaway-r selection by featsellr
%   K      	Desired number of features (default: K = 0, return optimal set)
%   T      	Tuning set to be used in FEATEVAL (optional)
%		PAR1,.. Optional parameters:
%						- L,R				: for 'lr' (default: L = 1, R = 0)
%
% OUTPUT
%		W 			Feature selection mapping
%
% DESCRIPTION
% Computation of a mapping W selecting K features. This routines offers a
% central interface to all other feature selection methods. W can be used
% for selecting features in a dataset B using B*W.
% 
% SEE ALSO
% MAPPINGS, DATASETS, FEATEVAL, FEATSELO, FEATSELB, FEATSELI,
% FEATSELP, FEATSELF, FEATSELLR

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: featselm.m,v 1.7 2003/10/19 10:00:56 dick Exp $

function w = featselm(a,crit,arg3,ksel,t,par1,par2)

	prtrace(mfilename);
	
	if (nargin < 2)
    prwarning(2,'criterion not specified, assuming NN');
		crit = 'NN';        
	end
	if (nargin < 3)
    prwarning(2,'method not specified, assuming forward');
		arg3 = 'forward'; 
	end
	if (nargin < 4)
		ksel = 0;
	end
	if (nargin < 5)
    prwarning(3,'no tuning set supplied (risk of overfit)');
		t = [];             
	end
	if (nargin < 6), par1 = []; end;
	if (nargin < 7), par2 = []; end;

	% If no arguments are supplied, return an untrained mapping.

	if (nargin == 0) | (isempty(a))
		w = mapping('featselm',{crit,arg3,ksel,t,par1,par2});
		w = setname(w,'Feature Selection');
		return
	end

	[m,k] = size(a);

	if (isstr(arg3))
		method = arg3;												% If the third argument is a string,
		switch (method)												%   it specifies the method to use.
		 case 'forward'												
		  w = featself(a,crit,ksel,t);
		 case 'float'
		  w = featselp(a,crit,ksel,t);
		 case 'backward'
		  w = featselb(a,crit,ksel,t);
		 case 'b&b'
		  w = featselo(a,crit,ksel,t);
		 case 'ind'
		  w = featseli(a,crit,ksel,t);
		 case 'lr'
		  w = featsellr(a,crit,ksel,par1,par2,t);
		 otherwise
		  error('Unknown method specified.')
		end
	elseif (ismapping(arg3))								
		w = arg3;															% If the third argument is a mapping,
		isuntrained(w);												%   assert it is untrained 
		w = a*setdata(w,{crit,ksel,t});				% 	and train it.
	else
		error('Illegal method specified.')
	end

return
