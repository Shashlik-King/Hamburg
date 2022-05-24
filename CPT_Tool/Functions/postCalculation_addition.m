function [data, settings] = postCalculation_addition(settings,data,values,Folder,i)
%%%-------------------------------------------------------------------------%%%
% Function for performing additional post-processing calculations to determine
% further parameters if needed and compare calculated parameters to
% received parameters if any double information is found
%
% If any new post-processed parameters are added to this function please
% also add this in the "ParametersFunction" vector
%
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by FKMV                     23-07-2020
% Updated by CONN                   17-08-2020
% Add extra correlations by CHLT    01-10-2020

% ParametersFunction = [{'c_u'},...
%     {'V_s'},...
%     {'rho'}];

%% Find self-defined units for layers
if settings.calc.Unit == 2
    data.postprocess.(data.nameSave{i}).LayersUnitSelf = data.Layering.LayerSelectionData(find(strcmp(data.Layering.LayerSelectionData(:,1),data.nameSave{i})),5);
    for j = 1:size(data.postprocess.(data.nameSave{i}).LayersUnitSelf,1)
        if isempty(find(strcmp(data.postprocess.(data.nameSave{i}).LayersUnitSelf{j},settings.calc.soils(:,1))))
            error(strcat('Cant find the following layer type in main page: ',data.postprocess.(data.nameSave{i}).LayersUnitSelf{j}))
        else
            LayerUnitType{j} = settings.calc.soils{find(strcmp(data.postprocess.(data.nameSave{i}).LayersUnitSelf{j},settings.calc.soils(:,1))),2}; % Defining how to consider self-defined unit (either clay or sand)
        end
    end
else
    data.postprocess.(data.nameSave{i}).LayersUnitSelf = cell(size(data.postprocess.(data.nameSave{i}).indexLayer,1),1); % data.Layering.LayerSelectionData(find(strcmp(data.Layering.LayerSelectionData(:,1),data.nameSave{i})),5);
    data.postprocess.(data.nameSave{i}).LayersUnitSelf(:) = {'NaN'};
    for j = 1:size(data.postprocess.(data.nameSave{i}).zone.LocationSum{1,1},1)
        LayerUnitType{j} = 'NaN';
    end
end

%% Define empty parameter vectors
lVec = length(data.postprocess.(data.nameSave{i}).z);

I_D.Baldi = nan(lVec,1);
I_D.LunneNC = nan(lVec,1);
I_D.LunneOC = nan(lVec,1);
I_D.Baldi_star = nan(lVec,1);
I_D.NGI = nan(lVec,1);
CF = nan(lVec,1);
I_D.Jamiolkowski = nan(lVec,1);
OCR.MayneSand = nan(lVec,1);
OCR.MayneClay = nan(lVec,1);
OCR.Robertson = nan(lVec,1);
St = nan(lVec,1);
rho = nan(lVec,1);
V_s = nan(lVec,1);
Gmax.Baldi = nan(lVec,1);
Gmax.DNV = nan(lVec,1);
Gmax.RixStokoe = nan(lVec,1);
% Gmax.NGI = nan(lVec,1);
phi.KulhawyMayne = nan(lVec,1);
phi.Schmertmann = nan(lVec,1);
phi.Robertson = nan(lVec,1);
cu.value = nan(lVec,length(values.Nkt));
% Vs.value = nan(lVec,1);
LayerNumber = nan(lVec,1);
LayerDefined = cell(lVec,1);

%% Index properties
for j = 1:size(data.postprocess.(data.nameSave{i}).zone.LocationSum{1,1},1)
    k = data.postprocess.(data.nameSave{i}).indexLayer(j,1):data.postprocess.(data.nameSave{i}).indexLayer(j,2);
    LayerNumber(k) = j;
    LayerDefined(k,1) = data.postprocess.(data.nameSave{i}).LayersUnitSelf(j);
end

data.postprocess.(data.nameSave{i}).LayerNumber = LayerNumber;
data.postprocess.(data.nameSave{i}).LayerDefined = LayerDefined;


