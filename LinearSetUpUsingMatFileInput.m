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
c1min=1.1*1e-3;
c1mid=1.4*1e-3;
c1max=1.7*1e-3;
c2min=1.3*1e-3;
c2mid=1.9*1e-3;
c2max=2.5*1e-3;
c3min=1.15*1e-3;
c3mid=2.2*1e-3;
c3max=3.25*1e-3;
%Material parameters (MPa if spatial units are mm)
%Material parameter set cort= grey
%c1=1.216*1e-3; %Shear-modulus-like parameter
c1=c1mid;
m1=10; %Material parameter setting degree of non-linearity
k_factor=1e2; %Bulk modulus factor
k=c1*k_factor; %Bulk modulus

%c2=1.895*1e-3; %Shear-modulus-like parameter canc= white
c2=c2min;
m2=10; %Material parameter setting degree of non-linearity
k_factor=1e2; %Bulk modulus factor
k2=c2*k_factor; %Bulk modulus
c3=c3mid;
%c3=2.43*1e-3; %Shear-modulus-like parameter lesion inactive value - 1.6*1e-3 active
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





% FEA control settings
numTimeSteps=1; %Number of time steps desired
max_refs=25; %Max reforms
max_ups=0; %Set to zero to use full-Newton iterations
opt_iter=6; %Optimum number of iterations
max_retries=5; %Maximum number of retries
dtmin=(1/numTimeSteps)/100; %Minimum time step size
dtmax=1/numTimeSteps; %Maximum time step size
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

