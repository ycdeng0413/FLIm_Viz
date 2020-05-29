function [meanlifetime,sdlifetime,ol2,str1,str2] = replotImage(rawimgaeName, matfileName,approach,snrlb,channel,Rnum,Rregion,choice,we_include_ch4,idwp,idwtype,near,Data,standardR,txtfileName)

% read white-light image (WLI)
im = imread(rawimgaeName);

%%% There are four kinds of data which can be processed
% Data==1: Head and Neck Data (MAT file)
% Data==2: Brain Data (only Txt file)
% Data==3: Brain Data (Reconstructed)
% Data==4: Brain Data (Txt file + MAT file)

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
    
    % we can determine if we would like to include Ch4 to calculate the Intensity Ratio and Intensity Weighted Lifetime
    if we_include_ch4==1
        ch1 = mat_data(:,16)./(mat_data(:,16)+mat_data(:,17)+mat_data(:,18)+mat_data(:,19));
        ch2 = mat_data(:,17)./(mat_data(:,16)+mat_data(:,17)+mat_data(:,18)+mat_data(:,19));
        ch3 = mat_data(:,18)./(mat_data(:,16)+mat_data(:,17)+mat_data(:,18)+mat_data(:,19));
        ch4 = mat_data(:,19)./(mat_data(:,16)+mat_data(:,17)+mat_data(:,18)+mat_data(:,19));
        inlt1 = ch1.* mat_data(:, 12);
        inlt2 = ch2.* mat_data(:, 13);
        inlt3 = ch3.* mat_data(:, 14);
        inlt4 = ch4.* mat_data(:, 15);
        ltData.inlt={inlt1,inlt2,inlt3,inlt4};
        ltData.intensity ={ch1,ch2,ch3,ch4};
        ltData.ORR={(ch3./(ch2+ch3)),(ch3./(ch2+ch3)),(ch3./(ch2+ch3))};
    else
        ch1 = mat_data(:,16)./(mat_data(:,16)+mat_data(:,17)+mat_data(:,18));
        ch2 = mat_data(:,17)./(mat_data(:,16)+mat_data(:,17)+mat_data(:,18));
        ch3 = mat_data(:,18)./(mat_data(:,16)+mat_data(:,17)+mat_data(:,18));
        inlt1 = ch1.* mat_data(:, 12);
        inlt2 = ch2.* mat_data(:, 13);
        inlt3 = ch3.* mat_data(:, 14);
        ltData.intensity ={ch1,ch2,ch3};
        ltData.inlt={inlt1,inlt2,inlt3};
        ltData.ORR={(ch3./(ch2+ch3)),(ch3./(ch2+ch3)),(ch3./(ch2+ch3))};
    end
    
elseif Data==2
    mat_data = load( matfileName );
    posData = {};
    posData.px = mat_data(:, 6);
    posData.py = mat_data(:, 7);
    posData.frames = size(mat_data, 1);
    posData.radius = mat_data(:, 8)/2;
    ltData = {};
    ltData.lifetime  = {mat_data(:, 2), mat_data(:, 3), mat_data(:, 4), mat_data(:, 5)};
    %fabricate SNR
    SNR=zeros(posData.frames,1);
    ltData.snr = {SNR,SNR,SNR,SNR};
    
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
                
                if we_include_ch4==1
                    
                    ltData.intensity{1}(i) = INT_map{1}(r,c)/( INT_map{1}(r,c)+INT_map{2}(r,c)+INT_map{3}(r,c)+INT_map{4}(r,c));
                    ltData.intensity{2}(i) = INT_map{2}(r,c)/( INT_map{1}(r,c)+INT_map{2}(r,c)+INT_map{3}(r,c)+INT_map{4}(r,c));
                    ltData.intensity{3}(i) = INT_map{3}(r,c)/( INT_map{1}(r,c)+INT_map{2}(r,c)+INT_map{3}(r,c)+INT_map{4}(r,c));
                    ltData.intensity{4}(i) = INT_map{4}(r,c)/( INT_map{1}(r,c)+INT_map{2}(r,c)+INT_map{3}(r,c)+INT_map{4}(r,c));
                    
                    ltData.inlt{1}(i) =ltData.lifetime{1}(i)*ltData.intensity{1}(i);
                    ltData.inlt{2}(i) =ltData.lifetime{2}(i)*ltData.intensity{2}(i);
                    ltData.inlt{3}(i) =ltData.lifetime{3}(i)*ltData.intensity{3}(i);
                    ltData.inlt{4}(i) =ltData.lifetime{4}(i)*ltData.intensity{4}(i);
                    
                    ltData.ORR{1}(i)= ltData.intensity{3}(i)/(ltData.intensity{2}(i)+ltData.intensity{3}(i));
                    ltData.ORR{2}(i)= ltData.intensity{3}(i)/(ltData.intensity{2}(i)+ltData.intensity{3}(i));
                    ltData.ORR{3}(i)= ltData.intensity{3}(i)/(ltData.intensity{2}(i)+ltData.intensity{3}(i));
                    
                else
                    
                    ltData.intensity{1}(i) = INT_map{1}(r,c)/( INT_map{1}(r,c)+INT_map{2}(r,c)+INT_map{3}(r,c));
                    ltData.intensity{2}(i) = INT_map{2}(r,c)/( INT_map{1}(r,c)+INT_map{2}(r,c)+INT_map{3}(r,c));
                    ltData.intensity{3}(i) = INT_map{3}(r,c)/( INT_map{1}(r,c)+INT_map{2}(r,c)+INT_map{3}(r,c));
                    
                    ltData.inlt{1}(i) =ltData.lifetime{1}(i)*ltData.intensity{1}(i);
                    ltData.inlt{2}(i) =ltData.lifetime{2}(i)*ltData.intensity{2}(i);
                    ltData.inlt{3}(i) =ltData.lifetime{3}(i)*ltData.intensity{3}(i);
                    
                    ltData.ORR{1}(i)= ltData.intensity{3}(i)/(ltData.intensity{2}(i)+ltData.intensity{3}(i));
                    ltData.ORR{2}(i)= ltData.intensity{3}(i)/(ltData.intensity{2}(i)+ltData.intensity{3}(i));
                    ltData.ORR{3}(i)= ltData.intensity{3}(i)/(ltData.intensity{2}(i)+ltData.intensity{3}(i));
                end
                i=i+1;
            end
        end
    end
    posData.frames=length(posData.px(:));
    
    
