%% used to set hyperparameters -- needed for every object! 
%% IG: This overloads a method of the spider and adds more options.

if ~exist('hyper') hyper=[]; end

%IG Oct 5, add construction from struct
if isstruct(hyper)
    fn=fieldnames(hyper);
    for k=1:length(fn)
        a.(fn{k})=hyper.(fn{k});
    end
    return
end

% IG: print default values
if isstr(hyper) && strcmp(hyper, 'default')
    b=struct(a);
    if isfield(b, 'display_fields')
        ff=b.display_fields;
    else
        ff=fieldnames(b);
    end
    for k=1:length(ff)
        if isa(a.(ff{k}), 'default')
            df=get_default(a.(ff{k}));
            if isnumeric(df)
                fmt='%g';
            else
                fmt='%s'
            end
            fprintf(['%s=\t' fmt '\t-- range'], ff{k},df);
            disp(get_range(a.(ff{k})));
        end
    end
    hyper=[];
end
    
if  isempty(hyper) | (iscell(hyper) & isempty(hyper{1}) & length(hyper)==1 ) 
% ------------ only assign default values --------------
    ff=fields(a);
    for k=1:length(ff)
        if isa(a.(ff{k}), 'default')
            a.(ff{k})=get_default(a.(ff{k}));
        end
    end
    return 
end

% ------- try to split up input via semi-colons ------
if ~iscell(hyper) hyper={hyper}; end; % make it a cell
extra=[];
for j=1:length(hyper)
 if ischar(hyper{j})
   h=hyper{j}; ex=[];
   if h(length(h))==';' h=h(1:length(h)-1); end;
   f=find(h==';');  f=[0 f length(h)+1 ];
   for i=1:length(f)-1
     ex{i}=h(f(i)+1:f(i+1)-1);
   end
     hyper{j}=ex{1};
     a1=extra; if ~isempty(a1) a1=make_cell(a1); end;
     a2=ex(2:length(ex)); if ~isempty(a2) a2=make_cell(a2); end;
     extra=[a1 a2];
 end
end
if ~isempty(extra)
  hyper=[hyper extra];
end
for j=1:length(hyper)
     if iscell(hyper{j}) hyper{j}=hyper{j}{1}; end;
%% --------------- add '=1' if no equals -------------
     if ischar(hyper{j})                
      if isempty(findstr('=',hyper{j}))
       hyper{j}=[hyper{j} '=1'];
      end
     end
%% --------------- add algorithm calls -------------------------
%% -------------------------------------------------------------
end

b=a; % make a copy to keep default values.

% ------------if only one hyper no cell ------------
if length(hyper)==1 & (isa(hyper,'kernel') | isa(hyper,'distance') | isa(hyper,'algorithm'))
      a.child=hyper;
else
% ------------ evaluate input --------------

 for i=1:size(hyper,2)
      if iscell(hyper{i}) | isa(hyper{i},'kernel') | isa(hyper{i},'distance') | isa(hyper{i},'algorithm') | (isnumeric(hyper{i}) & length(hyper{i})>1)
           a.child=hyper{i};
      else
           value=hyper{i};
           if ischar(value)
                value(find(value=='"'))=char(39);
           end
           if exist('evalobject') & evalobject==0
                eval([value ';']);
           else
               try
                eval(['a.' value ';']);
               end
           end
      end
 end   
    
end

% ------------ check the defaults --------------
ff=fields(b);
for k=1:length(ff)
    if isa(b.(ff{k}), 'default')
        if isa(a.(ff{k}), 'default')
            a.(ff{k})=get_default(a.(ff{k}));
        else
            is_ok=check_range(b.(ff{k}), a.(ff{k}));
            if ~is_ok
                error(['Bad range for ' ff{k}]);
            end
        end
    end
end
            

