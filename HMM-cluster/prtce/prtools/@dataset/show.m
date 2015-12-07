%SHOW Image display, automatic scaling, no menubar
%
%       H = SHOW(A,N)
%
% Displays all images stored in the dataset A. The standard Matlab 
% imagesc-command is used for automatic scaling.
% The number of horizontal images is determined by N. If N is not
% given an approximately square window is generated.
%
% Note that A should be defined by the dataset command, such that
% OBJSIZE or FEATSIZE contains the image size.
%
% SEE ALSO
% DATASETS, DATA2IM, IMAGE.
