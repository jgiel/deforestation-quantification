function areaKmSq = getArea(I)
%takes image and returns area in km^2 (from Matlab)

% Area in pixels
props = regionprops("table",I,"Area");
areaPixels = sum(props.Area);

% Area in km^2
px2km = (51/20)^2;
areaKmSq = round(areaPixels*px2km);

