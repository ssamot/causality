%=============================================================================
% CEdata Cause-effet pair Data structure             
%=============================================================================  
%
%       D=CEdata(data)
%
% --> Construct from another data or CEdata object
%
%       D=CEdata(filename, prefix, publicdir, privatedir)
%
% --> Construc from data stored in csv format
%     in <publicdir>/<filename>_<prefix>_xxx.csv
%     and <privatedir>/<filename>_<prefix>_xxx.csv
%
%       D=CEdata(XA, XB, CA, CB, FA, FB, F1, G1, S_N1, F2, G2, S_N2, type, name)
%
% --> Construct from raw data
% XA, XB: matrix of variables, samples in lines, variables in columns
% CA, CB: 'Numerical', 'Categorical' or 'Binary' type of variable
% FA, FB: Names of variables
% F1: for artificial variables, first function used
% G1: for artificial variables, first noise used
% S_N1: for artificial variables, first signal to noise ratio
% F2: for artificial variables, second function used
% G2: for artificial variables, second noise used
% S_N2: for artificial variables, second signal to noise ratio
% type: Dataset type 'CE' (Cause-effet), 'R' 
% (Related but not as cause-effect pair), 'I' (independent), 'U'
% (unknown)
% name: dataset name
% 
% Creates a data container given a data file in Kaggle csv format, and
% optionally the corresponding solution file.
% Aleternatively, create CEdata from raw data matrices of variable pairs.
% Important: CEdata is a handle, so if you copy it, you do not duplicate
% the data. To copy D0 to D don't do D=D0 do D=CEdata(D0);

%==========================================================================
% Author of code: Isabelle Guyon -- isabelle@clopinet.com -- February 2013
%==========================================================================

