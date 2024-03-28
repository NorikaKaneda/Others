% 画像を読み込み、クリックされた画像上の15点からその中心を求めるプログラム

%% ファイルを読み込む。画像であればそのまま、動画であれば最後のフレームを出力
Movie_ = 2; % 動画なら1、画像なら0、tiffなら2
FilePass = "C:\Users\no5ri\OneDrive - The University of Tokyo\フォルダ\大学\授業課題等\卒業研究\自習\MATLAB\Others\フレーム-24-03-2024-05-06-03.tiff";
if Movie_==1
    %動画から最後のフレームを抽出
    Movie = VideoReader(FilePass);
    % 最後のフレームを読み込む
    Frame = read(Movie, Movie.NumFrames);
    % 最後のフレームを保存
    imwrite(Frame, "Frame.png");
elseif Movie_==0
    Frame = imread(FilePass);
elseif Movie_==2
    t = imread(FilePass);
    if ndims(t) == 3 && size(t, 3) > 1
    % 複数の平面を持つ場合は、最初の平面を使用します
    rgbImage = t(:,:,1:3);
    else
    % それ以外の場合はそのままの形式を使用します
    rgbImage = t;
    end
    Frame = rgbImage;
end
%% フレームを画面に出し、クリックして座標取得
imshow(Frame)
title("周の決定")
TrajAxes=gca;
Circle_Circumference = ginput(15);
writematrix(Circle_Circumference, "Circumference.csv");

%% 円のパラメーターを推定し、中心座標と直径を取得

% 初期係数の推定
initial_guess = [600; 350; 600];

% 最小二乗法を使用して楕円の方程式の係数を求める
Circle_params = lsqcurvefit(@Circle_residuals, initial_guess, Circle_Circumference, zeros(size(Circle_Circumference, 1), 1));

% 楕円の方程式の係数を表示
disp('円の方程式の係数:');
disp(Circle_params);

disp("この円の直径: ")
disp(Circle_params(3)*2)

%重ねて表示
hold(TrajAxes, "on")
fimplicit(@(x,y) (Circle_params(1) - x).^2 + (Circle_params(2) - y).^2 -Circle_params(3).^2, "LineWidth",3)
hold off



function residual = Circle_residuals(params, points)
    Cx = params(1);
    Cy = params(2);
    R = params(3);
    
    x = points(:, 1);
    y = points(:, 2);
    
    residual = (Cx - x).^2 + (Cy - y).^2-R.^2;
end