%Runs UI application where user:
% - selects images (of same dimension)
% - identifies non-forest objects using masking
% - identifies deforested areas using masking
% - is shown change in deforestation over years

%to do:
%sliders for thresholds
%handle differently sized images
%add title to each figure
%add surface area capability
clc;	
clear;
close all;	
imtool close all;	

%from MATLAB
if(~isdeployed)
	cd(fileparts(which(mfilename))); 
end

% check if user has  IPT installed. (From MATLAB)
hasIPT = license("test", "image_toolbox");
if ~hasIPT
	
	message = sprintf("You do not seem to have the Image Processing Toolbox.\nDo you want to continue?");
	reply = questdlg(message, "Toolbox missing", "Yes", "No", "Yes");
	if strcmpi(reply, "No")
		return;
	end
end


close all;
fontSize = 16;
gcf = figure;
set(gcf, "units","normalized","outerposition",[0 0 1 1]); %maximize figure

if(~isdeployed) % (?) necessary?
	cd(fileparts(which(mfilename)));
end

message = sprintf("First, choose images (of the same size) in chronological order for deforestation quantifictation");
reply = questdlg(message, "Continue?", "Continue", "Cancel", "Continue");
if strcmpi(reply, "Cancel")
    return;
end

% Let user pick their images 
cd(pwd); 
% Browse for the image file. 
[baseFileNames, folder] = uigetfile("*.*", "Specify satellite images (in chronological order)", "MultiSelect", "on"); %(?) only one file for now
numImages = length(baseFileNames); %number of images
if ischar(baseFileNames)
    numImages = 1;
end
fullImageFileNames = strings(numImages, 1);

%check to see if need to index file names
if (numImages > 1)
    for i = 1:numImages     
        fullImageFileNames(i) = fullfile(folder, baseFileNames(i)); 
        %check to see if file exists
        if ~exist(fullImageFileNames(i), "file")
            message = sprintf("This file does not exist:\n%s", fullImageFileNames(i));
            uiwait(msgbox(message));
            return; % (?) does this exit function if main file is not function
        end
    end   
else %if only one file chosen
    fullImageFileNames = fullfile(folder, baseFileNames); 
    if ~exist(fullImageFileNames, "file")
        message = sprintf("This file does not exist:\n%s", fullImageFileNames);
        uiwait(msgbox(message));
        return; % (?) does this exit function if main file is not function
    end
end



% Read in images into an array.
if numImages>1
    image1 = imread(fullImageFileNames(1));
    dim = size(image1); M = dim(1); N = dim(2);
    rgbImages = zeros(numImages ,M, N, 3);
    rgbImages(1,:,:,:) = image1; 
    %if more than one image, add to list
    for i = 2:numImages
        rgbImages(i,:,:,:) = imread(fullImageFileNames(i));
    end
    rgbImages = uint8(rgbImages);% (?) better way to cast to uint8
else
    image1 = imread(fullImageFileNames);
    dim = size(image1); M = dim(1); N = dim(2);
    rgbImages = zeros(numImages ,M, N, 3);
    rgbImages(1,:,:,:) = image1;
    rgbImages = uint8(rgbImages);
end

%masks = uint8(zeros(numImages, M, N));



%check if object detection necessary
objectMasks = uint8(zeros(numImages, M, N)); %remains 0 if object detection not necessary

