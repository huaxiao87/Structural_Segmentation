%GENCLASS Generate class frequency distribution
%
%  M = GENCLASS(N,P)
%
% INPUT
%  N    Number (scalar)
%  P    Prior probabilities (optional; default: equal prior probabilities)
%
% OUTPUT
%  M    Class frequency distribution
%
% DESCRIPTION
% Generates a class frequency distribution M of N (scalar) samples
% over a set of classes with prior probabilities given by the vector P.
% The numbers of elements in P determines the number of classes and
% thereby the number of elements in M. P should be such that SUM(P) = 1. 
% If N is a vector with length C, then M=N is returned. 
%
% Note that this is a random process, so M = GENCLASS(100,[0.5, 0.5]) 
% may result in M = [45 55].
%
% This routines is used in various data generation routines like
% GENDATH to determine the distribution of the objects over the classes.

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: genclass.m,v 1.5 2003/10/07 11:59:36 bob Exp $

function N = genclass(N,p)
	
	prtrace(mfilename);
	
	if nargin < 2 | isempty(p)
		p = ones(1,length(N))/length(N);
	end
	c = length(p);
	if length(N) == c 
		;
	elseif length(N) > 1
		error('Mismatch in numbers of classes')
	else
		if nargin < 2 | isempty(p)
			p = repmat(1/c,1,c);
		end
		P = cumsum(p);
		if abs(P(c)-1) > 1e-10
			error('Sum of class prior probabilities should be one')
		end
		X = rand(N,1);
		K = repmat(X,1,c) < repmat(P(:)',N,1);
		L = sum(K,1);
		N = L - [0 L(1:c-1)];
	end

	return
	
