    function code = habituation1
% habituation1   Code for the ViRMEn experiment habituation1.
%   code = habituation1   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.
% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT
% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)
vr.finalPathname = 'C:\Users\RajasethupathyLab\Documents\MATLAB\ViRMEn 2016-02-12\experiments';
%vr.pathname = 'C:\Users\tankadmin\Desktop\testlogs';
vr.filename = datestr(now,'THHMMSS');
exper = vr.exper; %#ok<NASGU> 
save([vr.filename '.mat'],'exper');

vr.habday=0;
vr.preexposure=0;
vr.trainday=2; %%% either 1 for T1, 2 for T2-T8

vr.reverseday=0;
vr.citricacid=1;
vr.oppositeconti=0;

vr.trackpupilday=0;
vr.Data=0;

vr.optocue=1;
vr.optorew=1;
vr.optorun=0;
vr.optoiti=0;

vr.precuethreshold=1;
vr.ititimer=0;
%% Start the DAQ acquisition
%intialize
devices = daq.getDevices;
vr.jndaq = daq.createSession('ni');
addAnalogInputChannel(vr.jndaq,'Dev1',[0 1 2 3], 'Voltage'); %device object, device ID, channel numbers, measurement type (voltage)
vr.name= 'mTest'; %'b451RM';
vr.catname=strcat(vr.name,'_T8_8_07_2023_',vr.filename);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%set up camera!%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if vr.trackpupilday==1
% % %PUPIL CODE setup start:
NET.addAssembly('C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet\uc480DotNet.dll');
vr.pupildirectory='C:\Users\RajasethupathyLab\Desktop\Pupil Data\'
vr.pupildirectory= [vr.pupildirectory datestr(now,'mmddyyyy') '\']
vr.pupildirectoryimages=[vr.pupildirectory, datestr(now,'HHMMSS') '\']

mkdir(vr.pupildirectory)
% mkdir(vr.pupildirectoryimages)
vr.pupilfilename = [vr.pupildirectory, strcat(vr.name, '_Pupil_',vr.filename), '.bin']

% Camera object handle
vr.cam = uc480.Camera;
% Open camera
vr.cam.Init(0);
vr.cam.Display.Mode.Set(uc480.Defines.DisplayMode.DiB);
vr.cam.Trigger.Set(uc480.Defines.TriggerMode.Software);
vr.cam.PixelFormat.Set(uc480.Defines.ColorMode.Mono8);

% %Set PixelClock to Max
% [~,vr.Min, vr.Max, ~]=vr.cam.Timing.PixelClock.GetRange()
% vr.cam.Timing.PixelClock.Set(vr.Min);
% %Set FrameRate to Min
% [~,vr.Min, vr.Max, ~]=vr.cam.Timing.Framerate.GetFrameRateRange()
% vr.cam.Timing.Framerate.Set(vr.Min);
% % idk
[~,vr.MemId] = vr.cam.Memory.Allocate(true);
[~,vr.Width,vr.Height,vr.Bits,~] = vr.cam.Memory.Inquire(vr.MemId);
% Set Exposure to Max
[~,vr.Min, vr.Max, ~] =vr.cam.Timing.Exposure.GetRange()
vr.cam.Timing.Exposure.Set(vr.Max)

vr.cam.Acquisition.Freeze(uc480.Defines.DeviceParameter.Wait)
[~,vr.tmp] = vr.cam.Memory.CopyToArray(vr.MemId);
vr.Data = reshape(uint8(vr.tmp),[vr.Width,vr.Height]);
vr.Data=imrotate(vr.Data,-90);
vr.Data=flipdim(vr.Data,2);
vr.Data = squeeze(vr.Data);
imwrite(vr.Data,'firstimg.tiff');
vr.roipic=imread('firstimg.tiff');
[vr.ROI,vr.x,vr.y]=roipoly(vr.roipic);
vr.x1=floor(min(vr.x));
vr.x2=ceil(max(vr.x));
vr.y1=floor(min(vr.y));
vr.y2=ceil(max(vr.y));

%set up AOI
vr.x1=roundn(vr.x1,1)-10;
vr.x2=roundn(vr.x2,1)+10;
vr.y1=roundn(vr.y1,1)-10;
vr.y2=roundn(vr.y2,1)+10;
[vr.x1 vr.x2 vr.y1 vr.y2]
vr.width=vr.x2-vr.x1;
vr.height=vr.y2-vr.y1;
if rem(vr.width,4)==2
    vr.width=vr.width+10;
end

[a,b,c]=vr.cam.Size.AOI.GetSizeRange
[a,lower_left_x,lower_left_y,w,h] = vr.cam.Size.AOI.Get;
% cam.Size.AOI.Set(x1,y1,1000,1000)
vr.cam.Size.AOI.Set(vr.x1,vr.y1,vr.width,vr.height);
[a,lower_left_x,lower_left_y,w,h] = vr.cam.Size.AOI.Get;

%Set PixelClock to Max
[a,MinPC, MaxPC, Inc]=vr.cam.Timing.PixelClock.GetRange()
% vr.cam.Timing.PixelClock.Set(5);
%Set FrameRate to Min
[a,MinFR, MaxFR, Inc]=vr.cam.Timing.Framerate.GetFrameRateRange()
vr.cam.Timing.Framerate.Set(23);
% Set Exposure to Max
[a,MinE, MaxE, Inc] =vr.cam.Timing.Exposure.GetRange()
vr.cam.Timing.Exposure.Set(44)


[a,vr.bFR]=vr.cam.Timing.Framerate.Get();
[a,vr.bPC]=vr.cam.Timing.PixelClock.Get();
[a,vr.bE]=vr.cam.Timing.Exposure.Get();

vr.fid_pupil= fopen(vr.pupilfilename,'w')
fwrite(vr.fid_pupil,vr.width,'double');
fwrite(vr.fid_pupil,vr.height,'double');
fwrite(vr.fid_pupil,vr.Bits,'double');



vr.cam.Acquisition.Capture(uc480.Defines.DeviceParameter.DontWait);
vr.countcapture=0;
end
vr.startrecordingpupil=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%F

vr.fid1 = fopen(strcat(vr.catname,'.bin'),'w');


%vr.fidJN = fopen('FfidJNlog.bin','w');



%listener must be called?
% creates a listener for the specified event, eventName, and fires an anonymous callback function.
% The anonymous function uses the specified input arguments and 
% executes the operation specified in the expression expr.
% Anonymous functions provide a quick means of creating 
% simple functions without storing them to a file.
%the @(src,event) is an anonymous fcn, logData is daqtoolbox demo function
vr.lh = addlistener(vr.jndaq,'DataAvailable',@(src, event)logData(src, event, vr.fid1));
%anonymous functios: perform single 
vr.jndaq.IsContinuous = true;
% vr.jndaq.Rate=1000;
vr.jndaq.startBackground;

%line 4 = room code (1=neutral) for arduino licks

%digital "session" is foreground
vr.jnDigitalSess = daq.createSession('ni');
addDigitalChannel(vr.jnDigitalSess,'dev1', 'Port0/Line0:7', 'OutputOnly'); %could pick individual line here..
addDigitalChannel(vr.jnDigitalSess,'dev1','Port1/Line0:2','OutputOnly');
%line 4 = room code (1=neutral) for arduino licks

%set to zeros
outputSingleScan(vr.jnDigitalSess,[0 0 0 0 0 0 0 0 0 0 0]);
vr.waterVal=0;
vr.sucroseVal=0;
vr.puffVal=0;

%vr.fid = fopen([vr.filename '.dat'],'w'); %maybe don't do this
% %% ARDUINO STUFF 
% %vr.a will be arduino with IO
% disp('opening arduino')
% vr.a=arduino('COM6','Uno');
% disp('arduino opened')


% vr.b is arduino for mouse motion function
% vr.b=arduino('COM4','Uno');


    vr.port='COM3';
    vr.s1=serial(vr.port);
    vr.s1.BaudRate=9600;
    disp('about to fopen vr.s1')
    fopen(vr.s1);
    disp('opened vr.st')

% % was .2x for first recording 7/25/2017
%  [vr.soundOnsetsRm1, vr.Y1] = createsound(4000,3,8,30);
%  vr.player(1) = audioplayer(vr.Y1,24000);
% % 
%  [vr.soundOnsetsRm2, vr.Y2] = createsound(4000,3,8,30);
%  vr.player(2) = audioplayer(vr.Y2,24000);
% % 
%  [vr.soundOnsetsRm3, vr.Y3] = createsound(4000,3,8,30);
%  vr.player(3) = audioplayer(vr.Y3,24000);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x=randi([1 2],1,200);
reroom=0;
feroom=0;
x(1)=2;
for i=1:numel(x)
if x(i)==1
reroom=reroom+1;
feroom=0;
end
if x(i)==2
    reroom=0;
    feroom=feroom+1;
end
if reroom==3
    x(i)=2;
    reroom=0;
    feroom=feroom+1;
end
if feroom==3
    x(i)=1;
    reroom=reroom+1;
    feroom=0;
end
end

vr.type=x;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YourVector=[ones(1,66) ones(1,134)+1];
% YourVector(randperm(length(YourVector)))
% vr.type=YourVector;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vr.movethresholdnum = 10;
vr.movethreshold = 1;
vr.transportto = 120;
vr.addtimereward=5;
vr.roombeginnings(1,1:360) = 20;
vr.rewardamount=0;
vr.rewardthreshold=7;
vr.fearamount=0;
vr.rewardthresholdadd=0;
vr.randroomnum=0;

vr.rooms = 100*randi([0 0],[1000,1]);
vr.rooms = vr.rooms + 20;
vr.roomnum = 0;



%vr.type(1:4)=1;
%vr.type(1:4)=2;
%vr.type(1:3)=1;
%vr.type(2:6)=2;
%probe trial input (retrieval)
% vr.swap=randperm(30,12)+10;
% for rp=vr.swap(1:6)
%     vr.type(rp)=3;
% end
% for fp=vr.swap(7:12)
%     vr.type(fp)=4;
% end

%make the puff times

    vr.engagetimer = zeros(400,1)' + 1.0;
    vr.contextstoptimer = zeros(400,1)' + 1.0;
    vr.ititimes = 3 + (5-3).* rand(1,400);
%     vr.ititimes = 6 + (8-6).* rand(1,400);
    vr.stopthreshold=2;
    vr.stopthreshold=2;
    
vr.puffnumber = 1;
vr.givepuff=0;
vr.pufftimer=0;
vr.rewardamount=0;
vr.dotraintransport=1;

vr.rewardmiss=0;
vr.fearmiss=0;
vr.rewardgot=0;
vr.feargot=0;

%%%%%%%setting thresholds for forced reward and fear trials
if vr.trainday==1
    vr.rewardamount=0;
    vr.rewardthreshold=5;
    vr.fearamount=0;
elseif vr.trainday==2
    vr.rewardamount=0;
    vr.rewardthreshold=3;
    vr.fearamount=1;
elseif vr.trainday==3
    vr.rewardamount=0;
    vr.rewardthreshold=0;
    vr.fearamount=1;
else
    vr.rewardamount=0;
    vr.rewardthreshold=0;
    vr.fearamount=1;
end

if vr.reverseday==1 && vr.oppositeconti==1
    vr.rewardamount=0;
    vr.rewardthreshold=3;
    vr.fearamount=1;
end


vr.visual=0;
vr.tone=0;
vr.olfactory=0;
vr.cuetypelist1=[randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6)];
vr.cuetypelist2=[randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6),randperm(6,6)];
vr.cuetypenumber1=1;
vr.cuetypenumber2=1;
vr.cuetype=1;
vr.dowatertime=1;
vr.itionce=1;
vr.docuetime=1;
vr.optoon=0;
vr.enterthecuezone=0;
vr.engagetimergo=1;
vr.startnewtrial=0;
vr.tones=[0 0 0];
vr.odors=[0 0 0];
vr.startrewardtimer=0;
vr.checkrewardtimer=0;
vr.waterVal=0;
vr.sucroseVal=0;
vr.puffVal=0;
vr.nothingVal=0;
vr.roomnumber1=0;
vr.roomnumber2=0;
vr.firststop=1;
vr.checkcuemovement=1;
vr.reward = [1 0];
vr.enterothercontext=0;
if  vr.oppositeconti==0
    vr.t=1;