message = sprintf("Does your image contain non-forest objects (such as rivers, towns, or text)?"); %(?) change text?
reply = questdlg(message, "Object detection required?", "Yes", "No", "No");
if strcmpi(reply, "Yes")

    %begin object detection
    message = sprintf("We will use HSV imagery to detect these non-forest objects"); %(?) change text?
	    reply = questdlg(message, "Continue?", "Continue", "Cancel", "Continue");
    if strcmpi(reply, "Cancel")
        return;
    end
    
    %instantiate user reply
    reuseReply = ""; %yes if user is reusing same thresholds as previous image
    objectMasks = uint8(zeros(numImages, M, N));
    %objectHSVMasks = uint8(zeros(numImages, M, N, 3)); %store masks for HSV separately
    %find threshold values and masks for identifying objects in each image
    for i = 1:numImages
        message = sprintf("Let's detect non-forest objects in image %d", i); % (?) change text?
	        reply = questdlg(message, "Continue?", "Continue", "Cancel", "Continue");
        if strcmpi(reply, "Cancel")
            return;
        end
        maskNum = 1;
        
        adequateReply = ""; %yes if one threshold is adequate
        newMaskReply = ""; %no if user is done finding thresholds for image
        %loop until threshold is adequate and all thresholds found
        while ~strcmpi(adequateReply, "Yes")|| strcmpi(newMaskReply, "Yes")
           %display H, S, and V images and histograms
    
            % Display the original image
            subplot(3, 4, 1);
            hRGB = imshow(squeeze(rgbImages(i,:,:,:)));
            % Set up an infor panel so you can mouse around and inspect the value values.
            hrgbPI = impixelinfo(hRGB);
            title("RGB Image", "FontSize", fontSize)
            set(hrgbPI, "Units", "Normalized", "Position",[.15 .69 .15 .02]);
            drawnow; % Make it display immediately. 
            
        
            % Convert RGB image to HSV
            hsvImage = rgb2hsv(squeeze(rgbImages(i,:,:,:)));
            % Extract out the H, S, and V images individually
            hImage = hsvImage(:,:,1);
            sImage = hsvImage(:,:,2);
            vImage = hsvImage(:,:,3);
            
            % Display the hue image.
            subplot(3, 4, 2);
            h1 = imshow(hImage);
            title("Hue Image", "FontSize", fontSize);
            % Set up an infor panel
            hHuePI = impixelinfo(h1);
            set(hHuePI, "Units", "Normalized", "Position",[.34 .69 .15 .02]);
            
            % Display the saturation image.
            h2 = subplot(3, 4, 3);
            imshow(sImage);
            title("Saturation Image", "FontSize", fontSize);
            % Set up an infor panel 
            hSatPI = impixelinfo(h2);
            set(hSatPI, "Units", "Normalized", "Position",[.54 .69 .15 .02]);
            
            % Display the value image.
            h3 = subplot(3, 4, 4);
            imshow(vImage);
            title("Value Image", "FontSize", fontSize);
            % Set up an infor panel 
            hValuePI = impixelinfo(h3);
            set(hValuePI, "Units", "Normalized", "Position",[.75 .69 .15 .02]);
        
        
            % Compute and plot the histogram of the "hue" band.
            hHuePlot = subplot(3, 4, 6); 
            [hueCounts, hueBinValues] = imhist(hImage); 
            maxCountHue = max(hueCounts); 
            area(hueBinValues, hueCounts, "FaceColor", "r"); 
            grid on; 
            xlabel("Hue"); 
            ylabel("Pixel Count"); 
            title("Histogram of Hue Image", "FontSize", fontSize);
        
            % Compute and plot the histogram of the "saturation" band.
            hSaturationPlot = subplot(3, 4, 7); 
            [saturationCounts, saturationBinValues] = imhist(sImage); 
            maxCountSaturation = max(saturationCounts); 
            area(saturationBinValues, saturationCounts, "FaceColor", "g"); 
            grid on; 
            xlabel("Saturation"); 
            ylabel("Pixel Count"); 
            title("Histogram of Saturation Image", "FontSize", fontSize);
        
            % Compute and plot the histogram of the "value" band.
            hValuePlot = subplot(3, 4, 8); 
            [valueCounts, valueBinValues] = imhist(vImage); 
            maxCountValue = max(valueCounts); 
            area(valueBinValues, valueCounts, "FaceColor", "b"); 
            grid on; 
            xlabel("Value"); 
            ylabel("Pixel Count"); 
            title("Histogram of Value Image", "FontSize", fontSize);
        
            % make all axes the same height
            maxCount = max([maxCountHue,  maxCountSaturation, maxCountValue]); 
            axis([hHuePlot hSaturationPlot hValuePlot], [0 1 0 maxCount]); 
        
            % Plot all 3 histograms in one plot.
            subplot(3, 4, 5); 
            plot(hueBinValues, hueCounts, "r", "LineWidth", 2); 
            grid on; 
            xlabel("Values"); 
            ylabel("Pixel Count"); 
            hold on; 
            plot(saturationBinValues, saturationCounts, "g", "LineWidth", 2); 
            plot(valueBinValues, valueCounts, "b", "LineWidth", 2); 
            title("Histogram of All Bands", "FontSize", fontSize); 
            % Make x-axis to just the max gray level on the bright end. 
            xlim([0 1]); 
    
            %if user is doing is repeating mask
            if strcmp(adequateReply, "No")
                message = sprintf("Repeating mask %d for image %d", maskNum, i);
                reply = questdlg(message, "Continue?", "Continue", "Cancel", "Continue");
                if strcmpi(reply, "Cancel")
                    return;
                end
            end
            %if user is doing new mask
            if strcmp(newMaskReply, "Yes")
                message = sprintf("Starting mask %d for image %d", maskNum, i);
                reply = questdlg(message, "Continue?", "Continue", "Cancel", "Continue");
                if strcmpi(reply, "Cancel")
                    return;
                end
            end
            %if user did not want to reuse the same threshold values as before
            if ~strcmp(reuseReply, "Reuse")
                message = sprintf("Enter the threshold values for the desired object in image %d using the black and white images\n(Hint: place your mouse on image to determine pixel values)", i);
	                reply = questdlg(message, "Continue?", "Continue", "Cancel", "Continue");
                if strcmpi(reply, "Cancel")
                    return;
                end
    
                opts.WindowStyle = "normal"; 
                hueLowBound = sscanf(cell2mat(inputdlg("Lower bound for hue:","Hue low bound", 1, {'0'}, opts)), "%f");
                hueUpBound = sscanf(cell2mat(inputdlg("Upper bound for hue:","Hue up bound", 1, {'1'}, opts)), "%f");
              
                PlaceThresholdBars(6, hueLowBound, hueUpBound);
    
                saturationLowBound = sscanf(cell2mat(inputdlg("Lower bound for saturation:","Saturation low bound", 1, {'0'}, opts)), "%f");
                saturationUpBound = sscanf(cell2mat(inputdlg("Upper bound for saturation:","Saturation up bound", 1, {'1'}, opts)), "%f");
              
                PlaceThresholdBars(7, saturationLowBound, saturationUpBound);
        
                valueLowBound = sscanf(cell2mat(inputdlg("Lower bound for value:","Value low bound", 1, {'0'}, opts)), "%f");
                valueUpBound = sscanf(cell2mat(inputdlg("Upper bound for value:","Value up bound", 1, {'1'}, opts)), "%f");
              
                PlaceThresholdBars(8, valueLowBound, valueUpBound);
            %reusing same thresholds as before
            else 
                message = sprintf("Reusing threshold values from previous image...");
                reply = questdlg(message, "Continue?", "Continue", "Cancel", "Continue");
                if strcmpi(reply, "Cancel")
                    return;
                end
                PlaceThresholdBars(6, hueLowBound, hueUpBound);
                PlaceThresholdBars(7, saturationLowBound, saturationUpBound);
                PlaceThresholdBars(8, valueLowBound, valueUpBound);
            end
    
        
            %apply masks by filtering each H, S, V
            hueMask = (hImage >= hueLowBound) & (hImage <= hueUpBound);
            saturationMask = (sImage >= saturationLowBound) & (sImage <= saturationUpBound);
            valueMask = (vImage >= valueLowBound) & (vImage <= valueUpBound);
            
            %show masked H S and V images separately
            fontSize = 16;
            subplot(3, 4, 10);
            imshow(hueMask, [0 1]);
            title("Hue Mask", "FontSize", fontSize);
            subplot(3, 4, 11);
            imshow(saturationMask, [0 1]);
            title("Saturation Mask", "FontSize", fontSize);
            subplot(3, 4, 12);
            imshow(valueMask, [0 1]);
            title("Value Mask", "FontSize", fontSize);
    
            %show masked image
            maskedImage = uint8(hueMask & saturationMask & valueMask); %masked BW image
            subplot(3, 4, 9);
            imshow(maskedImage, []);
            caption = sprintf("Masked image");
            title(caption, "FontSize", fontSize);
            message = sprintf("Now let's see the image with the masking applied");
            reply = questdlg(message, "Continue?", "Continue", "Cancel", "Continue");
            if strcmpi(reply, "Cancel")
                return;
            end
    
            %apply masking
            currentMaskedRGBImage(:,:, 1) = uint8(maskedImage(:,:)==0) .* squeeze(rgbImages(i,:,:,1));
            currentMaskedRGBImage(:,:,2) = uint8(maskedImage(:,:)==0) .* squeeze(rgbImages(i,:,:,2));
            currentMaskedRGBImage(:,:,3) = uint8(maskedImage(:,:)==0) .* squeeze(rgbImages(i,:,:,3));
            
          
            clf; %clear figure
            
            imshow(currentMaskedRGBImage)
            set(gcf, "units","normalized","outerposition",[0 0 1 1]); %maximize
    
            adequateReply = questdlg("Adequate threshold values?", "Check values","Yes", "No", "Yes");
            if strcmp(adequateReply, "No")
                reuseReply = "No"; %mask not to be reused (because not moving on yet)
                clf;
                set(gcf, "units","normalized","outerposition",[0 0 1 1]); 
    
           
            else
                %display threshold values
               disp(strcat("Object ", num2str(maskNum), " "," threshold values for image ", " ",num2str(i), ":"))
               disp(strcat("Hue values from ", num2str(hueLowBound), " to ", num2str(hueUpBound)))
               disp(strcat("Saturation values from ", num2str(saturationLowBound), " to ",num2str(saturationUpBound)))
               disp(strcat("Value values from ", num2str(valueLowBound), " "," to ", num2str(valueUpBound)))
               disp(" ") %print line
               objectMasks(i, :, :) = squeeze(objectMasks(i, :, :))+maskedImage; %add mask to running mask array (1"s are elements to ignore in mask)
    
    
               newMaskReply = questdlg("Create new mask on same image to detect different object?", "Repeat mask","Yes", "No", "Yes");
               if strcmp(newMaskReply, "Yes")
                   reuseReply = "No";%mask not to be reused (because not moving on yet)
                   clf; %clear figure
                   set(gcf, "units","normalized","outerposition",[0 0 1 1]); %maximize
    
                   maskNum = maskNum+1;
    
               end
            end
    
        end
      
        %when masking done for objects, construct final masked image
        objectMaskedRGBImages(i, :, :, 1) = uint8(squeeze(objectMasks(i,:,:))==0) .* squeeze(rgbImages(i,:,:,1));
        objectMaskedRGBImages(i, :, :, 2) = uint8(squeeze(objectMasks(i,:,:))==0) .* squeeze(rgbImages(i,:,:,2));
        objectMaskedRGBImages(i, :, :, 3) = uint8(squeeze(objectMasks(i,:,:))==0) .* squeeze(rgbImages(i,:,:,3));
        if i~=numImages
            reuseReply = questdlg("Repeat mask with same threshold values for next image?", "Reuse threshold values?","Reuse", "Get new thresholds", "Reuse");
            clf; 
	        set(gcf, "units","normalized","outerposition",[0 0 1 1]); 
        end
        
    
    end
    
    %show masked images with objects removed
    clf;
    set(gcf, "units","normalized","outerposition",[0 0 1 1]); 
    message = sprintf("Now we will show the satellite images with the identified objects turned black");
	    reply = questdlg(message, "Continue?", "Continue", "Cancel", "Continue");
    if strcmpi(reply, "Cancel")
        return;
    end
    for i = 1:numImages
        
        subplot(1, numImages, i)
        imshow(squeeze(objectMaskedRGBImages(i,:,:,:)))
    end
    set(gcf, "units","normalized","outerposition",[0 0 1 1]); 
    
    pause(1)
    
    message = sprintf("Now, we will repeat the masking process to identify areas of deforestation");
    reply = questdlg(message, "Continue?", "Continue", "Cancel", "Continue");
    if strcmpi(reply, "Cancel")
        return;
    end
    
end
    


clf;
set(gcf, "units","normalized","outerposition",[0 0 1 1]); 
finalMaskedRGBImages = zeros(size(rgbImages)); %masked color images
finalMasks = uint8(zeros(numImages, M, N)); %holds masked BW images
%find threshold values and masks for deforested areas in each image
reuseReply = "";
for i = 1:numImages
    message = sprintf("Let's identify deforested areas in image %d", i); % (?) change text?
    reply = questdlg(message, "Continue?", "Continue", "Cancel", "Continue");
    if strcmpi(reply, "Cancel")
        return;
    end
    maskNum = 1;
    
    %instantiate replys
    adequateReply = ""; %yes if one threshold is adequate
    %loop until threshold is adequate and all thresholds found
    while ~strcmpi(adequateReply, "Yes")
       %display H, S, and V images and histograms

        % Display the original image
        subplot(3, 4, 1);
        hRGB = imshow(squeeze(rgbImages(i,:,:,:)));
        % Set up an infor panel so you can mouse around and inspect the value values.
        hrgbPI = impixelinfo(hRGB);
        title("RGB Image", "FontSize", fontSize)
        set(hrgbPI, "Units", "Normalized", "Position",[.15 .69 .15 .02]);
        drawnow; % Make it display immediately. 
        
    
        % Convert RGB image to HSV
        hsvImage = rgb2hsv(squeeze(rgbImages(i,:,:,:)));
        % Extract out the H, S, and V images individually
        hImage = hsvImage(:,:,1);
        sImage = hsvImage(:,:,2);
        vImage = hsvImage(:,:,3);
        
        % Display the hue image.
        subplot(3, 4, 2);
        h1 = imshow(hImage);
        title("Hue Image", "FontSize", fontSize);
        % Set up an infor panel
        hHuePI = impixelinfo(h1);
        set(hHuePI, "Units", "Normalized", "Position",[.34 .69 .15 .02]);
        
        % Display the saturation image.
        h2 = subplot(3, 4, 3);
        imshow(sImage);
        title("Saturation Image", "FontSize", fontSize);
        % Set up an infor panel 
        hSatPI = impixelinfo(h2);
        set(hSatPI, "Units", "Normalized", "Position",[.54 .69 .15 .02]);
        
        % Display the value image.
        h3 = subplot(3, 4, 4);
        imshow(vImage);
        title("Value Image", "FontSize", fontSize);
        % Set up an infor panel 
        hValuePI = impixelinfo(h3);
        set(hValuePI, "Units", "Normalized", "Position",[.75 .69 .15 .02]);
    
    
        % Compute and plot the histogram of the "hue" band.
        hHuePlot = subplot(3, 4, 6); 
        [hueCounts, hueBinValues] = imhist(hImage); 
        maxCountHue = max(hueCounts); 
        area(hueBinValues, hueCounts, "FaceColor", "r"); 
        grid on; 
        xlabel("Hue"); 
        ylabel("Pixel Count"); 
        title("Histogram of Hue Image", "FontSize", fontSize);
    
        % Compute and plot the histogram of the "saturation" band.
        hSaturationPlot = subplot(3, 4, 7); 
        [saturationCounts, saturationBinValues] = imhist(sImage); 
        maxCountSaturation = max(saturationCounts); 
        area(saturationBinValues, saturationCounts, "FaceColor", "g"); 
        grid on; 
        xlabel("Saturation"); 
        ylabel("Pixel Count"); 
        title("Histogram of Saturation Image", "FontSize", fontSize);
    
        % Compute and plot the histogram of the "value" band.
        hValuePlot = subplot(3, 4, 8); 
        [valueCounts, valueBinValues] = imhist(vImage); 
        maxCountValue = max(valueCounts); 
        area(valueBinValues, valueCounts, "FaceColor", "b"); 
        grid on; 
        xlabel("Value"); 
        ylabel("Pixel Count"); 
        title("Histogram of Value Image", "FontSize", fontSize);
    
        %make axes the same height
        maxCount = max([maxCountHue,  maxCountSaturation, maxCountValue]); 
        axis([hHuePlot hSaturationPlot hValuePlot], [0 1 0 maxCount]); 
    
        % Plot all 3 histograms in one plot.
        subplot(3, 4, 5); 
        plot(hueBinValues, hueCounts, "r", "LineWidth", 2); 
        grid on; 
        xlabel("Values"); 
        ylabel("Pixel Count"); 
        hold on; 
        plot(saturationBinValues, saturationCounts, "g", "LineWidth", 2); 
        plot(valueBinValues, valueCounts, "b", "LineWidth", 2); 
        title("Histogram of All Bands", "FontSize", fontSize); 
        % Make x-axis to just the max gray level on the bright end. 
        xlim([0 1]); 

        %if user is doing is repeating mask
        if strcmp(adequateReply, "No")
            message = sprintf("Repeating deforestation mask for image %d", maskNum, i);
            reply = questdlg(message, "Continue?", "Continue", "Cancel", "Continue");
            if strcmpi(reply, "Cancel")
                return;
            end
        end
        
        %if user did not want to reuse the same threshold values as before
        if ~strcmp(reuseReply, "Reuse (recommended)")
            message = sprintf("Enter the threshold values for the deforested areas in image %d using the black and white images\n(Hint: place your mouse on image to determine pixel values)", i);
	            reply = questdlg(message, "Continue?", "Continue", "Cancel", "Continue");
            if strcmpi(reply, "Cancel")
                return;
            end

            opts.WindowStyle = "normal"; 
            hueLowBound = sscanf(cell2mat(inputdlg("Lower bound for hue:","Hue low bound", 1, {'0'}, opts)), "%f");
            hueUpBound = sscanf(cell2mat(inputdlg("Upper bound for hue:","Hue up bound", 1, {'1'}, opts)), "%f");
          
            PlaceThresholdBars(6, hueLowBound, hueUpBound);

            saturationLowBound = sscanf(cell2mat(inputdlg("Lower bound for saturation:","Saturation low bound", 1, {'0'}, opts)), "%f");
            saturationUpBound = sscanf(cell2mat(inputdlg("Upper bound for saturation:","Saturation up bound", 1, {'1'}, opts)), "%f");
          
            PlaceThresholdBars(7, saturationLowBound, saturationUpBound);
    
            valueLowBound = sscanf(cell2mat(inputdlg("Lower bound for value:","Value low bound", 1, {'0'}, opts)), "%f");
            valueUpBound = sscanf(cell2mat(inputdlg("Upper bound for value:","Value up bound", 1, {'1'}, opts)), "%f");
          
            PlaceThresholdBars(8, valueLowBound, valueUpBound);
        %reusing same thresholds as before
        else 
            message = sprintf("Reusing threshold values from previous image...");
            reply = questdlg(message, "Continue?", "Continue", "Cancel", "Continue");
            if strcmpi(reply, "Cancel")
                return;
            end
            PlaceThresholdBars(6, hueLowBound, hueUpBound);
            PlaceThresholdBars(7, saturationLowBound, saturationUpBound);
            PlaceThresholdBars(8, valueLowBound, valueUpBound);
        end

    
        %apply masks by filtering each H, S, V
        hueMask = (hImage >= hueLowBound) & (hImage <= hueUpBound);
        saturationMask = (sImage >= saturationLowBound) & (sImage <= saturationUpBound);
        valueMask = (vImage >= valueLowBound) & (vImage <= valueUpBound);

        %show masked H S and V images separately
        fontSize = 16;
        subplot(3, 4, 10);
        imshow(hueMask, [0 1]);
        title("Hue Mask", "FontSize", fontSize);
        subplot(3, 4, 11);
        imshow(saturationMask, [0 1]);
        title("Saturation Mask", "FontSize", fontSize);
        subplot(3, 4, 12);
        imshow(valueMask, [0 1]);
        title("Value Mask", "FontSize", fontSize);

        %show masked image
        maskedImage = uint8(hueMask & saturationMask & valueMask); %masked BW image
        subplot(3, 4, 9);
        imshow(maskedImage, []);
        caption = sprintf("Masked image");
        title(caption, "FontSize", fontSize);
        message = sprintf("Now let's see the image with thresholded areas turned black");
        reply = questdlg(message, "Continue?", "Continue", "Cancel", "Continue");
        if strcmpi(reply, "Cancel")
            return;
        end

        %apply masking
        currentMaskedRGBImage(:,:, 1) = uint8(maskedImage(:,:)==0) .* squeeze(rgbImages(i,:,:,1));
        currentMaskedRGBImage(:,:,2) = uint8(maskedImage(:,:)==0) .* squeeze(rgbImages(i,:,:,2));
        currentMaskedRGBImage(:,:,3) = uint8(maskedImage(:,:)==0) .* squeeze(rgbImages(i,:,:,3));
        
      
        clf; %clear figure
        
        imshow(currentMaskedRGBImage)%shows all pixels within thresholds as black (?) show identified objects as different color?
        set(gcf, "units","normalized","outerposition",[0 0 1 1]); %maximize

        adequateReply = questdlg("Adequate threshold values?", "Check values","Yes", "No", "Yes");
        if strcmp(adequateReply, "No")
            reuseReply = "No"; %mask not to be reused (because not moving on yet)
            clf; %clear figure
            set(gcf, "units","normalized","outerposition",[0 0 1 1]);    
        else
            %display saturation values in console
            disp(strcat("Deforestation threshold values for image ", num2str(i), ":"))
            disp(strcat("Hue values from ", num2str(hueLowBound), " to ", num2str(hueUpBound)))
            disp(strcat("Saturation values from ", num2str(saturationLowBound), " to ", num2str(saturationUpBound)))
            disp(strcat("Value values from ", num2str(valueLowBound), " "," to ", num2str(valueUpBound)))
            disp(" ")
            finalMasks(i, :, :) = squeeze(finalMasks(i, :, :))+uint8(maskedImage); %add mask to running mask array (1"s are elements to ignore in mask)
        end

    end
  
    finalMasks(i,:,:) = squeeze(finalMasks(i,:,:)).*uint8(squeeze(objectMasks(i,:,:))==0); %change pixels that are objects to black
    notObjectAndIsDeforested = uint8(squeeze(finalMasks(i,:,:))==0); %set white elements in final mask to 0
    
    %set indices that are not an object and are deforested to 0 in RGBs
    finalMaskedRGBImages(i, :, :, 1) = uint8(notObjectAndIsDeforested) .* squeeze(rgbImages(i,:,:,1));
    finalMaskedRGBImages(i, :, :, 2) = uint8(notObjectAndIsDeforested) .* squeeze(rgbImages(i,:,:,2));
    finalMaskedRGBImages(i, :, :, 3) = uint8(notObjectAndIsDeforested) .* squeeze(rgbImages(i,:,:,3));
    finalMaskedRGBImages = uint8(finalMaskedRGBImages);

    
    if i~=numImages
        reuseReply = questdlg("Repeat mask with same threshold values for next image?", "Reuse threshold values?","Reuse (recommended)", "Get new thresholds", "Reuse (recommended)");
        clf; 
	    set(gcf, "units","normalized","outerposition",[0 0 1 1]); 
    end
   
end


%show masked images with objects removed
clf;
set(gcf, "units","normalized","outerposition",[0 0 1 1]); 
message = sprintf("Now we will show the satellite images with deforested areas in black (excluding any previously identified objects)");
reply = questdlg(message, "Continue?", "Continue", "Cancel", "Continue");
if strcmpi(reply, "Cancel")
    return;
end
for i = 1:numImages
    
    subplot(2, numImages, i)
    imshow(squeeze(finalMaskedRGBImages(i,:,:,:)))
end

set(gcf, "units","normalized","outerposition",[0 0 1 1]); %maximize

%show bar graph of percent white
pause(1)
message = sprintf("Finally, let's see the change in percent deforestation in a bar graph");
	reply = questdlg(message, "Continue?", "Continue", "Cancel", "Continue");
if strcmpi(reply, "Cancel")
    return;
end
percentWhite = zeros(1, numImages);
percentObject = percentWhite;
xlabels = strings(1, numImages);
for i = 1:numImages
    idx = squeeze(objectMasks(i,:,:))==1; %indices that should be ignored
    percentObject(i) = nnz(idx)/(M*N); %get percentage of image that is detected object
    percentWhite(i) = getPercentWhite(squeeze(finalMasks(i,:,:)), idx);
    xlabels(i) = strcat("Image #", num2str(i));
end
subplot(2, numImages, (3*numImages+1)/2) %center bar graph
bar(1:numImages, percentWhite)
ylabel("% Deforestation")
xlabel("Image #")

disp(" ")
disp("Final percentages of deforestation:")
for i = 1:numImages
    disp(strcat("Image ", num2str(i), ": ",num2str(percentWhite(i)*100), "%"))
end

disp(" ")
disp("Final percentages of detectedObjects:")
for i = 1:numImages
    disp(strcat("Image ", num2str(i), ": ",num2str(percentObject(i)*100), "%"))
end
%---------------------------------------------------------------------------------------------------------------------------------

% Function to show the low and high threshold bars on the histogram plots.
% FROM author Image Analyst
% (https://www.mathworks.com/matlabcentral/fileexchange/28512-simplecolordetectionbyhue?s_tid=srchtitle)
function PlaceThresholdBars(plotNumber, lowThresh, highThresh)
try
	% Show the thresholds as vertical red bars on the histograms.
	subplot(3, 4, plotNumber); 
	hold on;
	yLimits = ylim;
	line([lowThresh, lowThresh], yLimits, "Color", "r", "LineWidth", 3);
	line([highThresh, highThresh], yLimits, "Color", "r", "LineWidth", 3);
	% Place a text label on the bar chart showing the threshold.
	fontSizeThresh = 14;
	annotationTextL = sprintf("%d", lowThresh);
	annotationTextH = sprintf("%d", highThresh);
	% For text(), the x and y need to be of the data class "double" so let"s cast both to double.
	text(double(lowThresh + 5), double(0.85 * yLimits(2)), annotationTextL, "FontSize", fontSizeThresh, "Color", [0 .5 0], "FontWeight", "Bold");
	text(double(highThresh + 5), double(0.85 * yLimits(2)), annotationTextH, "FontSize", fontSizeThresh, "Color", [0 .5 0], "FontWeight", "Bold");
	
catch ME
	errorMessage = sprintf("Error in function %s() at line %d.\n\nError Message:\n%s", ...
		ME.stack(1).name, ME.stack(1).line, ME.message);
	fprintf(1, "%s\n", errorMessage);
	uiwait(warndlg(errorMessage));
end
return; % from PlaceThresholdBars()
end


function [percentWhite] = getPercentWhite(MaskedImage, idxs)
%PERCENTWHITE returns array of percent of white in BW image 
%   takes:
%       masked image and (optional) indexes that should be ignored
%   returns:
%       percentage of white pixels (ignoring specified pixels)
    dim = size(MaskedImage); numImages = dim(1);
    percentWhite = zeros(1, numImages);

    if exist("idxs", "var") %if idxs to ignore are passed to method 
        numIgnore = nnz(idxs(:,:)); %num of elements to ignore (elements that are 1 from river)
            
        numWhite = nnz(MaskedImage(:,:));% # white pixels
        numTotal = numel(MaskedImage(:,:))-numIgnore; % # of total pixels, except those from first mask (river)
    
        percentWhite = numWhite / numTotal; %percent deforestation of each images

    else
        for i = 1:numImages
            
            numWhite = nnz(MaskedImage(:,:));% # white pixels
            numTotal = numel(MaskedImage(:,:)); % # of total pixels, except those from first mask (river)
        
            percentWhite = numWhite / numTotal; %percent deforestation of each images
        end
    end
end


	
