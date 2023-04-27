# Deforestation Quantification

## Starting the application
After running the program, select satellite images of the same size to quanitify deforestation and you will be shown the image decomposed into its hue, saturation, and value.

## Identifying non-forest objects
You will be asked to choose threshold values for identifying each non-forest object in the hue, saturation, and value images. A pixel will only be identified if its values in the hue, saturation, and value images each fall within the respective range. To find pixel values in the HSV decomposition for the desired non-forest object, hover your mouse over the object and enter the range in which you think the pixel values of this object fall within. If the H, S, or V image does not contain relevant information about the object, enter a threshold of [0, 1] for that image. You will be shown the mask using your selected thresholds and you can decide whether this mask is is adequate or if you would like to select new thresholds. Repeat this process for each object in each image.

## Identifying deforested areas
Then, you will be asked to choose threshold values for deforested areas. Select these thresholds in the same way that you selected thresholds for the non-forest objects. Finally, you will be shown the quantification of deforestation in each satellite image that you provided. 
