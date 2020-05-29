function [meanlifetime,sdlifetime,ol2,str1,str2] = processImgInterpGUI( im, posData, ltData, approach,snrlb,channel,Rregion,Rnum,choice,idwp,idwtype,near)

%%% the method is required to be specified %%%
% Approach 1: Inverse Distance Weighting (P=2)
% Approach 2: Inverse Distance Weighting (P=3)
% Approach 3: Natural Neighbor Interpolation
% Approach 4: Inverse Distance Weighting (P=1)
% Approach 5: Standard Method (Averaging Overlapping Area)
% Approach 6: Inverse Distance Weighting (Customized P)
if approach ==1 || approach==2 ||approach==3 || approach==4 || approach==5 || approach==6
    
    alpha=1;
    % extract the SNR_lowerbound and desired Channel from input arguments
    snr_lowerbound = snrlb;
    dest_channel = channel;
    
    % Initial matrix for lifetime data storage
    [row,col,dim]=size(im);
    for i=1:3
        lttable{i}= double(zeros(row,col,dim));
    end
    
    % Let df3 be the variable of WLI
    df3 = im;
    % we filter our the data (X:col,Y:row,lifteime:lifetime,snr:SNR) if:
    % the SNR is lower than SNR lowerbound
    % the data does not have SNR
    % if the location of the measurement is not reasonable
    k=1;
    for t=1:posData.frames
        if ltData.snr{dest_channel}(t)>=snr_lowerbound  && ~isnan(ltData.snr{dest_channel}(t))
            if posData.px(t)>0 && posData.py(t)>0
                % choice == 1 : plot lifetime value
                if choice==1
                    if ltData.lifetime{dest_channel}(t)>0
                        filterX(k,1)=posData.px(t);
                        filterY(k,1)=posData.py(t);
                        Radius(k,1)=round(posData.radius(t));
                        filterlifetime(k,1)=ltData.lifetime{dest_channel}(t);
                        k=k+1;
                    end
                    % choice == 2 : plot intensity ratio
                elseif choice==2
                    if ltData.intensity{dest_channel}(t)>0
                        filterX(k,1)=posData.px(t);
                        filterY(k,1)=posData.py(t);
                        Radius(k,1)=round(posData.radius(t));
                        filterlifetime(k,1)=ltData.intensity{dest_channel}(t);
                        k=k+1;
                    end
                    % choice == 3: plot intesity weighted lifetime
                elseif choice==3
                    if ltData.inlt{dest_channel}(t)>0
                        filterX(k,1)=posData.px(t);
                        filterY(k,1)=posData.py(t);
                        Radius(k,1)=round(posData.radius(t));
                        filterlifetime(k,1)=ltData.inlt{dest_channel}(t);
                        k=k+1;
                    end
                    % choice == 4: plot optical redox ratio
                elseif choice==4
                    if ltData.ORR{dest_channel}(t)>0
                        filterX(k,1)=posData.px(t);
                        filterY(k,1)=posData.py(t);
                        Radius(k,1)=round(posData.radius(t));
                        filterlifetime(k,1)=ltData.ORR{dest_channel}(t);
                        k=k+1;
                    end
                else
                end
            end
        end
    end
    
    % we use cell, called table, to store the data (filtered observed data)
    table = {};
    table.xposition=filterX;
    table.yposition=filterY;
    table.lifetime=filterlifetime;
    table.radius=Radius;
    
    % calculate the upperbound and lowerbound of dynamic color bar
    % the default scale is from (mean-2*SD) to (mean+2*SD)
    meanlifetime= mean(filterlifetime);
    sdlifetime= std(filterlifetime);
    
    scale_from(dest_channel)= (meanlifetime-2.*sdlifetime);
    if scale_from(dest_channel)<0
        scale_from(dest_channel)=0;
    end
    scale_to(dest_channel)=(meanlifetime+2.*sdlifetime);
    
    % Color Map settings
    set(gcf,'Visible', 'off');
    % if we choose to plot lifetime, the default map is "jet"
    if choice==1
        ColorMap = colormap('jet');
        % if we choose to plot intensity, the default map is "hot"
    elseif choice==2
        ColorMap = colormap('hot');
        % if we choose to plot intensity weighting lifetime, the default map is "jet"
    elseif choice==3
        ColorMap = colormap('jet');
        % if we choose to plot intensity, the default map is "hot"
    elseif choice==4
        ColorMap = colormap('hot');
    else
    end
    
    %%% use interpreduce5,6(IDW,NNI) function to plot the overlay (output:lttalbe) %%%
    if approach==1
        %IDW parameter p
        parameterp=2;
        fprintf('Inverse Distance Weighting P=2 \n');
        fprintf('SNR LowerBound = %f,Alpha = %f, Parameter P=%d \n', snr_lowerbound, alpha, parameterp);
        [lttable{dest_channel}]=IDW(table,im,scale_from(dest_channel),scale_to(dest_channel),parameterp, Rregion,Rnum,idwtype,near);
    elseif approach ==2
        %IDW parameter p
        parameterp=3;
        fprintf('Inverse Distance Weighting P=3 \n' );
        fprintf('SNR LowerBound = %f,Alpha = %f, Parameter P=%d \n', snr_lowerbound, alpha, parameterp);
        [lttable{dest_channel}]=IDW(table,im,scale_from(dest_channel),scale_to(dest_channel),parameterp, Rregion,Rnum,idwtype,near);
    elseif approach==3
        fprintf('Natural Neighbor Interpolation \n');
        fprintf('SNR LowerBound = %f,Alpha = %f \n', snr_lowerbound, alpha);
        [lttable{dest_channel}]=NaturalNeighbor(table,im,scale_from(dest_channel),scale_to(dest_channel), Rregion,Rnum);
    elseif approach==4
        %IDW parameter p
        parameterp=1;
        fprintf('Inverse Distance Weighting P=1 \n');
        fprintf('SNR LowerBound = %f,Alpha = %f, Parameter P=%d \n', snr_lowerbound, alpha, parameterp);
        [lttable{dest_channel}]=IDW(table,im,scale_from(dest_channel),scale_to(dest_channel),parameterp, Rregion,Rnum,idwtype,near);
    elseif approach==5
        fprintf('Standard Method \n');
        fprintf('SNR LowerBound = %f,Alpha = %f\n', snr_lowerbound, alpha);
        [lttable{dest_channel}]=OriginalCircle(table,im,scale_from(dest_channel),scale_to(dest_channel), Rregion,Rnum);
    elseif approach==6
        %IDW parameter p
        parameterp=idwp;
        fprintf('Inverse Distance Weighting P=%d \n',idwp);
        fprintf('SNR LowerBound = %f,Alpha = %f, Parameter P=%d \n', snr_lowerbound, alpha, parameterp);
        [lttable{dest_channel}]=IDW(table,im,scale_from(dest_channel),scale_to(dest_channel),parameterp, Rregion,Rnum,idwtype,near);
    else
    end
    
    % output a variable, called ol2, which is lifetime matrix storing the lifetime value to its corresponding position of the WLI
    ol2=lttable{dest_channel};
    
    % now we fit the lifetime value to the scale of color bar
    lttable{dest_channel}(logical(lttable{dest_channel}<scale_from(dest_channel)&logical(lttable{dest_channel}>0)))=scale_from(dest_channel);
    lttable{dest_channel}(logical(lttable{dest_channel}<scale_from(dest_channel)&logical(lttable{dest_channel}<0)))=0;
    lttable{dest_channel}(logical(lttable{dest_channel}>scale_to(dest_channel)))=scale_to(dest_channel);
    
    % now we convert the lifetime value to the RGB value for each position in the constructed overlay
    [map_r,map_c,map_v]=find(lttable{dest_channel});
    
    % we now plot the RGB overlay onto WLI
    for y=1:length(map_r)
        % we first determine the corresponding RGB values
        z=floor((map_v(y)-scale_from(dest_channel))/(scale_to(dest_channel)-scale_from(dest_channel))*63+1);
        % then we display it on the WLI
        df3(map_r(y),map_c(y),1)= floor(ColorMap(z,1).*255);
        df3(map_r(y),map_c(y),2)= floor(ColorMap(z,2).*255);
        df3(map_r(y),map_c(y),3)= floor(ColorMap(z,3).*255);
    end
    
    % we now save the image file into folder for later use
    if approach==1
        a1=figure('visible','off');
        imshow(df3);
        caxis([scale_from(dest_channel) scale_to(dest_channel)]);
        if choice==1
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['Lifetime CH', int2str(dest_channel),' (ns)'],'Fontsize',16)
        elseif choice==2
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['Intensity Ratio CH', int2str(dest_channel)],'Fontsize',16)
        elseif choice==3
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['IR Lifetime CH', int2str(dest_channel),' (ns)'],'Fontsize',16)
        elseif choice==4
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['ORR'],'Fontsize',16)
        else
        end
        
        if choice==4
            if idwtype == 1
                str2= sprintf('Global IDW, P=%s, LowerBound=%d', num2str(parameterp), snr_lowerbound);
                str1= sprintf('Global IDW, P=%s, LowerBound=%d, (%s)', num2str(parameterp), snr_lowerbound,datestr(now,'yy-mm-dd'));
            else
                str2= sprintf('Local IDW (R=%s), P=%s, LowerBound=%d', num2str(near), num2str(parameterp), snr_lowerbound);
                str1= sprintf('Local IDW (R=%s), P=%s, LowerBound=%d, (%s)', num2str(near) , num2str(parameterp), snr_lowerbound,datestr(now,'yy-mm-dd'));
            end
            
        else
            if idwtype ==1
                str2= sprintf('Global IDW, P=%s, Channel=%d, LowerBound=%d', num2str(parameterp), dest_channel, snr_lowerbound);
                str1= sprintf('Global IDW, P=%s, Channel=%d, LowerBound=%d, (%s)',num2str(parameterp), dest_channel, snr_lowerbound,datestr(now,'yy-mm-dd'));
            else
                str2= sprintf('Local IDW (R=%s), P=%s, Channel=%d, LowerBound=%d', num2str(near), num2str(parameterp), dest_channel, snr_lowerbound);
                str1= sprintf('Local IDW (R=%s), P=%s, Channel=%d, LowerBound=%d, (%s)', num2str(near), num2str(parameterp), dest_channel, snr_lowerbound,datestr(now,'yy-mm-dd'));
            end
        end
        title(str2,'Fontsize',18)
        truesize([420 680]);
        saveas(a1,[str1,'.jpg']);
        
    elseif approach==2
        a1=figure('visible','off');
        imshow(df3);
        caxis([scale_from(dest_channel) scale_to(dest_channel)]);
        if choice==1
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['Lifetime CH', int2str(dest_channel),' (ns)'],'Fontsize',16)
        elseif choice==2
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['Intensity Ratio CH', int2str(dest_channel)],'Fontsize',16)
        elseif choice==3
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['IR Lifetime CH', int2str(dest_channel),' (ns)'],'Fontsize',16)
        elseif choice==4
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['ORR'],'Fontsize',16)
        else
        end
        if choice==4
            if idwtype == 1
                str2= sprintf('Global IDW, P=%s, LowerBound=%d', num2str(parameterp), snr_lowerbound);
                str1= sprintf('Global IDW, P=%s, LowerBound=%d, (%s)', num2str(parameterp), snr_lowerbound,datestr(now,'yy-mm-dd'));
            else
                str2= sprintf('Local IDW (R=%s), P=%s, LowerBound=%d', num2str(near), num2str(parameterp), snr_lowerbound);
                str1= sprintf('Local IDW (R=%s), P=%s, LowerBound=%d, (%s)', num2str(near) , num2str(parameterp), snr_lowerbound,datestr(now,'yy-mm-dd'));
            end
            
        else
            if idwtype ==1
                str2= sprintf('Global IDW, P=%s, Channel=%d, LowerBound=%d', num2str(parameterp), dest_channel, snr_lowerbound);
                str1= sprintf('Global IDW, P=%s, Channel=%d, LowerBound=%d, (%s)',num2str(parameterp), dest_channel, snr_lowerbound,datestr(now,'yy-mm-dd'));
            else
                str2= sprintf('Local IDW (R=%s), P=%s, Channel=%d, LowerBound=%d', num2str(near), num2str(parameterp), dest_channel, snr_lowerbound);
                str1= sprintf('Local IDW (R=%s), P=%s, Channel=%d, LowerBound=%d, (%s)', num2str(near), num2str(parameterp), dest_channel, snr_lowerbound,datestr(now,'yy-mm-dd'));
            end
        end
        title(str2,'Fontsize',18)
        truesize([420 680]);
        saveas(a1,[str1,'.jpg']);
    elseif approach==3
        a1=figure('visible','off');
        imshow(df3);
        caxis([scale_from(dest_channel) scale_to(dest_channel)]);
        if choice==1
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['Lifetime CH', int2str(dest_channel),' (ns)'],'Fontsize',16)
        elseif choice==2
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['Intensity Ratio CH', int2str(dest_channel)],'Fontsize',16)
        elseif choice==3
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['IR Lifetime CH', int2str(dest_channel),' (ns)'],'Fontsize',16)
        elseif choice==4
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['ORR'],'Fontsize',16)
        else
        end
        if choice==4
            str2= sprintf('Natural Neighbor Interpolation, LowerBound=%d', snr_lowerbound);
            str1= sprintf('Natural Neighbor Interpolation, LowerBound=%d, (%s)', snr_lowerbound,datestr(now,'yy-mm-dd'));
        else
            str2= sprintf('Natural Negihbor Interpolation, Channel=%d, LowerBound=%d', dest_channel, snr_lowerbound);
            str1= sprintf('Natural Negihbor Interpolation, Channel=%d, LowerBound=%d, (%s)', dest_channel, snr_lowerbound,datestr(now,'yy-mm-dd'));
        end
        title(str2,'Fontsize',18)
        truesize([420 680]);
        saveas(a1,[str1,'.jpg']);
    elseif approach==4
        a1=figure('visible','off');
        imshow(df3);
        caxis([scale_from(dest_channel) scale_to(dest_channel)]);
        if choice==1
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['Lifetime CH', int2str(dest_channel),' (ns)'],'Fontsize',16)
        elseif choice==2
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['Intensity Ratio CH', int2str(dest_channel)],'Fontsize',16)
        elseif choice==3
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['IR Lifetime CH', int2str(dest_channel),' (ns)'],'Fontsize',16)
        elseif choice==4
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['ORR'],'Fontsize',16)
        else
        end
        if choice==4
            if idwtype == 1
                str2= sprintf('Global IDW, P=%s, LowerBound=%d', num2str(parameterp), snr_lowerbound);
                str1= sprintf('Global IDW, P=%s, LowerBound=%d, (%s)', num2str(parameterp), snr_lowerbound,datestr(now,'yy-mm-dd'));
            else
                str2= sprintf('Local IDW (R=%s), P=%s, LowerBound=%d', num2str(near), num2str(parameterp), snr_lowerbound);
                str1= sprintf('Local IDW (R=%s), P=%s, LowerBound=%d, (%s)', num2str(near) , num2str(parameterp), snr_lowerbound,datestr(now,'yy-mm-dd'));
            end
            
        else
            if idwtype ==1
                str2= sprintf('Global IDW, P=%s, Channel=%d, LowerBound=%d', num2str(parameterp), dest_channel, snr_lowerbound);
                str1= sprintf('Global IDW, P=%s, Channel=%d, LowerBound=%d, (%s)',num2str(parameterp), dest_channel, snr_lowerbound,datestr(now,'yy-mm-dd'));
            else
                str2= sprintf('Local IDW (R=%s), P=%s, Channel=%d, LowerBound=%d', num2str(near), num2str(parameterp), dest_channel, snr_lowerbound);
                str1= sprintf('Local IDW (R=%s), P=%s, Channel=%d, LowerBound=%d, (%s)', num2str(near), num2str(parameterp), dest_channel, snr_lowerbound,datestr(now,'yy-mm-dd'));
            end
        end
        title(str2,'Fontsize',18)
        truesize([420 680]);
        saveas(a1,[str1,'.jpg']);
    elseif approach==5
        a1=figure('visible','off');
        imshow(df3);
        caxis([scale_from(dest_channel) scale_to(dest_channel)]);
        if choice==1
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['Lifetime CH', int2str(dest_channel),' (ns)'],'Fontsize',16)
        elseif choice==2
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['Intensity Ratio CH', int2str(dest_channel)],'Fontsize',16)
        elseif choice==3
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['IR Lifetime CH', int2str(dest_channel),' (ns)'],'Fontsize',16)
        elseif choice==4
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['ORR'],'Fontsize',16)
        else
        end
        if choice==4
            str2= sprintf('Standard Method, LowerBound=%d', snr_lowerbound);
            str1= sprintf('Standard Method, LowerBound=%d, (%s)', snr_lowerbound,datestr(now,'yy-mm-dd'));
        else
            str2= sprintf('Standard Method, Channel=%d, LowerBound=%d', dest_channel, snr_lowerbound);
            str1= sprintf('Standard Method, Channel=%d, LowerBound=%d, (%s)', dest_channel, snr_lowerbound,datestr(now,'yy-mm-dd'));
        end
        title(str2,'Fontsize',18)
        truesize([420 680]);
        saveas(a1,[str1,'.jpg']);
        
    elseif approach==6
        a1=figure('visible','off');
        imshow(df3);
        caxis([scale_from(dest_channel) scale_to(dest_channel)]);
        if choice==1
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['Lifetime CH', int2str(dest_channel),' (ns)'],'Fontsize',16)
        elseif choice==2
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['Intensity Ratio CH', int2str(dest_channel)],'Fontsize',16)
        elseif choice==3
            colormap jet
            h0 = colorbar;
            ylabel(h0, ['IR Lifetime CH', int2str(dest_channel),' (ns)'],'Fontsize',16)
        elseif choice==4
            colormap hot
            h0 = colorbar;
            ylabel(h0, ['ORR'],'Fontsize',16)
        else
        end
        if choice==4
            if idwtype == 1
                str2= sprintf('Global IDW, P=%s, LowerBound=%d', num2str(parameterp), snr_lowerbound);
                str1= sprintf('Global IDW, P=%s, LowerBound=%d, (%s)', num2str(parameterp), snr_lowerbound,datestr(now,'yy-mm-dd'));
            else
                str2= sprintf('Local IDW (R=%s), P=%s, LowerBound=%d', num2str(near), num2str(parameterp), snr_lowerbound);
                str1= sprintf('Local IDW (R=%s), P=%s, LowerBound=%d, (%s)', num2str(near) , num2str(parameterp), snr_lowerbound,datestr(now,'yy-mm-dd'));
            end
            
        else
            if idwtype ==1
                str2= sprintf('Global IDW, P=%s, Channel=%d, LowerBound=%d', num2str(parameterp), dest_channel, snr_lowerbound);
                str1= sprintf('Global IDW, P=%s, Channel=%d, LowerBound=%d, (%s)',num2str(parameterp), dest_channel, snr_lowerbound,datestr(now,'yy-mm-dd'));
            else
                str2= sprintf('Local IDW (R=%s), P=%s, Channel=%d, LowerBound=%d', num2str(near), num2str(parameterp), dest_channel, snr_lowerbound);
                str1= sprintf('Local IDW (R=%s), P=%s, Channel=%d, LowerBound=%d, (%s)', num2str(near), num2str(parameterp), dest_channel, snr_lowerbound,datestr(now,'yy-mm-dd'));
            end
        end
        title(str2,'Fontsize',18)
        truesize([420 680]);
        saveas(a1,[str1,'.jpg']);
    end
else
    % if you fail to choose the approach, it will pop up the error messages
    fprintf("please specify your visualization method \n");
end

