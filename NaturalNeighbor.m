function [lttable]=NaturalNeighbor(table,im,from,to,Rregion,Rnum)

%table:
 %(1)first cell is the width values
 %(2)second cell is the length values
 %(3)third cell is the measurement values
%im: WLI
%from: lowerbound of colorbar
%to: upperbound of colorbar
%Rregion: decision making region
%Rnum: required number of data

% determine the size of our WLI
[row,col,dim]=size(im);

% we construct a data matrix (we put the values into its corresponding position)
lttable= zeros(row,col);

% xpos: X position(column), ypos: Y position(row), lt: lifetime
xpos=table.xposition; ypos=table.yposition; lifetime=table.lifetime;

% we determine the xmax xmin ymax ymix in order to construct a rectangular
% which can include all the oberserved data (measurements)
xmax= max(xpos(:)); xmin=min(xpos(:));
ymax= max(ypos(:)); ymin=min(ypos(:));

% put all the values into matrix according to its position
for i=1:length(xpos)
    xx=xpos(i);
    yy=ypos(i);
    lttable(yy,xx)=lifetime(i);
end
datatable=lttable;

%%%Natural Neighbor interpolation%%%

F = scatteredInterpolant(xpos,ypos,lifetime);
F.Method = 'natural';
x=1:col;
y=1:row;
[xq,yq] = meshgrid(x,y);
vq1 = F(xq,yq);

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

% we use progress bar when calculating the overlay
h0=waitbar(0,'please wait');
hund=sst-ssf+1;

% we now start to do Inverse Distance Weighting interpolation
for s=ssf:sst
    for t=ttf:ttt
        % wvalue denotes the interpolated value (the value after doing IDW)
        datanum=0;
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
                    if (sqrt((t-b)^2+(s-a)^2))<Rregion
                        if datatable(a,b)>0
                            datanum=datanum+1;
                        end
                    end
                end
            end
            
            % if there are greater than or equal to "Rnum" data observed in
            % determination region, we do the interpolation at that position
            % if the number of data we observed is less than the required
            % number of data, we do not interpolate vale at that position
            if datanum>=Rnum
                lttable(s,t)= vq1(s,t);
            end
        end
    end
    
    barstr=['Plotting... ',num2str((s-ssf+1)/hund*100),'%'];
    waitbar((s-ssf+1)/hund,h0,barstr) 
end


barstr1=['Almost done....'];
waitbar((s-ssf+1)/hund,h0,barstr1)
end




