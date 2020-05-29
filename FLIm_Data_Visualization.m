function varargout = FLIm_Data_Visualization(varargin)
% FLIM_DATA_VISUALIZATION MATLAB code for FLIm_Data_Visualization.fig
%      FLIM_DATA_VISUALIZATION, by itself, creates a new FLIM_DATA_VISUALIZATION or raises the existing
%      singleton*.
%
%      H = FLIM_DATA_VISUALIZATION returns the handle to a new FLIM_DATA_VISUALIZATION or the handle to
%      the existing singleton*.
%
%%
%      FLIM_DATA_VISUALIZATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLIM_DATA_VISUALIZATION.M with the given input arguments.
%
%      FLIM_DATA_VISUALIZATION('Property','Value',...) creates a new FLIM_DATA_VISUALIZATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FLIm_Data_Visualization_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FLIm_Data_Visualization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FLIm_Data_Visualization

% Last Modified by GUIDE v2.5 06-Feb-2020 07:49:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FLIm_Data_Visualization_OpeningFcn, ...
    'gui_OutputFcn',  @FLIm_Data_Visualization_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% End initialization code - DO NOT EDIT

% --- Executes just before FLIm_Data_Visualization is made visible.
function FLIm_Data_Visualization_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FLIm_Data_Visualization (see VARARGIN)

% Choose default command line output for FLIm_Data_Visualization
handles.output=hObject;
handles.filename='';
handles.filename1='';
handles.filename2='';
handles.selpath='';
handles.str='';
handles.plot=0;
% Update handles structure
guidata(hObject, handles);
set(handles.axes1,'XTick',[])
set(handles.axes1,'YTick',[])
set(handles.axes2,'XTick',[])
set(handles.axes2,'YTick',[])
set(handles.axes3,'XTick',[])
set(handles.axes3,'YTick',[])


% UIWAIT makes FLIm_Data_Visualization wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = FLIm_Data_Visualization_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.idw1,'Enable','off')
set(handles.idw2,'Enable','off')
set(handles.idw3,'Enable','off')
set(handles.nni,'Enable','off')
set(handles.om,'Enable','off');
set(handles.IDWP,'Enable','off')
set(handles.P,'Enable','off')
set(handles.browseIMG,'Enable','off')
set(handles.browseMAT,'Enable','off')
set(handles.browseTXT,'Enable','off')
set(handles.ch1,'Enable','off')
set(handles.ch2,'Enable','off')
set(handles.ch3,'Enable','off')
set(handles.edit1,'Enable','off')
set(handles.snrchoice,'Enable','off')
set(handles.radius,'Enable','off')
set(handles.number,'Enable','off')
set(handles.from,'Enable','off')
set(handles.to,'Enable','off')
set(handles.jet,'Enable','off')
set(handles.hot,'Enable','off')
set(handles.CI,'Enable','off')

% path of the raw image and the mat file as well as the text file if apply
rawimage=handles.filename;
mat=handles.filename1;
txt=handles.filename2;

% choices of the map 
% LT: lifetime
% IR: Intensity Ratio
% INLT: Intensity Weighting Lifetime
% ORR: Optical Redox Ratio)
if (get(handles.LT,'Value') == get(handles.LT,'Max'))
    choice=1;
elseif (get(handles.IR,'Value') == get(handles.IR,'Max'))
    choice=2;
elseif (get(handles.INLT,'Value') == get(handles.INLT,'Max'))
    choice=3;
elseif (get(handles.ORR,'Value') == get(handles.ORR,'Max'))
    choice=4;
else
end

% determine if we include channel 4 or not
if (get(handles.inch4,'Value') == get(handles.inch4,'Max'))
    we_include_ch4 = 1;
else
    we_include_ch4 = 0;
end

% determine which kind of dataset we use
if get(handles.Bdata,'Value')==get(handles.Bdata,'Max')
    Data=2;
elseif  get(handles.HNdata,'Value')==get(handles.HNdata,'Max')
    Data=1;
elseif get(handles.Bdata_R,'Value')==get(handles.Bdata_R,'Max')
    Data=3;
elseif get(handles.Bdata_mat,'Value')==get(handles.Bdata_mat,'Max')
    Data=4;
end

% make the choice of dataset (Data) as a global variable
handles.Data=Data;

% if you fail to load the white-light image and/or the dataset, the error message will be display
if isempty(rawimage) || isempty(mat)
    handles.messagebox.String='Please Choose the File(s)';
elseif Data==4 && isempty(txt)
    handles.messagebox.String='Please Choose the Txt File';
    
