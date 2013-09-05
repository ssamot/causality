% For compilation under Linux/Octave you need to install the package
% octavex.x-headers.
% Under Windows/Octave, compilation works out of the box.
%
% There is a big variety of platforms running Matlab around i.e.
%    'SUN4','SOL2','HP700','SGI','SGI64','IBM_RS','ALPHA',
%    'LNX86','GLNX86','GLNXA64',
%    'MAC', 'MACI'
% the following script is only tested for the most common ones (Mac,Linux,Win)
% but should work with minor modifications on your architecture.
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch 2010-07-18.

OCTAVE = exist('OCTAVE_VERSION') ~= 0;        % check if we run Matlab or Octave

%% 0) change directory
me = mfilename; % what is my filename
mydir = which(me); mydir = mydir(1:end-2-numel(me)); % where am I located
cd(mydir)

if OCTAVE
  %% 1) compile sq_dist
  mkoctfile --mex sq_dist.c
  delete sq_dist.o

  %% 2) compile solve_chol
  mkoctfile --mex solve_chol.c
  delete solve_chol.o

else % MATLAB
  %% 1) compile sq_dist
  mex -O sq_dist.c

  %% 2) compile solve_chol
  if ispc                                                              % Windows
    libext = 'lib';

    % remove the trailing underscore after the Lapack function "dpotrs"
    % we do that in a clumsy way since there is no sed/awk under Windows
    fid = fopen('solve_chol.c','r');
    fid_win = fopen('solve_chol2XXXX.c','w');
    while 1
      tline = fgetl(fid);
      if ~ischar(tline), break, end
      id = strfind(tline,'dpotrs');
      if numel(id)
        tline = [tline(1:id-1),'dpotrs',tline(id+7:end)];
      end
      fprintf(fid_win,[tline,'\n']);
    end
    fclose(fid_win);
    fclose(fid);

    if numel(strfind(computer,'64'))                                    % 64 bit
      ospath = 'extern/lib/win64/microsoft';
    else                                                                % 32 bit
      ospath = 'extern/lib/win32/lcc';
    end

    % compile
    comp_cmd = 'mex -O solve_chol2XXXX.c -output solve_chol';
    eval([comp_cmd,' ''',matlabroot,'/',ospath,'/libmwlapack.',libext,''''])
    delete solve_chol2XXXX*
    return
  end
  comp_cmd = 'mex -O solve_chol.c';
  if isunix
    if ismac                                                               % Mac
      libext = 'dylib';
      if numel(strfind(lower(computer),'maci'))                          % Intel
        ospath = 'bin/maci';
      else
        ospath = 'bin/mac';
      end
    else
      libext = 'so';
      if numel(strfind(lower(computer),'sol'))                         % Solaris
        ospath = 'bin/sol64';
      else                                                               % Linux
        if numel(strfind(computer,'64'))
          ospath = 'bin/glnxa64';                                       % 32 bit
        else                                                            % 64 bit
          ospath = 'bin/glnx86';
        end
      end
    end
  end
  eval([comp_cmd,' ',matlabroot,'/',ospath,'/libmwlapack.',libext])
end
