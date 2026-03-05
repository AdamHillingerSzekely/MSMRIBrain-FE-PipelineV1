clear ; close all; clc;

load('meshDataQ1.mat');
V=meshData.V;
Fb=meshData.Fb;
E=meshData.E;
E1=meshData.E1;
E2=meshData.E2;
E3=meshData.E3;
F_pressure = meshData.F_pressure;
bcLoad_List=meshData.bcLoad_List; 
%This is the working model, find material parameters for lesion tissue
fontSize=15;
faceAlpha1=0.3;
faceAlpha2=1;
%Material parameters (MPa if spatial units are mm)
%Material parameter set cort= grey
c1=1.2*1e-3; %Shear-modulus-like parameter
m1=10; %Material parameter setting degree of non-linearity
k_factor=1e2; %Bulk modulus factor
k=c1*k_factor; %Bulk modulus

c2=1.8*1e-3; %Shear-modulus-like parameter canc= white
m2=10; %Material parameter setting degree of non-linearity
k_factor=1e2; %Bulk modulus factor
k2=c2*k_factor; %Bulk modulus

c3=2.4*1e-3; %Shear-modulus-like parameter lesion inactive value - 1.6*1e-3 active
m3=10; %Material parameter setting degree of non-linearity
k_factor=1e2; %Bulk modulus factor
k3=c3*k_factor; %Bulk modulus
pressureHgmm= 15;
%pressure in pascals
PressurePa=pressureHgmm*133.322;
%pressure in Mega pascals
appliedPressure= -PressurePa/10^6;

g11=0.213326; %Weight Factor
g12=0.522501; 
g13=0.071011;
g14=0.071011;
g15=0.042665;
g16=0.042665;
t11=0.00010; %Characteristic Relaxation Time
t12=0.00145;
t13=0.0155;
t14 = 0.145;
t15=10;
t16=100;

g21=0.403349; %Weight Factor
g22=0.321121; 
g23=0.080736;
g24=0.073939;
g25=0.040285;
g26=0.040285;
t21=0.000736; %Characteristic Relaxation Time
t22=0.00223;
t23=0.0251;
t24 = 0.273;
t25=10;
t26=100;


d=1e-9; %Density (not required for static analysis)

loadType='pressure';%'traction';
%pressure in pascals
%% Control parameters
defaultFolder = fileparts(fileparts(mfilename('fullpath')));
savePath=fullfile(defaultFolder,'data','temp');
% Path names
pathNameSTL=fullfile(defaultFolder,'data','STL'); 
saveName_SED=fullfile(savePath,'SED_no_implant.mat');
defaultFolder = fileparts(fileparts(mfilename('fullpath')));
savePath=fullfile(defaultFolder,'data','temp');

% Defining file names
febioFebFileNamePart='tempModel';
febioFebFileName=fullfile(savePath,[febioFebFileNamePart,'.feb']); %FEB file name
febioLogFileName=[febioFebFileNamePart,'.txt']; %FEBio log file name
febioLogFileName_disp=[febioFebFileNamePart,'_disp_out.txt']; %Log file name for exporting displacement
febioLogFileName_stress=[febioFebFileNamePart,'_stress_out.txt']; %Log file name for exporting stress

n=1;

% Distance markers and scaling factor
scaleFactorSize=1;


analysisType='static'; 

% FEA control settings
numTimeSteps=50; %Number of time steps desired
max_refs=50; %Max reforms
max_ups=0; %Set to zero to use full-Newton iterations
opt_iter=6; %Optimum number of iterations
max_retries=5; %Maximum number of retries
dtmin=(numTimeSteps)/200; %Minimum time step size
dtmax=1; %Maximum time step size
symmetric_stiffness=1;
min_residual=1e-20;
runMode='internal'; %'external' or 'internal'




markerSize=1; 
%Get a template with default settings
%Get a template with default settings
[febio_spec]=febioStructTemplate;

%febio_spec version
febio_spec.ATTR.version='4.0';

%Module section
febio_spec.Module.ATTR.type='solid';