% if you successfully load the files, we begin to process
else
    
    % determine the parameter p when choosing IDW method
    idwp = get(handles.P,'String');
    idwp = round(str2num (idwp),2,'significant');
    handles.P.String=num2str(idwp);
    
    % load the SNR lowerbound
    if (get(handles.snrchoice,'Value')==1)
        snrlb=0;
    elseif (get(handles.snrchoice,'Value')==2)
        snrlb=30;
    elseif (get(handles.snrchoice,'Value')==3)
        snrlbtxt= get(handles.edit1,'String');
        snrlb = str2num (snrlbtxt);
    else
    end
    
    % load the channel
    if (get(handles.ch1,'Value') == get(handles.ch1,'Max'))
        channel=1;
    elseif (get(handles.ch2,'Value') == get(handles.ch2,'Max'))
        channel=2;
    elseif (get(handles.ch3,'Value') == get(handles.ch3,'Max'))
        channel=3;
    else
    end
    
    % load the Required Number of Data, radius of decision making region
    RequiredNumberofData=get(handles.number,'String');
    RequiredNumberofData=str2num(RequiredNumberofData);
    RadiusofObservedRegion=get(handles.radius,'String');
    RadiusofObservedRegion=str2num(RadiusofObservedRegion);
    
    % load the radius of local IDW or global IDW
    if (get(handles.idwtype,'Value')==1)
        % idwtype==1: global IDW
        idwtype=1;
        near=0;
    elseif (get(handles.idwtype,'Value')==2)
        % idwtype==2: local IDW with radius = "near"
        idwtype=2;
        near=get(handles.near,'String');
        near=str2num(near);
    end
    
    % load the radius for standard method
    standardR=get(handles.stdR,'String');
    standardR=str2num(standardR);
    handles.standardR=standardR;
        
    % if snr lowerbound is less than 0, it will show the error message
    if  snrlb<0
        handles.messagebox.String='SNR lower bound is not valid.';
    
    % if required number of data is less than 0, it will show error message
    elseif RequiredNumberofData<0
        handles.messagebox.String='The "required number of data" must be larger than or equal to 0.';
        
    % if radius of decision making region is less than 1 pixel, it will show error message
    elseif RadiusofObservedRegion<1 || floor(RadiusofObservedRegion)~=RadiusofObservedRegion
        handles.messagebox.String='The radius of observed region must be positive integer.';
    
    % if the value of decay parameter is not defined, it will have error
    elseif isempty(idwp)
        handles.messagebox.String='P value should be numeric.';
    
    % if the local IDW radius value is not defined, it will have error
    elseif isempty(near)||near<0
        handles.messagebox.String='Radius of Local IDW must be numeric and larger than or equal to zero.';
       
    % if we choose the third kind of dataset, we need to indicate the radius for standard method 
    elseif Data==3 && (isempty(standardR)||standardR<0)
        handles.messagebox.String='When running "reconstructed dataset", please indicate the valid radius for the standard method';
    
    % if there is no error occurred, we will start the plotting procedure  
    else
        msg= append('Plotting now...   ','( Channel : ', num2str(channel),'    ','SNR LowerBound : ',num2str(snrlb),' )');
        handles.messagebox.String=msg;
        drawnow;
        msg1=append('FLIm map constructed successfully !');
                
        if (get(handles.idw2,'Value') == get(handles.idw2,'Max'))
            [meanlifetime,sdlifetime,Overlay,str1,str2]=replotImage(rawimage,mat,1,snrlb,channel,RequiredNumberofData,RadiusofObservedRegion,choice,we_include_ch4,idwp,idwtype,near,Data,standardR,txt);
            str=append(str1,'.jpg');
            plot= imread(str);
            axes(handles.axes1);
            imshow(plot);
            handles.messagebox.String=msg1;
        elseif (get(handles.idw3,'Value') == get(handles.idw3,'Max'))
            [meanlifetime,sdlifetime,Overlay,str1,str2]=replotImage(rawimage,mat,2,snrlb,channel,RequiredNumberofData,RadiusofObservedRegion,choice,we_include_ch4,idwp,idwtype,near,Data,standardR,txt);
            str=append(str1,'.jpg');
            plot= imread(str);
            axes(handles.axes1);
            imshow(plot);
            handles.messagebox.String=msg1;
        elseif (get(handles.nni,'Value') == get(handles.nni,'Max'))
            warning off
            [meanlifetime,sdlifetime,Overlay,str1,str2]=replotImage(rawimage,mat,3,snrlb,channel,RequiredNumberofData,RadiusofObservedRegion,choice,we_include_ch4,idwp,idwtype,near,Data,standardR,txt);
            str=append(str1,'.jpg');
            plot= imread(str);
            axes(handles.axes1);
            imshow(plot);
            handles.messagebox.String=msg1;
        elseif (get(handles.idw1,'Value') == get(handles.idw1,'Max'))
            [meanlifetime,sdlifetime,Overlay,str1,str2]=replotImage(rawimage,mat,4,snrlb,channel,RequiredNumberofData,RadiusofObservedRegion,choice,we_include_ch4,idwp,idwtype,near,Data,standardR,txt);
            str=append(str1,'.jpg');
            plot= imread(str);
            axes(handles.axes1);
            imshow(plot);
            handles.messagebox.String=msg1;
        elseif (get(handles.om,'Value') == get(handles.om,'Max'))
            [meanlifetime,sdlifetime,Overlay,str1,str2]=replotImage(rawimage,mat,5,snrlb,channel,RequiredNumberofData,RadiusofObservedRegion,choice,we_include_ch4,idwp,idwtype,near,Data,standardR,txt);
            str=append(str1,'.jpg');
            plot= imread(str);
            axes(handles.axes1);
            imshow(plot);
            handles.messagebox.String=msg1;
        elseif (get(handles.IDWP,'Value') == get(handles.om,'Max'))
            [meanlifetime,sdlifetime,Overlay,str1,str2]=replotImage(rawimage,mat,6,snrlb,channel,RequiredNumberofData,RadiusofObservedRegion,choice,we_include_ch4,idwp,idwtype,near,Data,standardR,txt);
            str=append(str1,'.jpg');
            plot= imread(str);
            axes(handles.axes1);
            imshow(plot);
            handles.messagebox.String=msg1;
        else
            handles.messagebox.String= "please specify the plotting method";
            str='';
            plot=0;
        end
        
        if get(handles.HNdata,'Value')==1 || get(handles.Bdata_R,'Value')==1 || get(handles.Bdata_mat,'Value')==1
            set(handles.snrmap,'Enable','on')
        end
                
        % delete the waiting bar
        F=findall(0,'type','figure','tag','TMWWaitbar');
        delete(F)
        
        % convert the outputs to global variables for future use
        handles.mean=meanlifetime;
        handles.sd=sdlifetime;
        handles.scalefrom= (meanlifetime-2*sdlifetime);
        if handles.scalefrom<0
            handles.scalefrom=0;
        end
        handles.scaleto= (meanlifetime+2*sdlifetime);
        
        % display the current color bar scale to the GUI
        handles.from.String=num2str(handles.scalefrom);
        handles.to.String=num2str(handles.scaleto);
        
        % Overlay: constructed overlay
        handles.Overlay=Overlay;
        % plot: White-light image 
        handles.plot=plot;
        % str: name of the constructed FLIm map file
        handles.str=str;
        % str2: title of the constructed FLIm map
        handles.str2=str2;
        % channel
        handles.channel=channel;
        % map kind
        handles.choice=choice;
        guidata(hObject,handles)
        
    end