%% State properties
for j = 1:size(data.postprocess.(data.nameSave{i}).zone.LocationSum{1,1},1)                                         % Loop over each layer in profile
    for k = data.postprocess.(data.nameSave{i}).indexLayer(j,1):data.postprocess.(data.nameSave{i}).indexLayer(j,2) % Loop over each CPT-measurement index in CPT for specific layer
        if and(settings.calc.Unit==1,any(strcmpi(data.postprocess.(data.nameSave{i}).zone.LocationSum{1,1}(j,7),{'sand','silt'})))  || and(settings.calc.Unit==2, or(strcmpi(LayerUnitType{j},'sand'),strcmpi(LayerUnitType{j},'silt')))
            I_D.Baldi(k,1) = (100/2.91)*log(data.postprocess.(data.nameSave{i}).qt(k)*1000 / (205 * (data.postprocess.(data.nameSave{i}).sigma_v0_eff(k)*1000)^0.51)) ; % density index [%] for coarse grained material (qt and sigma in kPa) Baldi et al. (1986)
            I_D.LunneNC(k,1) = (100/2.41)*log(data.postprocess.(data.nameSave{i}).qt(k)*1000 / (157 * (data.postprocess.(data.nameSave{i}).sigma_v0_eff(k)*1000)^0.55)) ; % density index [%] for coarse grained material (qt and sigma in kPa) Lunne et al. (1997) NC sands
            I_D.LunneOC(k,1) = (100/2.61)*log(data.postprocess.(data.nameSave{i}).qt(k)*1000 / (181 * (data.postprocess.(data.nameSave{i}).sigma_v0_eff(k)*1000)^0.55)) ; % density index [%] for coarse grained material (qt and sigma in kPa) Lunne et al. (1997) OC sands
            I_D.Baldi_star(k,1) = (100/2.96)*log(data.postprocess.(data.nameSave{i}).qt(k)*1000/100 / (24.94* (data.postprocess.(data.nameSave{i}).sigma_v0_eff(k)*1000/100)^0.46)) ; % density index [%] for coarse grained material (qt and sigma in kPa) Jamiolkowski et al. (2003)
            I_D.NGI(k,1) = (1/3.1)*log(data.postprocess.(data.nameSave{i}).qt(k)*1000/100 / (17.68* (data.postprocess.(data.nameSave{i}).sigma_v0_eff(k)*1000/100)^0.50))*100 ; % density index [%] for coarse grained material (qt and sigma in kPa) Jamiolkowski et al. (2003)
            CF(k,1) =-1.87+2.32*log(data.postprocess.(data.nameSave{i}).qt(k)*1000/((data.postprocess.(data.nameSave{i}).sigma_v0_eff(k)*100)^0.5));
            I_D.Jamiolkowski(k,1)=I_D.Baldi_star(k,1)+I_D.Baldi_star(k,1)/100*CF(k,1);
            m=0.72; % Used for Mayne (2012)
            OCR.MayneSand(k,1) = 0.33 * ( data.postprocess.(data.nameSave{i}).qt(k) - data.postprocess.(data.nameSave{i}).sigma_v0(k) )^m * ( values.P_a / 100 )^(1 - m) / data.postprocess.(data.nameSave{i}).sigma_v0_eff(k); % Overconsolidation ratio - Mayne (2012)
            if and(settings.calc.Unit==1,any(strcmpi(data.postprocess.(data.nameSave{i}).zone.LocationSum{1,1}(j,7),{'sand'}))) || and(settings.calc.Unit==2, strcmpi(LayerUnitType{j},'sand'))
                OCR.Robertson(k,1) = NaN;
                OCR.MayneClay(k,1) = NaN;
                St(k,1) = NaN;
            end
        end
        if and(settings.calc.Unit==1,any(strcmpi(data.postprocess.(data.nameSave{i}).zone.LocationSum{1,1}(j,7),{'clay','silt'})))  || and(settings.calc.Unit==2, or(strcmpi(LayerUnitType{j},'clay'),strcmpi(LayerUnitType{j},'silt')))
            OCR.Robertson(k,1) = 0.3 * ( (data.postprocess.(data.nameSave{i}).qt(k) - data.postprocess.(data.nameSave{i}).sigma_v0(k)) / data.postprocess.(data.nameSave{i}).sigma_v0_eff(k) ) ; % Over-consolidation ratio for grained materials
            m=1.0;   % Used for Mayne (2012)
            OCR.MayneClay(k,1) = 0.33 * ( data.postprocess.(data.nameSave{i}).qt(k) - data.postprocess.(data.nameSave{i}).sigma_v0(k) )^m * ( values.P_a / 100 )^(1 - m)/ data.postprocess.(data.nameSave{i}).sigma_v0_eff(k); % Overconsolidation ratio - Mayne (2012)
            Ns = 7.5; % Imperical value for St - normally seen in the range of 6-9.
            St(k,1) = Ns./data.postprocess.(data.nameSave{i}).Rf(k);
            if and(settings.calc.Unit==1,any(strcmpi(data.postprocess.(data.nameSave{i}).zone.LocationSum{1,1}(j,7),{'clay'}))) || and(settings.calc.Unit==2, strcmpi(LayerUnitType{j},'clay'))
                I_D.Baldi(k,1) = NaN;
                I_D.LunneNC(k,1) = NaN;
                I_D.LunneOC(k,1) = NaN;
                I_D.Jamiolkowski(k,1) = NaN;
                I_D.NGI(k,1) = NaN;
                OCR.MayneSand(k,1) = NaN;
            end
        end
    end
