%GETPRIOR Get class prior probabilities of dataset
%
%   [PRIOR,LABLIST] = GETPRIOR(A)
%
% INPUT
%   A        Dataset
%
% OUTPUT
%   PRIOR    Class prior probabilities
%   LABLIST  Label list
%
% DESCRIPTION
% Returns the class prior probabilities as defined in the dataset A.
% In LABLIST the corresponding class labels are returned.
%
% Note that if these are not set (A.PRIOR = []), the class frequencies
% are measured and returned. Consequently, there is an essential difference
% in the use of A.PRIOR, which returns the true contents of the field, and
% GETPRIOR(A), which returns the interpretation for the empty A.PRIOR.
%
% If A has soft labels, these are used to estimate the class frequencies. 
% If A has target labels, an error is returned since in that case, no 
% classes are defined.
%
% SEE 
% DATASETS
