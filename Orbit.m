% defines Orbit class for oorb
classdef Orbit < handle
    properties
        prm = struct;   % Parameters
        xyt1 = [];      % Array of xyt coordinates for Camera 1 [x y t good calibset match]
        xyt2 = [];      % Array of xyt coordinates for Camera 2 [x y t good calibset match]
        xyzt = [];      % Array of xyzt 3D coordinates [x y z t(frame) strk traj t(seconds)]
    end
    
    %% Methods
    % TODO:
    
    methods
        function obj = Orbit()
            % Constructor to initialize xyt1 and xyt2
        end

        function xyt = good(obj,camID)
            % Method to only keep good points
            switch camID
                case 1
                    idx = logical(obj.xyt1(:,4));
                    xyt = obj.xyt1(idx,:);
                case 2
                    idx = logical(obj.xyt2(:,4));
                    xyt = obj.xyt2(idx,:);
                otherwise
                    error('No good column of invalid camID.')
            end
        end

        function n = n1(obj,raw)
            % Converts xyt1 into time series n1
            % Uses only "good" coordinates (default) except if raw = 'raw'
            if nargin == 1
                xyt1 = obj.good(1); %#ok<*PROPLC>
            elseif nargin==2 & strcmp(raw,'raw')
                xyt1 = obj.xyt1;
            else
                error('Invalid input for n1 method.')
            end
            t = xyt1(:,3);
            T = max(t);
            n = histcounts(t,0.5:T+0.5);
        end

        function n = n2(obj,raw)
            % Converts xyt2 into time series n2
            % Uses only "good" coordinates (default) except if raw = 'raw'
            if nargin == 1
                xyt2 = obj.good(2); %#ok<*PROPLC>
            elseif nargin==2 & strcmp(raw,'raw')
                xyt2 = obj.xyt2;
            else
                error('Invalid input for n1 method.')
            end
            t = xyt2(:,3);
            T = max(t);
            n = histcounts(t,0.5:T+0.5);
        end

        function n = n3(obj)
            % Converts xyzt into time series n3
            t = obj.xyzt(:,4);
            T = max(t);
            n = histcounts(t,0.5:T+0.5);
        end

        function xy = xy1(obj)
            % Method to convert xyt1 array into xy{t} cell array
            xy = mat2cell(obj.xyt1(:,1:3),accumarray(obj.xyt1(:,3),obj.xyt1(:,3),[],@numel));
        end

        function xy = xy2(obj)
            % Method to convert xyt2 array into xy{t} cell array
            xy = mat2cell(obj.xyt2(:,1:3),accumarray(obj.xyt2(:,3),obj.xyt2(:,3),[],@numel));
        end

        function xyz = xyz(obj)
            % Method to convert xyzt array into xyz{t} cell array
            xyz = mat2cell(obj.xyzt(:,1:4),accumarray(obj.xyzt(:,4),obj.xyzt(:,4),[],@numel));
        end

        function stk = strk(obj)
            % Returns cell array of streaks from xyztkj
            dimTime = 4;
            dimStrk = 5;
            xyztk = sortrows(obj.xyzt,[dimStrk dimTime]);
            rp = regionprops(xyztk(:,dimStrk),'Area');
            rowDist = vertcat(rp(:).Area);
            stk = mat2cell(xyztk,rowDist);
        end

        function trj = traj(obj)
            % Returns cell array of trajectories from xyztkj
            dimTime = 4;
            dimTraj = 6;
            xyztkj = sortrows(obj.xyzt,[dimStrk dimTime]);
            rp = regionprops(xyztkj(:,dimTraj),'Area');
            rowDist = vertcat(rp(:).Area);
            trj = mat2cell(xyztkj,rowDist);
        end

        function plot1(obj)
            % Plot .xyt1
            xyt = obj.good(1);
            figure,
            scatter(xyt(:,1),xyt(:,2),10,xyt(:,3),'filled')
            axis equal ij, box on
            xlim([0 obj.prm.mov.frameWidth])
            ylim([0 obj.prm.mov.frameHeight])
        end


        function plot2(obj)
            % Plot .xyt2
            xyt = obj.good(2);
            figure,
            scatter(xyt(:,1),xyt(:,2),10,xyt(:,3),'filled')
            axis equal ij, box on
            xlim([0 obj.prm.mov.frameWidth])
            ylim([0 obj.prm.mov.frameHeight])
        end

        function plot3(obj)
            % Plot .xyzt
            figure,
            scatter3(obj.xyzt(:,1),obj.xyzt(:,2),obj.xyzt(:,3),10,obj.xyzt(:,4),'filled')
            axis equal
            xlim([-10 10]), xlabel('x (m)')
            ylim([-10 10]), ylabel('y (m)')
            zlim([-10 10]), zlabel('z (m)')
        end

        function reset(obj, arg)
            % Method to reset flags
            switch arg
                case 'trk'
                    flagsToReset = {'trk', 'cln', 'clb', 'trg', 'stk', 'trj'};
                case 'cln'
                    flagsToReset = {'cln', 'clb', 'trg', 'stk', 'trj'};
                case 'clb'
                    flagsToReset = {'clb', 'trg', 'stk', 'trj'};
                case 'trg'
                    flagsToReset = {'trg', 'stk', 'trj'};
                case 'stk'
                    flagsToReset = {'stk', 'trj'};
                case 'trj'
                    flagsToReset = {'trj'};
                otherwise
                    warning('Invalid argument for reset; doing nothing.');
                    return;
            end

            for i = 1:numel(flagsToReset)
                obj.prm.flag.(flagsToReset{i}) = false;
            end
        end


    end
    
    %% Methods private
    methods (Access = private)
    end

end

