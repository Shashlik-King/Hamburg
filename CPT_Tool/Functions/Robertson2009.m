function Robertson2009(Q_tn,Fr,color)
% Function used for Robertson classification with regard to 2009 chart

% Use for each layer to plot the points

%% zone 1
Fr1 = 0.1:0.01:2;
Q_tn1 = 12*exp(-1.4*Fr1);
%% zone 8 & 9
Fr89 = 1.5:0.01:10;
Q_tn89 = 1./(0.005*(Fr89-1)-0.0003*(Fr89-1).^2-0.002);
Q_tn89_2 = 1/(0.005*(4.5-1)-0.0003*(4.5-1)^2-0.002);

%% zone 2
Fr2 = 0.1:0.01:10;
I_c2 = 3.60;
Q_tn2 = 10.^(3.47 - sqrt(I_c2^2 - (1.22+log10(Fr2)).^2));
counter1 = 1;
counter2 = 1;
while Q_tn2(counter1) < Q_tn1(counter1)
    if counter1 == length(Q_tn2)
        break
    else
        counter1 = counter1+1;
    end
end
Fr2 = Fr2(counter1:length(Fr2));
Q_tn2 = Q_tn2(counter1:length(Q_tn2));

%% Zone 3

Fr3 = 0.1:0.01:10;
I_c3 = 2.95;
Q_tn3 = 10.^(3.47 - sqrt(I_c3^2 - (1.22+log10(Fr3)).^2));
counter1 = 1;
counter2 = 1;
while Q_tn3(counter1) < Q_tn1(counter1)
    if counter1 == length(Q_tn3)
        break
    else
        counter1 = counter1+1;
    end
end
Fr3 = Fr3(counter1:length(Fr3));
Q_tn3 = Q_tn3(counter1:length(Q_tn3));

%% Zone 4

Fr4 = 0.1:0.01:10;
I_c4 = 2.60;
Q_tn4 = 10.^(3.47 - sqrt(I_c4^2 - (1.22+log10(Fr4)).^2));
counter1 = 1;
while Q_tn4(counter1) < Q_tn1(counter1)
    if counter1 == length(Q_tn4)
        break
    else
        counter1 = counter1+1;
    end
end
counter2 = length(0.1:0.01:1.5);
while Q_tn4(counter2) < Q_tn89(counter2-length(0.1:0.01:1.5)+1)
    counter2 = counter2+1;
end
Fr4 = Fr4(counter1:counter2);
Q_tn4 = Q_tn4(counter1:counter2);

%% Zone 5

Fr5 = 0.1:0.01:10;
I_c5 = 2.05;
Q_tn5 = 10.^(3.47 - sqrt(I_c5^2 - (1.22+log10(Fr5)).^2));
counter1 = 1;
while Q_tn5(counter1) < Q_tn1(counter1)
    if counter1 == length(Q_tn5)
        break
    else
        counter1 = counter1+1;
    end
end
counter2 = length(0.1:0.01:1.5);
while Q_tn5(counter2) < Q_tn89(counter2-length(0.1:0.01:1.5)+1)
    counter2 = counter2+1;
end
Fr5 = Fr5(counter1:counter2);
Q_tn5 = Q_tn5(counter1:counter2);

%% Zone 6

Fr6 = 0.1:0.01:1.5;
I_c6 = 1.31;
Q_tn6 = 10.^(3.47 - sqrt(I_c6^2 - (1.22+log10(Fr6)).^2));
counter1 = 1;
while Q_tn6(counter1) < Q_tn1(counter1)
    if counter1 == length(Q_tn6)
        break
    else
        counter1 = counter1+1;
    end
end
Fr6 = Fr6(counter1:length(Fr6));
Q_tn6 = Q_tn6(counter1:length(Q_tn6));

%% Plot classification card
%figure

for i=1:length(Fr1)
    if isreal(Fr1(i))==0
        Fr1(i)=NaN;
    end
end
for i=1:length(Fr2)
    if isreal(Fr2(i))==0
        Fr2(i)=NaN;
    end
end
for i=1:length(Fr3)
    if isreal(Fr3(i))==0
        Fr3(i)=NaN;
    end
end
for i=1:length(Fr4)
    if isreal(Fr4(i))==0
        Fr4(i)=NaN;
    end
end
for i=1:length(Fr5)
    if isreal(Fr5(i))==0
        Fr5(i)=NaN;
    end
end
for i=1:length(Fr6)
    if isreal(Fr6(i))==0
        Fr6(i)=NaN;
    end
end
for i=1:length(Fr89)
    if isreal(Fr89(i))==0
        Fr89(i)=NaN;
    end
end
for i=1:length(Q_tn1)
    if isreal(Q_tn1(i))==0
        Q_tn1(i)=NaN;
    end
end
for i=1:length(Q_tn2)
    if isreal(Q_tn2(i))==0
        Q_tn2(i)=NaN;
    end
end
for i=1:length(Q_tn3)
    if isreal(Q_tn3(i))==0
        Q_tn3(i)=NaN;
    end
end
for i=1:length(Q_tn4)
    if isreal(Q_tn4(i))==0
        Q_tn4(i)=NaN;
    end
end
for i=1:length(Q_tn5)
    if isreal(Q_tn5(i))==0
        Q_tn5(i)=NaN;
    end
end
for i=1:length(Q_tn6)
    if isreal(Q_tn6(i))==0
        Q_tn6(i)=NaN;
    end
end
for i=1:length(Q_tn89)
    if isreal(Q_tn89(i))==0
        Q_tn89(i)=NaN;
    end
end

hold all
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
scatter(Fr,Q_tn)
loglog(Fr1,Q_tn1,'k',Fr2,Q_tn2,'k',Fr3,Q_tn3,'k',Fr4,Q_tn4,'k',Fr5,Q_tn5,'k',Fr6,Q_tn6,'k',[4.5 4.5],[Q_tn89_2 1000],'k',Fr89,Q_tn89,'k')
%loglog(Q_tn,Fr,'color',color)%color)  % 'o'
%legend_2009(i) = loglog(F_r,Q_tn,'o');
text(0.3,2.5,'1'); text(6,1.8,'2'); text(1.7,2.7,'3'); text(0.8,8,'4'); text(0.25,16,'5'); text(0.18,70,'6'); text(0.25,500,'7'); text(3,500,'8'); text(6.5,150,'9')
xlim([0.1 10])
ylim([1 1000])
title('Robertson, 2009')
xlabel('Friction ratio, F_r [%]')
ylabel('Normalized cone resistance, Q_{tn} [-]')