else
    vr.t=2;
end
%tic
% vr.Td = []



%1 is for start signal
%2, 3, 4 for odor
%5 for water
%6 for sugar
%7 for 
%8, 9, 10 for tone

%below, call: outputSingleScan(vr.jndaq,[0 1]) to output value on lines
%above (line2,3 on port0)
%vr.jnDigitalSess.startForeground;



function vr = runtimeCodeFun(vr)
%disp(toc);
% vr.Td(end+1) = toc;
%tic;
vr.roomChange=0; %it will only be non-zero when a room change occurs in one of the conditional statements below
% vr.startrewardtime=0;
vr.startcuetime=0;

if isnan(vr.position(2)) && vr.iterations<500
    vr.position(2)=0;
    vr.iterations = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%do something at the beginning%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if vr.iterations<=20 
    vr.position(2)=20;
    vr.enterthecuezone=0;
    if vr.habday==1
    vr.position(2)=250;
    end
    if vr.timeElapsed==0
    vr.roomnum = 1;
    n = 1;
    vr.s = vr.timeElapsed;
    vr.e = 0;
    vr.counter = vr.timeElapsed;
    end
    vr.meanmovement=0;
else
    vr.meanmovement=mean(vr.velnum(end-vr.movethresholdnum:end));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%set the triggers%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if vr.iterations==50 || vr.iterations==5000 || vr.iterations==10000
    outputSingleScan(vr.jnDigitalSess,[1 0 0 0 vr.waterVal vr.sucroseVal 0 0 0 0 vr.optoon]); 
    %daq synchronization "trigger"
    %I think elements in the second argument are values to be sent on each of
    %the lines defined above
    vr.M(vr.iterations,3)=1;
    outputSingleScan(vr.jnDigitalSess,[0 0 0 0 vr.waterVal vr.sucroseVal 0 0 0 0 vr.optoon]);
    %PULSE SHOULD HAVE A CORRESPONDING VALUE SAVED IN VIRMEN
    %MAYBE A VR.PULSETIME VARIABLE, OUTPUT ON EVERY TELEPORT?
    if vr.trackpupilday==1
    vr.startrecordingpupil=1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%read out the speed of mice %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if vr.habday>1
