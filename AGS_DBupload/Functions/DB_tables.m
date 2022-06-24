function [GROUPS,COLUMNS] = DB_tables

GROUPS = {'LOCA';
    'SCPG';
    'SCPT';
    'GEOL';
    'DETL';
    'DREM';
    % LAB
    'GRAG';
    'GRAT';
    'GCHM';
    'RELD';
    'LPDN';
    'LPEN';
    'LRES';
    'LVAN';
    'LDEN';
    };

%% CPT AND BH groups
COLUMNS.LOCA = [%{'HEADING'},{'variable name'},{'Unit'};
    % LOCA group
    {'LOCA_ID'},{'LOCA_ID',{''}};
    {'LOCA_TYPE'},{'LOCA_TYPE',{''}};
    {'LOCA_STAT'},{'LOCA_STAT',{''}};
    {'LOCA_NATE'},{'LOCA_NATE',{'m'}};
    {'LOCA_NATN'},{'LOCA_NATN',{'m'}};
    {'LOCA_GREF'},{'LOCA_GREF',{''}};
    {'LOCA_GL'},{'LOCA_GL'},{'m'};           % Water level
    {'LOCA_REM'},{'LOCA_REM',{''}};
    {'LOCA_FDEP'},{'LOCA_FDEP',{'m'}};
    {'LOCA_STAR'},{'LOCA_STAR',{''}};
    {'LOCA_PURP'},{'LOCA_PURP',{''}};
    {'LOCA_TERM'},{'LOCA_TERM',{''}};
    {'LOCA_ENDD'},{'LOCA_ENDD',{''}};
    {'LOCA_LETT'},{'LOCA_LETT',{''}};
    {'LOCA_LOCX'},{'LOCA_LOCX',{'m'}};
    {'LOCA_LOCY'},{'LOCA_LOCY',{'m'}};
    {'LOCA_LOCZ'},{'LOCA_LOCZ',{'m'}};
    {'LOCA_LREF'},{'LOCA_LREF',{''}};
    {'LOCA_DATM'},{'LOCA_DATM',{''}};
    {'LOCA_ETRV'},{'LOCA_ETRV',{'m'}};
    {'LOCA_NTRV'},{'LOCA_NTRV',{'m'}};
    {'LOCA_LTRV'},{'LOCA_LTRV',{'m'}};
    {'LOCA_XTRL'},{'LOCA_XTRL',{'m'}};
    {'LOCA_YTRL'},{'LOCA_YTRL',{'m'}};
    {'LOCA_ZTRL'},{'LOCA_ZTRL',{'m'}};
    {'LOCA_LAT'},{'LOCA_LAT',{''}};
    {'LOCA_LON'},{'LOCA_LON',{''}};
    {'LOCA_ELAT'},{'LOCA_ELAT',{''}};
    {'LOCA_ELON'},{'LOCA_ELON',{''}};
    {'LOCA_LLZ'},{'LOCA_LLZ',{''}};
    {'LOCA_LOCM'},{'LOCA_LOCM',{''}};
    {'LOCA_LOCA'},{'LOCA_LOCA',{''}};
    {'LOCA_CLST'},{'LOCA_CLST',{''}};
    {'LOCA_ALID'},{'LOCA_ALID',{''}};
    {'LOCA_OFFS'},{'LOCA_OFFS',{''}};
    {'LOCA_CNGE'},{'LOCA_CNGE',{''}};
    {'LOCA_TRAN'},{'LOCA_TRAN',{''}};
    {'FILE_FSET'},{'FILE_FSET',{''}};
    {'LOCA_NATD'},{'LOCA_NATD',{''}};
    {'LOCA_ORID'},{'LOCA_ORID',{''}};
    {'LOCA_ORJO'},{'LOCA_ORJO',{''}};
    {'LOCA_ORCO'},{'LOCA_ORCO',{''}};
    ];

