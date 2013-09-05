function labels = double2labels(B)
% DOUBLE2LABELS Transforms a double matrix into a cell array of strings.

[n m] = size(B);
labels = cell(n, m);

for i = 1:n
    for j = 1:m
	if B(i, j) == 0
	    labels{i, j} = '';
	else
	    labels{i, j} = sprintf('%.2g', B(i, j));
	end
    end
end
