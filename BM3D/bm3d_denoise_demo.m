%% BM3D: Estimate image using BM3D technique from a noisy Image
% Author: Jaimeet Patel
% Email : jpatel99@hawk.iit.edu
% Date  : 08/17/2016
% Description: This program takes a parameter file as the input. The
% parameter file specifies the folder, the header name of the input
% images, the start and end number of images, and the value of sigma
% (std of noise). The input images must be grayscale. The program applies
% BM3D technique to the noisy image to estimate the image.
% Estimated images are inside the root folder in a folder named BM3D025.
% Note that input images names are of format headername_0000.ext


clc;
clear all;
close all;
paramFile = 'method_params.txt';
fid = fopen(paramFile);
params = textscan(fid, '%[^= ]%*[= ]%s', 'CommentStyle', '%');
fclose(fid);

rootFolder = params{2}(strcmp(params{1},'rootFolder')); rootFolder = rootFolder{1};
inputFolder = params{2}(strcmp(params{1},'inputFolder')); inputFolder = inputFolder{1};
imageHeader = params{2}(strcmp(params{1},'imageHeader')); imageHeader = imageHeader{1};
imageExt = params{2}(strcmp(params{1},'imageExt')); imageExt = imageExt{1};
startNum = params{2}(strcmp(params{1},'startNum')); startNum = startNum{1};
endNum = params{2}(strcmp(params{1},'endNum')); endNum = endNum{1};
sigma = params{2}(strcmp(params{1},'sigma')); sigma = sigma{1}; sigmaDouble = str2double(sigma);
outputFolder = params{2}(strcmp(params{1},'outputFolder')); outputFolder = outputFolder{1};

outputFolder = [rootFolder, '/BM3D', sigma];
mkdir(outputFolder)

%% Read/convet input noisy image and estimates the the original image using BM3D Technique

numImages = str2double(endNum) - str2double(startNum) + 1;
step1_time=zeros(1,numImages);
step2_time=zeros(1,numImages);
% read noisy image
for i = 1:numImages
    
    % read one image
    imageNum = sprintf('%04d',i-1);
    imageAddress = [rootFolder, inputFolder, '/', imageHeader, '_', imageNum, '.', imageExt];
    inputImage = mat2gray(imread(imageAddress));
    if length(size(inputImage)) > 2
        inputImage = inputImage(:,:,1);
    end
    
    
    % BM3D funtion to estimate the original image from the noisy image.
    [y_est,y_hat,a,b] = BM3D(1, inputImage, sigma);
    step1_time(i)=a;
    step2_time(i)=b;
    BM3D_step_1_result =y_hat;
    BM3D_result =y_est;
    
    
   
    % save the image
    BM3D_result_Address= [outputFolder, '/',imageHeader,'_BM3D', sigma, '_', imageNum, '.png'];
    imwrite(BM3D_result, BM3D_result_Address);
    
end
avg_step_1_time=mean(a);
avg_step_2_time=mean(b);



