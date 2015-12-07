%VERTCAT Vertical concatenation of datasets (object extension)
%
%    C = [A;B]
%
% The datasets A and B are vertically concatenated, i.e. the
% objects of B are added to the dataset A. This is possible if
% the labels of B are given in a similar way as those of A.
% If new labels (i.e. classes) are added, the PRIOR field of
% A is cleared.
%
% If B is not a dataset, empty labels are generated.
%
% The new objects are checked for the feature domains.
%
% See also SETLABELS, TESTFEATDOM
