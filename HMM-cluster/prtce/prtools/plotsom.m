function h = plotsom(W)
%PLOTSOM Plot the Self-Organizing Map in 2D
%
%    plotsom(W)
%
% Plot the Self-Organizing Map W, trained by som.m. This is only
% possible if the map is 2D.
%
% See also: som

% Copyright: D.M.J. Tax, davidt@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% Maybe I should introduce the possibility to set the linewidth and
% markersize... 

if ~ismapping(W)
	error('I expect a SOM mapping!');
end
if ( ~strcmp(getmapping_file(W),'som') & ...
	 ~strcmp(getmapping_file(W),'som_dd') )
    error('I expect a SOM mapping!');
end
if size(W,2)~=2
	error('The SOM can only be plotted in 2D');
end

% Get the data:
W = +W;  w=W.w; k=W.k;
% Plot the bloody thing:
hold on;
% The 'horizontal' lines:
for i=0:k(2)-1
    h=plot(w(i*k(1)+(1:k(1)),1),w(i*k(1)+(1:k(1)),2),'o-');
    set(h,'linewidth',2,'markersize',8);
end
I = reshape(1:k(1)*k(2),k(1),k(2))';
% The 'vertical' lines:
for i=0:k(1)-1
    h=plot(w(I(i*k(2)+(1:k(2))),1),w(I(i*k(2)+(1:k(2))),2),'o-');
    set(h,'linewidth',2,'markersize',8);
end

% Return the handle only when it is required
if (nargout==0)
	clear h;
end

return