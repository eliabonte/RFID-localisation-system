classdef DifferentialDrive < handle 

%     _   _   _        _ _           _            
%    / \ | |_| |_ _ __(_) |__  _   _| |_ ___  ___ 
%   / _ \| __| __| '__| | '_ \| | | | __/ _ \/ __|
%  / ___ \ |_| |_| |  | | |_) | |_| | ||  __/\__ \
% /_/   \_\__|\__|_|  |_|_.__/ \__,_|\__\___||___/
%                                                 
properties 
    x;  % current position of the robot. Is a 3x1 vector of the form
        %   [x; y; theta]       x, y [m], theta [rad]

    x_est; % current estimated position of the robot. Is a 3x1 vector of the form [x_est [m]; y_est [m]; theta [rad]]

    L;  % half of the distance between the 2 wheels [m]
    R;  % radius of the wheel [m]

end % properties

%  ____        _     _ _        __  __                _                                                             
% |  _ \ _   _| |__ | (_) ___  |  \/  | ___ _ __ ___ | |__   ___ _ __ ___                                           
% | |_) | | | | '_ \| | |/ __| | |\/| |/ _ \ '_ ` _ \| '_ \ / _ \ '__/ __|                                          
% |  __/| |_| | |_) | | | (__  | |  | |  __/ | | | | | |_) |  __/ |  \__ \                                          
% |_|    \__,_|_.__/|_|_|\___| |_|  |_|\___|_| |_| |_|_.__/ \___|_|  |___/                                          
%
% Even if Matlab do not provide an "easy" way to discriminate public and private member functions,
% here we firstly define the functions that are intended to be called in the main program                                                                                                                   
methods 

    function obj = DifferentialDrive(initlal_state,R,L) % constructor
        obj.x = zeros(3,1);
        obj.x(1) = initial_state(1);
        obj.x(2) = initial_state(2)
        obj.x(3) = initial_state(3)

        obj.R = R;
        obj.L = L;

    end

    function x_next = dynamics(obj,vL,vR,dt)
        v,w = vvTovw(vL,vR);
        obj.x(1) = obj.x(1) + v*cos(obj(3))*dt;
        obj.x(2) = obj.x(2) + v*sin(obj(3))*dt;
        obj.x(3) = obj.x(3) + w*dt;

        x_next = obj.x; 
    end

    function u_est,omega_est = odometry(obj,v,w,dt)
        vR,vL = vwTovv(v,w);

        % angles measured by encoders
        phiR = vR*dt + normrand(0,0.1);   
        phiL = vL*dt + normrand(0,0.1);

        u_est = obj.R*(phiR + phiL)/2
        omega_est = obj.R*(phiR - phiL)/(2*obj.L)

        obj.x_est(1) = obj.x_est(1) + u_est*cos(obj.x_est(3)); 
        obj.x_est(2) = obj.x_est(2) + u_est*sin(obj.x_est(3)); 
        obj.x_est(3) = obj.x_est(3) + omega_est
    end

%  ____       _            _         __  __                _                   
% |  _ \ _ __(_)_   ____ _| |_ ___  |  \/  | ___ _ __ ___ | |__   ___ _ __ ___ 
% | |_) | '__| \ \ / / _` | __/ _ \ | |\/| |/ _ \ '_ ` _ \| '_ \ / _ \ '__/ __|
% |  __/| |  | |\ V / (_| | ||  __/ | |  | |  __/ | | | | | |_) |  __/ |  \__ \
% |_|   |_|  |_| \_/ \__,_|\__\___| |_|  |_|\___|_| |_| |_|_.__/ \___|_|  |___/
%
% Here are defined auxiliary functions used in the public members or for other simpler computations
    function vR,vL = vwTovv(obj,v,w) % switch from v, omega to vR,vL
        vR = (v + obj.L*w)/obj.R;
        vL = (v - obj.L*w)/obj.R;       
    end

    function v,w = vvTovw(obj,vR,vL)    %switch from vR.vL to v, omega
        v = obj.R*(vR+vL)/2;
        omega = obj.R*(vR-vL)/2;
    end


end % methods
end 