% SCPG group
COLUMNS.SCPG = [
    {'LOCA_ID'},{'LOCA_ID',{''}};
    {'SCPG_TESN'},{'SCPG_TESN',{''}};
    {'SCPG_TYPE'},{'SCPG_TYPE',{''}};
    {'SCPG_REF'},{'SCPG_REF',{''}};
    {'SCPG_CSA'},{'SCPG_CSA',{'cm2'}};
    {'SCPG_RATE'},{'SCPG_RATE',{'mm/s'}};
    {'SCPG_FILT'},{'SCPG_FILT',{''}};
    {'SCPG_FRIC'},{'SCPG_FRIC',{''}};
    {'SCPG_WAT'},{'SCPG_WAT'},{'m'};             % Groundwater level at time of test
    {'SCPG_WATA'},{'SCPG_WATA',{''}};
    {'SCPG_REM'},{'SCPG_REM',{''}};
    {'SCPG_ENV'},{'SCPG_ENV',{''}};
    {'SCPG_CONT'},{'SCPG_CONT',{''}};
    {'SCPG_METH'},{'SCPG_METH',{''}};
    {'SCPG_CRED'},{'SCPG_CRED',{''}};
    {'SCPG_CAR'},{'SCPG_CAR'},{''};              % Cone area ratio
    {'SCPG_SLAR'},{'SCPG_SLAR'},{''};            	% Sleeve area ratio used to calculate ft
    {'FILE_FSET'},{'FILE_FSET',{''}};
    ];