%Control section
febio_spec.Control.analysis='STATIC';
febio_spec.Control.time_steps=40;%change time
febio_spec.Control.step_size=1;
febio_spec.Control.solver.max_refs=max_refs;
febio_spec.Control.solver.qn_method.max_ups=max_ups;
febio_spec.Control.time_stepper.dtmin=1;
febio_spec.Control.time_stepper.dtmax=1;
febio_spec.Control.time_stepper.max_retries=max_retries;
febio_spec.Control.time_stepper.opt_iter=opt_iter;


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
febio_spec.LoadData.load_controller{1}.interpolate='LINEAR';
%febio_spec.LoadData.load_controller{1}.extend='CONSTANT';
febio_spec.LoadData.load_controller{1}.points.pt.VAL=[0 0; 40 40];

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
runFlag=1;
if runFlag==1 %i.e. a succesful run


    dataStruct=importFEBio_logfile(fullfile(savePath,febioLogFileName_disp),0,1);

    %Access data
    N_disp_mat=dataStruct.data; %Displacement

    % Convert output matrices
    N_disp_mat = single(N_disp_mat); 

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
    E_stress_mat = single(E_stress_mat);

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
    
        % Step 1: Identify surface nodes for each material
    surfaceNodes1 = unique(F_pressure(:)); % Nodes on the surface for Material 1
    surfaceNodes2 = unique(E1(:)); % Assuming surface nodes are part of E1
    surfaceNodes3 = unique(E2(:)); % Assuming surface nodes are part of E2

    % Initialize arrays to store average displacement data
    avgDisp1 = zeros(size(N_disp_mat, 3), 1);
    avgDisp2 = zeros(size(N_disp_mat, 3), 1);
    avgDisp3 = zeros(size(N_disp_mat, 3), 1);

    % Step 2: Calculate average displacement for each time step
    for qt = 1:size(N_disp_mat, 3)
        % Displacement magnitudes for surface nodes of Material 1
        DN_magnitude1 = sqrt(sum(N_disp_mat(surfaceNodes1,:,qt).^2, 2));
        avgDisp1(qt) = mean(DN_magnitude1);

        %Displacement magnitudes for surface nodes of Material 2
        DN_magnitude2 = sqrt(sum(N_disp_mat(surfaceNodes2,:,qt).^2, 2));
        avgDisp2(qt) = mean(DN_magnitude2);

        % Displacement magnitudes for surface nodes of Material 3
        DN_magnitude3 = sqrt(sum(N_disp_mat(surfaceNodes3,:,qt).^2, 2));
        avgDisp3(qt) = mean(DN_magnitude3);
    end

    % Plotting the average displacement over time
    figure;
    plot(timeVec, avgDisp1, 'r-', 'LineWidth', 2); hold on;
    plot(timeVec, avgDisp2, 'g-', 'LineWidth', 2);
    plot(timeVec, avgDisp3, 'b-', 'LineWidth', 2);
    xlabel('Time');
    ylabel('Average Displacement [mm]');
    legend('Grey Matter', 'White Matter', 'Lesions');
    title('Average Displacement of Surface Nodes');
    grid on;

    % Initialize arrays to store statistical displacement data
    q2Disp1 = zeros(size(N_disp_mat, 3), 1); % Median (Q2)
    q1Disp1 = zeros(size(N_disp_mat, 3), 1); % First quartile (Q1)
    q3Disp1 = zeros(size(N_disp_mat, 3), 1); % Third quartile (Q3)
    minDisp1 = zeros(size(N_disp_mat, 3), 1); % Minimum
    maxDisp1 = zeros(size(N_disp_mat, 3), 1); % Maximum
    
    q2Disp2 = zeros(size(N_disp_mat, 3), 1);
    q1Disp2 = zeros(size(N_disp_mat, 3), 1);
    q3Disp2 = zeros(size(N_disp_mat, 3), 1);
    minDisp2 = zeros(size(N_disp_mat, 3), 1);
    maxDisp2 = zeros(size(N_disp_mat, 3), 1);
    
    q2Disp3 = zeros(size(N_disp_mat, 3), 1);
    q1Disp3 = zeros(size(N_disp_mat, 3), 1);
    q3Disp3 = zeros(size(N_disp_mat, 3), 1);
    minDisp3 = zeros(size(N_disp_mat, 3), 1);
    maxDisp3 = zeros(size(N_disp_mat, 3), 1);
    
    % Step 2: Calculate statistics for each time step
    for qt = 1:size(N_disp_mat, 3)
        % Displacement magnitudes for surface nodes of Material 1
        DN_magnitude1 = sqrt(sum(N_disp_mat(surfaceNodes1,:,qt).^2, 2));
        q2Disp1(qt) = quantile(DN_magnitude1, 0.5); % Median (Q2)
        q1Disp1(qt) = quantile(DN_magnitude1, 0.25); % Q1
        q3Disp1(qt) = quantile(DN_magnitude1, 0.75); % Q3
        minDisp1(qt) = min(DN_magnitude1); % Minimum
        maxDisp1(qt) = max(DN_magnitude1); % Maximum
    
        % Displacement magnitudes for surface nodes of Material 2
        DN_magnitude2 = sqrt(sum(N_disp_mat(surfaceNodes2,:,qt).^2, 2));
        q2Disp2(qt) = quantile(DN_magnitude2, 0.5); % Median (Q2)
        q1Disp2(qt) = quantile(DN_magnitude2, 0.25); % Q1
        q3Disp2(qt) = quantile(DN_magnitude2, 0.75); % Q3
        minDisp2(qt) = min(DN_magnitude2); % Minimum
        maxDisp2(qt) = max(DN_magnitude2); % Maximum
    
        % Displacement magnitudes for surface nodes of Material 3
        DN_magnitude3 = sqrt(sum(N_disp_mat(surfaceNodes3,:,qt).^2, 2));
        q2Disp3(qt) = quantile(DN_magnitude3, 0.5); % Median (Q2)
        q1Disp3(qt) = quantile(DN_magnitude3, 0.25); % Q1
        q3Disp3(qt) = quantile(DN_magnitude3, 0.75); % Q3
        minDisp3(qt) = min(DN_magnitude3); % Minimum
        maxDisp3(qt) = max(DN_magnitude3); % Maximum
    end
    
    % Plotting the displacement statistics over time for Material 1
    figure;
    subplot(3, 1, 1);
    hold on;
    plot(timeVec, q2Disp1, 'r-', 'LineWidth', 2); % Median (Q2)
    plot(timeVec, q1Disp1, 'c-', 'LineWidth', 1); % Q1
    plot(timeVec, q3Disp1, 'y-', 'LineWidth', 1); % Q3
    plot(timeVec, minDisp1, 'g-.', 'LineWidth', 1); % Minimum
    plot(timeVec, maxDisp1, 'b-.', 'LineWidth', 1); % Maximum
    xlabel('Time');
    ylabel('Displacement [mm]');
    legend('Q2 (Median)', 'Q1', 'Q3', 'Min', 'Max');
    title('Displacement Statistics for Grey Matter');
    grid on;
    
    % Plotting the displacement statistics over time for Material 2
    subplot(3, 1, 2);
    hold on;
    plot(timeVec, q2Disp2, 'r-', 'LineWidth', 2); % Median (Q2)
    plot(timeVec, q1Disp2, 'c-', 'LineWidth', 1); % Q1
    plot(timeVec, q3Disp2, 'y-', 'LineWidth', 1); % Q3
    plot(timeVec, minDisp2, 'g-.', 'LineWidth', 1); % Minimum
    plot(timeVec, maxDisp2, 'b-.', 'LineWidth', 1); % Maximum
    xlabel('Time');
    ylabel('Displacement [mm]');
    legend('Q2 (Median)', 'Q1', 'Q3', 'Min', 'Max');
    title('Displacement Statistics for White Matter');
    grid on;
    
    % Plotting the displacement statistics over time for Material 3
    subplot(3, 1, 3);
    hold on;
    plot(timeVec, q2Disp3, 'r-', 'LineWidth', 2); % Median (Q2)
    plot(timeVec, q1Disp3, 'c-', 'LineWidth', 1); % Q1
    plot(timeVec, q3Disp3, 'y-', 'LineWidth', 1); % Q3
    plot(timeVec, minDisp3, 'g-.', 'LineWidth', 1); % Minimum
    plot(timeVec, maxDisp3, 'b-.', 'LineWidth', 1); % Maximum
    xlabel('Time');
    ylabel('Displacement [mm]');
    legend('Q2 (Median)', 'Q1', 'Q3', 'Min', 'Max');
    title('Displacement Statistics for Lesions');
    grid on;

        % Initialize arrays to store average displacement data
    avgPres1 = zeros(size(E_stress_mat, 3), 1);
    avgPres2 = zeros(size(E_stress_mat, 3), 1);
    avgPres3 = zeros(size(E_stress_mat, 3), 1);

    % Step 2: Calculate average displacement for each time step
    for qt = 1:size(E_stress_mat, 3)
        % Displacement magnitudes for surface nodes of Material 1
        DN_magnitude1 = sqrt(sum(E_stress_mat(surfaceNodes1,:,qt).^2, 2));
        avgPres1(qt) = mean(DN_magnitude1);

        %Displacement magnitudes for surface nodes of Material 2
        DN_magnitude2 = sqrt(sum(E_stress_mat(surfaceNodes2,:,qt).^2, 2));
        avgPres2(qt) = mean(DN_magnitude2);

        % Displacement magnitudes for surface nodes of Material 3
        DN_magnitude3 = sqrt(sum(E_stress_mat(surfaceNodes3,:,qt).^2, 2));
        avgPres3(qt) = mean(DN_magnitude3);
    end

    % Plotting the average displacement over time
    figure;
    plot(timeVec, avgPres1, 'r-', 'LineWidth', 2); hold on;
    plot(timeVec, avgPres2, 'g-', 'LineWidth', 2);
    plot(timeVec, avgPres3, 'b-', 'LineWidth', 2);
    xlabel('Time');
    ylabel('Average Pressure [MPa]');
    legend('Grey Matter', 'White Matter', 'Lesions');
    title('Average Pressure of Surface Nodes');
    grid on;    % Initialize arrays to store average displacement data


        % Initialize arrays to store statistical Pressure data
    q2Pres1 = zeros(size(E_stress_mat, 3), 1); % Median (Q2)
    q1Pres1 = zeros(size(E_stress_mat, 3), 1); % First quartile (Q1)
    q3Pres1 = zeros(size(E_stress_mat, 3), 1); % Third quartile (Q3)
    minPres1 = zeros(size(E_stress_mat, 3), 1); % Minimum
    maxPres1 = zeros(size(E_stress_mat, 3), 1); % Maximum
    
    q2Pres2 = zeros(size(E_stress_mat, 3), 1);
    q1Pres2 = zeros(size(E_stress_mat, 3), 1);
    q3Pres2 = zeros(size(E_stress_mat, 3), 1);
    minPres2 = zeros(size(E_stress_mat, 3), 1);
    maxPres2 = zeros(size(E_stress_mat, 3), 1);
    
    q2Pres3 = zeros(size(E_stress_mat, 3), 1);
    q1Pres3 = zeros(size(E_stress_mat, 3), 1);
    q3Pres3 = zeros(size(E_stress_mat, 3), 1);
    minPres3 = zeros(size(E_stress_mat, 3), 1);
    maxPres3 = zeros(size(E_stress_mat, 3), 1);
    
    % Step 2: Calculate statistics for each time step
    for qt = 1:size(E_stress_mat, 3)
        % Pressure magnitudes for surface nodes of Material 1
        Pres_magnitude1 = sqrt(sum(E_stress_mat(surfaceNodes1,:,qt).^2, 2));
        q2Pres1(qt) = quantile(Pres_magnitude1, 0.5); % Median (Q2)
        q1Pres1(qt) = quantile(Pres_magnitude1, 0.25); % Q1
        q3Pres1(qt) = quantile(Pres_magnitude1, 0.75); % Q3
        minPres1(qt) = min(Pres_magnitude1); % Minimum
        maxPres1(qt) = max(Pres_magnitude1); % Maximum
    
        % Pressure magnitudes for surface nodes of Material 2
        Pres_magnitude2 = sqrt(sum(E_stress_mat(surfaceNodes2,:,qt).^2, 2));
        q2Pres2(qt) = quantile(Pres_magnitude2, 0.5); % Median (Q2)
        q1Pres2(qt) = quantile(Pres_magnitude2, 0.25); % Q1
        q3Pres2(qt) = quantile(Pres_magnitude2, 0.75); % Q3
        minPres2(qt) = min(Pres_magnitude2); % Minimum
        maxPres2(qt) = max(Pres_magnitude2); % Maximum
    
        % Pressure magnitudes for surface nodes of Material 3
        Pres_magnitude3 = sqrt(sum(E_stress_mat(surfaceNodes3,:,qt).^2, 2));
        q2Pres3(qt) = quantile(Pres_magnitude3, 0.5); % Median (Q2)
        q1Pres3(qt) = quantile(Pres_magnitude3, 0.25); % Q1
        q3Pres3(qt) = quantile(Pres_magnitude3, 0.75); % Q3
        minPres3(qt) = min(Pres_magnitude3); % Minimum
        maxPres3(qt) = max(Pres_magnitude3); % Maximum
    end
    
    % Plotting the Pressure statistics over time for Material 1
    figure;
    subplot(3, 1, 1);
    hold on;
    plot(timeVec, q2Pres1, 'r-', 'LineWidth', 2); % Median (Q2)
    plot(timeVec, q1Pres1, 'c-', 'LineWidth', 1); % Q1
    plot(timeVec, q3Pres1, 'y-', 'LineWidth', 1); % Q3
    plot(timeVec, minPres1, 'g-.', 'LineWidth', 1); % Minimum
    plot(timeVec, maxPres1, 'b-.', 'LineWidth', 1); % Maximum
    xlabel('Time');
    ylabel('Pressure [MPa]');
    legend('Q2 (Median)', 'Q1', 'Q3', 'Min', 'Max');
    title('Pressure Statistics for Grey Matter');
    grid on;
    
    % Plotting the Pressure statistics over time for Material 2
    subplot(3, 1, 2);
    hold on;
    plot(timeVec, q2Pres2, 'r-', 'LineWidth', 2); % Median (Q2)
    plot(timeVec, q1Pres2, 'c-', 'LineWidth', 1); % Q1
    plot(timeVec, q3Pres2, 'y-', 'LineWidth', 1); % Q3
    plot(timeVec, minPres2, 'g-.', 'LineWidth', 1); % Minimum
    plot(timeVec, maxPres2, 'b-.', 'LineWidth', 1); % Maximum
    xlabel('Time');
    ylabel('Pressure [MPa]');
    legend('Q2 (Median)', 'Q1', 'Q3', 'Min', 'Max');
    title('Pressure Statistics for White Matter');
    grid on;
    
    % Plotting the Pressure statistics over time for Material 3
    subplot(3, 1, 3);
    hold on;
    plot(timeVec, q2Pres3, 'r-', 'LineWidth', 2); % Median (Q2)
    plot(timeVec, q1Pres3, 'c-', 'LineWidth', 1); % Q1
    plot(timeVec, q3Pres3, 'y-', 'LineWidth', 1); % Q3
    plot(timeVec, minPres3, 'g-.', 'LineWidth', 1); % Minimum
    plot(timeVec, maxPres3, 'b-.', 'LineWidth', 1); % Maximum
    xlabel('Time');
    ylabel('Pressure [MPa]');
    legend('Q2 (Median)', 'Q1', 'Q3', 'Min', 'Max');
    title('Pressure Statistics for Lesions');
    grid on;