end

set(handles.idw1,'Enable','on')
set(handles.idw2,'Enable','on')
set(handles.idw3,'Enable','on')
set(handles.nni,'Enable','on')
set(handles.om,'Enable','on');
set(handles.IDWP,'Enable','on')
set(handles.P,'Enable','on')
set(handles.browseIMG,'Enable','on')
set(handles.browseMAT,'Enable','on')
set(handles.ch1,'Enable','on')
set(handles.ch2,'Enable','on')
set(handles.ch3,'Enable','on')
if get(handles.Bdata,'Value')==0
    set(handles.snrchoice,'Enable','on')
end
if get(handles.Bdata_R,'Value')==1
    set(handles.stdR,'Enable','on')
end
if get(handles.Bdata_mat,'Value')==1
    set(handles.browseTXT,'Enable','on')
end
set(handles.radius,'Enable','on')
set(handles.number,'Enable','on')
set(handles.jet,'Enable','on')
set(handles.hot,'Enable','on')
set(handles.CI,'Enable','on')

if (get(handles.snrchoice,'Value')==1)
    set(handles.edit1,'Enable','off')
elseif (get(handles.snrchoice,'Value')==2)
    set(handles.edit1,'Enable','off')
elseif (get(handles.snrchoice,'Value')==3)
    set(handles.edit1,'Enable','on')
else
end

set(handles.gray,'Enable','on')
set(handles.number,'Enable','on')
set(handles.alpha,'Enable','on')
set(handles.transvalue,'Enable','on')
set(handles.set,'Enable','on')
set(handles.from,'Enable','on')
set(handles.to,'Enable','on')

clear str

