function plotGif(p)
    im = p.im;
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