out = fscanf(vr.s1);
out = strsplit(out,',');
try % AT: added this try catch to avoid crashing due to errors
out = -[str2double(out(1)),str2double(out(2))]; 
catch
    out = [0,0];
end
vr.velocity = [0 sum(out) 0 0];
if sum(out) < 0
    vr.velocity = [0 0 0 0];
end
vr.velnum(vr.iterations,1)=vr.velocity(2);
%disp(vr.velocity(2));
vr.timeinroom = vr.timeElapsed - vr.counter;



if vr.enterthecuezone==0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% if habday later than 1%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%make the ITI happen%%%%%
if vr.ititimer==1 && vr.itionce==1
    if vr.timeinroom<=vr.ititimes(vr.roomnum)
            vr.position(2)=0;
            vr.engagetimestamp=vr.timeElapsed;
    else
            vr.position(2)=20;
            vr.itionce=0;
    end
end
%%%check if animal has walked for the specific time indicated%%%%%
    if vr.position(2)>19 && vr.position(2)<140 
        if vr.meanmovement>=1 && vr.engagetimergo==1
            vr.engagetimestamp=vr.timeElapsed;
            vr.engagetimergo=0;
        elseif vr.meanmovement<1
            vr.engagetimergo=1;
            vr.engagetimestamp=vr.timeElapsed;
            vr.position(1)=0;
            vr.position(2)=20;
        end

        %%%startcuetimer if animal has walked for 1-2secs in start zone%%%%%
        if vr.timeElapsed>vr.engagetimestamp+vr.engagetimer(vr.roomnum)
            vr.engagezone=0;
            vr.enterthecuezone=1;
            vr.timeincuestarted=vr.timeElapsed;
            vr.newposition=1;
            vr.timetochange=1;
            vr.roomnumber1=1;
            vr.timestop=vr.timeElapsed;
            vr.firststop=1;
        end
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%cue zone%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if vr.enterthecuezone==1
    vr.docuetime=0;
    vr.tones=[0 0 0];
    vr.odors=[0 0 0];
    if vr.optocue==1 && vr.rewardamount>=vr.rewardthreshold %&& vr.timeElapsed<=vr.timeincuestarted+3 && vr.fearamount>0
        if vr.t==2 || vr.t==1
        vr.optoon=1;
        end
    else 
        vr.optoon=0;
    end
        disp('.............................................................visual')
        vr.visual=1;
            if vr.newposition==1
                if vr.t==1 | vr.t==3
