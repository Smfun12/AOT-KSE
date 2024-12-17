function plotFinalErrorForVars(vars, p)
    legends = [];
    figure;
    for i=1:p.size_vars
        if contains(vars(i).observer_type, "Lagrangian")
            legends = [legends, vars(i).observer_type+ "(#sensors="+ length(vars(i).sensors) + ", a=" + vars(i).amplitude + ")"];
        else
            legends = [legends, vars(i).observer_type+ "("+ length(vars(i).sensors) + ", " + "offgrid=" + vars(i).off_grid  + ",interpolation=" + vars(i).interpolation_type + ")"];
        end
        if i > 1
            hold on;
        end
        time_axis = p.dt:p.dt:p.dt*length(vars(i).error_aot);
        semilogy(time_axis(1:100:length(vars(i).error_aot)), vars(i).error_aot(1:100:length(vars(i).error_aot)), vars(i).marker, 'LineWidth',3);
        hold off;
        % title("Error computed over time");
        if p.prod
            xlabel("$t$, Time", "Interpreter","latex", "FontSize", 48)
            ylabel("$\frac{1}{N} \|u-\hat{u}\|_F$","Interpreter","latex", "FontSize",48)
        else
            xlabel("$t$, Time", "Interpreter","latex", "FontSize", 36)
            ylabel("$\frac{1}{N} \|u-\hat{u}\|_F$","Interpreter","latex", "FontSize",36)
        end
        filename = vars(i).observer_type + "-testAnimated.gif"; % Specify the output file name
        total_frames = (length(vars(i).im));
        for idx = 1:total_frames
            if isempty(vars(i).im{idx})
                continue
            end
            [A,map] = rgb2ind(vars(i).im{idx},256);
            if idx == p.show
                imwrite(A,map,filename,"gif",LoopCount=Inf, ...
                        DelayTime=.1)
            else
                imwrite(A,map,filename,"gif",WriteMode="append", ...
                        DelayTime=.1)
            end
        end

    end
    legend(legends)
    if p.prod
        fontsize(48, "points");
    else
        fontsize(36, "points");
    end
    figure;
    legends = [];
    for i=1:p.size_vars
        vars(i).interpolation_error(vars(i).interpolation_error == 0) = 1e-15;
        time_axis = p.dt:p.dt:p.dt*length(vars(i).interpolation_error);
        semilogy(time_axis, vars(i).interpolation_error, vars(i).marker, "LineWidth",3)
        hold on
        legends = [legends, vars(i).observer_type + "(" + length(vars(i).sensors)+ ", offgrid=" + vars(i).off_grid + ", interpolation="+ vars(i).interpolation_type + ")"];

    end
    xlabel("$t$, Time", Interpreter="latex", FontSize=36)
    ylabel("$\epsilon$ ,Interpolation error", "Interpreter","latex", "FontSize",36)
    legend(legends)
    set(gca, "FontSize", 26)
    
end