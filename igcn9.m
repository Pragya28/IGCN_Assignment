clc;
clear all;
close all;

user = randi([1,6],[15,15]);
umax = max(max(user));

final = zeros(15,15);
final(4,4) = 115;  
final(2,9) = 205;  
final(4,12) = 165; 
final(10,1) = 80;  
final(14,2) = 75;  
final(9,7) = 215;  
final(15,9) = 120; 
final(11,14) = 135;
final(15,15) = 150;

c = 1;
for i = 1:15
    for j= 1:15
        if final(i,j)==0
          final(i,j) = user(i,j);
        else
          final(i,j) = final(i,j)-user(i,j);
          b(c) = final(i,j);
          xbs(c) = i;
          ybs(c) = j;
          c = c + 1;
        end
    end
end
nbs = length(b);
figure,
for i = nbs
    rectangle('Position',[xbs(i)-3, ybs(i)-3, 7, 7]);
end
xlim([1 15]);
ylim([1 15]);

for k = 1:nbs
    [m,n] = find(final == b(k));
    c = 1;
    for pa = m-3:m+3
        for qa = n-3:n+3
            if pa > 0 && qa > 0 && pa <= 15 && qa <= 15
                if (pa == m && qa == n)
                    continue;
                else
                    if final(pa,qa) > umax
                        bgroup(k,c) = nan;
                        xcod(k,c) = nan;
                        ycod(k,c) = nan;
                        agroup(k,c) = nan;
                    else
                        bgroup(k,c) = final(pa,qa);
                        xcod(k,c) = pa;
                        ycod(k,c) = qa;
                        agroup(k,c) = str2num([num2str(pa*10+qa),num2str(abs(pa*10-qa)),num2str(final(pa,qa))]);
                    end
                end
            else
                if (pa == m) && (qa == n)
                    continue;
                else
                    bgroup(k,c) = nan;
                    xcod(k,c) = nan;
                    ycod(k,c) = nan;
                    agroup(k,c) = nan;
                end
            end
            c = c+1;
        end
    end
end
len = length(bgroup);

C2 = nan(1,len+2);
if ~isempty(agroup)
    a = 1;
    for i = 1:nbs-1
        for j = i+1:nbs
            y = intersect(agroup(i,:),agroup(j,:));
            if ~isempty(y)
                C2(a,:) = [i,j,y,zeros(1,len-length(y))];            
                a = a + 1;            
            end
        end
    end
end

C3 = nan(1,len+3);
if ~isnan(C2)
    a = 1;
    for i = 1:size(C2,1)
        for j = i+2:nbs
            if C2(i,1) < j && C2(i,2) < j
                y = intersect(C2(i,2:length(C2)),agroup(j,:));
                if ~isempty(y)
                    C3(a,:) = [C2(i,1),C2(i,2),j,y,zeros(1,len-length(y))];
                    a = a + 1;                
                end
            end
        end
    end
end

x = [b;zeros(1,nbs)];

% figure,

for i = 1:nbs
    for j = 1:len
        if ~(ismember(agroup(i,j),C2(:,3:length(C2))))
            if bgroup(i,j) <= umax && bgroup(i,j) > 0 && x(1,i) >= bgroup(i,j)
              x(1,i) = x(1,i) - bgroup(i,j);
              x(2,i) = x(2,i) + 1;
              plot(xcod(i,j),ycod(i,j),'k.');
              hold on
            end
        end
    end
end

if ~isnan(C2)
    for i = 1:size(C2,1)
        b1 = C2(i,1);
        b2 = C2(i,2);
        for j = 3:length(C2)
            if ~eq(C2(i,j),0)
                if ~(ismember(C2(i,j),C3(:,4:length(C3))))
                    q = find(agroup(b1,:) == C2(i,j));
                    u = bgroup(b1,q);
                    if u > 0
                        if u < x(1,b1) && u < x(1,b2)
                            if x(1,b1) > x(1,b2)
                                x(1,b1) = x(1,b1) - u;
                                x(2,b1) = x(2,b1) + 1;
                                plot(xcod(b1,q),ycod(b1,q),'m.');
                                hold on;
                            else
                                x(1,b2) = x(1,b2) - u;
                                x(2,b2) = x(2,b2) + 1;
                                plot(xcod(b2,q),ycod(b2,q),'m.');
                                hold on;
                            end
                        elseif u < x(1,b1) && u > x(1,b2)
                            x(1,b1) = x(1,b1) - u;
                            x(2,b1) = x(2,b1) + 1;
                            plot(xcod(b1,q),ycod(b1,q),'m.');
                            hold on;
                        elseif u > x(1,b1) && u < x(1,b2)
                            x(1,b2) = x(1,b2) - u;
                            x(2,b2) = x(2,b2) + 1;
                            plot(xcod(b2,q),ycod(b2,q),'m.');
                            hold on;
                        end
                    end
                end
            end
        end
    end
end

if ~isnan(C3)
    for i = 1:size(C3,1)
        b1 = C3(i,1);
        b2 = C3(i,2);
        b3 = C3(i,3);
        for j = 4:length(C3)
            if ~eq(C3(i,j),0)
                q = find(agroup(b1,:) == C3(i,j));
                u = bgroup(b1,q);
                arr = [x(1,b1),x(1,b2),x(1,b3),u];
                arr2 = [x(2,b1),x(2,b2),x(2,b3)];
                sorted_ar = sort(arr);
                g = find(sorted_ar == u);
                h = find(arr == sorted_ar(g+1));
                arr(h) = arr(h) - u;
                arr2(h) = arr2(h) + 1;
                plot(xcod(b1,q),ycod(b1,q),'c.');
                hold on
            end
            x(:,b1) = [arr(1),arr2(1)];
            x(:,b2) = [arr(2),arr2(2)];
            x(:,b3) = [arr(3),arr2(3)];
        end
    end
end

plot(xbs,ybs,'rs');
xlim([1 15]);
ylim([1 15]);
hold off;

Ctxstatic = 0.8;
Ctxnl = 0.04;
Pspstatic = 15;
Pspnl = 0.55;
Cps = 0.11;
upa = 0.20;
Ptx = 24;

Pstatic = (Ptx/upa*Ctxstatic+Pspstatic)*(1+Cps);
for i = 1:nbs
    nl = x(2,i);
    Pdyn(i) = (Ptx/upa*(1+Ctxstatic)*Ctxnl+Pspnl)*nl*(1+Cps);
    Pbs(i) = Pstatic + Pdyn(i);
end