%%%%% method options %%%%%
% --- Executes on button press in nni.
function nni_Callback(hObject, eventdata, handles)
% hObject    handle to nni (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of nni
if (get(handles.nni,'Value') == get(handles.nni,'Max'))
    set(handles.idw2,'Value',0);
    set(handles.idw3,'Value',0);
    set(handles.idw1,'Value',0);
    set(handles.om,'Value',0);
    set(handles.IDWP,'Value',0);
    set(handles.P,'Enable','off');
    set(handles.P, 'string', 2);
    set(handles.idwtype,'Enable','off');
end

if (get(handles.IDWP,'Value')==get(handles.IDWP,'Min')) || (get(handles.idw2,'Value')==get(handles.idw2,'Min')) || (get(handles.idw3,'Value')==get(handles.idw3,'Min'))  || (get(handles.idw1,'Value')==get(handles.idw1,'Min'))  || (get(handles.om,'Value')==get(handles.om,'Min'))  || (get(handles.nni,'Value')==get(handles.nni,'Min'))
    set(handles.nni,'Value',1);
end
% --- Executes on button press in nni.
function idw3_Callback(hObject, eventdata, handles)
% hObject    handle to nni (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of nni
if (get(handles.idw3,'Value') == get(handles.idw3,'Max'))
    set(handles.idw2,'Value',0);
    set(handles.nni,'Value',0);
    set(handles.idw1,'Value',0);
    set(handles.om,'Value',0);
    set(handles.IDWP,'Value',0);
    set(handles.P,'Enable','off');
    set(handles.P, 'string', 2);
    set(handles.idwtype,'Enable','on');
end

if (get(handles.IDWP,'Value')==get(handles.IDWP,'Min')) || (get(handles.idw2,'Value')==get(handles.idw2,'Min')) || (get(handles.idw3,'Value')==get(handles.idw3,'Min'))  || (get(handles.idw1,'Value')==get(handles.idw1,'Min'))  || (get(handles.om,'Value')==get(handles.om,'Min'))  || (get(handles.nni,'Value')==get(handles.nni,'Min'))
    set(handles.idw3,'Value',1);
end
% --- Executes on button press in idw2.
function idw2_Callback(hObject, eventdata, handles)
% hObject    handle to idw2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of idw2
if (get(handles.idw2,'Value') == get(handles.idw2,'Max'))
    set(handles.idw3,'Value',0);
    set(handles.nni,'Value',0);
    set(handles.idw1,'Value',0);
    set(handles.om,'Value',0);
    set(handles.IDWP,'Value',0);
    set(handles.P,'Enable','off');
    set(handles.P, 'string', 2);
    set(handles.idwtype,'Enable','on');
end

if (get(handles.IDWP,'Value')==get(handles.IDWP,'Min')) || (get(handles.idw2,'Value')==get(handles.idw2,'Min')) || (get(handles.idw3,'Value')==get(handles.idw3,'Min'))  || (get(handles.idw1,'Value')==get(handles.idw1,'Min'))  || (get(handles.om,'Value')==get(handles.om,'Min'))  || (get(handles.nni,'Value')==get(handles.nni,'Min'))
    set(handles.idw2,'Value',1);
end
% --- Executes on button press in idw1.
function idw1_Callback(hObject, eventdata, handles)
% hObject    handle to idw1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of idw1
if (get(handles.idw1,'Value') == get(handles.idw1,'Max'))
    set(handles.idw3,'Value',0);
    set(handles.idw2,'Value',0);
    set(handles.nni,'Value',0);
    set(handles.om,'Value',0);
    set(handles.IDWP,'Value',0);
    set(handles.P,'Enable','off')
    set(handles.P, 'string', 2);
    set(handles.idwtype,'Enable','on');
end
if (get(handles.IDWP,'Value')==get(handles.IDWP,'Min')) || (get(handles.idw2,'Value')==get(handles.idw2,'Min')) || (get(handles.idw3,'Value')==get(handles.idw3,'Min'))  || (get(handles.idw1,'Value')==get(handles.idw1,'Min'))  || (get(handles.om,'Value')==get(handles.om,'Min'))  || (get(handles.nni,'Value')==get(handles.nni,'Min'))
    set(handles.idw1,'Value',1);
end
% --- Executes on button press in om.
function om_Callback(hObject, eventdata, handles)
% hObject    handle to om (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of om
if (get(handles.om,'Value') == get(handles.om,'Max'))
    set(handles.idw3,'Value',0);
    set(handles.idw2,'Value',0);
    set(handles.nni,'Value',0);
    set(handles.idw1,'Value',0);
    set(handles.IDWP,'Value',0);
    set(handles.P,'Enable','off');
    set(handles.P, 'string', 2);
    set(handles.idwtype,'Enable','off');
end

if (get(handles.IDWP,'Value')==get(handles.IDWP,'Min')) || (get(handles.idw2,'Value')==get(handles.idw2,'Min')) || (get(handles.idw3,'Value')==get(handles.idw3,'Min'))  || (get(handles.idw1,'Value')==get(handles.idw1,'Min'))  || (get(handles.om,'Value')==get(handles.om,'Min'))  || (get(handles.nni,'Value')==get(handles.nni,'Min'))
    set(handles.om,'Value',1);
end

% --- Executes on button press in IDWP.
function IDWP_Callback(hObject, eventdata, handles)
% hObject    handle to IDWP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IDWP
if (get(handles.IDWP,'Value') == get(handles.IDWP,'Max'))
    set(handles.idw3,'Value',0);
    set(handles.idw2,'Value',0);
    set(handles.nni,'Value',0);
    set(handles.idw1,'Value',0);
    set(handles.om,'Value',0);
    set(handles.P,'Enable','on');
    set(handles.idwtype,'Enable','on');
end

if (get(handles.IDWP,'Value')==get(handles.IDWP,'Min')) || (get(handles.idw2,'Value')==get(handles.idw2,'Min')) || (get(handles.idw3,'Value')==get(handles.idw3,'Min'))  || (get(handles.idw1,'Value')==get(handles.idw1,'Min'))  || (get(handles.om,'Value')==get(handles.om,'Min'))  || (get(handles.nni,'Value')==get(handles.nni,'Min'))
    set(handles.IDWP,'Value',1);
end



function P_Callback(hObject, eventdata, handles)
% hObject    handle to P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of P as text
%        str2double(get(hObject,'String')) returns contents of P as a double


% --- Executes during object creation, after setting all properties.
function P_CreateFcn(hObject, eventdata, handles)
% hObject    handle to P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% channel options %%%%%
% --- Executes on button press in ch1.
function ch1_Callback(hObject, eventdata, handles)
% hObject    handle to ch1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ch1
if (get(handles.ch1,'Value') == get(handles.ch1,'Max'))
    set(handles.ch2,'Value',0);
    set(handles.ch3,'Value',0);
end
if (get(handles.ch1,'Value') == get(handles.ch1,'Min')) || (get(handles.ch2,'Value') == get(handles.ch2,'Min')) ||(get(handles.ch3,'Value') == get(handles.ch3,'Min'))
    set(handles.ch1,'Value',1);
end
% --- Executes on button press in ch2.
function ch2_Callback(hObject, eventdata, handles)
% hObject    handle to ch2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of ch2

if (get(handles.ch2,'Value') == get(handles.ch2,'Max'))
    set(handles.ch1,'Value',0);
    set(handles.ch3,'Value',0);
end
if (get(handles.ch1,'Value') == get(handles.ch1,'Min')) || (get(handles.ch2,'Value') == get(handles.ch2,'Min')) ||(get(handles.ch3,'Value') == get(handles.ch3,'Min'))
    set(handles.ch2,'Value',1);
end
% --- Executes on button press in ch3.
function ch3_Callback(hObject, eventdata, handles)
% hObject    handle to ch3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of ch3

if (get(handles.ch3,'Value') == get(handles.ch3,'Max'))
    set(handles.ch1,'Value',0);
    set(handles.ch2,'Value',0);
end
if (get(handles.ch1,'Value') == get(handles.ch1,'Min')) || (get(handles.ch2,'Value') == get(handles.ch2,'Min')) ||(get(handles.ch3,'Value') == get(handles.ch3,'Min'))
    set(handles.ch3,'Value',1);
end

%%%%% SNR values textbox %%%%%
% --- Executes on selection change in snrchoice.
function snrchoice_Callback(hObject, eventdata, handles)
% hObject    handle to snrchoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns snrchoice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from snrchoice
if (get(handles.snrchoice,'Value')==3)
    set(handles.edit1,'Enable','on')
else
    set(handles.edit1,'Enable','off')
end
% --- Executes during object creation, after setting all properties.
function snrchoice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to snrchoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% message textbox %%%%%
function messagebox_Callback(hObject, eventdata, handles)
% hObject    handle to messagebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of messagebox as text
%        str2double(get(hObject,'String')) returns contents of messagebox as a double

% --- Executes during object creation, after setting all properties.
function messagebox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to messagebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% browse image file %%%%%
% --- Executes on button press in browseIMG.
function browseIMG_Callback(hObject, eventdata, handles)
% hObject    handle to browseIMG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.browseMAT,'Enable','off')
set(handles.browseTXT,'Enable','off')
[filename,filepath] = uigetfile ({'*.jpg';'*.png';'*.bmp'},'Search Image to be Displayed');
if filename==0
    filename='';
end
set(handles.imgname, 'string', filename);
handles.filename=[filepath filename];
raw_file=[filepath filename];
raw_one=imread(raw_file);
a0=figure('visible','off');
imshow(raw_one)
truesize([420 680]);
saveas(a0,['temp','.jpg']);
axes(handles.axes2);
imshow('temp.jpg')
delete('temp.jpg')
set(handles.browseMAT,'Enable','on')
if (get(handles.Bdata_mat,'Value') == get(handles.Bdata,'Max'))
    set(handles.browseTXT,'Enable','on')
end
guidata(hObject,handles)

%%%%% browse mat file %%%%%
% --- Executes on button press in browseMAT.
function browseMAT_Callback(hObject, eventdata, handles)
% hObject    handle to browseMAT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.browseIMG,'Enable','off')
set(handles.browseTXT,'Enable','off')
[filename1,filepath1] = uigetfile ({'*.mat'},'Search MAT to be Displayed');
if filename1==0
    filename1='';
end
set(handles.matname, 'string', filename1);
handles.filename1=[filepath1 filename1];
set(handles.browseIMG,'Enable','on')
if (get(handles.Bdata_mat,'Value') == get(handles.Bdata,'Max'))
    set(handles.browseTXT,'Enable','on')
end
guidata(hObject,handles)

%%%%% image file textbox %%%%%
function imgname_Callback(hObject, eventdata, handles)
% hObject    handle to imgname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of imgname as text
%        str2double(get(hObject,'String')) returns contents of imgname as a double


% --- Executes during object creation, after setting all properties.
function imgname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imgname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% mat file textbox %%%%%
function matname_Callback(hObject, eventdata, handles)
% hObject    handle to matname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles   ?? structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of matname as text
%        str2double(get(hObject,'String')) returns contents of matname as a double


% --- Executes during object creation, after setting all properties.
function matname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to matname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Browse Text File Button %%%%%
% --- Executes on button press in browseTXT.
function browseTXT_Callback(hObject, eventdata, handles)
% hObject    handle to browseTXT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.browseIMG,'Enable','off')
set(handles.browseMAT,'Enable','off')
[filename2,filepath2] = uigetfile ({'*.txt'},'Search TXT to be Displayed');
if filename2==0
    filename2='';
