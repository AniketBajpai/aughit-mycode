
readerobj = VideoReader('a.avi', 'tag', 'arena');  %reading video from folder
lastframe=read(readerobj, get(readerobj,'NumberOfFrames') );
secondlast=read(readerobj,get(readerobj,'NumberOfFrames')-5) ;
firstframe=read(readerobj,1);

radius=18 ;width=10;                                                      % to get the middle two values of x coordintes which will be used in reflection later
leftb=10 ;
rightb=792;                                                    % taking x coordinated of left boundary and right boundary 
yspan=40;xspan=68;
lengthofarena=800 ;effL=lengthofarena-2*(radius+width);
ratio=1;             % ratio is the ratio of actual to virtual distance


paddleT=imread('paddleT.png');                                 % templates
ballT=imread('ballT.png');
b=imread('brickT.png');

cc=normxcorr2(paddleT(:,:,1),lastframe(:,:,1));                % paddle detection
[m,location]=max(abs(cc(:)));
[y,x]=ind2sub(size(cc),location);
paddletop=y-36;
paddlecenter=x-68;


cc1=normxcorr2(ballT(:,:,2),lastframe(:,:,2));                 % ball detection 
cc2=normxcorr2(ballT(:,:,2),secondlast(:,:,2));
[m1,location1]=max(abs(cc1(:)));
[y1,x1]=ind2sub(size(cc1),location1);
[m2,location2]=max(abs(cc2(:)));
[y2,x2]=ind2sub(size(cc2),location2);
c1x=x1-19;c1y=y1-18;
c2x=x2-19;c2y=y2-18;


b_direction=(y2-y1)/(x2-x1);                                   % ball direction
 
if b_direction<0                                               % paddle movement

	b_direction=abs(b_direction);
	c1x=lengthofarena-c1x;
	finaly=paddletop-radius;
	finalx=(finaly-c1y)/b_direction+ c1x- (radius+width);
	n=finalx/effL;n=floor(n);
	R=rem(finalx,effL);
	
	
	if(rem(n,2)==0)
		new_pos=lengthofarena-(radius+width)-R;
		
	else
		new_pos=(radius+width)+R;
	end
	
end 


if b_direction>0

	finaly=paddletop-radius;
	finalx=(finaly-c1y)/b_direction+ c1x- (radius+width);
	n=finalx/effL;n=floor(n);
	R=rem(finalx,effL);
	
	
	if(rem(n,2)==0)
		new_pos=(radius+width)+R;
	else
		new_pos=lengthofarena-(radius+width)-R;
	end
			
end


                                       %% brick detection starts

diff_im = imsubtract(b(:,:,3), rgb2gray(b));
    diff_im=medfilt2(diff_im,[3 3]);
    diff_im=im2bw(diff_im,0.1);
    diff_im=bwareaopen(diff_im,50);                            
    bw5=bwlabel(diff_im,8);
	
	
	
    bound=lastframe ;                        
    diff_im = imsubtract(bound(:,:,1), rgb2gray(bound));
    diff_im=medfilt2(diff_im,[3 3]);
    diff_im=im2bw(diff_im,0.1);
    diff_im=bwareaopen(diff_im,50);                            
    bw1=bwlabel(diff_im,8);
                                 
    diff_im = imsubtract(bound(:,:,2), rgb2gray(bound));
    diff_im=medfilt2(diff_im,[3 3]);
    diff_im=im2bw(diff_im,0.1);
    diff_im=bwareaopen(diff_im,50);                            
    bw2=bwlabel(diff_im,8);
                                   
    diff_im = imsubtract(bound(:,:,3), rgb2gray(bound));
    diff_im=medfilt2(diff_im,[3 3]);
    diff_im=im2bw(diff_im,0.1);
    diff_im=bwareaopen(diff_im,50);                            
    bw3=bwlabel(diff_im,8);



bw4=bw1+bw2+bw3;        %bw4 is the image containg all elements in the image in white form
cc5=normxcorr2(bw5(:,:,1),bw4(:,:,1));
I=find(cc5 > 0.999 ) ;
[yb,xb]=ind2sub(size(cc5),I);
yb=yb-10-yspan/2;xb=xb-13-xspan/2;                               %%brick detection ends


                      %% brick aiming starts 

    xbs=sort(xb);
	ybs=sort(yb);
	paddlex=new_pos;
	paddley=paddletop;
    if b_direction>0            %%ball coming from left
                            %target left bottom brick
	 	
	i=1;y_xmin=[];
	for x=xb
		if  x==xbs(1) 
		y_xmin=[y_xmin,i];
		end
	i=i+1;
	end
	max=0;
	for j=i;
		if(yb(j)>=max)
		max=yb(j);
		end
	end
    targetbx=xbs(1);
	targetby=max;
	aim_angle=atan(( paddley-targetby-radius) /(paddlex-targetbx)) ;
    rotation=(aim_angle+atan(b_direction))/2; 
	end

	if b_direction<0                  %%ball coming from right 
                                   %%target right bottom brick
      b_direction=abs(b_direction);
	  targetbx=xbs(1);
	  targetby=ybs(1);
	  aim_angle=atan(abs( (paddley-targetby-radius) /(paddlex-targetbx-radius))) ;
      rotation=3.14-(aim_angle+atan(b_direction))/2; 
	  end       
                     %% brick aiming ends here

					 


distance_moved=(new_pos-paddlecenter)*ratio;
distance_moved=round(distance_moved);
rotation=180*rotation/3.14;
rotation=round(rotation);
string_moved=int2str(distance_moved);
if rotation~=0
	digits=0;r=rotation;string_rotation=[];
	while r>0
		string_rotation=[rem(r,10),string_rotation];
		r=floor(r/10);
		digits=digits+1;
	end
	if digits==1
		string_rotation=[0,0,string_rotation];
	elseif digits==2
		string_rotation=[0,string_rotation];
	else
		string_rotation=string_rotation;
	end
	string_moved=[string_moved,'a'];
	string_rotation=mat2str(string_rotation);
	str=' ';
	str(1)=string_rotation(2);
	str(2)=string_rotation(4);
	str(3)=string_rotation(6);
	strcat(string_moved,str)                         
else
	string_moved=[string_moved,'a','0','0','0']
end
	