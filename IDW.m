function [lttable]=IDW(table,im,from,to,p,Rregion,Rnum,idwtype,near)

%table:
 %(1)first cell is the width values
 %(2)second cell is the length values
 %(3)third cell is the measurement values
%im: WLI
%from: lowerbound of colorbar
%to: upperbound of colorbar
%p: IDW parameter (determining the decay of influence of data /measurement)
%Rregion: decision making region
%Rnum: the required number of data

% determine the size of our WLI
[row,col,dim]=size(im);

% we construct data matrix (we put the value in to its corresponding position)
lttable= zeros(row,col);

% xpos: X position(column), ypos: Y position(row), lt: lifetime
xpos=table.xposition;
ypos=table.yposition;
lifetime=table.lifetime;

% we determine the xmax xmin ymax ymix in order to construct a rectangular
% which can include all the oberserved data (measurements)
xmax= max(xpos(:)); xmin=min(xpos(:));
ymax= max(ypos(:)); ymin=min(ypos(:));

% put all the lifetime into matrix according to its position
for i=1:length(xpos)
    xx=xpos(i);
    yy=ypos(i);
    lttable(yy,xx)=lifetime(i);
end

datatable=lttable;

%%%IDW spatial interpolation%%%

% find the datatable ~=0 (i.e. find the measurements with its position)
[dr,dc,dl]=find(datatable);

% we now determine the region where we will do the plotting decision
ssf=ymin-Rregion;
if ssf <1
    ssf=1;
end
sst=ymax+Rregion;
if sst >row
    sst=row;
end
ttf=xmin-Rregion;
if ttf <1
    ttf=1;
end
ttt=xmax+Rregion;
if ttt >col
    ttt=col;
end

% we use progress bar when calculating the FLIm map
h0=waitbar(0,'please wait');
hund=sst-ssf+1;

% we now start to do Inverse Distance Weighting interpolation
for s=ssf:sst
    for t=ttf:ttt
        datanum=0;
        flag=0;
        % decision making process (the determination region is a circle with radius "Rregion")
        if datatable(s,t)==0
            e=s-Rregion;
            f=s+Rregion;
            j=t-Rregion;
            k=t+Rregion;
            if e<1
                e=1;
            end
            if j<1
                j=1;
            end
            if f>row
                f=row;
            end
            if k>col
                k=col;
            end
            for a=e:f
                for b=j:k
                    if (sqrt((t-b)^2+(s-a)^2))<=Rregion
                        if datatable(a,b)>0
                            datanum=datanum+1;
                            if datanum>=Rnum
                                flag=1;
                                break
                            end
                        end
                    end
                end
                if flag==1
                    break
                end
            end
            
            % if the number of the measurements inside the decision making region is greater than or equal to "Rnum", 
            % we will calculate the interpolation to that position
            
            if datanum>=Rnum
                
                % we firstly determine the distance (dis)
                % between the interpolated position
                % and
                % the positions of the measurements
                
                dis=sqrt((s-dr).^2+(t-dc).^2);
                
                % If we choose to calculate with the global IDW, we take all the measurements into account
                if idwtype==1
                    distance=dis;
                    lt=dl;
                % If we choose to calculate with the local IDW, we consider the measurements which is inside the radius R (near) of the interpolated positions
                elseif idwtype==2
                    Rlimit=near;
                    distance=dis(logical(dis<=Rlimit));
                    lt=dl(logical(dis<=Rlimit));
                else
                end
                
                
                % after taking the data we like, we caculate inverse distance
                inverdistance=1./(distance.^(p));
                % cumdistance is the cumulative distance from the interpolated position to each measurement
                cumdistance=sum(inverdistance);
                % we now calculate the IDW value (interpolated value)
                wvalue=sum(lt.*(inverdistance./cumdistance));
                
                % put it back to lttable (the matrix storing the measurement to its corresponding position/pixel)
                lttable(s,t)= wvalue;
            end
        end
    end
    
    barstr=['Plotting... ',num2str((s-ssf+1)/hund*100),'%'];
    waitbar((s-ssf+1)/hund,h0,barstr)
end

barstr1=['Almost done....'];
waitbar((s-ssf+1)/hund,h0,barstr1)
end




