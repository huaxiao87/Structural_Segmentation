%RENUMLAB Renumber labels
% 
%   [NLAB,LABLIST]        = RENUMLAB(LABELS)
%   [NLAB1,NLAB2,LABLIST] = RENUMLAB(LABELS1,LABELS2)
%
% INPUT
%   LABELS,LABELS1,LABELS2  Array of labels
%
% OUTPUT
%    NLAB,NLAB1,NLAB2       Vector of numeric labels
%    LABLIST                Unique labels
%
% DESCRIPTION 
% If a single array of labels LABELS is supplied, it is converted and
% renumbered to a vector of numeric labels NLAB. The conversion table
% LABLIST is such that LABELS = LABLIST(NLAB,:). When two arrays LABELS1
% and LABELS2 are given, they are combined into two numeric label vectors
% NLAB1 and NLAB2 with a common conversion table LABLIST.
%
% Note that numeric labels with value -inf or NaN and string labels CHAR(0)
% are interpreted as missing labels. Their entry in NLAB will be 0 and they
% will not have an entry in LABLIST.
%
% SEE ALSO
% DATASET

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: renumlab.m,v 1.7 2003/10/19 14:41:59 bob Exp $

function [out1,out2,out3] = renumlab(slab1,slab2)

	prtrace(mfilename);

	% Obsolete call?
	if (isempty(slab1)) & (nargin == 1)
		out1 = []; out2 = [];
		return
	end

	% Clean up the symbolic labels.
	slab1 = clean_lab(slab1);

	if (nargin == 1) | (isempty(slab2))

		% Find unique labels for LABLIST and indices into LABLIST for NLAB.  
		[lablist,dummy,nlab] = unique(slab1,'rows');

		% Remove "missing label", if present.
		[lablist,nlab] = remove_empty_label(lablist,nlab);

		% Set output arguments.
		out1 = nlab; out2 = lablist;

	else

		% Check whether SLAB1 and SLAB2 match in type.
		if (isstr(slab1) ~= isstr(slab2))
			error('label lists should be both characters, strings or numbers')
		end
		
		% Clean up SLAB2 and put the union of SLAB1 and SLAB2 into SLAB.
		slab2 = clean_lab(slab2);
		if isstr(slab1), slab = char(slab1,slab2); else, slab = [slab1;slab2]; end

		% Find unique labels for LABLIST and indices into LABLIST for NLAB.
		if (iscell(slab))
			[lablist,dummy,nlab] = unique(slab);
		else
			[lablist,dummy,nlab] = unique(slab,'rows');
		end;

		% Remove "missing label", if present.
		[lablist,nlab] = remove_empty_label(lablist,nlab);

		% Set output arguments.
		out1 = nlab(1:size(slab1,1));      % Renumbered SLAB1 labels 
		out2 = nlab(size(slab1,1)+1:end);  % Renumbered SLAB2 labels
		out3 = lablist;
	end

	return


% LAB = CLEAN_LAB (LAB)
%
% Clean labels; for now, just replaces occurences of NaN in numeric labels
% by -inf (both denoting "missing labels").

function slab = clean_lab (slab)

	if (iscell(slab))        % Cell array of labels.
		;
	elseif (size(slab,2) == 1) & (~isstr(slab))  	% Vector of numeric labels.
		J = isnan(slab);
		slab(J) = -inf;
	elseif (isstr(slab))     % Array of string labels.
		;
	else
		error('labels should be strings or scalars')
	end

	return


% [LABLIST,NLAB] = REMOVE_EMPTY_LABEL (LABLIST,NLAB)
%
% Removes the empty first label from LABLIST and NLAB (corresponding to the 
% "missing label"), if present.

function [lablist,nlab] = remove_empty_label (lablist,nlab)

% Find occurences of '' (in cell array label lists), '\0' (in string 
% label lists) or -inf (in numeric label lists) and remove them.

	if (iscellstr(lablist))    % Cell array of labels.	
		if (strcmp(lablist{1},'')), lablist(1) = []; nlab = nlab -1; end
	elseif (isstr(lablist))    % Array of string labels.
		if (strcmp(lablist(1,:),char(0))) lablist(1,:) = []; nlab = nlab -1; end
	else
		% Vector of numeric labels.
		if (lablist(1) == -inf), lablist(1) = []; nlab = nlab -1; end
	end

	return
