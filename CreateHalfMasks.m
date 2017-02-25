function [Left,Right]=CreateHalfMasks()
    %Gives left and right masks with 8 orientations.
    SUP=25;                 % Support of the largest filter (must be odd)
    SCALE=[0.25 0.5 1];     % Sigma_{x} for the oriented filters
    NORIENT=8;              % Number of orientations
    
    NF=NORIENT*length(SCALE);
    Left=zeros(SUP,SUP,NF);
    Right=zeros(SUP,SUP,NF);
    
    ix=SUP;iy=SUP;
    cx=round(ix/2);cy=round(iy/2);r=round(ix/2);
    
    count=1;
    for scale=1:length(SCALE)
        mask=zeros(ceil(ix*SCALE(scale)),ceil(iy*SCALE(scale)));
        for i=1:size(mask,1)
            for j=1:size(mask,2)
                mask(i,j)=((ceil(cx*SCALE(scale))-i)^2+(ceil(cy*SCALE(scale))-j)^2<=(SCALE(scale)*r)^2 && i<=ceil(cx*SCALE(scale)));
            end
        end
        mask=imresize(mask,[ix,iy],'nearest');
        for orient=0:NORIENT-1
            angle=180*orient/NORIENT;  % Not 2pi as filters have symmetry
            Left(:,:,count)=imrotate(mask,angle,'crop');
            Right(:,:,count)=imrotate(mask,-angle,'crop');
            count=count+1;
        end
    end
return