clear;
%% establish connection
arduino = serial("/dev/cu.usbmodemFD131",'BaudRate',115200);
fopen(arduino);
fprintf(arduino,'Hello from matlab');
fscanf(arduino);
fclose(arduino);
clear;
%% play a random sound
arduino = serial("/dev/cu.usbmodemFD131",'BaudRate',115200);
fopen(arduino);
fprintf(arduino,'%s',char(111));
fclose(arduino);
clear;