end

% After calculating average displacements
disp('Final Average Displacements:');
disp(['Grey Matter: ', num2str(avgDisp1(end))]);
disp(['White Matter: ', num2str(avgDisp2(end))]);
disp(['Lesions: ', num2str(avgDisp3(end))]);

% After calculating displacement statistics
disp('Final Displacement Statistics:');
disp('Grey Matter:');
disp(['Median (Q2): ', num2str(q2Disp1(end))]);
disp(['Q1: ', num2str(q1Disp1(end))]);
disp(['Q3: ', num2str(q3Disp1(end))]);
disp(['Minimum: ', num2str(minDisp1(end))]);
disp(['Maximum: ', num2str(maxDisp1(end))]);

disp('White Matter:');
disp(['Median (Q2): ', num2str(q2Disp2(end))]);
disp(['Q1: ', num2str(q1Disp2(end))]);
disp(['Q3: ', num2str(q3Disp2(end))]);
disp(['Minimum: ', num2str(minDisp2(end))]);
disp(['Maximum: ', num2str(maxDisp2(end))]);

disp('Lesions:');
disp(['Median (Q2): ', num2str(q2Disp3(end))]);
disp(['Q1: ', num2str(q1Disp3(end))]);
disp(['Q3: ', num2str(q3Disp3(end))]);
disp(['Minimum: ', num2str(minDisp3(end))]);
disp(['Maximum: ', num2str(maxDisp3(end))]);

