%SELDAT Select subset of dataset
%
%	B = SELDAT(A,C,F,N)
%	B = SELDAT(A,D)
%
% INPUT
%   A   Dataset
%   C   Indexes of classes (optional; default: all)
%   F   Indexes of features (optional; default: all)
%   N   Indices of objects extracted from classes in C
%       Should be cell array in case of multiple classes 
%       (optional; default: all)
%   D   Dataset
%	
% OUTPUT
%   B   Subset of the dataset A
%
% DESCRIPTION
% B is a subset of the dataset A defined by the set of classes (C),
% the set of features (F) and the set of objects (N). Classes and
% features have to be identified by their index. The order of class
% names can be found by GETLABLIST(A). The index of a particular 
% class can be determined by GETCLASSI. N is applied to each class
% defined in C. Defaults: select all, except unlabeled objects.
%
%   B = SELDAT(A,D)
%
% If D is a dataset that is somehow is derived from A, e.g. by selection
% and mappings, then the corresponding objects of A are retrieved by their
% object identifiers and returned into B.
%
%   B = SELDAT(A)
%
% Retrieves all labeled objects of A.
%
% In all cases empty classes are removed.
%
% EXAMPLES
% Generate 8 class, 2-D dataset and select: the second feature, objects
% 1 from class 1, 0 from class 2 and 1:3 from class 6
%
%   A = GENDATM([3,3,3,3,3,3,3,3]); 
%   B = SELDAT(A,[1 0 6],2,{1;[];1:3});
% or
%   B = SELDAT(A,[],2,{1;[];[];[];[];1:3});
%
% SEE ALSO
% DATASETS, GENDAT, GETLABLIST, GETCLASSI, REMCLASS

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: seldat.m,v 1.18 2004/03/19 09:24:23 duin Exp $

function b = seldat(a,clas,feat,n)
		prtrace(mfilename);
	[m,k,c] = getsize(a);
	allfeat = 0;
	allclas = 0;
	if nargin < 4, n = {}; end
	if nargin < 3 | isempty(feat), allfeat = 1; feat = [1:k]; end
	if nargin < 2 | (isempty(clas) & isempty(n))	allclas = 1; clas = [1:c]; end

	if isdataset(clas)
		% If input D is a dataset, it is assumed that D was derived from
		% A, and therefore the object identifiers have to be matched.
		J = getident(clas);
		L = findident(a,J);
		L = cat(1,L{:});
		b = a(L,:);
	else
		% Otherwise, we have to extract the right class/fetaures and/or
		% objects:

		if max(feat) > k
			error('Feature out of range');
		end
		if max(clas) > c
			error('Class number out of range')
		end
		if size(n,1) ~= size(clas,2)
			prwarning(2,'number of objects is not equal number of classes');
		end
	

		if iscell(n)
			if (~(isempty(n) | isempty(clas))) & (length(n) ~= size(clas,2))
				error('Number of cells in N should be equal to the number of classes')
			end
		else
			if size(clas,2) > 1
				error('N should be a cell array, specifying objects for each class');
			end
			n = {n};
		end
		
		% Do the extraction:
	
		if allclas & isempty(n)
			J = findnlab(a,0);
			if ~isempty(J)
				a(J,:) = [];
			end
		else

			if isempty(clas) & ~isempty(n)
			clas = zeros(1,length(n));	
				for i = 1:length(n)
					if(~isempty(n(i)))	
						clas(1,i) = i;
					end 
				end
			end

			J = [];
			for j = 1:size(clas,2)
				JC = findnlab(a,clas(1,j));
				if ~isempty(n)
					if max(cat(1,n{j})) > length(JC)
						error('Requested objects not available in dataset')
					end
					J = [J; JC(n{j})];
				else
					J = [J; JC];
				end
			end
			a = a(J,:);
		end

		if allfeat
			b = a;
		else
			b = a(:,feat);
		end
		
	end

	b = setlablist(b); % reset lablist to remove empty classes

return;