classdef CEdata < data
    	properties (SetAccess = public)
            YT=[]; % Holds the detailed truth values
                   % 1: A->B
                   % 2: A<-B
                   % 3: A-B
                   % 4: A|B
                   % 0: A?B
            F1={};  % 1st Function
            G1={};  % 1st Noise
            S_N1=[];% 1st Signal to noise ratio
            F2={};  % 2nd Function
            G2={};  % 2nd Noise
            S_N2=[];% 2nd Signal to noise ratio
            name={}; % original dataset name
        end
        properties (SetAccess = private)
            num_values=10000; % Number of quantization levels
            min_size=500;     % Bounds on CE pair sample num //500 - 8000
            max_size=8000;    % old: 100 - 6400
            log_scale=1;      % Scaling of CE pair sample num
        end
    
	    methods
        %%%%%%%%%%%%%%%%%%%
        %%% CONSTRUCTOR %%%
        %%%%%%%%%%%%%%%%%%%
        function this = CEdata(arg1, arg2, CA, CB, FA, FB, F1, G1, S_N1, F2, G2, S_N2, type, name) 
            % this=CEdata(data)
            % this=CEdata(filename, prefix, publicdir, privatedir)
            % this=CEdata(XA, XB, CA, CB, FA, FB, F1, G1, S_N1, F2, G2, S_N2, type, name)
            if nargin<14, name='unknown'; end
            if nargin<13, type='U'; end
            if nargin<10, F2={}; G2=[]; S_N2=[]; end
            if nargin<7, F1={}; G1=[]; S_N1=[]; end
            if nargin<3, CA=[]; end
            if nargin<4, CB=[]; end
            if nargin<5, FA=[]; end
            if nargin<6, FB=[]; end 
            if nargin<2, arg2=[]; end
            this=this@data;
            if nargin<1, return; end
            if isa(arg1, 'data')
                f=fields(arg1);
                for k=1:length(f)
                    this.(f{k})=arg1.(f{k});
                end
                return
            end 
            if isnumeric(arg1)
                good_idx=create(this, arg1, arg2, CA, CB, FA, FB, type);
                if ~isempty(F1)
                    this.F1=F1(good_idx);
                    this.G1=G1(good_idx);
                    this.S_N1=S_N1(good_idx);
                end
                if ~isempty(F2)
                    this.F2=F2(good_idx);
                    this.G2=G2(good_idx);
                    this.S_N2=S_N2(good_idx);
                end
                this.name=cell(size(this.Y));
                for k=1:length(this.X)
                    this.name{k}=name;
                end
            elseif isstruct(arg1)
                load_real(this, arg1, arg2, CA);
            else               
                load(this, arg1, arg2, CA, CB);
            end
        end   % constructor
        
        function n=sample_num(this, k)
            %n=sample_num(this, k)
            % Returns the number of samples for pair k,
            % or a vector with all the numbers of samples if k is []
            if nargin<2 || isempty(k), k=[]; end
            num=length(this);
            if k<1 | k>num, n=[]; return; end
            if isempty(k), k=1:num; end
            n=zeros(length(k),1);
            for i=k
                n(i)=length(this.X{this.subidx(i)}.A);
            end
        end
        
        function n=random_sample(this, num, min_size, max_size, r)
            %n=random_sample(this, num, min_size, max_size, r)
            % Draw num values of sample sizes for CE pairs
            % with at most max_size values.
            if nargin<3 || isempty(min_size), min_size=this.min_size; end
            if nargin<4 || isempty(max_size), max_size=this.max_size; end
            if nargin<5 || r==0, 
                r=rand(num,1); 
            else
                r=(0:num)/num;
            end

            if this.log_scale
                % Log2 scale min_size ... max_size
                s=log2(max_size/min_size);
                n=round(min_size*2.^(s*r));
            else
                % Linear scale between min_size and max_size
                n=round(min_size+r*(max_size-min_size));
            end
        end

        function good_idx=create(this, XA, XB, CA, CB, FA, FB, type) 
            % create(this, XA, XB, CA, CB, FA, FB, type)
            % Create a CE data object from data pairs in XA and XB
            % with CA and CB data types and FA and FB names.
            % type is the pair type: CE, R, I, U
            [dim, num]=size(XA);
            this.X=cell(num,1);
            if strcmp(type, 'CE') % Cause or effect A->B or A<-B
                this.Y=sign(randn(num,1));
                this.YT=(-this.Y+1)/2+1;
            else
                this.Y=-ones(num,1);
                if strcmp(type, 'R') % A - B
                    this.YT=3*ones(num,1);
                elseif strcmp(type, 'I') % A | B
                    this.YT=4*ones(num,1);
                elseif strcmp(type, 'U') % A ? B
                    this.YT=-ones(num,1);
                else
                    error('Bad data type');
                end
            end
            this.subidx=(1:num)';
            
            percent_done=0;
            old_percent_done=0;
            tic;
            fprintf('Starting\n');

            k=0;
            good_idx=[];
            n=random_sample(this, num, this.min_size, min(dim, this.max_size));

            for j=1:num
                
                percent_done=floor(j/num*100);
                if ~mod(percent_done,5) && percent_done~=old_percent_done,
                    fprintf(' %d%%(%5.2f)', percent_done, toc);
                end
                old_percent_done=percent_done;
    
                if isempty(CA)
                    ca=[]; cb=[]; fa=[]; fb=[];
                else
                    ca=CA{j}; cb=CB{j}; fa=FA{j}; fb=FB{j};
                end
                % Preprocess variables
                xa=XA(:,j); xb=XB(:,j);
                idxg=find(~isnan(xa) & ~isinf(xa) & ~isnan(xb) & ~isinf(xb));
                xa=xa(idxg); xb=xb(idxg);
                if ~isempty(xa)
                    [xa, ca, idx]=prepro_var(xa, ca, this.num_values, n(j));
                end
                if ~isempty(xa) && ~isempty(xb) 
                    [xb, cb] =prepro_var(xb, cb, this.num_values, n(j), idx);
                end
                if ~isempty(xa) && ~isempty(xb)
                    k=k+1;
                    good_idx(k)=j;
                    if this.Y(k)>0
                        this.X{k}=CEpair(xa, xb, ca, cb, fa, fb);
                    else
                        this.X{k}=CEpair(xb, xa, cb, ca, fb, fa);
                    end 
                end
            end
            this.YT=this.YT(1:k);
            this.subidx=this.subidx(1:k);
            this.Y=this.Y(1:k);
            this.X=this.X(1:k);
            fprintf('\nDone\n');
            
        end
        
        function load_real(this, V, D, type)
            % load_real(this, V, D, type)
            % Load real cause-effect pairs, e.g. the Max Plank CE pairs
            % V --  struct array V.C, V.E, V.Cid, V.Eid, V.Cva, V.Eva, V.source
            % D --  struct array D.source and other redundant info
            if nargin<3, D=[]; end
            if nargin<4 || isempty(type), type='CE'; end
            if isfield(V(1), 'type'), type=V(1).type; end
            
            if ~isempty(D)
                % Choose only unidim pairs
                idxgood=[];
                for i=1:length(V)
                    if D(i).c1==D(i).c2 && D(i).e1==D(i).e2
                        idxgood=[idxgood i];
                    end
                end
            else
                idxgood=1:length(V);
            end
            num=length(idxgood);
            
            n=random_sample(this, num);
            
            this.X=cell(num,1);
            this.Y=zeros(num,1);
            this.YT=zeros(num,1);
            this.subidx=(1:num)';
            this.name=cell(num,1);
            randflip=sign(randn(num,1));
            
            Cva='Numerical';
            Eva='Numerical';
            for k=1:num
                i=idxgood(k);
                fa=clean_str(V(i).Cid); 
                fb=clean_str(V(i).Eid);
                if isfield(V, 'Cva')
                    Cva=V(i).Cva; Eva=V(i).Eva; 
                end                    
                [xa, ca, idx]=prepro_var(V(i).C, Cva, this.num_values, n(k));
                [xb, cb]     =prepro_var(V(i).E, Eva, this.num_values, n(k), idx);
                
                if randflip(k)>0
                    this.X{k}=CEpair(xa, xb, ca, cb, fa, fb);
                else
                    this.X{k}=CEpair(xb, xa, cb, ca, fb, fa);
                end
                
                if strcmp(type, 'CE') % A -> B or A <- B
                    this.Y(k)=randflip(k);
                    this.YT(k)=(-this.Y(k)+1)/2+1;
                elseif strcmp(type, 'R') % A - B
                    this.YT(k)=3;
                elseif strcmp(type, 'I') % A | B
                    this.YT(k)=4;
                elseif strcmp(type, 'U') % A ? B
                    this.YT(k)=0;
                else
                    error('Bad data type');
                end
            
                if ~isempty(D)
                    name=clean_str(D(i).source);
                    this.name{k}=sprintf('MPI%04d - %s', i, name);
                else
                    this.name{k}=clean_str(V(i).name);
                end                
            end
        end

        function load(this, filename, prefix, publicdir, privatedir)
            % load(this, filename, prefix, publicdir, privatedir)
            % load all the files starting with "filename" relevant to
            % construct the CE data object
            if nargin<2, filename=''; end
            if nargin<3, prefix='train'; end
            if nargin<4 || isempty(publicdir), publicdir='./'; else publicdir=[publicdir '/']; end
            if nargin<5 || isempty(privatedir), privatedir='./'; else privatedir=[privatedir '/']; end
            filename0=filename;
            if ~isempty(filename), filename=[filename '_']; end
            % Load from Matlab format
            filename=[filename prefix];
            if exist([privatedir filename '.mat'], 'file')
                load([privatedir filename '.mat']);
            elseif exist([publicdir filename '.mat'], 'file') && ~exist([privatedir filename '_privateinfo.csv'], 'file')
                load([publicdir filename '.mat']);
            end
            if exist('THIS_CE_DATA', 'var')
                %fprintf('Loading from Matlab format\n');
                f=fields(THIS_CE_DATA);
                for k=1:length(f)
                    this.(f{k})=THIS_CE_DATA.(f{k});
                    [n1, n2]=size(this.(f{k}));
                    if n2>n1, this.(f{k})=this.(f{k})'; end % Fixes a bug
                end
                return
            end      
            % Read pairs
            fprintf('\n*** READING FROM TEXT FILES, CAN BE SLOOOOOW ***\n');
            filename=[filename '_'];
            [header, ID, X]=read_file([publicdir filename 'pairs']);
            XA=X(:,1); XB=X(:,2);
            % Fill default index
            num=length(ID);
            this.subidx=(1:num)';
            % Read target values
            if strcmp(prefix, 'train')
                [header, ID, Y]=read_file([publicdir filename 'target']);
            else
                [header, ID, Y]=read_file([privatedir filename 'target']);
            end
            if ~isempty(Y)
                this.Y=cell2mat(Y(:,1));
                this.YT=cell2mat(Y(:,2));
            end
            % Read info
            FA={}; FB={}; CA={}; CB={};
            [header, ID, I]=read_file([privatedir filename 'privateinfo']);
            if ~isempty(I)
                this.name=I(:, 1);
                FA=I(:, 2); FB=I(:, 3);
                this.F1=I(:, 4); this.G1=I(:, 5); this.S_N1=cell2mat(I(:, 6));
                this.F2=I(:, 7); this.G2=I(:, 8); this.S_N2=cell2mat(I(:, 9));
            end
            [header, ID, C]=read_file([publicdir filename 'publicinfo']);
            if ~isempty(C)
                CA=C(:,1); CB=C(:,2);
            end
            % Fill in X
            ca=''; cb=''; fa=''; fb='';
            for k=1:num
                xa=XA{k}; xb=XB{k};
                if ~isempty(CA) && ~isempty(CB)
                    ca=CA{k}; cb=CB{k}; 
                end
                if ~isempty(FA) && ~isempty(FB)
                    fa=FA{k}; fb=FB{k};
                end
                this.X{k}=CEpair(xa, xb, ca, cb, fa, fb);
            end
            % Save the values in Matlab format for faster reloading
            fprintf('*** SAVING AS MATLAB FORMAT FOR FASTER RELOADING ***\n');
            save(this, filename0, prefix, publicdir, privatedir);
            fprintf('... done saving!\n');
        end
        
        function save(this, filename, prefix, publicdir, privatedir)
            %save(this, filename, prefix, publicdir, privatedir)
            % Save in Matlab format
            if nargin<2, filename=''; end
            if nargin<3, prefix='train'; end
            if nargin<4, publicdir='./'; else publicdir=[publicdir '/']; end
            if nargin<5, privatedir='./'; else privatedir=[privatedir '/']; end
            if ~isempty(filename), filename=[filename '_']; end
            % Save to Matlab format
            fprintf('Saving %s to Matlab format ...\n', filename);
            warning off; THIS_CE_DATA=struct(this); warning on
            filename=[filename prefix];
            if ~isempty(this.name)
                save([privatedir filename], 'THIS_CE_DATA');
            else
                save([publicdir filename], 'THIS_CE_DATA');
            end
            fprintf('Done\n');  
        end
        
        function savecsv(this, filename, prefix, mode, offset)
            %savecsv(this, filename, prefix, mode, offset)
            % Save the results in csv format
            if nargin<3, prefix='train'; end
            if nargin<4, mode='w'; end
            if nargin<5, offset=0; end
            if ~isempty(filename), filename=[filename '_']; end
            makedir('PUBLIC');
            makedir('PRIVATE');
            makedir('KAGGLE');
            filename=[filename prefix '_'];
            % samples
            samples=this.get_X;
            write_file(['PUBLIC/' filename 'pairs'], samples, [], prefix, mode,[],[],offset, {'SampleID', 'A', 'B'});
            % labels
            kaggle_label=get_labels(this, prefix);
            label=get_labels(this);
            if strcmp(prefix, 'train')
                write_file(['PUBLIC/' filename 'target'], label, [], prefix, mode,[],[],offset, {'SampleID', 'Target [1 for A->B; -1 otherwise]', 'Details [1 for A->B; 2 for A<-B; 3 for A-B; 4 for A|B]'});
            else
                write_file(['PRIVATE/' filename 'target'], label, [], prefix, mode,[],[],offset, {'SampleID', 'Target [1 for A->B; -1 otherwise]', 'Details [1 for A->B; 2 for A<-B; 3 for A-B; 4 for A|B]'});
            end
            write_file(['KAGGLE/' filename 'solution'], kaggle_label, [], prefix, mode,[],[],offset, {'SampleID', 'Target', 'Usage'});
            % info
            private=get_private(this);
            public=get_public(this);
            write_file(['PRIVATE/' filename 'privateinfo'], private, [], prefix, mode,[],[],offset, {'SampleID', 'Source', 'A name' , 'B name', 'F1', 'N1', 'S/N 1', 'F2', 'N2', 'S/N 2'});
            write_file(['PUBLIC/' filename 'publicinfo'], public, [], prefix, mode,[],[],offset, {'SampleID', 'A type', 'B type'});           
        end
        
        function D = subset(this, idx)
            %D = subset(this, idx)
            % Select a data subset
            D=CEdata(this);
            D.subidx=idx(:);
        end 
        
        function Y=get_YT(this, num)
            %Y=get_YT(this, num)
            % Get the num value of YT (in subidx)
            % If num is [] or not given, get all values in subidx
            if nargin<2, num=[]; end
            Y=get_property(this, 'YT', num);
        end
        
        function Y=get_Y(this, num, sym)
            %Y=get_Y(this, num, sym)
            % Get the num value of Y (in subidx)
            % If num is [] or not given, get all values in subidx
            if nargin<2, num=[]; end
            if nargin<3, sym=1; end
            Y=get_property(this, 'YT', num);
            if sym
                Y(Y==2)=-1;
                Y(Y~=1&Y>0)=0;
            else
                Y(Y~=1)=-1;
            end
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
                case 'train'
                    tp='Training';
                case 'test'
                    tp='PrivateTest';
                case 'valid'
                    tp='PublicTest';
                otherwise
                    tp='Ignored';
            end
            num=length(this);
            Y=get_Y(this);
            YT=get_YT(this);
            L=cell(num,2);
            for k=1:num
                L{k,1}=turn2str(Y(k));
                if isempty(type)
                   L{k,2}=turn2str(YT(k));
                else
                   L{k,2}=tp;
                end
            end
        end
        
        function lbl=get_lbl(this, num)
            %lbl=get_lbl(this, num)
            % Get a string suitable to display the label
            Y=get_YT(this, num);
            lbl='';
            if ~isempty(Y)
                switch Y
                    case 1
                        lbl='A->B';
                    case 2
                        lbl='A<-B';
                    case 3
                        lbl='A-B';
                    case 4
                        lbl='A|B';
                    otherwise
                        lbl='A?B';
                end
            end
            nm=get_name(this, num);
            info=get_info(this, num);
            if ~isempty(info)
                lbl=[lbl '   [' nm ' ' info '] '];
            elseif ~isempty(nm)
                lbl=[lbl '   [' nm '] '];
            end
            if ~isempty(lbl), lbl=['Truth: ' lbl]; end
            if 1==2 % This computes an orientation score
                X=get_X(this, num);
                Causality=causa(X);
                Dependency=indep(X);
                lbl=[lbl sprintf(' Score: %5.2f', Causality*Dependency)];
            end
        end
        
        function nm=get_name(this, num)
            %nm=get_name(this, num)
            % Get the name of the original dataset
            if nargin<2, num=[]; end
            nm=get_property(this, 'name', num);
        end
        
        function info=get_info(this, num)
            %info=get_info(this, num)
            % Get the function and noise info for artificial variables
            if isempty(this.F1) || (~isempty(this.F2) && strcmp(this.F1{num}, 'NA')), info=''; return; end
            % Find the pattern number
            if num<1 || num>length(this.name), info=''; return; end
            num=this.subidx(num);
            if isempty(this.F2) || (~isempty(this.F2) && isempty(this.F2{num})) || (~isempty(this.F2) && strcmp(this.F2{num}, 'NA'))
                info=sprintf('%s %s %5.2g', this.F1{num}, this.G1{num}, this.S_N1(num));
            else
                info=sprintf('%s %s %5.2g + %s %s %5.2g', ...
                    this.F1{num}, this.G1{num}, this.S_N1(num), ...
                    this.F2{num}, this.G2{num}, this.S_N2(num));
            end
        end
        
        function sn=get_sn(this, num, i)
            %sn=get_sn(this, num, i)
            % Get the signal to noise ratio
            if nargin<2 || isempty(num), num=1:length(this); end
            if nargin<3, i=1; end
            sn=[];
            if i==1 
                sn=get_property(this, 'S_N1', num);
            elseif i==2
                sn=get_property(this, 'S_N2', num);
            end
        end  
        
        function I=get_public(this)
            % I=get_public(this)
            % Provide as a cell array of strings of the public info
            num=length(this);
            I=cell(num, 2);
            for k=1:num
                x=get_X(this, k);
                I{k, 1}=x.CA;
                I{k, 2}=x.CB;
            end
        end
        
        function I=get_private(this)
            % I=get_private(this)
            % Provide as a cell array of strings of the private info
            num=length(this);
            I=cell(num, 3);
            for k=1:num
                I{k, 1}=get_name(this, k);
                x=get_X(this, k);
                I{k, 2}=x.FA;
                I{k, 3}=x.FB;
                p=get_property(this, 'F1', k); if isempty(p), p='NA'; end
                I{k, 4}=p;
                p=get_property(this, 'G1', k); if isempty(p), p='NA'; end
                I{k, 5}=p;
                if ~strcmp(p, 'NA'), p=get_property(this, 'S_N1', k); end
                I{k, 6}=turn2str(p);
                p=get_property(this, 'F2', k); if isempty(p), p='NA'; end
                I{k, 7}=p;
                p=get_property(this, 'G2', k); if isempty(p), p='NA'; end
                I{k, 8}=p;
                if ~strcmp(p, 'NA'), p=get_property(this, 'S_N2', k); end
                I{k, 9}=turn2str(p);
            end            
        end   
        
        function names=get_var_name(this, k)
            %names=get_var_name(this, k)
            % Returns the names of variables for pair k,
            % or a vector with all the numbers of samples if k is []
            if nargin<2 || isempty(k), k=[]; end
            num=length(this);
            if k<1 | k>num, n=[]; return; end
            if isempty(k), k=1:num; end
            names=cell(length(k),2);
            for i=k
                names{i,1}=this.X{this.subidx(i)}.FA;
                names{i,2}=this.X{this.subidx(i)}.FB;
            end
        end
 
        function types=get_var_type(this, k)
            %types=get_var_type(this, k)
            % Returns the types of variables for pair k,
            % or a vector with all the numbers of samples if k is []
            if nargin<2 || isempty(k), k=[]; end
            num=length(this);
            if k<1 | k>num, n=[]; return; end
            if isempty(k), k=1:num; end
            types=cell(length(k),2);
            for i=k
                types{i,1}=this.X{this.subidx(i)}.CA;
                types{i,2}=this.X{this.subidx(i)}.CB;
            end
        end
        
        function show_stats(this, filename)
            %show_stats(this, filename)
            % Compute and display statistice
            if nargin<2, fp=2; else fp=fopen(filename, 'w'); end
            S=stats(this);
            f=fields(S);
            for k=1:length(f)
                ff=fields(S.(f{k}));
                fprintf(fp, '\n%s\n', upper(f{k}));
                for j=1:length(ff)
                    fprintf(fp, '\t%s: \t', ff{j});
                    val=S.(f{k}).(ff{j});
                    if isnumeric(val)
                        if round(val(1,1))==val(1,1), fmt='%d'; else fmt='%5.2f'; end
                        fprintf([fmt '\t\t'], val(1,:));
                        for ii=2:size(val, 1)
                            fprintf('\n\t');
                            fprintf(['\t' fmt '\t'], val(ii,:));
                        end
                    elseif iscell(val)
                        for ii=1:length(val)
                            fprintf('%s\t', val{ii});
                        end
                    end
                    fprintf('\n');
                end
            end
        end
            
        function S=stats(this)
            %S=stats(this)
            % Collects statistics about the data in a data structure.
            
            YT=get_YT(this);
            Y=get_Y(this);
            
            % Fraction of A->B, B->A, A-B, A|B, A?B
            S.truth.All_pairs=length(this);
            S.truth.A_causes_B=length(find(Y==1));
            S.truth.B_causes_A=length(find(YT==2));
            S.truth.A_related_B=length(find(YT==3));
            S.truth.A_indept_B=length(find(YT==4));
            S.truth.A_unknown_B=length(find(YT==0));
            
            % Number of real CE pairs
            S.CEpairs.Total=length(find(YT==1 | YT==2));
            names=get_name(this);
            S.CEpairs.Artif = length(strmatch('ARTIFCE', names));
            S.CEpairs.Real= S.CEpairs.Total - S.CEpairs.Artif;           
            NYU_CE= length(strmatch('YEAST', names)) + length(strmatch('ECOLI', names)) ;
            S.CEpairs.Real_= S.CEpairs.Real-NYU_CE;
            
            % Statistics about "Numerical", "Binary", "Categorical"
            types=this.get_var_type;
            S.types.Name=unique(types(:))';
            nt=length(S.types.Name);
            S.types.Num=zeros(nt,nt); 
            for k=1:S.truth.All_pairs
                i=strmatch(types{k,1}, S.types.Name);
                j=strmatch(types{k,2}, S.types.Name);
                S.types.Num(i, j)=S.types.Num(i, j)+1;
            end
            
            % Distribution of sample sizes
            n=this.sample_num;
            if this.log_scale
                bin_num=round(log2(this.max_size/this.min_size));
            else
                bin_num=max(4, round((max_dim-min_dim))/1000);
            end
            Bounds=random_sample(this, bin_num,[],[],1);
            for k=1:length(Bounds)-1
                S.sizes.Bins{k}=sprintf('%d-%d', Bounds(k), Bounds(k+1));
            end
            S.sizes.Num=zeros(1, bin_num);
            S.sizes.Num(1)=length(find(n<Bounds(2)));
            for k=2:bin_num-1
                S.sizes.Num(k)=length(find(n>=Bounds(k) & n<Bounds(k+1)));
            end
            S.sizes.Num(bin_num)=length(find(n>=Bounds(bin_num)));
            
            % Distribution of noise values
            noise=[get_sn(this, [], 1); get_sn(this, [], 2)];
            noise=noise(~isnan(noise));
            S.noise.S_N=unique(noise)';
            S.noise.Freq=zeros(size(S.noise.S_N));
            for k=1:length(S.noise.S_N);
                S.noise.Freq(k)=length(find(noise==S.noise.S_N(k)));
            end
            S.noise.Freq=S.noise.Freq/length(noise);
        end
        
    end % methods
end % classdef
