clear all;
%% establish connection (arduino: sendStringMessage.ino)
arduino = serial("/dev/cu.usbmodemFD131",'BaudRate',115200);
fopen(arduino);
fprintf(arduino,'Hello from matlab\n');
fscanf(arduino);
fclose(arduino);
clear all;
%% arduino: sendSpeakeridxMatlab.ino
arduino = serial("/dev/cu.usbmodemFD131",'BaudRate',115200);
fopen(arduino);
fprintf(arduino,'%s',char(2)); 
fclose(arduino);
clear all;