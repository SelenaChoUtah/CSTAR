function [v, ind] = firstMinimum(Z)
% Finds the first minimum of column vector Z using the derivatives of Z.
% Returns the index ind of the first minimum and the value of the first
% minimum v.

dZ = diff(Z);
ind = find(dZ>0,1,'first');
v = Z(ind);
end