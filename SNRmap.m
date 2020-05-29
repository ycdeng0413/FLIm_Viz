function  SNRmap(rawimgaeName,matfileName,snrlb,channel,Data,standardR,txtfileName)

% read raw image data
im = imread(rawimgaeName);

if Data==1
    % read segmentation position from mat file
    % mat file structure:
    %(1-8) Frame, ID Txt, Lifetime 1, Lifetime 2, Lifetime 3, Lifetime 4, Width, Height,
    %(9-15) Z-Axis,	Unknown, ID Deconv, Lifetime 1 Deconv, Lifetime 2 Deconv, Lifetime 3 Deconv, Lifetime 4 Deconv,
    %(16-19) Intensity 1 Deconv, Intensity 2 Deconv, Intensity 3 Deconv, Intensity 4 Deconv,
    %(20-23) SNR 1 Deconv, SNR 2 Deconv, SNR 3 Deconv, SNR 4 Deconv
    mat_file = load( matfileName );
    fields = fieldnames(mat_file);
    mat_data = getfield(mat_file, fields{1,1});
    
    % write into one object
    % -px [Nx1]
    % -py [Nx1]
    % -frames [integer N]
    posData = {};
    posData.px = mat_data(:, 7);
    posData.py = mat_data(:, 8);
    posData.frames = size(mat_data, 1);
    posData.radius = mat_data(:, 9)/2;
    
    % read lifetime related values from mat file
    % write into one object
    % -lt {4x1cell}: {[Nx1 double], [Nx1 double], [Nx1 double], [Nx1 double]}
    % -int {4x1cell}: {[Nx1 double], [Nx1 double], [Nx1 double], [Nx1 double]}
    % -snr {4x1cell}: {[Nx1 double], [Nx1 double], [Nx1 double], [Nx1 double]}
    ltData = {};
    ltData.lifetime  = {mat_data(:, 12), mat_data(:, 13), mat_data(:, 14), mat_data(:, 15)};
    ltData.snr = {mat_data(:, 20), mat_data(:, 21), mat_data(:, 22), mat_data(:, 23)};
    
elseif Data==3
    
    load(matfileName,'INT_map','INT_R_map','LT_map','SNR_map');
    [R,C]=size(LT_map{1});
    ltData={};
    posData={};
    
    i=1;
    for r=1:R
        for c=1:C
            if LT_map{1}(r,c)~=0
                posData.px(i)=c;
                posData.py(i)=r;
                posData.radius(i)=standardR;
                ltData.lifetime{1}(i)=LT_map{1}(r,c);
                ltData.lifetime{2}(i)=LT_map{2}(r,c);
                ltData.lifetime{3}(i)=LT_map{3}(r,c);
                ltData.lifetime{4}(i)=LT_map{4}(r,c);
                ltData.snr{1}(i)=SNR_map{1}(r,c);
                ltData.snr{2}(i)=SNR_map{2}(r,c);
                ltData.snr{3}(i)=SNR_map{3}(r,c);
                ltData.snr{4}(i)=SNR_map{4}(r,c);
                i=i+1;
            end
        end
    end
    posData.frames=length(posData.px(:));
elseif Data==4
    
    txt=load(txtfileName);
    load(matfileName,'ID','SNR','lifet_avg');    
    
    ltData={};
    posData={};
    
    for ind=1:length(ID)
        
        indices=find(txt(:,1)==ID(ind));
        if isempty(indices)
            continue
        end
        indices=min(indices);
        posData.px(ind)=round(txt(indices,6));
        posData.py(ind)=round(txt(indices,7));
        posData.radius(ind)=txt(indices,8);
        ltData.lifetime{1}(ind)=lifet_avg{1}(ind);
        ltData.lifetime{2}(ind)=lifet_avg{2}(ind);
        ltData.lifetime{3}(ind)=lifet_avg{3}(ind);
        ltData.lifetime{4}(ind)=lifet_avg{4}(ind);
        ltData.snr{1}(ind)=SNR{1}(ind);
        ltData.snr{2}(ind)=SNR{2}(ind);
        ltData.snr{3}(ind)=SNR{3}(ind);
        ltData.snr{4}(ind)=SNR{4}(ind);
        
    end
    posData.frames=length(posData.px(:));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
