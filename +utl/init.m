function orb = init(varargin)
% initialize Orbit object orb based on input arguments

argin = varargin{1};
narg = length(argin);


if (narg == 1) && isobject(argin{1}) %isstruct(argin{1}) && isfield(argin{1},'gp1')
    disp('input is Orbit')
    orb = argin{1};

elseif (narg == 1) && isstruct(argin{1}) %&& isfield(argin{1},'flag')
    disp('input is prm')

    [v1,v2] = utl.getv1v2();
    
    orb = Orbit();
    orb.prm = argin{1};

    orb.prm.mov.v1 = v1;
    orb.prm.mov.v2 = v2;

elseif (narg == 1) && isnumeric(argin{1})
    disp('input is cyber2world')

    [v1,v2] = utl.getv1v2();

    orb = Orbit();
    
    w = VideoReader(v1{1});
    orb.prm = prm.set(argin{1},w);

    orb.prm.mov.v1 = v1;
    orb.prm.mov.v2 = v2;

    

elseif (narg == 2)

elseif (narg == 3) && isstruct(argin{3})
    disp('input is v1, v2, prm')

elseif (narg == 3) && isnumeric(argin{3})
    disp('input is v1, v2, cyber2world')
    
    orb = Orbit();
    orb.prm = prm.set(argin{3},argin{1});

    orb.prm.mov.v1{1} = [argin{1}.Path '/' argin{1}.Name]; %argin{1};
    orb.prm.mov.v2{1} = [argin{2}.Path '/' argin{2}.Name]; %argin{2};

else
    error('Invalid argument(s). Please refer to sphirefly help.')

end

end