%                     vr.position(2)=140;
%                     vr.position(1)=-20;       
                    vr.position(2)=20;
                   vr.position(1)=0;
                else
%                    vr.position(2)=140;
%                    vr.position(1)=20;       
                    vr.position(2)=20;
                   vr.position(1)=0;
                end
                vr.newposition=0;
            end
        
            if (vr.timeElapsed-vr.timeincuestarted)>0 && (vr.timeElapsed-vr.timeincuestarted)<0.5
                disp('.............................................................tone')
                vr.tone=1;
                disp('.............................................................olfactory')
                vr.olfactory=1;
                if vr.t==1 | vr.t==3
                    vr.tones=[1 0 0];
                    vr.odors=[1 0 0];
                   %outputSingleScan(vr.jnDigitalSess,[0 0 0 0 vr.waterVal vr.sucroseVal vr.puffVal 1 0 0 vr.optoon]); %outputSingleScan(vr.jnDigitalSess,[0 puff]); puff at 0 gives no puff, puff at 1 gives puff
                else
                    vr.tones=[0 0 1];
                    vr.odors=[0 0 1];
                    %outputSingleScan(vr.jnDigitalSess,[0 0 0 0 vr.waterVal vr.sucroseVal vr.puffVal 0 0 1 vr.optoon]); %outputSingleScan(vr.jnDigitalSess,[0 puff]); puff at 0 gives no puff, puff at 1 gives puff
                end
            end
            
            if (vr.timeElapsed-vr.timeincuestarted)>3
                vr.tone=0;
                vr.olfactory=0;
            end
    
            
    %%%check if stop happened in room %%%%%
    %%%check if no stop happened then start next trial%%%%%
    if vr.checkcuemovement==1
    if vr.meanmovement<=vr.stopthreshold 
        if vr.firststop==1
            vr.timestop=vr.timeElapsed;
            vr.firststop=0;
        else
        disp(strcat('----------------------------------------------------------------------------------timersincestop===',num2str(round(vr.timestop,1))))
        disp(strcat('----------------------------------------------------------------------------------timeElapsed===',num2str(round(vr.timeElapsed,1))))
        end
    else
    vr.timestop=vr.timeElapsed;
    vr.firststop=1;
    end
