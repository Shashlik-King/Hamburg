function [B, L, U] = smoothening_CPT(A)

%% Importing data from CPTs files
%CPT_location = {'CPT02','CPT05A','CPT06A','CPT09','CPT12','CPT13A','CPT14','CPT15B','CPT18','CPT19','CPT20B','CPT21A','CPT22A','CPT24A','CPT25','CPT29','CPT30','CPT31A','CPT33A','CPT36A','CPT37','CPT40A','CPT41','CPT42A','CPT45','CPT47'} ;

for i=1%:length(CPT_location)
    
%     [A,Text]=xlsread([pwd,'\CPT entire data.xlsx'],CPT_location{i});

% E(:,1)=Text(2:length(Text),1);
% E(:,2)=Text(2:length(Text),8);
% T=Text(1,:);

%% Smoothening of picks
                                                                                                                                                                                                                                                                                                        
U=A;
B=A;
L=A;

F=1;            %empirical factor (low peaks smoothening)
G=1;            %empirical factor (high peaks smoothening)

%% Best estimate 

for z= (11):(length(A)-11)                                % qc smoothening
    S= std(A((z-10):(z+10),2));
    M= mean(A((z-10):(z+10),2));
    if ((M-F*S) > A(z,2)) || ((M+G*S) < A(z,2))
        B((z-9):(z+9),2)=M;
    end
end

% for z= (11):(length(A)-11)                                % qt smoothening
%     S= std(A((z-10):(z+10),3));
%     M= mean(A((z-10):(z+10),3));
%     if ((M-F*S) > A(z,3)) | ((M+G*S) < A(z,3))
%         B((z-9):(z+9),3)=M;
%     end
% end
% 
% for z= (11):(length(A)-11)                                % u2 smoothening
%     S= std(A((z-10):(z+10),5));
%     M= mean(A((z-10):(z+10),5));
%     if ((M-F*S) > A(z,5)) | ((M+G*S) < A(z,5))
%         B((z-9):(z+9),5)=M;
%     end
% end

%% Upper bound

for z= (11):(length(A)-11)                               % qc smoothening
    S= std(A((z-10):(z+10),2));
    M= mean(A((z-10):(z+10),2));
    if ((M-F*S) > A(z,2)) 
        U((z-9):(z+9),2)=M;
    end
end

% for z= (11):(length(A)-11)                               % qt smoothening
%     S= std(A((z-10):(z+10),3));
%     M= mean(A((z-10):(z+10),3));
%     if ((M-F*S) > A(z,3)) 
%         U((z-9):(z+9),3)=M;
%     end
% end
% 
% for z= (11):(length(A)-11)                                % u2 smoothening
%     S= std(A((z-10):(z+10),5));
%     M= mean(A((z-10):(z+10),5));
%     if ((M-F*S) > A(z,5)) 
%         U((z-9):(z+9),5)=M;
%     end
% end

%% Lower bound

for z= (11):(length(A)-11)                                % qc smoothening
    S= std(A((z-10):(z+10),2));
    M= mean(A((z-10):(z+10),2));
    if  ((M+G*S) < A(z,2))
        L((z-9):(z+9),2)=M;
    end
end

% for z= (11):(length(A)-11)                                % qt smoothening
%     S= std(A((z-10):(z+10),3));
%     M= mean(A((z-10):(z+10),3));
%     if ((M+G*S) < A(z,3))
%         L((z-9):(z+9),3)=M;
%     end
% end
% 
% for z= (11):(length(A)-11)                                % u2 smoothening
%     S= std(A((z-10):(z+10),5));
%     M= mean(A((z-10):(z+10),5));
%     if  ((M+G*S) < A(z,5))
%         L((z-9):(z+9),5)=M;
%     end
% end

% xlswrite([pwd,'\Updated values BE.xlsx'],T,[CPT_location{i}],'A1:I1');
% xlswrite([pwd,'\Updated values BE.xlsx'],B(:,1:6),[CPT_location{i}],['B2:G',num2str(length(A))]);
% xlswrite([pwd,'\Updated values BE.xlsx'],B(:,8),[CPT_location{i}],['I2:I',num2str(length(A))]);
% xlswrite([pwd,'\Updated values BE.xlsx'],E(:,1),[CPT_location{i}],['A2:A',num2str(length(A))]);
% xlswrite([pwd,'\Updated values BE.xlsx'],E(:,2),[CPT_location{i}],['H2:H',num2str(length(A))]);
% 
% xlswrite([pwd,'\Updated values UB.xlsx'],T,[CPT_location{i}],'A1:I1');
% xlswrite([pwd,'\Updated values UB.xlsx'],U(:,1:6),[CPT_location{i}],['B2:G',num2str(length(A))]);
% xlswrite([pwd,'\Updated values UB.xlsx'],U(:,8),[CPT_location{i}],['I2:I',num2str(length(A))]);
% xlswrite([pwd,'\Updated values UB.xlsx'],E(:,1),[CPT_location{i}],['A2:A',num2str(length(A))]);
% xlswrite([pwd,'\Updated values UB.xlsx'],E(:,2),[CPT_location{i}],['H2:H',num2str(length(A))]);
% 
% xlswrite([pwd,'\Updated values LB.xlsx'],T,[CPT_location{i}],'A1:I1');
% xlswrite([pwd,'\Updated values LB.xlsx'],L(:,1:6),[CPT_location{i}],['B2:G',num2str(length(A))]);
% xlswrite([pwd,'\Updated values LB.xlsx'],L(:,8),[CPT_location{i}],['I2:I',num2str(length(A))]);
% xlswrite([pwd,'\Updated values LB.xlsx'],E(:,1),[CPT_location{i}],['A2:A',num2str(length(A))]);
% xlswrite([pwd,'\Updated values LB.xlsx'],E(:,2),[CPT_location{i}],['H2:H',num2str(length(A))]);
% 
% clear D A B D E U L S T z 

B = B(:,2);
L = L(:,2);
U = U(:,2);


end




    
    
    
    