%Control sections for each step
febio_spec.Step.step{1}.Control=febio_spec.Control; %Copy from template
febio_spec.Step.step{1}.ATTR.id=1;
febio_spec.Step.step{1}.Control.analysis=analysisType;
febio_spec.Step.step{1}.Control.time_steps=50;
febio_spec.Step.step{1}.Control.step_size=1;
febio_spec.Step.step{1}.Control.solver.max_refs=max_refs;
febio_spec.Step.step{1}.Control.time_stepper.dtmin=dtmin;
febio_spec.Step.step{1}.Control.time_stepper.dtmax=dtmax; 
febio_spec.Step.step{1}.Control.time_stepper.max_retries=max_retries;
febio_spec.Step.step{1}.Control.time_stepper.opt_iter=opt_iter;

febio_spec.Step.step{2}.Control=febio_spec.Control; %Copy from template
febio_spec.Step.step{2}.ATTR.id=2;
febio_spec.Step.step{2}.Control.analysis=analysisType;
febio_spec.Step.step{2}.Control.time_steps=50;
febio_spec.Step.step{2}.Control.step_size=1;
febio_spec.Step.step{2}.Control.solver.max_refs=max_refs;
febio_spec.Step.step{2}.Control.time_stepper.dtmin=dtmin;
febio_spec.Step.step{2}.Control.time_stepper.dtmax=dtmax; 
febio_spec.Step.step{2}.Control.time_stepper.max_retries=max_retries;
febio_spec.Step.step{2}.Control.time_stepper.opt_iter=opt_iter;
febio_spec=rmfield(febio_spec,'Control'); 


%Material section
materialName1='Material1';
febio_spec.Material.material{1}.ATTR.name=materialName1;
febio_spec.Material.material{1}.ATTR.id=1;
febio_spec.Material.material{1}.ATTR.type='reactive viscoelastic';
febio_spec.Material.material{1}.kinetics=1;
febio_spec.Material.material{1}.trigger=0;
febio_spec.Material.material{1}.wmin=0.05;
febio_spec.Material.material{1}.emin=0.001;




febio_spec.Material.material{1}.elastic{1}.ATTR.type='Ogden unconstrained';
febio_spec.Material.material{1}.elastic{1}.c1=c1;
febio_spec.Material.material{1}.elastic{1}.m1=m1;
febio_spec.Material.material{1}.elastic{1}.c2=c1;
febio_spec.Material.material{1}.elastic{1}.m2=-m1;
febio_spec.Material.material{1}.elastic{1}.cp=k;

febio_spec.Material.material{1}.bond.ATTR.type = 'Ogden unconstrained';
febio_spec.Material.material{1}.bond.c1 = c1;
febio_spec.Material.material{1}.bond.m1 = m1;
febio_spec.Material.material{1}.bond.c2= c1;
febio_spec.Material.material{1}.bond.m2=-m1;
febio_spec.Material.material{1}.bond.cp = k;

febio_spec.Material.material{1}.relaxation.ATTR.type = 'relaxation-Prony';
febio_spec.Material.material{1}.relaxation.g1=g11;
febio_spec.Material.material{1}.relaxation.t1=t11;
febio_spec.Material.material{1}.relaxation.g2=g12;
febio_spec.Material.material{1}.relaxation.t2=t12;
febio_spec.Material.material{1}.relaxation.g3=g13;
febio_spec.Material.material{1}.relaxation.t3=t13;
febio_spec.Material.material{1}.relaxation.g4=g14;
febio_spec.Material.material{1}.relaxation.t4=t14;
febio_spec.Material.material{1}.relaxation.g5=g15;
febio_spec.Material.material{1}.relaxation.t5=t15;
febio_spec.Material.material{1}.relaxation.g6=g16;
febio_spec.Material.material{1}.relaxation.t6=t16;


materialName2='Material2';
febio_spec.Material.material{2}.ATTR.name=materialName2;
febio_spec.Material.material{2}.ATTR.id=2;
febio_spec.Material.material{2}.ATTR.type='reactive viscoelastic';
febio_spec.Material.material{2}.kinetics=1;
febio_spec.Material.material{2}.trigger=0;
febio_spec.Material.material{2}.wmin=0.05;
febio_spec.Material.material{2}.emin=0.001;

febio_spec.Material.material{2}.elastic{1}.ATTR.type='Ogden unconstrained';
febio_spec.Material.material{2}.elastic{1}.c1=c2;
febio_spec.Material.material{2}.elastic{1}.m1=m2;
febio_spec.Material.material{2}.elastic{1}.c2=c2;
febio_spec.Material.material{2}.elastic{1}.m2=-m2;
febio_spec.Material.material{2}.elastic{1}.cp=k2;

