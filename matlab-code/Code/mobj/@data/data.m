%=============================================================================
% data structure             
%=============================================================================  
% D = data(X, Y) 
% D = data(X)
% D = data(result)
% D = data(CEdata)
% D = data(other_data)
% 
% Creates a data structure, similar to the data structures of the Spider
% http://www.kyb.mpg.de/bs/people/spider/ and CLOP http://clopinet.com/CLOP: 
% X is a data matrix and Y the truth value vector.
% Warning: a data object is a handle. To make a physical copy of D0, use
% D=data(D0); not D=D0; or use D=subset(D0, idx);
%
% X and Y may be matrices or cell arrays.
% If X is a matrix, it is of dimension (p, n), p number of patterns and n
% number of features. If it is a cell array, it is of dimension p.
% If Y is a matrix, it is of dimension (p, m), p number of patterns and m
% number of labels. If it is a cell array, it is of dimension p.
%
% The contructor and the subset method accept both other data objects and
% result objects as arguments. 

%==========================================================================
% Author of code: Isabelle Guyon -- isabelle@clopinet.com -- Feb 2013
%==========================================================================

classdef data < handle
	properties (SetAccess = public)
        subidx=[];
        Y=[]; % Holds the truth values
        X=[]; % Holds the data 
    end
    methods
        %%%%%%%%%%%%%%%%%%%
        %%% CONSTRUCTOR %%%
        %%%%%%%%%%%%%%%%%%%
        function this = data(obj, Y, subidx) 
            %this = data
            %this = data(X, Y) 
            %this = data(X, Y, subidx) 
            %this = data(X)
            %this = data(result)
            %this = data(CEdata)
            %this = data(other_data)
            if nargin<1, return; end
            if isa(obj, 'data') 
                f=intersect(fields(obj), fields(this));
                for k=1:length(f)
                    this.(f{k})=obj.(f{k});
                end
            elseif isnumeric(obj) || iscell(obj)
                this.X=obj;
                if nargin>1
                    this.Y=Y;
                end
                if nargin>2 && ~isempty(subidx)
                    this.subidx=subidx;
                else
                    this.subidx=(1:size(obj,1))';
                end
            end
        end          
        
        function D = subset(this, idx)
            %D = subset(this, idx)
            % Select a data subset
            D=data(this);
            D.subidx=idx(:);
        end 
        
        function P=get_property(this, name, num)
            %P=get_sn(this, name, num)
            % Get the values of any property
            % Get the num value in subidx
            % If num is [] or not given, get all values in subidx
            if isempty(this.(name)), P=[]; return; end
            % Find the pattern number
            if nargin<3 || isempty(num)
                num=this.subidx;
            else
                if length(num)==1 && (num<1 || num>length(this.(name))), P=[]; return; end
                num=this.subidx(num);
            end          
            if iscell(this.(name)) && length(num)==1
                P=this.(name){num};
            else
                P=this.(name)(num,:);
            end 
        end 
        
        function Y=get_Y(this, num)
            %Y=get_Y(this, num)
            % Get the num value of Y (in subidx)
            % If num is [] or not given, get all values in subidx
            if nargin<2, num=[]; end
            Y=get_property(this, 'Y', num);
        end
        
        function L=get_labels(this, type)
            %L=get_labels(this, type)
            % Get the labels and their Kaggle info
            % In a cell array format
            % type: 'train', 'valid' or 'test' 
            % => 'Public' (validation data) 'Private' (test data) or
            % 'Ignored' (other)
            if nargin<2, type=''; end
            switch type
                case 'test'
                    tp='Private';
                case 'valid'
                    tp='Public'
                otherwise
                    tp='Ignored';
            end
            num=length(this);
            Y=get_Y(this);
            if ~isempty(type)
                L=cell(num,2);
            else
                L=cell(num,1);
            end
            for k=1:num
                L{k,1}=turn2str(Y(k));
                if ~isempty(type)
                   L{k,2}=tp;
                end
            end
        end
            
        
        function lbl=get_lbl(this, num)
            %lbl=get_lbl(this, num)
            % Get a string suitable to display the label
            lbl=turn2str(get_Y(this, num));
        end
        
        function subidx=get_subidx(this)
            %subidx=get_subidx(this)
            subidx=this.subidx;
        end

        function set_subidx(this)
            %set_subidx(this)
            this.subidx=subidx;
        end
        
        function shuffle(this, n)
            %shuffle(this, n)
            N=length(this);
            if nargin<2, n=N; end
            rp=randperm(N);
            n=min(n, N);
            this.subidx=this.subidx(rp(1:n));
        end
        
        function X=get_X(this, num)
            %X=get_X(this, num)
            % Get the num line of X (in subidx)
            % If num is [], get all lines (restricted to subidx)
            % If num is not given, get current line of X  (in subidx)
            if nargin<2, num=[]; end
            X=get_property(this, 'X', num);
        end
        
        function set_Y(this, num, val)
            %set_Y(this, num, val)
            num=this.subidx(num);
            if iscell(this.Y) && length(num)==1
                this.Y{num}=val;
            else
                this.Y(num, :)=val;
            end
        end
        
        function set_X(this, num, val)
            %set_X(this, num, val)
            num=this.subidx(num);
            if iscell(this.X) && length(num)==1
                this.X{num}=val;
            else
                this.X(num, :)=val;
            end
        end  
        
        function n=length(this)
            %n=length(this)
            % number of samples
            n=length(this.subidx);
        end
        
        function n=featnum(this)
            %n=featnum(this)
            % number of features 
            n=length(get_X(this, 1));
        end
        
        function n=labelnum(this)
            %n=labelnum(this)
            % number of labels 
            n=length(get_Y(this, 1));
        end
            
        function save(this, filename, prefix, mode, offset, use_subidx)
            %save(this, filename, prefix, mode, offset, use_subidx)
            % Save the results in csv format
            if nargin<3, prefix='train'; end
            if nargin<4, mode='w'; end
            if nargin<5, offset=0; end
            if nargin<6, use_subidx=0; end
            if use_subidx
                samples=this.get_X;
                label=this.get_Y;
            else
                samples=this.X;
                label=this.Y;
            end
            write_file(filename, samples, [], prefix, mode,[],[],offset);
            if ~isempty(label)
                write_file([filename '_solution'], [], label, prefix, mode,[],[],offset);
            end
        end
        
        function h=show(this, num, h)
            %h=show(this, num, h)
            % Shows the nth pattern  
            if nargin<2, num=[]; end
            if nargin<3, h=figure; else figure(h); end
            X=get_X(this, num);
            Y=get_Y(this, num);
            lbl=get_lbl(this, num);
            if isempty(X)
                error('A is empty');
            end
            if isnumeric(X)
                if ~isnumeric(Y)
                    Y=str2num(Y);
                end
                if size(Y, 1)==size(X, 1)
                    X=[X, Y];
                end
                cmat_display(X, h);
                ylabel('Samples', 'FontSize', 14, 'FontWeight', 'Bold');
                xlabel(sprintf('%d Features and %d Label(s)', featnum(this), labelnum(this)), 'FontSize', 14, 'FontWeight', 'Bold');
            else
                show(X, h);
                axis square
                dim=length(X);
                title([lbl '   (' num2str(dim) ' points)'], 'FontSize', 14, 'FontWeight', 'Bold');
            end
        end % show
            
    end %methods
end % classdef