%%%give out reward if stop exceeds 2 seconds%%%%%
    if vr.timeElapsed>(vr.timestop+1) && vr.timeElapsed>vr.timeincuestarted+3
        vr.startrewardtimer=1;
        vr.checkrewardtimer=1;
        vr.rewardamount=vr.rewardamount+1;
        vr.checkcuemovement=0;
    end
    end
        %%%%decide how to end the trial by running%%%%
    if vr.timeElapsed>vr.timeincuestarted+3 && vr.meanmovement>(vr.stopthreshold) && vr.checkrewardtimer==0
        vr.startnewtrial=1;
        
        if vr.trainday>0 && vr.rewardamount>=vr.rewardthreshold
            if vr.t==1 
                vr.rewardmiss=vr.rewardmiss+1;
            elseif vr.t==2
                vr.fearmiss=vr.fearmiss+1;
            end
        elseif vr.reverseday>0 && vr.rewardamount>=vr.rewardthreshold
            if vr.t==1
                vr.fearmiss=vr.fearmiss+1;
            elseif vr.t==2
                vr.rewardmiss=vr.rewardmiss+1;
            end
        elseif vr.preexposure>0 && vr.rewardamount>=vr.rewardthreshold
            if vr.t==1 
                vr.rewardmiss=vr.rewardmiss+1;
            elseif vr.t==2
                vr.fearmiss=vr.fearmiss+1;
            end
        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%reward timer/second context timer%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if vr.enterothercontext==1
    vr.roomnum=vr.roomnum+1;
    if vr.roomnumber1==0
        vr.startnewtrial=1;
    end
    
    if vr.t==1
            vr.t=2;
            vr.enterothercontext=0;
            vr.engagezone=0;
            vr.enterthecuezone=1;
            vr.timeincuestarted=vr.timeElapsed;
            vr.newposition=1;
            vr.timetochange=1;
            vr.timestop=vr.timeElapsed;
            vr.firststop=1;
    elseif vr.t==2
            vr.t=1;
            vr.enterothercontext=0;
            vr.engagezone=0;
            vr.enterthecuezone=1;
            vr.timeincuestarted=vr.timeElapsed;
            vr.newposition=1;
            vr.timetochange=1;
            vr.timestop=vr.timeElapsed;
            vr.firststop=1;
    end
    
    if vr.rewardamount<vr.rewardthreshold && vr.oppositeconti==0
    vr.t = 1;
    elseif vr.rewardamount<vr.rewardthreshold && vr.oppositeconti==1
    vr.t = 2;
    elseif vr.rewardamount==vr.rewardthreshold && vr.fearamount==0 && vr.oppositeconti==0
    vr.t = 2;
    elseif vr.rewardamount==vr.rewardthreshold && vr.fearamount==0 && vr.oppositeconti==1
    vr.t = 1;
    end
    
