%% BLS-GSM: Generate denoised image using BLS-GSM(Bayesian Least Squares  - Gaussian Scale Mixture ) technique from a noisy Image
% Author: Jaimeet Patel
% Email : jpatel99@hawk.iit.edu
% Date  : 11/9/2016
% Description: This program takes a parameter file as the input. The
% parameter file specifies the folder, the header name of the input
% images, the start and end number of images, and the value of sigma
% (std of noise). The input images must be grayscale. The program applies
% BLS-GSM technique to the noisy image to estimate the image.
% Estimated images are inside the root folder in a folder named BLS-GSM_025.
% Note that input images names are of format headername_0000.ext

%% read parameteres
clc;
clear all;

%Load path
dir =pwd;
addpath([dir '/denoising_subprograms']);
addpath([dir '/Added_PyrTools']);
addpath([dir '/Simoncelli_PyrTools']);
addpath([dir 'rwt-master/bin']);
addpath([dir '/matlabPyrTools-master']);

%Load Parameter File
paramFile = 'method_params.txt';
fid = fopen(paramFile);
params = textscan(fid, '%[^= ]%*[= ]%s', 'CommentStyle', '%');
fclose(fid);

rootFolder = params{2}(strcmp(params{1},'rootFolder')); rootFolder = rootFolder{1};
inputFolder = params{2}(strcmp(params{1},'inputFolder')); inputFolder = inputFolder{1};
imageHeader = params{2}(strcmp(params{1},'imageHeader')); imageHeader = imageHeader{1};

inputFolder_Ref = params{2}(strcmp(params{1},'inputFolder_Ref')); inputFolder_Ref = inputFolder_Ref{1};
imageHeader_Ref = params{2}(strcmp(params{1},'imageHeader_Ref')); imageHeader_Ref = imageHeader_Ref{1};


imageExt = params{2}(strcmp(params{1},'imageExt')); imageExt = imageExt{1};

startNum = params{2}(strcmp(params{1},'startNum')); startNum = startNum{1};
endNum = params{2}(strcmp(params{1},'endNum')); endNum = endNum{1};
sigma = params{2}(strcmp(params{1},'sigma')); sigma = sigma{1}; sigmaDouble = str2double(sigma);
outputFolder = params{2}(strcmp(params{1},'outputFolder')); outputFolder = outputFolder{1};
%outputFolder = [rootFolder, '/BLS-GSM', sigma];
mkdir(outputFolder)

%% Read/convet input noisy image and estimates the the original image using BM3D Technique

numImages = str2double(endNum) - str2double(startNum) + 1;

% read noisy image
for i = 1:numImages
    imageNum = sprintf('%04d',i-1);
    imageAddress = [rootFolder, inputFolder, '/', imageHeader, '_', imageNum, '.', imageExt];
    imageAddress_Ref = [rootFolder, inputFolder_Ref, '/', imageHeader_Ref, '_', imageNum, '.', imageExt];
    im_noisy= double(imread(imageAddress));
    im_clean=double(imread(imageAddress_Ref));
    [Ny,Nx] = size(im_noisy);
    PS = ones(size(im_noisy));	% power spectral density (in this case, flat, i.e., white noise)
    seed=0;
    % Pyramidal representation parameters
    Nsc = ceil(log2(min(Ny,Nx)) - 4);  % Number of scales (adapted to the image size)
    Nor = 3;				            % Number of orientations (for X-Y separable wavelets it can only be 3)
    repres1 = 'uw';                     % Type of pyramid (shift-invariant version of an orthogonal wavelet, in this case)
    repres2 = 'daub1';                  % Type of wavelet (daubechies wavelet, order 2N, for 'daubN'; in this case, 'Haar')
    
    % Model parameters (optimized: do not change them unless you are an advanced user with a deep understanding of the theory)
    blSize = [3 3];	    % n x n coefficient neighborhood of spatial neighbors within the same subband
    % (n must be odd):
    parent = 0;			% including or not (1/0) in the neighborhood a coefficient from the same spatial location
    % and orientation as the central coefficient of the n x n neighborhood, but
    % next coarser scale. Many times helps, but not always.
    boundary = 1;		% Boundary mirror extension, to avoid boundary artifacts
    covariance = 1;     % Full covariance matrix (1) or only diagonal elements (0).
    optim = 1;          % Bayes Least Squares solution (1), or MAP-Wiener solution in two steps (0)
    
    % Uncomment the following 4 code lines for reproducing the results of our IEEE Trans. on Im. Proc., Nov. 2003 paper
    % This configuration is slower than the previous one, but it gives slightly better results (SNR)
    % on average for the test images "lena", "barbara", and "boats" used in the cited article.
    
    Nor = 8;                           % 8 orientations
    repres1 = 'fs';                    % Full Steerable Pyramid, 5 scales for 512x512
    repres2 = '';                      % Dummy parameter when using repres1 = 'fs'
    parent = 1;                        % Include a parent in the neighborhood
    
    
    
    % % and show it on the screen
    % figure(2)
    % showIm(im,rang);title(['Degraded image, \sigma^2 =', num2str(sig^2)])
    
    % Call the denoising function
    tic;
    im_denoised = denoi_BLS_GSM(im_noisy, sigmaDouble, PS, blSize, parent, boundary, Nsc, Nor, covariance, optim, repres1, repres2, seed); toc
    
    
    
%     %get PSNR values
%     psnr_noisy = getPSNR(im_noisy, im_clean, 255);
%     psnr_denoised = getPSNR(im_denoised, im_clean, 255);
%     fprintf('PSNRs: noisy: %.2fdB, denoised: %.2fdB\n',psnr_noisy,psnr_denoised);
    
    % save the image
    BLS_GSM_result_Address= [outputFolder, '/',imageHeader,'_BLS-GSM', sigma, '_', imageNum, '.png'];
    imwrite(im_denoised/255, BLS_GSM_result_Address)
    
end
