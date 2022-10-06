function animaition_dogrun
    clear
    stepangle=2;
    stepdrop=1;
    stepjump=2;
    inter=3;
    A=[0 0;0 0;0 0;0 0];
    B=[0 0;0 0;2 0;2 0];
    angPF=30/180*pi;
    angNF=-30/180*pi;
    angPB=30/180*pi;
    angNB=-30/180*pi;
    angM=0/180*pi;
    hhigh=2*cos(max([abs(angNF),abs(angNB)]))*0.95;
    hmid=hhigh*0.7;
    hlow=hhigh*0.7;

%     figure;
    n=0;
    for p=1:1
        %standby and jump up
        jaF=[angM repmat(angNF,[1 stepjump])];
        jaB=[angM repmat(angNB,[1 stepjump])];
        h=[hlow:(hhigh-hlow)/stepjump:hhigh];
        for j=1:length(h);
            loop1;
        end
        
        %draw back
        jaF=repmat([angNF],stepdrop);
        jaB=repmat([angNB],stepdrop);        
        h=[(hhigh+(hlow-hhigh)/stepdrop):(hlow-hhigh)/stepdrop:hlow];
        for j=1:length(h);
            loop2;
        end

        % move leg forward
        jaF=[angM angPF];
        jaB=[angM angPB];
        h=[hlow hmid];
        for j=1:length(h);
            loop2;
        end
        
        % put leg down
        dl(1)=B(1,2);
        dl(2)=B(1,2);
        jaF=(angPF);
        jaB=(angPB);
        h=(hmid);
        for j=1:length(h)
            O=O-repmat(dl,[4 1]);
            loop2;
        end
        
        % move leg backward
        jaF=(angPF:(angM-angPF)/(stepangle):angM);
        jaB=(angPB:(angM-angPB)/(stepangle):angM);
        h=hlow+(0:stepangle)*(hlow-hmid)/stepangle;
        for j=1:length(h)
            loop1;
        end
    end
    
    % shift front and back leg
    ang1=ang;
    shift=3;
    ang1(1:(size(ang,1)-shift),[3 4 7 8])=ang((shift+1):(size(ang,1)),[3 4 7 8]);
    ang1((size(ang,1)-shift+1):size(ang,1),[3 4 7 8])=ang(1:shift,[3 4 7 8]);
    ang=ang1;

    %interpalation
    ang1=zeros(size(ang,1)*inter,size(ang,2));
    for i=1:size(ang,2)
        for j=1:size(ang,1)-1
            ang1((j-1)*inter+(1:inter),i)=interp1([0 1],[ang(j,i) ang(j+1,i)],0:1/inter:1-1/inter);
        end
        ang1((j)*inter+(1:inter),i)=interp1([0 1],[ang(j+1,i) ang(1,i)],0:1/inter:1-1/inter);
    end
    ang=ang1;
%     animation_show(ang);
    ang=round(ang);
    
    fid=fopen('ang.txt','wt');
    fprintf(fid,'%g, ',size(ang,1));fprintf(fid,'%g, ',0);fprintf(fid,'%g, ',0);fprintf(fid,'%g,\n',1);
    for i=1:size(ang,1)
        fprintf(fid,'  ');
        for j=1:size(ang,2)
            text=ang(i,j);
            fprintf(fid,'%g, ',text);
        end
        fprintf(fid,'\n');
    end

    function leg=legdown(h,ja)
        leg(1)=h/2/cos(ja)*sin(ja)+sqrt(1-(h/2/cos(ja))^2)*cos(ja);
        leg(2)=h/2/cos(ja)*cos(ja)-sqrt(1-(h/2/cos(ja))^2)*sin(ja);
    end
    function leg=legup(h,ja)
        leg(1)=h/2/cos(ja)*sin(ja)-sqrt(1-(h/2/cos(ja))^2)*cos(ja);
        leg(2)=h/2/cos(ja)*cos(ja)+sqrt(1-(h/2/cos(ja))^2)*sin(ja);
    end
    function plotleg
        hold off;
        plot(-15,-5,'.');hold on;axis equal
        plot(3,5,'.');
        plot([O(1,1) O(4,1)],[O(1,2) O(4,2)]);
        for ii=1:4
            plot([O(ii,1),A(ii,1)],[O(ii,2),A(ii,2)]);plot([B(ii,1),A(ii,1)],[B(ii,2),A(ii,2)]);
        end
        pause(1.5);drawnow;
    end
    function toang
        ang(n,1:4)=(-atan((O(1:4,1)-A(1:4,1))./(O(1:4,2)-A(1:4,2)))/pi*180)';
        ang(n,5:8)=(mod(acot((A(1:4,1)-B(1:4,1))./(A(1:4,2)-B(1:4,2)))/pi*180-ang(n,1:4)'+89.9,180)-90)';
    end 
    function loop1
            n=n+1;
            A([1 2],:)=B([1 2],:)+repmat(legdown(h(j),jaF(j)),[2 1]);A([3 4],:)=B([3 4],:)+repmat(legdown(h(j),jaB(j)),[2 1]);
            O([1 2],:)=A([1 2],:)+repmat(legup(h(j),jaF(j)),[2 1]);O([3 4],:)=A([3 4],:)+repmat(legup(h(j),jaB(j)),[2 1]);
            toang;
%             plotleg;
    end
    function loop2
            n=n+1;
            A([1 2],:)=O([1 2],:)-repmat(legup(h(j),jaF(j)),[2 1]);A([3 4],:)=O([3 4],:)-repmat(legup(h(j),jaB(j)),[2 1]);
            B([1 2],:)=A([1 2],:)-repmat(legdown(h(j),jaF(j)),[2 1]);B([3 4],:)=A([3 4],:)-repmat(legdown(h(j),jaB(j)),[2 1]);
            toang;
%             plotleg;
    end
end