end
set(handles.txtname, 'string', filename2);
handles.filename2=[filepath2 filename2];
set(handles.browseIMG,'Enable','on')
set(handles.browseMAT,'Enable','on')
guidata(hObject,handles)


function txtname_Callback(hObject, eventdata, handles)
% hObject    handle to txtname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtname as text
%        str2double(get(hObject,'String')) returns contents of txtname as a double


% --- Executes during object creation, after setting all properties.
function txtname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% preferred path textbox %%%%%
function namesave_Callback(hObject, eventdata, handles)
% hObject    handle to namesave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of namesave as text
%        str2double(get(hObject,'String')) returns contents of namesave as a double

% --- Executes during object creation, after setting all properties.
function namesave_CreateFcn(hObject, eventdata, handles)
% hObject    handle to namesave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% preferred name textbox %%%%%
function savedname_Callback(hObject, eventdata, handles)
% hObject    handle to savedname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of savedname as text
%        str2double(get(hObject,'String')) returns contents of savedname as a double

% --- Executes during object creation, after setting all properties.
function savedname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savedname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% preferred name checkbox %%%%%
% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(handles.checkbox1,'Value') == get(handles.checkbox1,'Max'))
    set(handles.savedname,'Enable','on');
else
    set(handles.savedname,'Enable','off');
end
% Hint: get(hObject,'Value') returns toggle state of checkbox1

%%%%% browse path button%%%%%
% --- Executes on button press in pathbutton.
function pathbutton_Callback(hObject, eventdata, handles)
% hObject    handle to pathbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selpath = uigetdir;
if selpath==0
    selpath='';
end
set(handles.namesave, 'string', selpath);
handles.selpath=selpath;
guidata(hObject,handles)

%%%%% save file to certain path with certain name %%%%%
% --- Executes on button press in savebutton.
function savebutton_Callback(hObject, eventdata, handles)
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
target=handles.selpath;

if isempty(target)
    handles.messagebox.String='You Need to Determine the Path!';
else
    if isempty(handles.str)
        handles.messagebox.String='You Need to Plot First!';
    else
        if (get(handles.checkbox1,'Value') == get(handles.checkbox1,'Max'))
            saveimg = handles.plot;
            savename = get(handles.savedname,'String');
            result=[target,'/',savename,'.jpg'];
            imwrite(saveimg,result,'jpg');
            delete(handles.str);
            delete(['Gray Version,' handles.str]);
        else
            saveimg = handles.plot;
            savename = handles.str;
            result=[target,'/',savename];
            imwrite(saveimg,result,'jpg');
            delete(handles.str);
            delete(['Gray Version,' handles.str]);
        end
        
    end
end

%%%%% setting of required number of data %%%%%
function number_Callback(hObject, eventdata, handles)
% hObject    handle to number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of number as text
%        str2double(get(hObject,'String')) returns contents of number as a double

% --- Executes during object creation, after setting all properties.
function number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% setting of radius of searching area %%%%%
function radius_Callback(hObject, eventdata, handles)
% hObject    handle to radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of radius as text
%        str2double(get(hObject,'String')) returns contents of radius as a double

% --- Executes during object creation, after setting all properties.
function radius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in idwtype.
function idwtype_Callback(hObject, eventdata, handles)
% hObject    handle to idwtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns idwtype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from idwtype
if (get(handles.idwtype,'Value')==2)
    set(handles.near,'Enable','on')
else
    set(handles.near,'Enable','off')
end