% After calculating average pressures
disp('Final Average Pressures:');
disp(['Grey Matter: ', num2str(avgPres1(end))]);
disp(['White Matter: ', num2str(avgPres2(end))]);
disp(['Lesions: ', num2str(avgPres3(end))]);

% After calculating pressure statistics
disp('Final Pressure Statistics:');
disp('Grey Matter:');
disp(['Median (Q2): ', num2str(q2Pres1(end))]);
disp(['Q1: ', num2str(q1Pres1(end))]);
disp(['Q3: ', num2str(q3Pres1(end))]);
disp(['Minimum: ', num2str(minPres1(end))]);
disp(['Maximum: ', num2str(maxPres1(end))]);

disp('White Matter:');
disp(['Median (Q2): ', num2str(q2Pres2(end))]);
disp(['Q1: ', num2str(q1Pres2(end))]);
disp(['Q3: ', num2str(q3Pres2(end))]);
disp(['Minimum: ', num2str(minPres2(end))]);
disp(['Maximum: ', num2str(maxPres2(end))]);

disp('Lesions:');
disp(['Median (Q2): ', num2str(q2Pres3(end))]);
disp(['Q1: ', num2str(q1Pres3(end))]);
disp(['Q3: ', num2str(q3Pres3(end))]);
disp(['Minimum: ', num2str(minPres3(end))]);
disp(['Maximum: ', num2str(maxPres3(end))]);