end

if vr.checkrewardtimer==1
    
            %%%do the opto thing in reward
            if vr.optorew==1 && vr.rewardamount>=vr.rewardthreshold
            vr.optoon=1;
            end
            
            
    if vr.startrewardtimer==1 %&& vr.timeElapsed>vr.timeincuestarted+3
        vr.startrewardtimer=0;
        vr.startrewardtime=vr.timeElapsed;  
        vr.endrewardtime=vr.timeElapsed+3;  
        

    
        %%%%decide how to give out rewards%%%%
        if vr.trainday>0
            if vr.t==1
                vr.waterVal=1;
            elseif vr.t==2 && vr.citricacid==1
                vr.sucroseVal=1;
            end
        elseif vr.reverseday>0 
            if vr.t==1 && vr.citricacid==1
                vr.sucroseVal=1;
            elseif vr.t==2
                vr.waterVal=1;
            end
        elseif vr.preexposure>0
                vr.waterVal=1;
        end
        %%%%decide how to give out rewardfeargotmissed%%%%
        if vr.trainday>0 && vr.rewardamount>=vr.rewardthreshold
            if vr.t==1
                vr.rewardgot=vr.rewardgot+1;
            elseif vr.t==2
                vr.feargot=vr.feargot+1;
            end
        elseif vr.reverseday>0 && vr.rewardamount>=vr.rewardthreshold
            if vr.t==1
                vr.feargot=vr.feargot+1;
            elseif vr.t==2
                vr.rewardgot=vr.rewardgot+1;
            end
        elseif vr.preexposure>0 && vr.rewardamount>=vr.rewardthreshold
            if vr.t==1
                vr.rewardgot=vr.rewardgot+1;
            elseif vr.t==2
                vr.feargot=vr.feargot+1;
            end
        end

    end
    disp(strcat('------------------------------------------------------startrewardtime===',num2str(vr.startrewardtime)))
        
    if vr.startrewardtimer==0 && vr.timeElapsed>=vr.endrewardtime
        vr.startnewtrial=1;
    end
%     end
end

