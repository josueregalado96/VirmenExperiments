function [velocity,Type] = moveMouse1D(vr)
%%#ok<INUSD>
%port = '/dev/cu.usbmodem1421';

%%DOUBLE COMMENTED STUFF was moved to initializationCodeFun(vr) in
% % port = 'COM4';
% % s1 = serial(port);
% % s1.BaudRate = 9600;
% % fopen(s1)

out = fscanf(vr.s1);
out = strsplit(out,',');
% out = -[str2double(out(1)),str2double(out(2))]; %JN added negative 8.16.2017

try % AT: added this try catch to avoid crashing due to errors
out = -[str2double(out(1)),str2double(out(2))]; 
catch
    out = [0,0];
end

% % % % % % % % % disp('out below');
% % % % % % % % % disp(out);
% % % % % % % % % disp('velocity below'); 

%we need norm(out) to give negative values too
%displacement = [0 norm(out)/300 0 0]
%displacement = [0 norm(out)/100 0 0]; %this causes backwards actual motion
%to create forward visual motion
velocity = [0 sum(out)*1.5 0 0];%[0 sum(out)*1.7 0 0]; %[0 0 0 0] or [0 sum(out)*2 0 0];

%currently, positive numbers of out are from backward motion, and negative
%numbers are from forward motion. need to flip mouse or sign-flip these
%values, then test this function to see if the if statement below causes a
%problematic delay;

if sum(out) < 0
% % % % % % % % % %     disp('less than zero sum(out)');
    velocity = [0 0 0 0];
end
% % % % % 
% % % % % disp(velocity);



%displacement = [0 sum(out)/100 0 0]; %this causes backward to go visually forwards
%and forwards to present backwards visual motion
%displacement is [x,y,z,viewangle]
Type = 'v'; %Type = 'v' and Type = 'd' work with this configuration


    
% % fclose(s1)
% % delete(s1)
% % clear s1

end
