function save_gif(fname, lambda_test, img_hyper)

img_save = uint8(img_hyper/3000*256);

figure;
img = insertText(img_save(:, :, 1), [1,1], lambda_test(1)*1e9, 'TextColor', 'white', 'BoxOpacity', 0);
h = imagesc(img);
colormap(gray(256));
% caxis([0, 3000]);
axis image
colorbar

gif(fname)
for lam_ = 1:length(lambda_test)
    img = insertText(img_save(:, :, lam_), [1,1], lambda_test(lam_)*1e9, 'TextColor', 'white', 'BoxOpacity', 0);
    set(h,'Cdata',img)
    % drawnow
    gif
end
% gif('clear')

end
