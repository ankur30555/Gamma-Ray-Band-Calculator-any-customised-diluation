clear
clc
tolerance=input('please input maximum diluation length in meters=');
tolerance=tolerance+0.011;
[aa,rr,xx]=xlsread('base.xlsx');
aa(isnan(aa))=-1;
tt=size(aa);
cutoff_grade=input('please input cutoff grade (eg 0.01 or 0.02 etc) in percentage='); % you can change your cutoff grade to any value.
cutoff_grade=cutoff_grade-0.0005; %sometime lab gives 0.0095 but shows like 0.01 to not ignore such values we substract 0.0005
for i=1:tt
    if aa(i,1)>-1 && aa(i,3)==1;
        a(i,1)=aa(i,2)-0.1;
        a(i,2)=10;
        a(i,3)=0;
    elseif aa(i,1)==-1 && aa(i,3)==1;
        a(i,1)=0;
        a(i,2)=10;
        a(i,3)=0;
    elseif aa(i,1)==-1 && aa(i,3)==-1;
        a(i,1)=0;
        a(i,2)=10;
        a(i,3)=aa(i,4);
    end;
end;
aaa=a;
s=size(a);
%The above code convert the gamma ray data into core-assay format 

for i=1:s(1);
    if a(i,1)~=0;
    p(i,1)=a(i,1);
    p(i,2)=a(i,1)+a(i,2)/100;
    p(i,3)=a(i,3);
    else
        a(i,1)=p(i-1,2);
        p(i,1)=a(i,1);
        p(i,2)=a(i,1)+a(i,2)/100;
        p(i,3)=a(i,3);
    end;
end;
%the above loop convert the data into 'from (m)' 'to(m)' 'grade' format
%Till now the values correspond to grade less than 0.01 not removed yet
t=1;

for i=1:s(1);
    if p(i,3)~=0;
        q(t,1)=p(i,1);q(t,2)=p(i,2);q(t,3)=p(i,2)-p(i,1);q(t,4)=p(i,3);
        t=t+1;
    end;
end;
%loop return q matrix in format of 'from(m)' 'to(m)' 'width(m)' 'grade'
%It also remove bands correspond to grade <0.01 
u=size(q);
w=1;

for i=1:u(1,1)-1;
    if q(i+1,1)-q(i,2)==0
        b(w,1)=q(i,1);b(w,2)=q(i,2);b(w,3)=q(i,3);b(w,4)=q(i,4);
        w=w+1;
    else 
        b(w,1)=q(i,1);b(w,2)=q(i,2);b(w,3)=q(i,3);b(w,4)=q(i,4);
        b(w+1,1)=q(i,2);b(w+1,2)=q(i+1,1);b(w+1,3)=b(w+1,2)-b(w+1,1);b(w+1,4)=0;
        w=w+2;
    end;
end;
 b(w,1)=q(i+1,1);b(w,2)=q(i+1,2);b(w,3)=b(w,2)-b(w,1);b(w,4)=q(i+1,4);
 %loop return matrix b, b is in format of 'from' 'to' 'thick' 'grade'
 %It also insert <0.01 grade band inbetween the non-zero grade bands 
 y=size(b);
 w=1;
 
 for i=1:y(1,1)
     if b(i,4)~=0 
         c(w,1)=b(i,1);
         c(w,2)=b(i,2);
         c(w,3)=b(i,3);
         c(w,4)=b(i,4);
         w=w+1;
     elseif b(i,4)==0 && b(i,3)<=tolerance
         c(w,1)=b(i,1);
         c(w,2)=b(i,2);
         c(w,3)=b(i,3);
         c(w,4)=b(i,4);
         w=w+1;
     end;
end;
c=[c;zeros(1,4)];
% The loop remove all bands with less than <0.01, except those bands whose
% thickness is less than or equal to tolerance.
% c=[c; zeros(1,4)]; puts zeros at the end of matrix 'c'
y=size(c);

for i=1:y(1,1)-1;
    if c(i,4)==0
       c(i,4)=0.005;
    end;