% Calculate initial volumes for Grey Matter, White Matter, and Lesions
V0_1 = calculate_convex_hull_volume(double(V(E1(:, 1), :))); % Initial volume for Grey Matter
V0_2 = calculate_convex_hull_volume(double(V(E2(:, 1), :))); % Initial volume for White Matter
V0_3 = calculate_convex_hull_volume(double(V(E3(:, 1), :))); % Initial volume for Lesions

% Initialize arrays to store volumetric strain data
volStrain1 = zeros(size(N_disp_mat, 3), 1); % Volumetric strain for Grey Matter
volStrain2 = zeros(size(N_disp_mat, 3), 1); % Volumetric strain for White Matter
volStrain3 = zeros(size(N_disp_mat, 3), 1); % Volumetric strain for Lesions

% Calculate volumetric strain for each time step
for qt = 1:size(N_disp_mat, 3)
    % Create deformed coordinate set for current time step
    V_DEF = N_disp_mat(:,:,qt) + V;
    
    % Current volume for Grey Matter, White Matter, and Lesions using convhull
    Vt_1 = calculate_convex_hull_volume(double(V_DEF(E1(:, 1), :))); % Grey Matter
    Vt_2 = calculate_convex_hull_volume(double(V_DEF(E2(:, 1), :))); % White Matter
    Vt_3 = calculate_convex_hull_volume(double(V_DEF(E3(:, 1), :))); % Lesions
    
    % Calculate volumetric strain
    volStrain1(qt) = abs(Vt_1 - V0_1) / V0_1; % Grey Matter
    volStrain2(qt) = abs(Vt_2 - V0_2) / V0_2; % White Matter
    volStrain3(qt) = abs(Vt_3 - V0_3) / V0_3; % Lesions
end

% Plotting Volumetric Strain over time for Grey Matter, White Matter, and Lesions
figure;
hold on;
plot(timeVec, volStrain1, 'r-', 'LineWidth', 2); % Grey Matter
plot(timeVec, volStrain2, 'b-', 'LineWidth', 2); % White Matter
plot(timeVec, volStrain3, 'g-', 'LineWidth', 2); % Lesions
xlabel('Time');
ylabel('Volumetric Strain');
legend('Grey Matter', 'White Matter', 'Lesions');
title('Volumetric Strain for Grey Matter, White Matter, and Lesions');
grid on;

% Print final volumetric strain for each material
disp('Final Volumetric Strains:');
disp(['Grey Matter: ', num2str(volStrain1(end))]);
disp(['White Matter: ', num2str(volStrain2(end))]);
disp(['Lesions: ', num2str(volStrain3(end))]);

% Function to calculate the volume of a mesh using convhull
function volume = calculate_convex_hull_volume(V)
    % Convert to double if needed
    V = double(V);
    % Compute the convex hull of the vertices
    [~, volume] = convhull(V(:, 1), V(:, 2), V(:, 3)); % K is the triangulation, volume is returned
end