if vr.checkrewardtimer==1 && (vr.timeElapsed-vr.startrewardtime)>0 && (vr.timeElapsed-vr.startrewardtime)<0.5
                 disp('.............................................................tone')
                vr.tone=1;
                disp('.............................................................olfactory')
                vr.olfactory=1;
                if vr.t==1 | vr.t==3
                    vr.tones=[1 0 0];
                    vr.odors=[1 0 0];
                   %outputSingleScan(vr.jnDigitalSess,[0 0 0 0 vr.waterVal vr.sucroseVal vr.puffVal 1 0 0 vr.optoon]); %outputSingleScan(vr.jnDigitalSess,[0 puff]); puff at 0 gives no puff, puff at 1 gives puff
                else
                    vr.tones=[0 0 1];
                    vr.odors=[0 0 1];
                    %outputSingleScan(vr.jnDigitalSess,[0 0 0 0 vr.waterVal vr.sucroseVal vr.puffVal 0 0 1 vr.optoon]); %outputSingleScan(vr.jnDigitalSess,[0 puff]); puff at 0 gives no puff, puff at 1 gives puff
                end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%code to start a new trial%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if vr.startnewtrial==1
    
    vr.enterothercontext=0;
    vr.dowatertime=1;
    vr.docuetime=1;
    vr.e = vr.timeElapsed;
    vr.roomnum = vr.roomnum + 1;
    vr.itionce=1;
        if vr.ititimer==1
    vr.position(2) = 0;
    else
    vr.position(2) = 20;
        end
    vr.position(1) = 0;
    vr.roomChange=vr.t;
    vr.dotraintransport=1;
    

    if vr.rewardamount<vr.rewardthreshold && vr.oppositeconti==0
    vr.t = 1;
    elseif vr.rewardamount<vr.rewardthreshold && vr.oppositeconti==1
    vr.t = 2;
    elseif vr.rewardamount==vr.rewardthreshold && vr.fearamount==0 && vr.oppositeconti==0
    vr.t = 2;
    elseif vr.rewardamount==vr.rewardthreshold && vr.fearamount==0 && vr.oppositeconti==1
    vr.t = 1;
    else
        vr.randroomnum=vr.randroomnum+1;
        vr.t= vr.type(vr.randroomnum);
    end
                    
    
    vr.counter = vr.timeElapsed;
    vr.s = vr.timeElapsed;
    n = 1;
    vr.givepuff=1;
    vr.visual=0;
    vr.tone=0;
    vr.olfactory=0;
    vr.optoon=0;
    vr.waterVal=0;
    vr.sucroseVal=0;
    vr.puffVal=0;
    vr.nothingVal=0;
    vr.enterthecuezone=0;
    vr.roomnumber1=0;
    vr.roomnumber2=0;
    vr.startnewtrial=0;
    vr.startrewardtimer=0;
    vr.checkrewardtimer=0;
    vr.newposition=0;
    vr.engagetimergo=1;
    vr.checkcuemovement=1;
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%record pupil%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if vr.startrecordingpupil==1
    % [~,vr.MemId] = vr.cam.Memory.Allocate(true);
    % [~,vr.Width,vr.Height,vr.Bits,~] = vr.cam.Memory.Inquire(vr.MemId);
    vr.countcapture = vr.countcapture+1;
    [~,vr.tmp] = vr.cam.Memory.CopyToArray(vr.MemId);
    % reformat image
    vr.Data = reshape(uint8(vr.tmp),[vr.Width,vr.Height]);
    vr.Data=imrotate(vr.Data,-90);
    vr.Data=flipdim(vr.Data,2);
    vr.Data = squeeze(vr.Data);
    vr.ROIy = 1:vr.height;
    vr.ROIx = 1:vr.width;
    vr.Data = vr.Data(vr.ROIy,vr.ROIx);
    fwrite(vr.fid_pupil,vr.countcapture,'double');
    fwrite(vr.fid_pupil,vr.Data(:));
    
%imwrite(vr.Data,[vr.pupildirectoryimages, sprintf('%d.png',vr.countcapture)])

% disp(strcat('---------------------------------------------------------framerate===',num2str(vr.bFR)));
% disp(strcat('---------------------------------------------------------expo===',num2str(vr.bE)));
% disp(strcat('---------------------------------------------------------pixelcount===',num2str(vr.bPC)));
%vr.pupilarray(:,:,vr.countcapture)=vr.Data;
% display image
%  imshow(imadjust(vr.Data));
%  colormap gray
%  drawnow
end

% if vr.optorun==1 
%     if vr.meanmovement>=1
%         if vr.t==2 || vr.t==1
%     vr.optoon=1;
%         end
%     else
%         vr.optoon=0;
%     end
    if vr.enterthecuezone==1 && vr.optocue==1 && vr.rewardamount>=vr.rewardthreshold %&& vr.timeElapsed<=vr.timeincuestarted+3 && vr.fearamount>0
        if vr.t==2  || vr.t==1
        vr.optoon=1;
        end
    end
    
%     if vr.optoiti==1 && vr.enterthecuezone==0
%         if vr.timeElapsed<=vr.counter+5
%         if vr.t==2  || vr.t==1
%         vr.optoon=1;
%         end
%         else
%         vr.optoon=0;
%         end
%     else
%         vr.optoon=0;
%     end 
    
% end

outputSingleScan(vr.jnDigitalSess,[0 vr.odors(1) vr.odors(2) vr.odors(3) vr.waterVal vr.sucroseVal vr.puffVal vr.tones(1) vr.tones(2) vr.tones(3) vr.optoon]);

if vr.position(2)>80
    vr.position(2)=20;
end
% 
% if vr.puffVal==1
%     vr.fearamount=1;
% end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%display stuff%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(strcat('------------------------------------------------------rewardfeargotmissed===',num2str(vr.rewardgot),',',num2str(vr.rewardmiss),',',num2str(vr.feargot),',',num2str(vr.fearmiss)))
disp(strcat('---------------------------------------------------------------------movement===',num2str(vr.meanmovement)))
disp(vr.timeElapsed)
disp(strcat('-----------------------------------------------rewardamount===',num2str(vr.rewardamount)))    
disp(strcat('---------------------------------------------------------Yposition===',num2str(vr.position(2))))
disp(strcat('vr.t===',num2str(vr.t),'------------------------------------------'))
disp(strcat('vr.roomnum===',num2str(vr.roomnum),'------------------------------------------'))

