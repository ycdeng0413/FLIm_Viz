function [lttable]=OriginalCircle(table,im,from,to,Rregion,Rnum)

%table:
 %(1)first cell is the width values
 %(2)second cell is the length values
 %(3)third cell is the measurement values
%im: WLI
%from: lowerbound of colorbar
%to: upperbound of colorbar
%Rregion: decision making region
%Rnum: the required number of data

% determine the size of our WLI
[row,col,dim]=size(im);

% we construct a data matrix (we put the value in to its corresponding position)
lttable= zeros(row,col);
countable=zeros(row,col);

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
    if down>row
        down=row;
    end
    if right>col
        right=col;
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

% We average the values of the overlapping regions
lttable=lttable./countable;
lttable(isnan(lttable))=0;


barstr1=['Almost done....'];
waitbar((i-++1)/hund,h0,barstr1)
end