febio_spec.Material.material{2}.bond.ATTR.type = 'Ogden unconstrained';
febio_spec.Material.material{2}.bond.c1 = c2;
febio_spec.Material.material{2}.bond.m1 = m2;
febio_spec.Material.material{2}.bond.c2= c2;
febio_spec.Material.material{2}.bond.m2=-m2;
febio_spec.Material.material{2}.bond.cp = k2;


febio_spec.Material.material{2}.relaxation.ATTR.type = 'relaxation-Prony';
febio_spec.Material.material{2}.relaxation.g1=g21;
febio_spec.Material.material{2}.relaxation.t1=t21;
febio_spec.Material.material{2}.relaxation.g2=g22;
febio_spec.Material.material{2}.relaxation.t2=t22;
febio_spec.Material.material{2}.relaxation.g3=g23;
febio_spec.Material.material{2}.relaxation.t3=t23;
febio_spec.Material.material{2}.relaxation.g4=g24;
febio_spec.Material.material{2}.relaxation.t4=t24;
febio_spec.Material.material{2}.relaxation.g5=g25;
febio_spec.Material.material{2}.relaxation.t5=t25;
febio_spec.Material.material{2}.relaxation.g6=g26;
febio_spec.Material.material{2}.relaxation.t6=t26;


materialName3='Material3';
febio_spec.Material.material{3}.ATTR.name=materialName3;
febio_spec.Material.material{3}.ATTR.id=3;
febio_spec.Material.material{3}.ATTR.type='reactive viscoelastic';
febio_spec.Material.material{3}.kinetics=1;
febio_spec.Material.material{3}.trigger=0;
febio_spec.Material.material{3}.wmin=0.05;
febio_spec.Material.material{3}.emin=0.001;

febio_spec.Material.material{3}.elastic{1}.ATTR.type='Ogden unconstrained';
febio_spec.Material.material{3}.elastic{1}.c1=c3;
febio_spec.Material.material{3}.elastic{1}.m1=m3;
febio_spec.Material.material{3}.elastic{1}.c2=c3;
febio_spec.Material.material{3}.elastic{1}.m2=-m3;
febio_spec.Material.material{3}.elastic{1}.cp=k3;


febio_spec.Material.material{3}.bond.ATTR.type = 'Ogden unconstrained';
febio_spec.Material.material{3}.bond.c1 = c3;
febio_spec.Material.material{3}.bond.m1 = m3;
febio_spec.Material.material{3}.bond.c2= c3;
febio_spec.Material.material{3}.bond.m2=-m3;
febio_spec.Material.material{3}.bond.cp = k3;


febio_spec.Material.material{3}.relaxation.ATTR.type = 'relaxation-Prony';
febio_spec.Material.material{3}.relaxation.g1=g21;
febio_spec.Material.material{3}.relaxation.t1=t21;
febio_spec.Material.material{3}.relaxation.g2=g22;
febio_spec.Material.material{3}.relaxation.t2=t22;
febio_spec.Material.material{3}.relaxation.g3=g23;
febio_spec.Material.material{3}.relaxation.t3=t23;
febio_spec.Material.material{3}.relaxation.g4=g24;
febio_spec.Material.material{3}.relaxation.t4=t24;
febio_spec.Material.material{3}.relaxation.g5=g25;
febio_spec.Material.material{3}.relaxation.t5=t25;
febio_spec.Material.material{3}.relaxation.g6=g26;
febio_spec.Material.material{3}.relaxation.t6=t26;

%Mesh section
% -> Nodes
febio_spec.Mesh.Nodes{1}.ATTR.name='nodeSet_all'; %The node set name
febio_spec.Mesh.Nodes{1}.node.ATTR.id=(1:size(V,1))'; %The node id's
febio_spec.Mesh.Nodes{1}.node.VAL=V; %The nodel coordinates


% -> Elements
partName1='Part1';
febio_spec.Mesh.Elements{1}.ATTR.name=partName1; %Name of this part
febio_spec.Mesh.Elements{1}.ATTR.type='tet4'; %Element type
febio_spec.Mesh.Elements{1}.elem.ATTR.id=(1:1:size(E1,1))'; %Element id's
febio_spec.Mesh.Elements{1}.elem.VAL=E1; %The element matrix

