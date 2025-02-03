classdef SubDomain
    %PLOTSENSOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        xmin
        xmax
        final_box
        nsensors
        discrete_integral
        kappa
        sensors
    end
    
    methods
        function obj = SubDomain(xmin, xmax, final_box, nsensors, discrete_integral, kappa, sensors)
            %PLOTSENSOR Construct an instance of this class
            %   Detailed explanation goes here
            obj.xmin = xmin;
            obj.xmax = xmax;
            obj.final_box = final_box;
            obj.nsensors = nsensors;
            obj.discrete_integral = discrete_integral;
            obj.kappa = kappa;
            obj.sensors = sensors;
        end
    end
end