function sff = init(varargin)
% initialize sff structure based on input arguments

argin = varargin{1};
narg = length(argin);

if (narg == 1) && isstruct(argin{1}) && isfield(argin{1},'gp1')
    disp('input is sff')
    sff = argin{1};

elseif (narg == 1) && isstruct(argin{1}) && isfield(argin{1},'flag')
    disp('input is prm')

    [v1,v2] = utl.getv1v2();

    sff.prm = argin{1};

    sff.gp1.mov = v1;
    sff.gp2.mov = v2;

elseif (narg == 1) && isnumeric(argin{1})
    disp('input is cyber2world')

    [v1,v2] = utl.getv1v2();
    
    w = VideoReader(v1{1});
    sff.prm = prm.set(argin{1},w);

    sff.gp1.mov = v1;
    sff.gp2.mov = v2;

    

elseif (narg == 2)

elseif (narg == 3) && isstruct(argin{3})
    disp('input is v1, v2, prm')

elseif (narg == 3) && isnumeric(argin{3})
    disp('input is v1, v2, cyber2world')

    sff.prm = prm.set(argin{3},argin{1});

    sff.gp1.mov = argin{1};
    sff.gp2.mov = argin{2};

else
    error('Invalid argument(s). Please refer to sphirefly help.')

end

end