partName2='Part2';
febio_spec.Mesh.Elements{2}.ATTR.name=partName2; %Name of this part
febio_spec.Mesh.Elements{2}.ATTR.type='tet4'; %Element type
febio_spec.Mesh.Elements{2}.elem.ATTR.id=size(E1,1)+(1:1:size(E2,1))'; %Element id's
febio_spec.Mesh.Elements{2}.elem.VAL=E2; %The element matrix

partName3='Part3';
febio_spec.Mesh.Elements{3}.ATTR.name=partName3; %Name of this part
febio_spec.Mesh.Elements{3}.ATTR.type='tet4'; %Element type
febio_spec.Mesh.Elements{3}.elem.ATTR.id=size(E1,1)+size(E2,1)+(1:1:size(E3,1))'; %Element id's
febio_spec.Mesh.Elements{3}.elem.VAL=E3; %The element matrix

% -> Surfaces
surfaceName1='LoadedSurface';
febio_spec.Mesh.Surface{1}.ATTR.name=surfaceName1;
febio_spec.Mesh.Surface{1}.tri3.ATTR.id=(1:1:size(F_pressure,1))';
febio_spec.Mesh.Surface{1}.tri3.VAL=F_pressure;

% -> NodeSets
nodeSetName1='bcSupportList';
febio_spec.Mesh.NodeSet{1}.ATTR.name=nodeSetName1;
febio_spec.Mesh.NodeSet{1}.VAL=mrow(bcLoad_List);

%MeshDomains section
febio_spec.MeshDomains.SolidDomain{1}.ATTR.name=partName1;
febio_spec.MeshDomains.SolidDomain{1}.ATTR.mat=materialName1;

febio_spec.MeshDomains.SolidDomain{2}.ATTR.name=partName2;
febio_spec.MeshDomains.SolidDomain{2}.ATTR.mat=materialName2;

febio_spec.MeshDomains.SolidDomain{3}.ATTR.name=partName3;
febio_spec.MeshDomains.SolidDomain{3}.ATTR.mat=materialName3;

%Boundary condition section
% -> Fix boundary conditions
febio_spec.Boundary.bc{1}.ATTR.name='FixedDisplacement01';
febio_spec.Boundary.bc{1}.ATTR.type='zero displacement';
febio_spec.Boundary.bc{1}.ATTR.node_set=nodeSetName1;
febio_spec.Boundary.bc{1}.x_dof=1;
febio_spec.Boundary.bc{1}.y_dof=1;
febio_spec.Boundary.bc{1}.z_dof=1;

%Loads section
% -> Surface load
switch loadType
    case 'pressure'
        febio_spec.Loads.surface_load{1}.ATTR.type='pressure';
        febio_spec.Loads.surface_load{1}.ATTR.surface=surfaceName1;
        febio_spec.Loads.surface_load{1}.pressure.ATTR.lc=1;
        febio_spec.Loads.surface_load{1}.pressure.VAL=appliedPressure;
        febio_spec.Loads.surface_load{1}.symmetric_stiffness=1;
    case 'traction'
        febio_spec.Loads.surface_load{1}.ATTR.type='traction';
        febio_spec.Loads.surface_load{1}.ATTR.surface=surfaceName1;
        febio_spec.Loads.surface_load{1}.scale.ATTR.lc=1;
        febio_spec.Loads.surface_load{1}.scale.VAL=appliedPressure;
        febio_spec.Loads.surface_load{1}.traction=[0 0 -1];
end

%LoadData section
% -> load_controller
febio_spec.LoadData.load_controller{1}.ATTR.name='LC_1';
febio_spec.LoadData.load_controller{1}.ATTR.id=1;
febio_spec.LoadData.load_controller{1}.ATTR.type='loadcurve';
febio_spec.LoadData.load_controller{1}.interpolate='Smooth Step';
febio_spec.LoadData.load_controller{1}.extend='repeat';
febio_spec.LoadData.load_controller{1}.points.pt.VAL=[0 0; 10 1;(20) 0];
%Output section
% -> log file
febio_spec.Output.logfile.ATTR.file=febioLogFileName;
febio_spec.Output.logfile.node_data{1}.ATTR.file=febioLogFileName_disp;
febio_spec.Output.logfile.node_data{1}.ATTR.data='ux;uy;uz';
febio_spec.Output.logfile.node_data{1}.ATTR.delim=',';

