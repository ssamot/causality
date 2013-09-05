function [acc, sigma] =bac( Output, Target )
%[acc, sigma] =bac( Output, Target )

[errate, errate_pos, errate_neg, sigma]=ber( Output, Target );
acc=1-errate;
end