% --- Executes during object creation, after setting all properties.
function idwtype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to idwtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%% setting of IDW type %%%%%
function near_Callback(hObject, eventdata, handles)
% hObject    handle to near (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of near as text
%        str2double(get(hObject,'String')) returns contents of near as a double

% --- Executes during object creation, after setting all properties.
function near_CreateFcn(hObject, eventdata, handles)
% hObject    handle to near (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%% checkbox for gray scale %%%%%
% --- Executes on button press in gray.
function gray_Callback(hObject, eventdata, handles)
% hObject    handle to gray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gray

%%%%% checkbox for transparency %%%%%
% --- Executes on button press in alpha.
function alpha_Callback(hObject, eventdata, handles)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of alpha

%%%%% textbox for transparency %%%%%
function transvalue_Callback(hObject, eventdata, handles)
% hObject    handle to transvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of transvalue as text
%        str2double(get(hObject,'String')) returns contents of transvalue as a double

% --- Executes during object creation, after setting all properties.
function transvalue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to transvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% color bar setting %%%%%
function from_Callback(hObject, eventdata, handles)
% hObject    handle to from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of from as text
%        str2double(get(hObject,'String')) returns contents of from as a double

% --- Executes during object creation, after setting all properties.
function from_CreateFcn(hObject, eventdata, handles)
% hObject    handle to from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function to_Callback(hObject, eventdata, handles)
% hObject    handle to to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of to as text
%        str2double(get(hObject,'String')) returns contents of to as a double

% --- Executes during object creation, after setting all properties.
function to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% color map options %%%%%
% --- Executes on button press in jet.
function jet_Callback(hObject, eventdata, handles)
% hObject    handle to jet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(handles.jet,'Value') == get(handles.jet,'Max'))
    set(handles.hot,'Value',0);
end
if (get(handles.hot,'Value') == get(handles.hot,'Min'))
    set(handles.jet,'Value',1);
end

% Hint: get(hObject,'Value') returns toggle state of jet

% --- Executes on button press in hot.
function hot_Callback(hObject, eventdata, handles)
% hObject    handle to hot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(handles.hot,'Value') == get(handles.hot,'Max'))
    set(handles.jet,'Value',0);
end
if (get(handles.jet,'Value') == get(handles.jet,'Min'))
    set(handles.hot,'Value',1);
end
% Hint: get(hObject,'Value') returns toggle state of hot

%%%%% statistical scale %%%%%
% --- Executes on button press in CI.
function CI_Callback(hObject, eventdata, handles)
% hObject    handle to CI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.mean-2*handles.sd)<0
    handles.from.String='0';
else
    handles.from.String=num2str(handles.mean-2*handles.sd);
end
handles.to.String= num2str(handles.mean+2*handles.sd);

% Hint: get(hObject,'Value') returns toggle state of CI


%%%%% change setting button %%%%%
% --- Executes on button press in set.
function set_Callback(hObject, eventdata, handles)
% hObject    handle to set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
warning off

set(handles.set,'Enable','off')
drawnow;
% to find the colormap choice
if (get(handles.jet,'Value') == get(handles.jet,'Max'))
    mapchoice=1;
    ColorMap = colormap('jet');
elseif (get(handles.hot,'Value') == get(handles.hot,'Max'))
    mapchoice=2;
    ColorMap = colormap('hot');
else
end

% get color map choice
choice=handles.choice;

% get the colorbar scale
handles.scalefrom= str2num(handles.from.String);
handles.scaleto= str2num(handles.to.String);
if isempty(handles.scalefrom) || isempty(handles.scaleto) || handles.scalefrom >= handles.scaleto
    handles.messagebox.String='Colorbar scale is invalid';
    set(handles.set,'Enable','on')
    return
end

% get the alpha value
if (get(handles.alpha,'Value') == get(handles.alpha,'Max'))
    avalue= get(handles.transvalue,'String');
    avalue = str2num (avalue)./100;
    if avalue <0
        avalue=0;
        set(handles.transvalue,'string',num2str(avalue*100));
    elseif avalue>1
        avalue=1;
        set(handles.transvalue,'string',num2str(avalue*100));
    elseif isempty(avalue)
        handles.messagebox.String='Alpha value is invalid';
        set(handles.set,'Enable','on')
        return
    end
else
    avalue = 1;
end

% get the Overlay (with lifetime value)
Overlay=handles.Overlay;

% now we fit the overlay to the scale of color bar
Overlay(logical(Overlay<handles.scalefrom)&logical(Overlay>0))=handles.scalefrom;
Overlay(logical(Overlay<handles.scalefrom)&logical(Overlay<0))=0;
Overlay(logical(Overlay>handles.scaleto))=handles.scaleto;

% if we set the background image (WLI) to be grayscale
if (get(handles.gray,'Value') == get(handles.gray,'Max'))
    grayraw= imread(handles.filename);
    df3(:,:,1)=rgb2gray(grayraw);
    df3(:,:,2)=rgb2gray(grayraw);
    df3(:,:,3)=rgb2gray(grayraw);
    
    blendimg=df3;
    
    % now we fit the values to the colorbar scale and plot the RGB overlay onto WLI
    [map_r,map_c,map_v]=find(Overlay);
    
    for y=1:length(map_r)
        z=floor((map_v(y)-handles.scalefrom)/(handles.scaleto-handles.scalefrom)*63+1);
        blendimg(map_r(y),map_c(y),1)= floor(ColorMap(z,1).*255);
        blendimg(map_r(y),map_c(y),2)= floor(ColorMap(z,2).*255);
        blendimg(map_r(y),map_c(y),3)= floor(ColorMap(z,3).*255);
    end
    
    % we set the alpha value
    df3=avalue.*blendimg+(1-avalue).*df3;
    
    savename = ['Gray Version,',handles.str];
    result=savename;
    handles.delstr = savename;
    
    a1=figure('visible','off');
    imshow(df3);
    caxis([handles.scalefrom handles.scaleto]);
    
    % we determine the colormap
    if mapchoice==1
        if choice==1
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['Lifetime CH', num2str(handles.channel) ,' (ns)'],'Fontsize',16)
        elseif choice==2
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['Intensity Ratio CH',num2str(handles.channel) ],'Fontsize',16)
        elseif choice==3
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['IR Lifetime CH', num2str(handles.channel) ,' (ns)'],'Fontsize',16)
        elseif choice==4
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['ORR'],'Fontsize',16)
        else
        end
        
    elseif mapchoice==2
        if choice==1
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['Lifetime CH', num2str(handles.channel) ,' (ns)'],'Fontsize',16)
        elseif choice==2
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['Intensity Ratio CH', num2str(handles.channel) ],'Fontsize',16)
        elseif choice==3
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['IR Lifetime CH', num2str(handles.channel) ,' (ns)'],'Fontsize',16)
        elseif choice==4
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['ORR'] ,'Fontsize',16)
        else
        end
    else
    end
    
    title(handles.str2,'Fontsize',18)
    truesize([420 680]);
    saveas(a1,result);
    
    grayimg=imread(result);
    axes(handles.axes1);
    imshow(grayimg);
    handles.plot=grayimg;
    delete(handles.str);
    