end

data.postprocess.(data.nameSave{i}).Id.methods = [{'Baldi et al. (1986)'},{'Lunne et al. (1997) NC'}, {'Lunne et al. (1997) OC'},{'Jamiolkowski et al. (2003)'},{'NGI Beacon'}];
data.postprocess.(data.nameSave{i}).Id.values = [I_D.Baldi, I_D.LunneNC, I_D.LunneOC, I_D.Jamiolkowski, I_D.NGI];
data.postprocess.(data.nameSave{i}).Id.values(imag(data.postprocess.(data.nameSave{i}).Id.values)~=0) = nan;  % Replace imaginary numbers with NaN
data.postprocess.(data.nameSave{i}).Id.unit = {'%'};
data.postprocess.(data.nameSave{i}).OCR.methods = [{'Robertson (1990)'},{'Mayne - Sand (2012)'}, {'Mayne - Clay (2012)'}];
data.postprocess.(data.nameSave{i}).OCR.values = [OCR.Robertson, OCR.MayneSand, OCR.MayneClay];
data.postprocess.(data.nameSave{i}).OCR.values(imag(data.postprocess.(data.nameSave{i}).OCR.values)~=0) = nan;  % Replace imaginary numbers with NaN
data.postprocess.(data.nameSave{i}).OCR.unit = {'-'};
data.postprocess.(data.nameSave{i}).St.methods = {'Sensitivity'};
data.postprocess.(data.nameSave{i}).St.values = [St];
data.postprocess.(data.nameSave{i}).St.values(imag(data.postprocess.(data.nameSave{i}).St.values)~=0) = nan;  % Replace imaginary numbers with NaN
data.postprocess.(data.nameSave{i}).St.unit = {'-'};

%% Stiffness properties
for j = 1:size(data.postprocess.(data.nameSave{i}).zone.LocationSum{1,1},1)
    for k = data.postprocess.(data.nameSave{i}).indexLayer(j,1):data.postprocess.(data.nameSave{i}).indexLayer(j,2)
        rho = ones(size(data.postprocess.(data.nameSave{i}).z,1),1) * (values.unitWeight.soil*1000/9.81);     % [Mg/m3]
        if and(settings.calc.Unit==1,any(strcmpi(data.postprocess.(data.nameSave{i}).zone.LocationSum{1,1}(j,7),{'Sand'})))  || and(settings.calc.Unit==2, strcmp(LayerUnitType{j},'Sand'))
            V_s(k,1) = 277 * (data.postprocess.(data.nameSave{i}).qt(k))^0.13 * (data.postprocess.(data.nameSave{i}).sigma_v0_eff(k))^0.27 ; % coarse grained material - FKMV 23072020
        else
