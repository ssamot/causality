function p = permsOctave(n)
% PERMSOCTAVE Generate permutations.
%
% permsOctave(n)  Generates all possible permutations of 1:n in
%                 lexicographic order.
%
% This implementation is a translation of a C implementation by
% Frank Ruskey and Joe Sawada (Permlex.c). The latest version of
% the original implementation may be found at the site 
%     http://theory.cs.uvic.ca/inf/perm/PermInfo.html

% Check input arguments
if ~exist('n') || isempty(n) || n <= 0
    error('Input argument must be greater than zero');
end

nPerms = prod(1:n);    % number of permutations
p = zeros(nPerms, n);  % permutations in lexicographic order

prev = 0:n;            % previous permutation (= prev(2:n + 1))
p(1, :) = 1:n;         % set the first permutation

% Generate the rest of permutations
for i = 2:nPerms
    next = nextPerm(prev, n);
    p(i, :) = next(2:n + 1);
    prev = next;
end


% -----------------------------------------------------------------------------
function next = nextPerm(prev, n)
% NEXTPERM Generate the next permutation in lexicographic order.

k = n;

while prev(k) > prev(k + 1)
    k = k - 1;
end

if k == 1 
    next = [];
    return
end

j = n + 1;
while prev(k) > prev(j)
    j = j - 1;
end

% Swap elements j and k
temp = prev(k);
prev(k) = prev(j);
prev(j) = temp;

r = n + 1;
s = k + 1;
while r > s
    % Swap elements r and s
    temp = prev(s);
    prev(s) = prev(r);
    prev(r) = temp;

    r = r - 1;
    s = s + 1;
end

next = prev;
