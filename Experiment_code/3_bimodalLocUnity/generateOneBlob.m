%This function takes the locations of centroids, VSinfo and ScreenInfo as inputs
%and generate a texture of clouds
function dotClouds = generateOneBlob(windowPtr,blob_coordinates,VSinfo,ScreenInfo)
    loc = round(blob_coordinates);
    %define where to draw the blob center - 0.5 box size in all directions
    %make that region brighter - define as VSinfo.Cloud
    VSinfo.transCanvas((loc(1)-floor(VSinfo.boxSize/2)):...
        (loc(1)+floor(VSinfo.boxSize/2)),(loc(2)-floor(VSinfo.boxSize/2)):...
        (loc(2)+floor(VSinfo.boxSize/2))) = VSinfo.Cloud;
    VSinfo.Screen_wBlob = VSinfo.blackBackground + VSinfo.transCanvas; 
    %reset the transCanvas
    VSinfo.transCanvas = zeros(ScreenInfo.xaxis,ScreenInfo.yaxis); 
    %Turn the matrix to texture
    dotClouds =  Screen('MakeTexture', windowPtr, VSinfo.Screen_wBlob,[],[],[],2);    
end
