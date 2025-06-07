function plotGif(p)
    filename = "testAnimated1.gif"; % Specify the output file name
    im = p.im;
    % total_frames = (length(im));
    % for idx = 1:total_frames
    %     if isempty(im{idx})
    %         continue
    %     end
    %     [A,map] = rgb2ind(im{idx},256);
    %     if idx == p.show
    %         imwrite(A,map,filename,"gif",LoopCount=Inf, ...
    %                 DelayTime=.1)
    %     else
    %         imwrite(A,map,filename,"gif",WriteMode="append", ...
    %                 DelayTime=.1)
    %     end
    % end

    v = VideoWriter('output.mp4', 'MPEG-4'); % Or use 'Motion JPEG AVI' for AVI
    v.FrameRate = 50; % Adjust as needed
    open(v);
    
    for k = 1:length(im)
        if isempty(im{k})
            continue
        end
        writeVideo(v, im{k});
    end
    
    close(v);
end