vr.M(vr.iterations,1)=vr.timeElapsed(1);
vr.M(vr.iterations,2)=vr.timeinroom;
vr.M(vr.iterations,3)=vr.position(2);
vr.M(vr.iterations,4)=vr.position(1);
vr.M(vr.iterations,5)=vr.meanmovement;
vr.M(vr.iterations,6)=vr.visual;
vr.M(vr.iterations,7)=vr.tone;
vr.M(vr.iterations,8)=vr.olfactory;
vr.M(vr.iterations,9)=vr.waterVal;
vr.M(vr.iterations,10)=vr.sucroseVal;
vr.M(vr.iterations,11)=vr.puffVal;
vr.M(vr.iterations,12)=vr.cuetype;
vr.M(vr.iterations,13)=vr.t;
vr.M(vr.iterations,14)=vr.roomnum;
vr.M(vr.iterations,15)=vr.optoon;
vr.M(vr.iterations,16)=mean(mean(vr.Data));
%s is start e is end t is which stimulus (1,2,3 depending on room)
% M(6:8)=[vr.t,vr.s,vr.e];
%dlmwrite(vr.filename,M,'-append','delimiter',' ','precision',2);
% % % %dlmwrite('/Users/rajasethupathylab/Documents/MATLAB/results/stimdata.dat',[vr.t,vr.s,vr.e],'-append','precision',8);
%M=dlmread('vr.filename')
%tic;

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
% figure; subplot(1,2,1);plot(vr.Td);
% subplot(1,2,2); histogram(vr.Td(100:end),50);
% disp(median(vr.Td));
% disp(sum(vr.Td>0.03)/length(vr.Td))    

if vr.trackpupilday==1
fclose(vr.fid_pupil)
vr.cam.Acquisition.Stop(uc480.Defines.DeviceParameter.DontWait);
vr.cam.Exit;
end

outputSingleScan(vr.jnDigitalSess,[0 0 0 0 0 0 0 0 0 0 0]);
fclose(vr.s1)
delete(vr.s1)
clear vr.s1

%% DAQ termination
%vr.s.stop;
vr.jndaq.stop;
vr.jnDigitalSess.stop;
delete(vr.lh);
fclose(vr.fid1);
% fclose(vr.fidJN);

%to look at logged stuff:
% fid2 = fopen('logtest.bin','r');
% [data,count] = fread(fid2,[4,inf],'double');
% fclose(fid2);
% t = data(1,:);
% ch = data(2:4,:);
% plot(t, ch);

% fidJN2=fopen('fidJNlog.bin','r');
% [dats,counts]=fread(fidJN2,[5,inf],'double');
% fclose(fidJN2);

% vr.finalPathname = 'C:\Users\RajasethupathyLab\Documents\MATLAB\ViRMEn 2016-02-12\experiments';
%vr.pathname = 'C:\Users\tankadmin\Desktop\testlogs';
%vr.filename1 = strcat(vr.name,'_habituation',datestr(now,'yyyymmddTHHMMSS'));
vr.filename1 = vr.catname;
vr.filename2 = strcat(vr.filename1,'astim1.mat');
vr.filename3 = strcat(vr.filename1,'astim2.mat');
vr.filename4 = strcat(vr.filename1,'astim3.mat');
%exper = vr.exper; %#ok<NASGU>
exper=struct('M',vr.M);

% exper=struct('M',vr.M,'astim1',vr.Y1,'astim2',vr.Y2,'astim3',vr.Y3,...
%     'astim1Times',vr.soundOnsetsRm1,'astim2Times',vr.soundOnsetsRm2,'astim3Times',vr.soundOnsetsRm3);

save([vr.filename1 '.mat'],'exper');
% save([vr.filename1,'astim1.mat'],vr.Y1);
% save([vr.filename1,'astim2.mat'],vr.Y2);
% save([vr.filename1,'astim3.mat'],vr.Y3);
%vr.fid = fopen([vr.filename '.dat'],'w');

fclose all;
% fid = fopen([vr.filename '.dat']);
% data = fread(fid,'double');
% num = data(1);
% data = data(2:end);
% data = reshape(data,num,numel(data)/num);
% assignin('base','data',data);
% fclose all;
