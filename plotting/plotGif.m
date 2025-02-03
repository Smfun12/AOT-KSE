function plotGif(var, p)
    filename = var.observer_type + "-testAnimated.gif"; % Specify the output file name
    im = var.im;
    total_frames = (length(im));
    for idx = 1:total_frames
        if isempty(im{idx})
            continue
        end
        [A,map] = rgb2ind(im{idx},256);
        if idx == p.show
            imwrite(A,map,filename,"gif",LoopCount=Inf, ...
                    DelayTime=.1)
        else
            imwrite(A,map,filename,"gif",WriteMode="append", ...
                    DelayTime=.1)
        end
    end
end