end;
% The loop give diluated bands grade of 0.05 and calculate thickness*grade
% for these diluated bands at column four (i.e c(i,4)).
 y=size(c);
 for i=1:y(1,1)
     c(i,5)=i;
 end;
 %here I have add extra coloumn 5 which contain index of each band  that 
 %I will use ahead to sort the bands according to their respective depth.
 d=1;
for i=1:y(1,1);
    if c(i,4)>=cutoff_grade;
        g(d,1)=c(i,1);g(d,2)=c(i,2);g(d,3)=c(i,3);g(d,4)=c(i,4);g(d,5)=c(i,5);
        d=d+1;
    end;
end;

u=size(g);
% The above loop give matrix of values >=cutoff_grade.
h=[0 0 0 0 y(1,1)+1];
% here in case if the upcoming loop return empty matrix then this h will
% not give error at 135th line where we combine h with 
w=1;
for i=1:u(1,1)-1
    if g(i+1,1)-g(i,2)~=0 && g(i+1,1)-g(i,2)<=tolerance
        dif=g(i+1,5)-g(i,5)-1;
        k=g(i,5);jj=1;
        for ii=1:dif
            h(w,1)=c(k+jj,1);
            h(w,2)=c(k+jj,2);
            h(w,3)=c(k+jj,3);
            h(w,4)=c(k+jj,4);
            h(w,5)=c(k+jj,5);
            jj=jj+1;w=w+1;
        end;
    end;
end;
Permitted_diluation_bands(:,1:4)=h(:,1:4);
%the above loop return the 'h' matrix which contain only those bands which lie inbetween cutoff
%grade bands that can be diluated because there combine thickness is less than
% or equal to tolerance or permitted diluation length
if h(1,1)==0 && h(1,2)==0;
    hh=g;
else hh=[h;g];
end;
% here we combine the diluated bands with cutoff grade bands
bb=sortrows(hh,5);
%here we depth wise sorted the combine bands and permissible diluated bands
kk(:,1:4)=bb(:,1:4);
%here just copy the the first 4 coloumn of bb matrix into kk matrix.
bb(:,4)=bb(:,4).*bb(:,3);
%calulate the 'thickness x grade' for the individual band in 'coloumn 4'.
bb=[bb;zeros(1,5)];
y=size(bb);w=1;u=1;e(w,3)=0;e(w,4)=0;
 for i=1:y(1,1)-1
     e(w,1)=bb(u,1);
     e(w,2)=bb(i,2);
     e(w,3)=e(w,3)+bb(i,3);
     e(w,4)=e(w,4)+bb(i,4);
     if bb(i+1,1)-bb(i,2)~=0 
        e(w,4)=e(w,4)/e(w,3);
        w=w+1;u=i+1;e(w,3)=0;e(w,4)=0;
     end;
end;
y=length(e);
GR_O2_band_accurate=e(1:y(1,1)-1,:);
GR_O2_Individualband_with_diluated_values=kk;
clearvars -except GR_O2_band_accurate GR_O2_Individualband_with_diluated_values Permitted_diluation_bands g 
%'GR_O2_Individualband_with_diluated_values' contain all bands which are
%greater than, equal to and less than desired cutoff grade and have been
%used for the calculation of bands in 'GR_O2_band_accurate' matrix
GR=GR_O2_band_accurate;
s=size(GR);
p=size(g);
for i=1:s(1);
    ss=0;
    for ii=1:p(1);
    if g(ii,1)>=GR(i,1) && g(ii,1)<=GR(i,2);
        ss=ss+g(ii,3);
    end;
    end;
    dp(i,1)=ss;
    dp(i,1)=(GR(i,3)-dp(i,1))*100/GR(i,3);
end;
ANK_GR_band(:,1:2)=[GR_O2_band_accurate(:,1:2)+0.05];
ANK_GR_band(:,3:4)=[GR_O2_band_accurate(:,3:4)];
ANK_GR_band(:,5)=[dp(:,1)];
ANK_GR_Individualband_with_diluated_values(:,1:2)=[GR_O2_Individualband_with_diluated_values(:,1:2)+0.05];
ANK_GR_Individualband_with_diluated_values(:,3:4)=[GR_O2_Individualband_with_diluated_values(:,3:4)];
clearvars -except ANK_GR_band ANK_GR_Individualband_with_diluated_values Permitted_diluation_bands  