% if we set the background image (WLI) to be rgb scale
elseif (get(handles.gray,'Value') == get(handles.gray,'Min'))
    rgbraw=imread(handles.filename);
    df3=rgbraw;
    blendimg=df3;
    
    % now we fit the values to the colorbar scale and plot the RGB overlay onto WLI
    [map_r,map_c,map_v]=find(Overlay);
    
    for y=1:length(map_r)
        z=floor((map_v(y)-handles.scalefrom)/(handles.scaleto-handles.scalefrom)*63+1);
        blendimg(map_r(y),map_c(y),1)= floor(ColorMap(z,1).*255);
        blendimg(map_r(y),map_c(y),2)= floor(ColorMap(z,2).*255);
        blendimg(map_r(y),map_c(y),3)= floor(ColorMap(z,3).*255);
    end
    
    % we set the alpha value
    df3=avalue.*blendimg+(1-avalue).*df3;
    
    savename = handles.str;
    result=savename;
    handles.delstr = savename;
    
    a1=figure('visible','off');
    imshow(df3);
    caxis([handles.scalefrom handles.scaleto]);
    
    % we determine the colormap
    if mapchoice==1
        if choice==1
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['Lifetime CH',  num2str(handles.channel),' (ns)'],'Fontsize',16)
        elseif choice==2
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['Intensity Ratio CH',  num2str(handles.channel)],'Fontsize',16)
        elseif choice==3
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['IR Lifetime CH', num2str(handles.channel),' (ns)'],'Fontsize',16)
        elseif choice==4
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['ORR'],'Fontsize',16)
        else
        end
    elseif mapchoice==2
        if choice==1
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['Lifetime CH',  num2str(handles.channel),' (ns)'],'Fontsize',16)
        elseif choice==2
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['Intensity Ratio CH',  num2str(handles.channel)],'Fontsize',16)
        elseif choice==3
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['IR Lifetime CH', num2str(handles.channel) ,' (ns)'],'Fontsize',16)
        elseif choice==4
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['ORR'],'Fontsize',16)
        else
        end
    else
    end
    
    title(handles.str2,'Fontsize',18)
    truesize([420 680]);
    saveas(a1,result);
    
    img=imread(result);
    axes(handles.axes1);
    imshow(img);
    handles.plot=img;
    
    dstr=['Gray Version,',handles.str];
    delete(dstr);
end

set(handles.set,'Enable','on')

guidata(hObject,handles)


%%%%% map options %%%%%
% --- Executes on button press in LT.
function LT_Callback(hObject, eventdata, handles)
% hObject    handle to LT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(handles.LT,'Value') == get(handles.LT,'Max'))
    set(handles.IR,'Value',0);
    set(handles.INLT,'Value',0);
    set(handles.ORR,'Value',0);
end

if (get(handles.LT,'Value') == get(handles.LT,'Min')) ||(get(handles.IR,'Value') == get(handles.IR,'Min'))||(get(handles.INLT,'Value') == get(handles.INLT,'Min')) || (get(handles.ORR,'Value') == get(handles.ORR,'Min'))
    set(handles.LT,'Value',1);
end
% Hint: get(hObject,'Value') returns toggle state of LT


% --- Executes on button press in IR.
function IR_Callback(hObject, eventdata, handles)
% hObject    handle to IR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(handles.IR,'Value') == get(handles.IR,'Max'))
    set(handles.LT,'Value',0);
    set(handles.INLT,'Value',0);
    set(handles.ORR,'Value',0);
end
if (get(handles.LT,'Value') == get(handles.LT,'Min')) ||(get(handles.IR,'Value') == get(handles.IR,'Min'))||(get(handles.INLT,'Value') == get(handles.INLT,'Min')) || (get(handles.ORR,'Value') == get(handles.ORR,'Min'))
    set(handles.IR,'Value',1);
end
% Hint: get(hObject,'Value') returns toggle state of IR

% --- Executes on button press in INLT.
function INLT_Callback(hObject, eventdata, handles)
% hObject    handle to INLT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(handles.INLT,'Value') == get(handles.INLT,'Max'))
    set(handles.IR,'Value',0);
    set(handles.LT,'Value',0);
    set(handles.ORR,'Value',0);
end

if (get(handles.LT,'Value') == get(handles.LT,'Min')) ||(get(handles.IR,'Value') == get(handles.IR,'Min'))||(get(handles.INLT,'Value') == get(handles.INLT,'Min')) || (get(handles.ORR,'Value') == get(handles.ORR,'Min'))
    set(handles.INLT,'Value',1);
end
% Hint: get(hObject,'Value') returns toggle state of INLT

% --- Executes on button press in ORR.
function ORR_Callback(hObject, eventdata, handles)
% hObject    handle to ORR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(handles.ORR,'Value') == get(handles.ORR,'Max'))
    set(handles.IR,'Value',0);
    set(handles.INLT,'Value',0);
    set(handles.LT,'Value',0);
end

if (get(handles.LT,'Value') == get(handles.LT,'Min')) ||(get(handles.IR,'Value') == get(handles.IR,'Min'))||(get(handles.INLT,'Value') == get(handles.INLT,'Min')) || (get(handles.ORR,'Value') == get(handles.ORR,'Min'))
    set(handles.ORR,'Value',1);
end
% Hint: get(hObject,'Value') returns toggle state of ORR


%%%%% include channel 4 or not %%%%%
% --- Executes on button press in inch4.
function inch4_Callback(hObject, eventdata, ~)
% hObject    handle to inch4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of inch4


% --- Executes on button press in snrmap.
function snrmap_Callback(hObject, eventdata, handles)
% hObject    handle to snrmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.snrmap,'Enable','off')
rawimage=handles.filename;
mat=handles.filename1;
txt=handles.filename2;
% load channel
if (get(handles.ch1,'Value') == get(handles.ch1,'Max'))
    channel=1;
