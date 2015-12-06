%FINDIDENT Determine indices of objects having specified identifiers
%
%	   J = FINDIDENT(A,IDENT)
%
% If IDENT is a single object identifier then J is a vector with indices
% to all objects with that identifier.
%
% If IDENT is a column vector of cells, numbers or characters, representing object
% identifiers, then J is a column vector of cells, such that J{n} contains a vector
% with indices to all objects having identifier IDENT{n}.