febio_spec.Output.logfile.element_data{1}.ATTR.file=febioLogFileName_stress;
febio_spec.Output.logfile.element_data{1}.ATTR.data='s1';
febio_spec.Output.logfile.element_data{1}.ATTR.delim=',';

febio_spec.Output.plotfile.compression=0;

febioStruct2xml(febio_spec,febioFebFileName); %Exporting to file and domNode

febioAnalysis.run_filename=febioFebFileName; %The input file name
febioAnalysis.run_logname=febioLogFileName; %The name for the log file
febioAnalysis.disp_on=1; %Display information on the command window
febioAnalysis.runMode=runMode;

[runFlag]=runMonitorFEBio(febioAnalysis);%START FEBio NOW!!!!!!!!

if runFlag==1 %i.e. a succesful run


    dataStruct=importFEBio_logfile(fullfile(savePath,febioLogFileName_disp),0,1);

    %Access data
    N_disp_mat=dataStruct.data; %Displacement
    timeVec=dataStruct.time; %Time

    %Create deformed coordinate set
    V_DEF=N_disp_mat+repmat(V,[1 1 size(N_disp_mat,3)]);

        DN_magnitude=sqrt(sum(N_disp_mat(:,:,end).^2,2)); %Current displacement magnitude

    % Create basic view and store graphics handle to initiate animation
    hf=cFigure; %Open figure
    gtitle([febioFebFileNamePart,': Press play to animate']);
    title('Displacement magnitude [mm]','Interpreter','Latex')
    hp=gpatch(Fb,V_DEF(:,:,end),DN_magnitude,'k',1); %Add graphics object to animate
    hp.Marker='.';
    hp.MarkerSize=markerSize;
    hp.FaceColor='interp';

    axisGeom(gca,fontSize);
    colormap(gjet(250)); colorbar;
    caxis([0 max(DN_magnitude)]);
    axis(axisLim(V_DEF)); %Set axis limits statically
    camlight headlight;

    % Set up animation features
    animStruct.Time=timeVec; %The time vector
    for qt=1:1:size(N_disp_mat,3) %Loop over time increments
        DN_magnitude=sqrt(sum(N_disp_mat(:,:,qt).^2,2)); %Current displacement magnitude

        %Set entries in animation structure
        animStruct.Handles{qt}=[hp hp]; %Handles of objects to animate
        animStruct.Props{qt}={'Vertices','CData'}; %Properties of objects to animate
        animStruct.Set{qt}={V_DEF(:,:,qt),DN_magnitude}; %Property values for to set in order to animate
    end
    anim8(hf,animStruct); %Initiate animation feature
    drawnow;

        dataStruct=importFEBio_logfile(fullfile(savePath,febioLogFileName_stress),0,1);

    %Access data
    E_stress_mat=dataStruct.data;

    E_stress_mat(isnan(E_stress_mat))=0;

        [CV]=faceToVertexMeasure(E,V,E_stress_mat(:,:,end));

    % Create basic view and store graphics handle to initiate animation
    hf=cFigure; %Open figure
    gtitle([febioFebFileNamePart,': Press play to animate']);
    title('$\sigma_{1}$ [MPa]','Interpreter','Latex')
    hp=gpatch(Fb,V_DEF(:,:,end),CV,'k',1); %Add graphics object to animate
    hp.Marker='.';
    hp.MarkerSize=markerSize;
    hp.FaceColor='interp';

    axisGeom(gca,fontSize);
    colormap(gjet(250)); colorbar;
    caxis([min(E_stress_mat(:)) max(E_stress_mat(:))]/3);
    axis(axisLim(V_DEF)); %Set axis limits statically
    camlight headlight;

    % Set up animation features
    animStruct.Time=timeVec; %The time vector
    for qt=1:1:size(N_disp_mat,3) %Loop over time increments

        [CV]=faceToVertexMeasure(E,V,E_stress_mat(:,:,qt));

        %Set entries in animation structure
        animStruct.Handles{qt}=[hp hp]; %Handles of objects to animate
        animStruct.Props{qt}={'Vertices','CData'}; %Properties of objects to animate
        animStruct.Set{qt}={V_DEF(:,:,qt),CV}; %Property values for to set in order to animate
    end
    anim8(hf,animStruct); %Initiate animation feature
    drawnow;
end 