elseif (get(handles.ch2,'Value') == get(handles.ch2,'Max'))
    channel=2;
elseif (get(handles.ch3,'Value') == get(handles.ch3,'Max'))
    channel=3;
else
end
if (get(handles.snrchoice,'Value')==1)
    snrlb=0;
elseif (get(handles.snrchoice,'Value')==2)
    snrlb=30;
elseif (get(handles.snrchoice,'Value')==3)
    snrlbtxt= get(handles.edit1,'String');
    snrlb = str2num (snrlbtxt);
else
end

SNRmap(rawimage,mat,snrlb,channel,handles.Data,handles.standardR,txt);
axes(handles.axes3);
imshow('SNR.jpg');
F=findall(0,'type','figure','tag','TMWWaitbar');
delete(F)

%%%%% Different Dataset Execution%%%%%
% --- Executes on button press in HNdata.
function HNdata_Callback(hObject, eventdata, handles)
% hObject    handle to HNdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(handles.HNdata,'Value') == get(handles.HNdata,'Max'))
    set(handles.Bdata,'Value',0);
    set(handles.Bdata_R,'Value',0);
    set(handles.Bdata_mat,'Value',0);
end
if (get(handles.Bdata,'Value') == get(handles.Bdata,'Min')) || (get(handles.HNdata,'Value') == get(handles.HNdata,'Min')) || (get(handles.Bdata_mat,'Value') == get(handles.Bdata_mat,'Min')) 
    set(handles.HNdata,'Value',1);
end

set(handles.IR,'Enable','on')
set(handles.INLT,'Enable','on')
set(handles.ORR,'Enable','on')
set(handles.snrchoice,'Enable','on');
set(handles.inch4,'Enable','on');
set(handles.stdR,'Enable','off');
set(handles.browseTXT,'Enable','off');


% Hint: get(hObject,'Value') returns toggle state of HNdata

% --- Executes on button press in Bdata.
function Bdata_Callback(hObject, eventdata, handles)
% hObject    handle to Bdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(handles.Bdata,'Value') == get(handles.Bdata,'Max'))
    set(handles.HNdata,'Value',0);
    set(handles.Bdata_R,'Value',0);
    set(handles.Bdata_mat,'Value',0);
end
if (get(handles.Bdata,'Value') == get(handles.Bdata,'Min')) || (get(handles.HNdata,'Value') == get(handles.HNdata,'Min')) || (get(handles.Bdata_mat,'Value') == get(handles.Bdata_mat,'Min')) 
    set(handles.Bdata,'Value',1);
end

set(handles.IR,'Enable','off')
set(handles.INLT,'Enable','off')
set(handles.ORR,'Enable','off')
set(handles.LT,'Value',1)
set(handles.IR,'Value',0)
set(handles.INLT,'Value',0)
set(handles.ORR,'Value',0)
set(handles.snrchoice,'Value',1);
set(handles.snrchoice,'Enable','off');
set(handles.edit1,'Enable','off');
set(handles.inch4,'Enable','off');
set(handles.snrmap,'Enable','off')
set(handles.stdR,'Enable','off');
set(handles.browseTXT,'Enable','off');


% Hint: get(hObject,'Value') returns toggle state of Bdata


% --- Executes on button press in Bdata_R.
function Bdata_R_Callback(hObject, eventdata, handles)
% hObject    handle to Bdata_R (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Bdata_R
if (get(handles.Bdata_R,'Value') == get(handles.Bdata_R,'Max'))
    set(handles.HNdata,'Value',0);
    set(handles.Bdata,'Value',0);
    set(handles.Bdata_mat,'Value',0);
end
if (get(handles.Bdata,'Value') == get(handles.Bdata,'Min')) || (get(handles.HNdata,'Value') == get(handles.HNdata,'Min')) || (get(handles.Bdata_mat,'Value') == get(handles.Bdata_mat,'Min')) 
    set(handles.Bdata_R,'Value',1);
end

set(handles.snrchoice,'Enable','on');
set(handles.IR,'Enable','on')
set(handles.INLT,'Enable','on')
set(handles.ORR,'Enable','on')
set(handles.LT,'Value',1)
set(handles.IR,'Value',0)
set(handles.INLT,'Value',0)
set(handles.ORR,'Value',0)
set(handles.edit1,'Enable','off');
set(handles.inch4,'Enable','on');
set(handles.stdR,'Enable','on');
set(handles.browseTXT,'Enable','off');

% --- Executes on button press in Bdata_mat.
function Bdata_mat_Callback(hObject, eventdata, handles)
% hObject    handle to Bdata_mat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Bdata_mat
if (get(handles.Bdata_mat,'Value') == get(handles.Bdata_mat,'Max'))
    set(handles.HNdata,'Value',0);
    set(handles.Bdata,'Value',0);
    set(handles.Bdata_R,'Value',0);
end
if (get(handles.Bdata,'Value') == get(handles.Bdata,'Min')) || (get(handles.HNdata,'Value') == get(handles.HNdata,'Min')) || (get(handles.Bdata_mat,'Value') == get(handles.Bdata_mat,'Min')) 
    set(handles.Bdata_mat,'Value',1);
end

set(handles.snrchoice,'Enable','on');
set(handles.IR,'Enable','on')
set(handles.INLT,'Enable','on')
set(handles.ORR,'Enable','on')
set(handles.LT,'Value',1)
set(handles.IR,'Value',0)
set(handles.INLT,'Value',0)
set(handles.ORR,'Value',0)
set(handles.edit1,'Enable','off');
set(handles.inch4,'Enable','on');
set(handles.stdR,'Enable','off');
set(handles.browseTXT,'Enable','on');

function stdR_Callback(hObject, eventdata, handles)
% hObject    handle to stdR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stdR as text
%        str2double(get(hObject,'String')) returns contents of stdR as a double

% --- Executes during object creation, after setting all properties.
function stdR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stdR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