elseif Data==4
    txt=load(txtfileName);
    load(matfileName,'ID','SNR','lifet_avg','spec_int');
    
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
        if we_include_ch4==1
            
            ltData.intensity{1}(ind) = spec_int{1}(ind)/( spec_int{1}(ind)+spec_int{2}(ind)+spec_int{3}(ind)+spec_int{4}(ind));
            ltData.intensity{2}(ind) = spec_int{2}(ind)/( spec_int{1}(ind)+spec_int{2}(ind)+spec_int{3}(ind)+spec_int{4}(ind));
            ltData.intensity{3}(ind) = spec_int{3}(ind)/( spec_int{1}(ind)+spec_int{2}(ind)+spec_int{3}(ind)+spec_int{4}(ind));
            ltData.intensity{4}(ind) = spec_int{4}(ind)/( spec_int{1}(ind)+spec_int{2}(ind)+spec_int{3}(ind)+spec_int{4}(ind));
            
            ltData.inlt{1}(ind) =ltData.lifetime{1}(ind)*ltData.intensity{1}(ind);
            ltData.inlt{2}(ind) =ltData.lifetime{2}(ind)*ltData.intensity{2}(ind);
            ltData.inlt{3}(ind) =ltData.lifetime{3}(ind)*ltData.intensity{3}(ind);
            ltData.inlt{4}(ind) =ltData.lifetime{4}(ind)*ltData.intensity{4}(ind);
            
            ltData.ORR{1}(ind)= ltData.intensity{3}(ind)/(ltData.intensity{2}(ind)+ltData.intensity{3}(ind));
            ltData.ORR{2}(ind)= ltData.intensity{3}(ind)/(ltData.intensity{2}(ind)+ltData.intensity{3}(ind));
            ltData.ORR{3}(ind)= ltData.intensity{3}(ind)/(ltData.intensity{2}(ind)+ltData.intensity{3}(ind));
        else
            ltData.intensity{1}(ind) = spec_int{1}(ind)/( spec_int{1}(ind)+spec_int{2}(ind)+spec_int{3}(ind));
            ltData.intensity{2}(ind) = spec_int{2}(ind)/( spec_int{1}(ind)+spec_int{2}(ind)+spec_int{3}(ind));
            ltData.intensity{3}(ind) = spec_int{3}(ind)/( spec_int{1}(ind)+spec_int{2}(ind)+spec_int{3}(ind));
            
            ltData.inlt{1}(ind) =ltData.lifetime{1}(ind)*ltData.intensity{1}(ind);
            ltData.inlt{2}(ind) =ltData.lifetime{2}(ind)*ltData.intensity{2}(ind);
            ltData.inlt{3}(ind) =ltData.lifetime{3}(ind)*ltData.intensity{3}(ind);
            
            ltData.ORR{1}(ind)= ltData.intensity{3}(ind)/(ltData.intensity{2}(ind)+ltData.intensity{3}(ind));
            ltData.ORR{2}(ind)= ltData.intensity{3}(ind)/(ltData.intensity{2}(ind)+ltData.intensity{3}(ind));
            ltData.ORR{3}(ind)= ltData.intensity{3}(ind)/(ltData.intensity{2}(ind)+ltData.intensity{3}(ind));
        end
    end
    posData.frames=length(posData.px(:));
end

% process
[meanlifetime,sdlifetime,ol2,str1,str2]=processImgInterpGUI(im, posData,ltData,approach,snrlb,channel,Rregion,Rnum,choice,idwp,idwtype,near);
end