%             V_s(k,1) = (10.1 * log10(data.postprocess.(data.nameSave{i}).qt(k)*1000) - 11.4)^1.67 * (data.postprocess.(data.nameSave{i}).fs(k) / data.postprocess.(data.nameSave{i}).qt(k)*100)^0.3; % coarse grained material - FKMV 23072020
            V_s(k,1) = 1.75 * (data.postprocess.(data.nameSave{i}).qt(k)*1000)^0.627 ;
        end
        Gmax.Baldi(k,1) = (rho(k) * V_s(k)^2 )/1000; % [MPa] both coarse and fine grained material - FKMV 23072020
        Gmax.DNV(k,1) = 22 * (0.6*I_D.Baldi(k,1) + 16) * sqrt(data.postprocess.(data.nameSave{i}).sigma_v0_eff(k)*values.P_a);
        if any(strcmp(fieldnames(data.postprocess.(data.nameSave{i})),'qc'))
            Gmax.RixStokoe(k,1) = (1634 * ( data.postprocess.(data.nameSave{i}).qc(k)*1000 / sqrt(data.postprocess.(data.nameSave{i}).sigma_v0_eff(k)*1000) )^(-0.75)*data.postprocess.(data.nameSave{i}).qc(k)*1000)/1000;
        else
            Gmax.RixStokoe(k,1) = (1634 * ( data.postprocess.(data.nameSave{i}).qt(k)*1000 / sqrt(data.postprocess.(data.nameSave{i}).sigma_v0_eff(k)*1000) )^(-0.75)*data.postprocess.(data.nameSave{i}).qt(k)*1000)/1000;
        end
    end
end
data.postprocess.(data.nameSave{i}).Gmax.methods = [{'Baldi et al. (1989)'},{'Rix and Stokoe (1991)'},{'DNVGL-RP-CP212 (2017)'}];
data.postprocess.(data.nameSave{i}).Gmax.values = [Gmax.Baldi, Gmax.RixStokoe, Gmax.DNV];
data.postprocess.(data.nameSave{i}).Gmax.values(imag(data.postprocess.(data.nameSave{i}).Gmax.values)~=0) = nan;  % Replace imaginary numbers with NaN
data.postprocess.(data.nameSave{i}).Gmax.unit = {'MPa'};
data.postprocess.(data.nameSave{i}).rho.methods = {'Rho'};
data.postprocess.(data.nameSave{i}).rho.values = rho;
data.postprocess.(data.nameSave{i}).rho.values(imag(data.postprocess.(data.nameSave{i}).rho.values)~=0) = nan;  % Replace imaginary numbers with NaN
data.postprocess.(data.nameSave{i}).rho.unit = {'Mg/m3'};
data.postprocess.(data.nameSave{i}).V_s.methods = {'Vs'};
data.postprocess.(data.nameSave{i}).V_s.values = V_s;
data.postprocess.(data.nameSave{i}).V_s.values(imag(data.postprocess.(data.nameSave{i}).V_s.values)~=0) = nan;  % Replace imaginary numbers with NaN
data.postprocess.(data.nameSave{i}).V_s.unit = {'m/s'};