% SCPT group
COLUMNS.SCPT = [
    {'LOCA_ID'},{'LOCA_ID',{''}};
    {'SCPG_TESN'},{'SCPG_TESN'},{''};          % Test reference or push number
    {'SCPT_DPTH'},{'SCPT_DPTH'},{'m'};              % Depth of result
    {'SCPT_RES'},{'SCPT_RES'},{'MPa'};            % Cone resistance (qc)
    {'SCPT_FRES'},{'SCPT_FRES'},{'MPa'};           % Local unit side friction resistance (fs)
    {'SCPT_PWP1'},{'SCPT_PWP1'},{'MPa'};           % Face porewater pressure (u1)
    {'SCPT_PWP2'},{'SCPT_PWP2'},{'MPa'};           % Shoulder porewater pressure (u2)
    {'SCPT_PWP3'},{'SCPT_PWP3'},{'MPa'};           % Top of sleeve porewater pressure (u3)
    {'SCPT_CON'},{'SCPT_CON',{'uS/cm'}};
    {'SCPT_TEMP'},{'SCPT_TEMP',{'degC'}};
    {'SCPT_PH'},{'SCPT_PH',{''}};
    {'SCPT_SLP1'},{'SCPT_SLP1',{'deg'}};
    {'SCPT_SLP2'},{'SCPT_SLP2',{'deg'}};
    {'SCPT_REDX'},{'SCPT_REDX',{'mV'}};
    {'SCPT_MAGT'},{'SCPT_MAGT',{''}};
    {'SCPT_MAGX'},{'SCPT_MAGX',{''}};
    {'SCPT_MAGY'},{'SCPT_MAGY',{''}};
    {'SCPT_MAGZ'},{'SCPT_MAGZ',{''}};
    {'SCPT_SMP'},{'SCPT_SMP',{'%'}};
    {'SCPT_NGAM'},{'SCPT_NGAM',{'counts/s'}};
    {'SCPT_REM'},{'SCPT_REM',{''}};
    {'SCPT_FRR'},{'SCPT_FRR'},{'%'};              % Friction ratio (Rf)
    {'SCPT_QT'},{'SCPT_QT'},{'MPa'};             % Corrected cone resistance (qt) piezocone only
    {'SCPT_FT'},{'SCPT_FT'},{'MPa'};             % Corrected sleeve resistance (ft) piezocone only
    {'SCPT_QE'},{'SCPT_QE'},{'MPa'};             % Effective cone resistance (qe) piezocone only
    {'SCPT_BDEN'},{'SCPT_BDEN'},{'Mg/m3'};         % Bulk density of material (measured or assumed)
    {'SCPT_CPO'},{'SCPT_CPO'},{'kPa'};           % Total vertical stress (based on SCPT_BDEN)
    {'SCPT_CPOD'},{'SCPT_CPOD'},{'kPa'};         % Effective vertical stress (calculated from SCPT_CPO and SCPT_ISPP or SCPG_WAT)
    {'SCPT_QNET'},{'SCPT_QNET'},{'MPa'};           % Net cone resistance (qn)
    {'SCPT_FRRC'},{'SCPT_FRRC'},{'%'};           % Corrected friction ratio (Rf') piezocone only
    {'SCPT_EXPP'},{'SCPT_EXPP',{'MPa'}};
    {'SCPT_BQ'},{'SCPT_BQ'},{'-'};               % Pore pressure ratio (Bq) piezocone only
    {'SCPT_ISPP'},{'SCPT_ISPP',{'MPa'}};
    {'SCPT_NQT'},{'SCPT_NQT',{''}}; 		% Normalised cone resistance (Qt)
    {'SCPT_NFR'},{'SCPT_NFR'},{'%'};        % Normalised friction ratio (Fr)
    {'FILE_FSET'},{'FILE_FSET',{''}};
    ];

% GEOL group
COLUMNS.GEOL = [
    {'LOCA_ID'},{'LOCA_ID',{''}};
    {'GEOL_TOP'},{'GEOL_TOP',{'m'}};
    {'GEOL_BASE'},{'GEOL_BASE',{'m'}};
    {'GEOL_DESC'},{'GEOL_DESC',{''}};
    {'GEOL_LEG'},{'GEOL_LEG',{''}};
    {'GEOL_GEOL'},{'GEOL_GEOL',{''}};
    {'GEOL_GEO2'},{'GEOL_GEO2',{''}};
    {'GEOL_STAT'},{'GEOL_STAT',{''}};
    {'GEOL_BGS'},{'GEOL_BGS',{''}};
    {'GEOL_FORM'},{'GEOL_FORM',{''}};
    {'GEOL_REM'},{'GEOL_REM',{''}};
    {'FILE_FSET'},{'FILE_FSET',{''}};
    ];

% DETL group
COLUMNS.DETL = [
    {'LOCA_ID'},{'LOCA_ID',{''}};
    {'DETL_TOP'},{'DETL_TOP',{'m'}};
    {'DETL_BASE'},{'DETL_BASE',{'m'}};
    {'DETL_DESC'},{'DETL_DESC',{''}};
    {'DETL_REM'},{'DETL_REM',{''}};
    {'FILE_FSET'},{'FILE_FSET',{''}};
    ];

% DREM group
COLUMNS.DREM = [
    {'LOCA_ID'},{'LOCA_ID',{''}};
    {'DREM_TOP'},{'DREM_TOP',{'m'}};
    {'DREM_BASE'},{'DREM_BASE',{'m'}};
    {'DREM_REM'},{'DREM_REM',{''}};
    {'FILE_FSET'},{'FILE_FSET',{''}};
    ];


%% LAB data
COLUMNS.GRAG = [
    {'LOCA_ID'},{'LOCA_ID',{''}};
    {'SAMP_TOP'},{'DREM_TOP',{'m'}};
    {'SAMP_REF'},{'DREM_BASE',{''}};
    {'SAMP_TYPE'},{'DREM_REM',{''}};
    {'SAMP_ID'},{'FILE_FSET',{''}};
    {'SPEC_REF'},{'LOCA_ID',{''}};
    {'SPEC_DPTH'},{'DREM_TOP',{'m'}};
    {'SPEC_DESC'},{'DREM_BASE',{''}};
    {'SPEC_PREP'},{'DREM_REM',{''}};
    {'GRAG_UC'},{'FILE_FSET',{'-'}};
    {'GRAG_VCRE'},{'LOCA_ID',{'%'}};
    {'GRAG_GRAV'},{'DREM_TOP',{'%'}};
    {'GRAG_SAND'},{'DREM_BASE',{'%'}};
    {'GRAG_SILT'},{'DREM_REM',{'%'}};
    {'GRAG_CLAY'},{'FILE_FSET',{'%'}};
    {'GRAG_FINE'},{'LOCA_ID',{'%'}};
    {'GRAG_REM'},{'DREM_TOP',{''}};
    {'GRAG_METH'},{'DREM_BASE',{''}};
    {'GRAG_LAB'},{'DREM_REM',{''}};
    {'GRAG_CRED'},{'FILE_FSET',{''}};    
    {'TEST_STAT'},{'TEST_STAT',{''}};
    {'FILE_FSET'},{'FILE_FSET',{''}};    
    ];


COLUMNS.GRAT = [
    {'LOCA_ID'},{'LOCA_ID',{''}};
    {'SAMP_TOP'},{'DREM_TOP',{'m'}};
    {'SAMP_REF'},{'DREM_BASE',{''}};
    {'SAMP_TYPE'},{'DREM_REM',{''}};
    {'SAMP_ID'},{'FILE_FSET',{''}};
    {'SPEC_REF'},{'LOCA_ID',{''}};
    {'SPEC_DPTH'},{'DREM_TOP',{'m'}};
    {'GRAT_SIZE'},{'DREM_BASE',{'mm'}};
    {'GRAT_PERP'},{'DREM_REM',{'%'}};
    {'GRAT_TYPE'},{'FILE_FSET',{''}};
    {'GRAT_REM'},{'LOCA_ID',{''}};
    {'FILE_FSET'},{'FILE_FSET',{''}};    
    ];


COLUMNS.GCHM = [
    {'LOCA_ID'},{'LOCA_ID',{''}};
    {'SAMP_TOP'},{'DREM_TOP',{'m'}};
    {'SAMP_REF'},{'DREM_BASE',{''}};
    {'SAMP_TYPE'},{'DREM_REM',{''}};
    {'SAMP_ID'},{'FILE_FSET',{''}};
    {'SPEC_REF'},{'LOCA_ID',{''}};
    {'SPEC_DPTH'},{'DREM_TOP',{'m'}};
    {'SPEC_DESC'},{'DREM_BASE',{''}};
    {'SPEC_PREP'},{'DREM_REM',{''}};
    {'GCHM_CODE'},{'FILE_FSET',{''}};
    {'GCHM_METH'},{'LOCA_ID',{''}};
    {'GCHM_TTYP'},{'DREM_TOP',{''}};
    {'GCHM_RESL'},{'DREM_BASE',{''}};
    {'GCHM_UNIT'},{'DREM_REM',{''}};
    {'GCHM_NAME'},{'FILE_FSET',{''}};
    {'GCHM_REM'},{'LOCA_ID',{''}};
    {'GCHM_LAB'},{'DREM_TOP',{''}};
    {'GCHM_CRED'},{'DREM_BASE',{''}};
    {'GCHM_RTXT'},{'DREM_REM',{''}};
    {'GCHM_DLM'},{'FILE_FSET',{''}};    
    {'TEST_STAT'},{'TEST_STAT',{''}};
    {'FILE_FSET'},{'FILE_FSET',{''}};    
    ];


COLUMNS.RELD = [
    {'LOCA_ID'},{'LOCA_ID',{''}};
    {'SAMP_TOP'},{'DREM_TOP',{'m'}};
    {'SAMP_REF'},{'DREM_BASE',{''}};
    {'SAMP_TYPE'},{'DREM_REM',{''}};
    {'SAMP_ID'},{'FILE_FSET',{''}};
    {'SPEC_REF'},{'LOCA_ID',{''}};
    {'SPEC_DPTH'},{'DREM_TOP',{'m'}};
    {'SPEC_DESC'},{'DREM_BASE',{''}};
    {'SPEC_PREP'},{'DREM_REM',{''}};
    {'RELD_DMAX'},{'FILE_FSET',{'Mg/m3'}};
    {'RELD_375'},{'LOCA_ID',{'%'}};
    {'RELD_063'},{'DREM_TOP',{'%'}};
    {'RELD_020'},{'DREM_BASE',{'%'}};
    {'RELD_DMIN'},{'DREM_REM',{'Mg/m3'}};
    {'RELD_REM'},{'FILE_FSET',{''}};
    {'RELD_METH'},{'LOCA_ID',{''}};
    {'RELD_LAB'},{'DREM_TOP',{''}};
    {'RELD_CRED'},{'DREM_BASE',{''}};
    {'RELD_DEV'},{'DREM_REM',{''}};
    {'TEST_STAT'},{'TEST_STAT',{''}};
    {'FILE_FSET'},{'FILE_FSET',{''}};    
    ];

COLUMNS.LPDN = [
    {'LOCA_ID'},{'LOCA_ID',{''}};
    {'SAMP_TOP'},{'DREM_TOP',{'m'}};
    {'SAMP_REF'},{'DREM_BASE',{''}};
    {'SAMP_TYPE'},{'DREM_REM',{''}};
    {'SAMP_ID'},{'FILE_FSET',{''}};
    {'SPEC_REF'},{'LOCA_ID',{''}};
    {'SPEC_DPTH'},{'DREM_TOP',{'m'}};
    {'SPEC_DESC'},{'DREM_BASE',{''}};
    {'SPEC_PREP'},{'DREM_REM',{''}};
    {'SPEC_BASE'},{'FILE_FSET',{'m'}};
    {'LPDN_PDEN'},{'LOCA_ID',{'Mg/m3'}};
    {'LPDN_TYPE'},{'DREM_TOP',{''}};
    {'LPDN_REM'},{'DREM_BASE',{''}};
    {'LPDN_METH'},{'DREM_REM',{''}};
    {'LPDN_LAB'},{'FILE_FSET',{''}};
    {'LPDN_CRED'},{'LOCA_ID',{''}};
    {'LPDN_DEV'},{'DREM_TOP',{''}};
    {'LPDN_PVOL'},{'DREM_REM',{''}};
    {'LPDN_GAS'},{'DREM_REM',{''}};
    {'TEST_STAT'},{'TEST_STAT',{''}};
    {'FILE_FSET'},{'FILE_FSET',{''}};    
    ];

COLUMNS.LPEN = [
    {'LOCA_ID'},{'LOCA_ID',{''}};
    {'SAMP_TOP'},{'DREM_TOP',{'m'}};
    {'SAMP_REF'},{'DREM_BASE',{''}};
    {'SAMP_TYPE'},{'DREM_REM',{''}};
    {'SAMP_ID'},{'FILE_FSET',{''}};
    {'SPEC_REF'},{'LOCA_ID',{''}};
    {'SPEC_DPTH'},{'DREM_TOP',{'m'}};
    {'SPEC_DESC'},{'DREM_BASE',{''}};
    {'SPEC_PREP'},{'DREM_REM',{''}};
    {'SPEC_BASE'},{'FILE_FSET',{'m'}};
    {'LPEN_PPEN'},{'LOCA_ID',{'kPa'}};
    {'LPEN_MC'},{'DREM_TOP',{'%'}};
    {'LPEN_REM'},{'DREM_BASE',{''}};
    {'LPEN_METH'},{'DREM_REM',{''}};
    {'LPEN_LAB'},{'FILE_FSET',{''}};
    {'LPEN_CRED'},{'LOCA_ID',{''}};
    {'LPEN_DEV'},{'DREM_TOP',{''}};
    {'TEST_STAT'},{'TEST_STAT',{''}};
    {'FILE_FSET'},{'FILE_FSET',{''}};    
    ];

COLUMNS.LRES = [
    {'LOCA_ID'},{'LOCA_ID',{''}};
    {'SAMP_TOP'},{'DREM_TOP',{'m'}};
    {'SAMP_REF'},{'DREM_BASE',{''}};
    {'SAMP_TYPE'},{'DREM_REM',{''}};
    {'SAMP_ID'},{'FILE_FSET',{''}};
    {'SPEC_REF'},{'LOCA_ID',{''}};
    {'SPEC_DPTH'},{'DREM_TOP',{'m'}};
    {'SPEC_DESC'},{'DREM_BASE',{''}};
    {'SPEC_PREP'},{'DREM_REM',{''}};
    {'SPEC_BASE'},{'FILE_FSET',{'m'}};
    {'LRES_BDEN'},{'LOCA_ID',{'Mg/m3'}};
    {'LRES_DDEN'},{'DREM_TOP',{'Mg/m3'}};
    {'LRES_MC'},{'DREM_BASE',{'%'}};
    {'LRES_COND'},{'DREM_REM',{''}};
    {'LRES_LRES'},{'FILE_FSET',{'ohm m'}};
    {'LRES_CDIA'},{'LOCA_ID',{'mm'}};
    {'LRES_CCSA'},{'DREM_TOP',{'mm2'}};
    {'LRES_CLEN'},{'TEST_STAT',{'mm'}};
    {'LRES_TEMP'},{'FILE_FSET',{'DegC'}};   
    {'LRES_ELEC'},{'LOCA_ID',{''}};
    {'LRES_PENT'},{'DREM_TOP',{''}};
    {'LRES_CSHP'},{'DREM_BASE',{''}};
    {'LRES_WAT'},{'DREM_REM',{'ml'}};
    {'LRES_WRES'},{'FILE_FSET',{'ohm m'}};
    {'LRES_PART'},{'LOCA_ID',{''}};
    {'LRES_REM'},{'DREM_TOP',{''}};
    {'LRES_METH'},{'TEST_STAT',{''}};
    {'LRES_LAB'},{'FILE_FSET',{''}};       
    {'LRES_CRED'},{'TEST_STAT',{''}};
    {'LRES_DEV'},{'FILE_FSET',{''}};       
    {'TEST_STAT'},{'TEST_STAT',{''}};
    {'FILE_FSET'},{'FILE_FSET',{''}};       
    ];


COLUMNS.LVAN = [
    {'LOCA_ID'},{'LOCA_ID',{''}};
    {'SAMP_TOP'},{'DREM_TOP',{'m'}};
    {'SAMP_REF'},{'DREM_BASE',{''}};
    {'SAMP_TYPE'},{'DREM_REM',{''}};
    {'SAMP_ID'},{'FILE_FSET',{''}};
    {'SPEC_REF'},{'LOCA_ID',{''}};
    {'SPEC_DPTH'},{'DREM_TOP',{'m'}};
    {'SPEC_DESC'},{'DREM_BASE',{''}};
    {'SPEC_PREP'},{'DREM_REM',{''}};
    {'SPEC_BASE'},{'FILE_FSET',{'m'}};
    {'LVAN_VNPK'},{'LOCA_ID',{'kPa'}};
    {'LVAN_VNRM'},{'DREM_TOP',{'kPa'}};
    {'LVAN_MC'},{'DREM_BASE',{'%'}};
    {'LVAN_SIZE'},{'DREM_REM',{'mm'}};
    {'LVAN_VLEN'},{'FILE_FSET',{'mm'}};
    {'LVAN_REM'},{'LOCA_ID',{''}};
    {'LVAN_METH'},{'DREM_TOP',{''}};
    {'LVAN_LAB'},{'DREM_REM',{''}};
    {'LVAN_CRED'},{'DREM_REM',{''}};
    {'LVAN_DEV'},{'TEST_STAT',{''}};
    {'LVAN_TYPE'},{'FILE_FSET',{''}};     
    {'TEST_STAT'},{'TEST_STAT',{''}};
    {'FILE_FSET'},{'FILE_FSET',{''}};    
    ];

COLUMNS.LDEN = [
    {'LOCA_ID'},{'LOCA_ID',{''}};
    {'SAMP_TOP'},{'DREM_TOP',{'m'}};
    {'SAMP_REF'},{'DREM_BASE',{''}};
    {'SAMP_TYPE'},{'DREM_REM',{''}};
    {'SAMP_ID'},{'FILE_FSET',{''}};
    {'SPEC_REF'},{'LOCA_ID',{''}};
    {'SPEC_DPTH'},{'DREM_TOP',{'m'}};
    {'SPEC_DESC'},{'DREM_BASE',{''}};
    {'SPEC_PREP'},{'DREM_REM',{''}};
    {'SPEC_BASE'},{'FILE_FSET',{'m'}};
    {'LDEN_TYPE'},{'LOCA_ID',{''}};
    {'LDEN_COND'},{'DREM_TOP',{''}};
    {'LDEN_SMTY'},{'DREM_BASE',{''}};
    {'LDEN_MC'},{'DREM_REM',{'%'}};
    {'LDEN_BDEN'},{'FILE_FSET',{'Mg/m3'}};
    {'LDEN_DDEN'},{'LOCA_ID',{'Mg/m3'}};
    {'LDEN_REM'},{'DREM_TOP',{''}};
    {'LDEN_METH'},{'DREM_REM',{''}};
    {'LDEN_LAB'},{'DREM_REM',{''}};
    {'LDEN_CRED'},{'TEST_STAT',{''}};
    {'LDEN_DEV'},{'FILE_FSET',{''}};     
    {'TEST_STAT'},{'TEST_STAT',{''}};
    {'FILE_FSET'},{'FILE_FSET',{''}};    
    ];
    

