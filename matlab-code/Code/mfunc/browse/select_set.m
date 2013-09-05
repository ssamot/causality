dataname=find_name(public_data_dir);
    
if ~exist('D')
    TRAIN=CEdata(dataname, 'train', public_data_dir, private_data_dir);
    VALID=CEdata(dataname, 'valid', public_data_dir, private_data_dir);
    TEST=CEdata(dataname, 'test', public_data_dir, private_data_dir);
end

set_choices = {'train', 'valid', 'test'};
[set_num,OK] = listdlg('PromptString','Select a dataset:',...
                      'SelectionMode','single',...
                      'ListString', set_choices);
if ~OK, 
    fprintf('You did not select anything, bye!\n'); 
    return;
else

switch(set_choices{set_num})
    case 'train'
        D=TRAIN;
    case 'valid'
        D=VALID;
	case 'test'
        D=TEST;
    otherwise
        error('No such option');
end

% Show a pair
num=1;
show(D, num, h);

col{1}=[.75 .05 .05];
col{2}=[.2 .5 .2];
col{3}=[.2 .2 .8];

set(n1, 'BackgroundColor', col{set_num}, 'String', set_choices{set_num});
set(n2, 'String', num2str(num));

show_score;
    
end