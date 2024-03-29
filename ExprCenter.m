% 画像を読み込み、クリックされた画像上の15点からその中心を求めるプログラム

%% ファイルを読み込み、フレームを表示する。ファイルの拡張子に応じて処理を分ける

File = "2023-06-15-NV12-3840x2160_fast.mov"; % 画像/動画のパスを入れる


%処理ごとに対応する拡張子のリストを作る
MovieEXT = [".mp4", ".mov"];
PictureEXT = [".png"];
Tiff = [".tiff"];


[Path, name, ext]=fileparts(File);

if ismember(ext, MovieEXT)
    %動画から最後のフレームを抽出
    Movie = VideoReader(File);
    % 最後のフレームを読み込む
    Frame = read(Movie, Movie.NumFrames);
    % 最後のフレームを保存
    imwrite(Frame, append(Path,name,"-Frame.png"));
elseif ismember(ext, PictureEXT)
    Frame = imread(File);
elseif ismember(ext, Tiff)
    t = imread(File);
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
writematrix(Circle_Circumference, append(Path, name, "-Circumference.csv"));%クリックした座標を別ファイルに保存

%% 円のパラメーターを推定し、中心座標と直径を取得

% 初期係数の推定（適宜変更）
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
fimplicit(@(x,y) (Circle_params(1) - x).^2 + (Circle_params(2) - y).^2 -Circle_params(3).^2, "LineWidth",2)
hold off

%円のデータをxmlに保存
circle = struct;
circle.center = [Circle_params(1), Circle_params(2)];
circle.R = Circle_params(1);
writestruct(circle,append(Path, name, "-CircleInfo.xml"));



function residual = Circle_residuals(params, points)
    Cx = params(1);
    Cy = params(2);
    R = params(3);
    
    x = points(:, 1);
    y = points(:, 2);
    
    residual = (Cx - x).^2 + (Cy - y).^2-R.^2;
end