%% Strength properties
for j = 1:size(data.postprocess.(data.nameSave{i}).zone.LocationSum{1,1},1)
    for k = data.postprocess.(data.nameSave{i}).indexLayer(j,1):data.postprocess.(data.nameSave{i}).indexLayer(j,2)
        if and(settings.calc.Unit==1,any(strcmpi(data.postprocess.(data.nameSave{i}).zone.LocationSum{1,1}(j,7),{'sand','silt'})))  || or(strcmpi(LayerUnitType{j},'sand'),strcmpi(LayerUnitType{j},'silt'))
            phi.KulhawyMayne(k,1) = 17.6 + 11 * log10((data.postprocess.(data.nameSave{i}).qt(k)/values.P_a) / ((data.postprocess.(data.nameSave{i}).sigma_v0_eff(k)/(values.P_a))^0.5));% angle of internal friction - Kulhawy and Mayne (1990)
            phi.Schmertmann(k,1) = 31.5 + 0.12 * I_D.Baldi(k,1);    % angle of internal friction - Schmertmann (1978)
            phi.Robertson(k,1) = atan(1/2.68 * log10(data.postprocess.(data.nameSave{i}).qt(k) / data.postprocess.(data.nameSave{i}).sigma_v0_eff(k)) + 0.29)*180/pi;% angle of internal friction - Schmertmann (1978)
            if and(settings.calc.Unit==1,any(strcmpi(data.postprocess.(data.nameSave{i}).zone.LocationSum{1,1}(j,7),{'sand'})))  || strcmpi(LayerUnitType{j},'sand')
                for L = 1:length(values.Nkt)
                    cu.value(k,L) = NaN;
                end
            end
        end
        if and(settings.calc.Unit==1,any(strcmpi(data.postprocess.(data.nameSave{i}).zone.LocationSum{1,1}(j,7),{'clay','silt'})))  || and(settings.calc.Unit==2, or(strcmpi(LayerUnitType{j},'clay'),strcmpi(LayerUnitType{j},'silt')))
            for L = 1:length(values.Nkt)
                cu.value(k,L) = (data.postprocess.(data.nameSave{i}).qt(k) - data.postprocess.(data.nameSave{i}).sigma_v0(k)) / values.Nkt(L) ; % undrained shear strength
            end
            if and(settings.calc.Unit==1,any(strcmpi(data.postprocess.(data.nameSave{i}).zone.LocationSum{1,1}(j,7),{'clay'}))) || and(settings.calc.Unit==2, strcmpi(LayerUnitType{j},'clay'))
                phi.KulhawyMayne(k,1) = NaN;
                phi.Schmertmann(k,1) = NaN;
                phi.Robertson(k,1) = NaN;
            end
        end
    end
end
data.postprocess.(data.nameSave{i}).phi.methods = [{'Kulhawy and Mayne (1990)'},{'Schmertmann (1978)'},{'Robertson and Campanella (1983)'}];
data.postprocess.(data.nameSave{i}).phi.values = [phi.KulhawyMayne, phi.Schmertmann, phi.Robertson];
data.postprocess.(data.nameSave{i}).phi.values(imag(data.postprocess.(data.nameSave{i}).phi.values)~=0) = nan;  % Replace imaginary numbers with NaN
data.postprocess.(data.nameSave{i}).phi.unit = {'deg'};
data.postprocess.(data.nameSave{i}).cu.methods = values.NktName;
data.postprocess.(data.nameSave{i}).cu.values = cu.value;
data.postprocess.(data.nameSave{i}).cu.values(imag(data.postprocess.(data.nameSave{i}).cu.values)~=0) = nan;  % Replace imaginary numbers with NaN
data.postprocess.(data.nameSave{i}).cu.unit = {'MPa'};


%% Check if post-processed parameters are defined in AGS file and / or create values in data structure
% for j = 1:length(ParametersFunction)    % Loop over all post-processed variables determined
%     if isfield(data.postprocess.(data.nameSave{i}),(ParametersFunction{j}))     % Check if parameter already exist in structure
%         % Compare calculated parameter to provided data structure
%         compareData(settings,data,newParameter,Folder,ParametersFunction{j},i)    % Function for making comparison plot
%         data.postprocess.(data.nameSave{i}).CAL.(ParametersFunction{j}) = newParameter.(ParametersFunction{j});     % Save calculated post-processed variables in "CAL" structure
%     else % Save calculated parameter to structure
%         data.postprocess.(data.nameSave{i}).(ParametersFunction{j}) = newParameter.(ParametersFunction{j});
%     end
% end

idx = 1:length(values.Id_methods);
settings.method.Id = idx(values.Id_methods==1);
idx = 1:length(values.phi_methods);
settings.method.phi = idx(values.phi_methods==1);
idx = 1:length(values.Gmax_methods);
settings.method.Gmax = idx(values.Gmax_methods==1);
idx = 1:length(values.OCR_methods);
settings.method.OCR = idx(values.OCR_methods==1);

settings.method.cu = 1;