snr_lowerbound = snrlb;
dest_channel = channel;
df4 = im;
k=1;
for t=1:posData.frames
    if ltData.snr{dest_channel}(t)>=snr_lowerbound  && ~isnan(ltData.snr{dest_channel}(t))
        if posData.px(t)>0 && posData.py(t)>0
            if ltData.lifetime{dest_channel}(t)>0
                filterX(k,1)=posData.px(t);
                filterY(k,1)=posData.py(t);
                Radius(k,1)=posData.radius(t);
                snr(k,1)=ltData.snr{dest_channel}(t);
                k=k+1;
            end
        end
    end
end

set(gcf,'Visible', 'off');
SNRtable.xposition=filterX;
SNRtable.yposition=filterY;
SNRtable.lifetime=snr;
SNRtable.radius=Radius;

[SNR_map]=PlotSNR(SNRtable,df4);

SNR_filter=snr;
SNR_filter(SNR_filter<0)=[];
minsnr=min(SNR_filter);
maxsnr=max(SNR_filter);

[SNR_r,SNR_c]=find(SNR_map>=0);

ColorMap = colormap('jet');
flcomptable1= transpose(linspace(minsnr,maxsnr,length(ColorMap)));
for aa=1:length(SNR_r)
    for bb=1:length(flcomptable1)
        if SNR_map(SNR_r(aa),SNR_c(aa))>= flcomptable1(bb)
            df4(SNR_r(aa),SNR_c(aa),1)= floor(ColorMap(bb,1).*255);
            df4(SNR_r(aa),SNR_c(aa),2)= floor(ColorMap(bb,2).*255);
            df4(SNR_r(aa),SNR_c(aa),3)= floor(ColorMap(bb,3).*255);
        end
    end
end
df4=df4*0.6+im*0.4;

a2=figure('visible','off');
imshow(df4);
caxis([minsnr maxsnr]);
colormap jet
h1=colorbar;
ylabel(h1, ['SNR'],'Fontsize',16)
truesize([420 680]);
saveas(a2,['SNR','.jpg']);


    function [lttable]=PlotSNR(table,im)
        
        [r,c,d]=size(im);
        
        % we construct data matrix (we put the value in to its corresponding position)
        lttable= zeros(r,c);
        countable=zeros(r,c);
        
        % xpos: X position(column), ypos: Y position(row), lt: lifetime
        xpos=table.xposition;
        ypos=table.yposition;
        lifetime=table.lifetime;
        radius=table.radius;
        
        % we use progress bar when calculating the overlay
        h0=waitbar(0,'please wait');
        hund=length(xpos)-1+1;
        
        % we now start to plot overlay
        for i=1 :length(xpos)
            currentxpos=xpos(i);
            currentypos=ypos(i);
            R=round(radius(i));
            left=currentxpos-R;
            right=currentxpos+R;
            up=currentypos-R;
            down=currentypos+R;
            if left<1
                left=1;
            end
            if up<1
                up=1;
            end
            if down>r
                down=r;
            end
            if right>c
                right=c;
            end
            
            for a=left:right
                for b=up:down
                    if (sqrt((currentypos-b)^2+(currentxpos-a)^2))<=R
                        countable(b,a)=countable(b,a)+1;
                        lttable(b,a)=lttable(b,a)+lifetime(i);
                    end
                end
            end
            
            barstr=['Plotting... ',num2str((i-1+1)/hund*100),'%'];
            waitbar((i-1+1)/hund,h0,barstr)
        end
        
        lttable=lttable./countable;
        lttable(isnan(lttable))=0;
        lttable(countable==0)=-1;
        
        barstr1=['Almost done....'];
        waitbar((i-++1)/hund,h0,barstr1)
    end
end