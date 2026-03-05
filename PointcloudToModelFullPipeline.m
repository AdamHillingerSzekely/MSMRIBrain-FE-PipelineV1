clear ; close all; clc;
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

c3=1.8*1e-3; %Shear-modulus-like parameter canc= white
m3=10; %Material parameter setting degree of non-linearity
k_factor=1e2; %Bulk modulus factor
k3=c3*k_factor; %Bulk modulus
pressureHgmm= 15;
%pressure in pascals
PressurePa=pressureHgmm*133.322;
%pressure in Mega pascals
appliedPressure= PressurePa/10^6;

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
numTimeSteps=20; %Number of time steps desired
max_refs=25; %Max reforms
max_ups=0; %Set to zero to use full-Newton iterations
opt_iter=6; %Optimum number of iterations
max_retries=5; %Maximum number of retires
dtmin=(1/numTimeSteps)/100; %Minimum time step size
dtmax=1/numTimeSteps; %Maximum time step size
symmetric_stiffness=1;
min_residual=1e-20;
runMode='internal'; %'external' or 'internal'
markerSize=25; 
% Load vertex data from TXT file
brainoriginal = pcread('brainvolume.ply');
Wbrain = pcread('WMnew.ply');
lesioni = pcread('patient1volume.ply');
Wbrain=pcmerge(Wbrain, lesioni, 0.001);
% Load the point cloud
brainoriginal=pcmerge(brainoriginal, Wbrain, 0.001);

% Define the dilation distance (adjust as needed)
dilation_distance = 3; % Adjust the distance as needed

% Determine the range of coordinates in the point cloud
min_coords = min(brainoriginal.Location);
max_coords = max(brainoriginal.Location);

% Calculate the volume size based on the range of coordinates
volume_size = ceil(max_coords - min_coords) + 1;

% Shift the coordinates to be non-negative
shifted_coords = bsxfun(@minus, brainoriginal.Location, min_coords) + 1;

% Convert point cloud to a binary volume
volume = zeros(volume_size);     % Initialize the binary volume
volume(sub2ind(volume_size, round(shifted_coords(:,1)), round(shifted_coords(:,2)), round(shifted_coords(:,3)))) = 1;  % Set voxel values to 1 for points in the point cloud

% Define the structuring element for dilation
se = strel('sphere', dilation_distance);  % Create a spherical structuring element

% Perform dilation on the binary volume
dilated_volume = imdilate(volume, se);  % Dilate the binary volume

% Convert the dilated binary volume back to a point cloud
[x, y, z] = ind2sub(volume_size, find(dilated_volume(:)));  % Find voxel indices with value 1
brainpointclouddilated = [x, y, z];  % Convert voxel indices to 3D coordinates
brainpointclouddilated=pointCloud(brainpointclouddilated);

% Calculate the centroids of the original and another point clouds
centroid_original = mean(brainpointclouddilated.Location);
centroid_another = mean(brainoriginal.Location);
figure;
pcshow(brainoriginal.Location, 'r'); % Plot point cloud 1 in red
hold on; % Hold the current plot
pcshow(brainpointclouddilated.Location, 'b'); % Plot point cloud 2 in blue
hold off; % Release the current plot
% Calculate the translation vector to align the centroids
translation_vector = centroid_original - centroid_another;

% Apply translation to the another point cloud
shifted_location = brainpointclouddilated.Location - translation_vector;
figure;
pcshow(brainoriginal.Location, 'r'); % Plot point cloud 1 in red

set(gca, 'Color', 'w');
set(gcf, 'Color', 'w'); % Figure background to white
set(gca, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k'); % Axes color to black
xlabel('X');
ylabel('Y');
zlabel('Z');
% Create a new point cloud with the translated coordinates
brainpointclouddilated= pointCloud(shifted_location, 'Color', brainpointclouddilated.Color); % Retain color information if available
% Visualize the original and dilated point clouds
figure;
pcshow(brainoriginal.Location, 'r'); % Plot point cloud 1 in red
hold on; % Hold the current plot
pcshow(brainpointclouddilated.Location, 'b'); % Plot point cloud 2 in blue
axis equal;
set(gca, 'Color', 'w');
set(gcf, 'Color', 'w'); % Figure background to white
set(gca, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k'); % Axes color to black
set(gca, 'GridColor', 'k'); % Grid color to black
xlabel('X');
ylabel('Y');
zlabel('Z');

 % Release the current plot

brain=brainpointclouddilated;

figure;
pcshow(brain);
axis equal;
set(gca, 'Color', 'w');
set(gcf, 'Color', 'w'); % Figure background to white
set(gca, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k'); % Axes color to black
set(gca, 'GridColor', 'k'); % Grid color to black
xlabel('X');
ylabel('Y');
zlabel('Z');
figure;


brain= brain.Location;
brain=double(brain);

shp = alphaShape(brain(:,1),brain(:,2),brain(:,3), 7);


plot(shp);
set(gca, 'Color', 'w');
set(gcf, 'Color', 'w'); % Figure background to white
set(gca, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k'); % Axes color to black
set(gca, 'GridColor', 'k'); % Grid color to black
xlabel('X');
ylabel('Y');
zlabel('Z');
%title('Alpha Shape Mesh');
[facets,nodes] = boundaryFacets(shp);
[tri,V] = alphaTriangulation(shp);

%tri = triangulateFaces(shp.tri);
%trimesh(tri,V(:,1),V(:,2),V(:,3));


[N]=numConnect(facets,nodes);
logicThree=N==3;


%remove3connected points
[Ft,Vt,~,L]=triSurfRemoveThreeConnect(facets,nodes,[]);
C=double(L);





%surface smoothening
cPar.n=25;      %check the best value
cPar.Method='HC';
[Vt]=patchSmooth(Ft,Vt,[],cPar);

% Visualize original and smoothed mesh
figure;

trisurf(Ft, V(:, 1), V(:, 2), V(:, 3), 'FaceColor', 'cyan', 'EdgeColor', 'black');
axis equal;
%title('Original Mesh');
set(gca, 'Color', 'w');
set(gcf, 'Color', 'w'); % Figure background to white
set(gca, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k'); % Axes color to black
set(gca, 'GridColor', 'k'); % Grid color to black
xlabel('X');
ylabel('Y');
zlabel('Z');
figure;

trisurf(Ft, Vt(:, 1), Vt(:, 2), Vt(:, 3), 'FaceColor', 'None', 'EdgeColor', 'black');
axis equal;
%title('Smoothed Mesh');

set(gca, 'Color', 'w');
set(gcf, 'Color', 'w'); % Figure background to white
set(gca, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k'); % Axes color to black
set(gca, 'GridColor', 'k'); % Grid color to black
xlabel('X');
ylabel('Y');
zlabel('Z');
Et=patchBoundary(Ft);




[Ft,Vt]=mergeVertices(Ft,Vt);







mesh = surfaceMesh(Vt,Ft);

% Count the number of faces
numFaces = size(Ft, 1);

% Display the number of faces
disp(['Number of faces in the mesh: ', num2str(numFaces)]);
% Check if the mesh is watertight
TF = isWatertight(mesh);
% Display the result
if TF
disp('The mesh is watertight.');
else
disp('The mesh is not watertight.');
end
cFigure;
hp1=gpatch(Ft,Vt,'kw','k',1,2);
hp2=gpatch(Et,Vt,'none','r',1,3);
legend([hp1 hp2],{'Mesh','Boundary edges'})
axisGeom; view(2);
%title('Visualisation of boundary edges (for instances in which mesh is not watertight)');
drawnow;




%White Matter



% Load vertex data from TXT file
WM = pcread('WMnew.ply');
lesion = pcread('patient1volume.ply');
%lesion = lesion.Location;
%lesion = double(lesion);
WM = pcmerge(lesion, WM, 0.001);
% Load the point cloud



% Define the dilation distance (adjust as needed)
dilation_distance = 2; % Adjust the distance as needed

% Determine the range of coordinates in the point cloud
min_coords = min(WM.Location);
max_coords = max(WM.Location);

% Calculate the volume size based on the range of coordinates
volume_size = ceil(max_coords - min_coords) + 1;


% Shift the coordinates to be non-negative
shifted_coords = bsxfun(@minus, WM.Location, min_coords) + 1;

% Convert point cloud to a binary volume
volume = zeros(volume_size);     % Initialize the binary volume
volume(sub2ind(volume_size, round(shifted_coords(:,1)), round(shifted_coords(:,2)), round(shifted_coords(:,3)))) = 1;  % Set voxel values to 1 for points in the point cloud

% Define the structuring element for dilation
se = strel('sphere', dilation_distance);  % Create a spherical structuring element

% Perform dilation on the binary volume
dilated_volume = imdilate(volume, se);  % Dilate the binary volume

% Convert the dilated binary volume back to a point cloud
[x, y, z] = ind2sub(volume_size, find(dilated_volume(:)));  % Find voxel indices with value 1
WMpointcloud = [x, y, z];  % Convert voxel indices to 3D coordinates
WMpointcloud=pointCloud(WMpointcloud);
% Calculate the centroids of the original and another point clouds
centroid_original = mean(WMpointcloud.Location);
centroid_another = mean(WM.Location);


figure;
pcshow(WM.Location, 'r'); % Plot point cloud 1 in red
set(gca, 'Color', 'w');
set(gcf, 'Color', 'w'); % Figure background to white
set(gca, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k'); % Axes color to black
set(gca, 'GridColor', 'k'); % Grid color to black
xlabel('X');
ylabel('Y');
zlabel('Z');
hold on; % Hold the current plot
pcshow(WMpointcloud.Location, 'b'); % Plot point cloud 2 in blue
 % Release the current plot
set(gca, 'Color', 'w');
set(gcf, 'Color', 'w'); % Figure background to white
set(gca, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k'); % Axes color to black
set(gca, 'GridColor', 'k'); % Grid color to black
xlabel('X');
ylabel('Y');
zlabel('Z');
% Calculate the translation vector to align the centroids
translation_vector = centroid_original - centroid_another;

% Apply translation to the another point cloud
shifted_location = WMpointcloud.Location - translation_vector;

% Create a new point cloud with the translated coordinates
shifted_brain = pointCloud(shifted_location, 'Color', WMpointcloud.Color); % Retain color information if available



WM = shifted_brain;

pcshow(WM)
set(gca, 'Color', 'w');
set(gcf, 'Color', 'w'); % Figure background to white
set(gca, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k'); % Axes color to black
set(gca, 'GridColor', 'k'); % Grid color to black
xlabel('X');
ylabel('Y');
zlabel('Z');
minDistanceW= 1;
minPointsW=10000;
[labelsW,numClustersW] = pcsegdist(WM, minDistanceW, 'NumClusterPoints', minPointsW);

idxValidPointsW = find(labelsW);
labelColorIndexW = labelsW(idxValidPointsW);
segmentedcloudW = select(WM, idxValidPointsW);

figure
colormap(hsv(numClustersW))
pcshow(segmentedcloudW.Location,labelColorIndexW)
set(gca, 'Color', 'w');
set(gcf, 'Color', 'w'); % Figure background to white
set(gca, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k'); % Axes color to black
set(gca, 'GridColor', 'k'); % Grid color to black
xlabel('X');
ylabel('Y');
zlabel('Z');
%title('Pointcloud white matter')
% Print characteristics of each cluster
for clusterW = 1:numClustersW
    fprintf('Cluster %d:\n', clusterW);
    
    % Extract points belonging to this cluster
    clusterPointsW = segmentedcloudW.Location(labelColorIndexW == clusterW, :);

    % Compute centroid
    centroidW = mean(clusterPointsW);
    fprintf('Centroid: %f, %f, %f\n', centroidW(1), centroidW(2), centroidW(3));
    
    % Compute cluster size (number of points)
    clusterSizeW = size(clusterPointsW, 1);
    fprintf('Number of points: %d\n', clusterSizeW);

    
    % Compute other properties as needed
    % For example, you can compute bounding box, surface area, etc.
    
    fprintf('\n'); % Add a newline for clarity
end
for clusterW = 1:numClustersW
    
    % Create a new figure for the current cluster
    %figure;
    

    
    % Extract points belonging to the current cluster
    clusterPointsW = segmentedcloudW.Location(labelColorIndexW == clusterW, :);
    
    % Plot points of the current cluster on the original coordinate system
    %pcshow(clusterPoints);
    
    % Set title for the current figure
    %title(['Cluster ', num2str(cluster)]);
    
    % Optionally, you can add additional visualization settings or properties
    
    %hold off; % Release the hold
    clusterPointsW=double(clusterPointsW);
    shpW = alphaShape(clusterPointsW(:,1),clusterPointsW(:,2),clusterPointsW(:,3), 7);

    %plot(shpL);

    [facetsW,nodesW] = boundaryFacets(shpW);
    [triW,VW] = alphaTriangulation(shpW);

    %triL = triangulateFaces(shpL.triL);
    %trimesh(triL,VL(:,1),VL(:,2),VL(:,3));


    [NW]=numConnect(facetsW,nodesW);
    logicThree=NW==3;


    %remove3connected points
    [FtW,VtW,~,LW]=triSurfRemoveThreeConnect(facetsW,nodesW,[]);
    C=double(LW);





    %surface smoothening
    cPar.n=25;      %check the best value
    cPar.Method='HC';
    [VtW]=patchSmooth(FtW,VtW,[],cPar);

    % Visualize original and smoothed mesh
    
    figure;

    trisurf(FtW, VW(:, 1), VW(:, 2), VW(:, 3), 'FaceColor', 'cyan', 'EdgeColor', 'black');
    axis equal;
    %title('Original Mesh');
    set(gca, 'Color', 'w');
    set(gcf, 'Color', 'w'); % Figure background to white
    set(gca, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k'); % Axes color to black
    set(gca, 'GridColor', 'k'); % Grid color to black
    xlabel('X');
    ylabel('Y');
    zlabel('Z');

    figure;

    trisurf(FtW, VtW(:, 1), VtW(:, 2), VtW(:, 3), 'FaceColor', 'None', 'EdgeColor', 'black');
    axis equal;
    set(gca, 'Color', 'w');
    set(gcf, 'Color', 'w'); % Figure background to white
    set(gca, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k'); % Axes color to black
    set(gca, 'GridColor', 'k'); % Grid color to black
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    %title('Smoothed Mesh');
    EtW=patchBoundary(FtW);

    [FtW,VtW]=mergeVertices(FtW,VtW);

    meshW = surfaceMesh(VtW,FtW);
    % Check if the mesh is watertight
    TF = isWatertight(meshW);
    % Display the result
    if TF
    disp('The mesh is watertight.');
    else
    disp('The mesh is not watertight.');
    end
    cFigure;
    hp1=gpatch(FtW,VtW,'kw','k',1,2);
    hp2=gpatch(EtW,VtW,'none','r',1,3);
    legend([hp1 hp2],{'Mesh','Boundary edges'})
    axisGeom; view(2);
    %title('Visualisation of boundary edges (for instances in which mesh is not watertight)');
    drawnow;


    
    
    
    smoothedmeshcombineW{clusterW}= struct('Vertices',VtW, 'Faces',FtW);
    
end
figure;
hold on;
for clusterW =1:numClustersW
    meshW = smoothedmeshcombineW{clusterW};
    trisurf(meshW.Faces, meshW.Vertices(:,1), meshW.Vertices(:,2), meshW.Vertices(:,3), 'FaceColor', 'None', 'EdgeColor', 'black');
end
axis equal;
%title('White Matter mesh');
hold off;

%Lesion code
% Load vertex data from TXT file
lesion = pcread('patient1volume.ply');

%lesion = lesion.Location;
%lesion = double(lesion);




pcshow(lesion.Location, 'r');
set(gca, 'Color', 'w');
set(gcf, 'Color', 'w'); % Figure background to white
set(gca, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k'); % Axes color to black
set(gca, 'GridColor', 'k'); % Grid color to black
xlabel('X');
ylabel('Y');
zlabel('Z');
minDistanceL = 1;
minPointsL=2000;
[labelsL,numClustersL] = pcsegdist(lesion, minDistanceL, 'NumClusterPoints', minPointsL);

idxValidPointsL = find(labelsL);
labelColorIndexL = labelsL(idxValidPointsL);
segmentedcloudL = select(lesion, idxValidPointsL);

figure
colormap(hsv(numClustersL))
pcshow(segmentedcloudL.Location,labelColorIndexL)
set(gca, 'Color', 'w');
set(gcf, 'Color', 'w'); % Figure background to white
set(gca, 'XColor', 'k', 'YColor', 'k', 'ZColor', 'k'); % Axes color to black
set(gca, 'GridColor', 'k'); % Grid color to black
xlabel('X');
ylabel('Y');
zlabel('Z');
%title('pointcloud Lesion')
% Print characteristics of each cluster
for clusterL = 1:numClustersL
    fprintf('Cluster %d:\n', clusterL);
    
    % Extract points belonging to this cluster
    clusterPointsL = segmentedcloudL.Location(labelColorIndexL == clusterL, :);

    % Compute centroid
    centroidL = mean(clusterPointsL);
    fprintf('Centroid: %f, %f, %f\n', centroidL(1), centroidL(2), centroidL(3));
    
    % Compute cluster size (number of points)
    clusterSizeL = size(clusterPointsL, 1);
    fprintf('Number of points: %d\n', clusterSizeL);

    
    % Compute other properties as needed
    % For example, you can compute bounding box, surface area, etc.
    
    fprintf('\n'); % Add a newline for clarity
end
for clusterL = 1:numClustersL
    
    % Create a new figure for the current cluster
    %figure;
    

    
    % Extract points belonging to the current cluster
    clusterPointsL = segmentedcloudL.Location(labelColorIndexL == clusterL, :);
    
    % Plot points of the current cluster on the original coordinate system
    %pcshow(clusterPoints);
    
    % Set title for the current figure
    %title(['Cluster ', num2str(cluster)]);
    
    % Optionally, you can add additional visualization settings or properties
    
    %hold off; % Release the hold
    clusterPointsL=double(clusterPointsL);
    shpL = alphaShape(clusterPointsL(:,1),clusterPointsL(:,2),clusterPointsL(:,3), 4);

    %plot(shpL);

    [facetsL,nodesL] = boundaryFacets(shpL);
    [triL,VL] = alphaTriangulation(shpL);

    %triL = triangulateFaces(shpL.triL);
    %trimesh(triL,VL(:,1),VL(:,2),VL(:,3));


    [NL]=numConnect(facetsL,nodesL);
    logicThree=NL==3;


    %remove3connected points
    [FtL,VtL,~,LL]=triSurfRemoveThreeConnect(facetsL,nodesL,[]);
    C=double(LL);




    %surface smoothening
    cPar.n=25;      %check the best value
    cPar.Method='HC';
    [VtL]=patchSmooth(FtL,VtL,[],cPar);

    % Visualize original and smoothed mesh
    
    figure;

    trisurf(FtL, VL(:, 1), VL(:, 2), VL(:, 3), 'FaceColor', 'cyan', 'EdgeColor', 'black');
    axis equal;
    %title('Original Mesh');
    

    figure;

    trisurf(FtL, VtL(:, 1), VtL(:, 2), VtL(:, 3), 'FaceColor', 'None', 'EdgeColor', 'black');
    axis equal;
    %title('smoothed Mesh');

   
    smoothedmeshcombineL{clusterL}= struct('Vertices',VtL, 'Faces',FtL);
    
end







%Everything in Combination
figure;
hold on;

for clusterL =1:numClustersL
    meshL = smoothedmeshcombineL{clusterL};
    trisurf(meshL.Faces, meshL.Vertices(:,1), meshL.Vertices(:,2), meshL.Vertices(:,3), 'FaceColor', 'None', 'EdgeColor', 'red');
end

for clusterW =1:numClustersW
    meshW = smoothedmeshcombineW{clusterW};
    trisurf(meshW.Faces, meshW.Vertices(:,1), meshW.Vertices(:,2), meshW.Vertices(:,3), 'FaceColor', 'None', 'EdgeColor', 'cyan');
end
trisurf(Ft, Vt(:, 1), Vt(:, 2), Vt(:, 3), 'FaceColor', 'None', 'EdgeColor', 'black');
axis equal;
%title('Smoothed Meshes for all Clusters');
hold off;
clear braincombine brainpointcloud centroid_another centroid_original


%Joining surface sets
FW_cell = cell(1, numClustersW);
VW_cell = cell(1, numClustersW);
for clusterW =1:numClustersW
    meshW = smoothedmeshcombineW{clusterW};
    FW=meshW.Faces;
    FW_cell{clusterW} = FW;
    VW =meshW.Vertices;
    VW_cell{clusterW}= VW;
end


FL_cell = cell(1, numClustersL);
VL_cell = cell(1, numClustersL);
for clusterL =1:numClustersL
    meshL = smoothedmeshcombineL{clusterL};
    FL=meshL.Faces;
    FL_cell{clusterL} = FL;
    VL =meshL.Vertices;
    VL_cell{clusterL}= VL;
end
%disp(size([{Ft}, FL_cell(:)']))





[F, V, C] = joinElementSets([{Ft}, FW_cell(:)', FL_cell(:)'], [{Vt}, VW_cell(:)', VL_cell(:)']);

%[F, V, C] = joinElementSets({Ft, FL}, {Vt, VL});

%%
% Find interior points
%[V_region1]=getInnerPoint({Ft,FL},{Vt,VL}); 
%[V_region2]=getInnerPoint(FL,VL);


[V_region1]=getInnerPoint([{Ft}, FW_cell(:)', FL_cell(:)'], [{Vt}, VW_cell(:)', VL_cell(:)']); 

[V_RegionCellW]= cell(1, numClustersW);
for clusterW =1:numClustersW
    meshW = smoothedmeshcombineW{clusterW};
    FW=meshW.Faces;
    VW =meshW.Vertices;
    [V_region] = getInnerPoint(FW,VW);
    V_RegionCellW{clusterW}=V_region;
end

V_regionsWM = [cat(1, V_RegionCellW{:})];



[V_RegionCellL]= cell(1, numClustersL);
for clusterL =1:numClustersL
    meshL = smoothedmeshcombineL{clusterL};
    FL=meshL.Faces;
    VL =meshL.Vertices;
    [V_region] = getInnerPoint(FL,VL);
    V_RegionCellL{clusterL}=V_region;
end

V_regionsL = [cat(1, V_RegionCellL{:})];





V_regions = [V_region1; V_regionsWM; V_regionsL];

%Define hole points
V_holes=[]; 


[V_VolParametersW]= cell(1, numClustersW);

for clusterW = 1:numClustersW
    meshW = smoothedmeshcombineW{clusterW};
    FW=meshW.Faces;
    VW =meshW.Vertices;
    [vol]=tetVolMeanEst(FW,VW);
    V_VolParametersW{clusterW}=vol;

end

[V_VolParametersL]= cell(1, numClustersL);

for clusterL = 1:numClustersL
    meshL = smoothedmeshcombineL{clusterL};
    FL=meshL.Faces;
    VL =meshL.Vertices;
    [vol]=tetVolMeanEst(FL,VL);
    V_VolParametersL{clusterL}=vol;

end





[vol1]=tetVolMeanEst(Ft,Vt);


regionTetVolumes=[vol1 V_VolParametersW{:} V_VolParametersL{:}]; %Element volume settings

stringOpt='-pq1.2AaY'; %Tetgen options

%%
% mesh using tet
%Create tetgen input structure
inputStruct.stringOpt=stringOpt; %Tetgen options
inputStruct.Faces=F; %Boundary faces
inputStruct.Nodes=V; %Nodes of boundary
inputStruct.faceBoundaryMarker=C; 
inputStruct.regionPoints=V_regions; %Interior points for regions
inputStruct.holePoints=V_holes; %Interior points for holes
inputStruct.regionA=regionTetVolumes; %Desired tetrahedral volume for each region

% Mesh model using tetrahedral elements using tetGen 
[meshOutput]=runTetGen(inputStruct); %Run tetGen 

%% 
% Access mesh output structure

E=meshOutput.elements; %The elements
V=meshOutput.nodes; %The vertices or nodes
CE=meshOutput.elementMaterialID; %Element material or region id
Fb=meshOutput.facesBoundary; %The boundary faces
Cb=meshOutput.boundaryMarker; %The boundary markers

black=[0 0 0];
red=[1 0 0];
blue=[0 0 1];
cyan=[0 1 1];
%%
% Visualization
cMap = zeros(numClustersL+numClustersW+1, 3);  % Initialize the matrix with zeros
cMap(1:numClustersL, :) = repmat(red, numClustersL, 1);  % Set the first n rows to [0 0 1]
cMap(numClustersL+1: numClustersL+numClustersW, :) = repmat(cyan, numClustersW, 1);
cMap(end, :) = black;  % Set the last row to [1 0 0]

patchColor=cMap(1,:);

cMap2 = zeros(numClustersL+numClustersW+1, 3);  % Initialize the matrix with zeros
cMap2(1, :) = black;  % Set the first row to [1 0 0]
for i = 2:(numClustersL+1)
    cMap2(i, :) = cyan;  % Set the remaining rows to [0 0 1]
end% Blue for internal structures
for i = 2+numClustersL:(numClustersW+numClustersL+1)
    cMap2(i, :) = red;  % Set the remaining rows to [0 0 1]
end% Blue for internal structures

patchColor2=cMap2(1,:);

hf=cFigure; 
subplot(1,2,1); hold on;
%title('Input boundaries','FontSize',fontSize);
hp(1) = gpatch(Fb, V, Cb, 'k', faceAlpha1);
hp(2) = plotV(V_regions, 'r.', 'MarkerSize', markerSize);
%legend(hp, {'Input mesh', 'Interior point(s)'}, 'Location', 'NorthWestOutside');
axisGeom(gca, fontSize); 
camlight headlight;
%colormap(cMap2); 
%icolorbar;

hs = subplot(1,2,2); hold on;
%title('Tetrahedral mesh','FontSize',fontSize);

% Visualizing using |meshView|
optionStruct.hFig = [hf,hs];
meshView(meshOutput,optionStruct);

axisGeom(gca, fontSize); 
colormap(cMap); 
gdrawnow;


% Example target material ID you want to select elements for
GreyMatter = -2;  % Change this to the material ID you are interested in
WhiteMatter = -3;
% Step 1: Find the indices of elements with the target material ID
selectedElementIndicesGrey = find(CE == GreyMatter);
% Step 2: Select elements from E based on these indices
E1 = E(selectedElementIndicesGrey, :);
selectedElementIndicesWhite = find(CE == WhiteMatter);
% Step 2: Select elements from E based on these indices
E2 = E(selectedElementIndicesWhite, :);
selectedElementIndicesLesions = find(CE ~=-2 & CE ~=-3 );
E3 = E(selectedElementIndicesLesions, :);

w=10;
f=[1 2 3 4];
v=w*[-1 -1 0.48; -1 1 0; 1 1 0.48; 1 -1 0.48];

p=[0 0 0];
Q=euler2DCM([0 (180/180)*pi 0]);
v=v*Q;
v=v+p;

Vr=V*Q';
Vr=Vr+p;
logicHeadNodes=Vr(:,3);%<35;
logicHeadFaces=all(logicHeadNodes(Fb),2);
F_pressure=Fb(logicHeadFaces,:);
%F_pressure=Fb(Cb==1,:);



hf=cFigure;
%title('Boundary conditions','FontSize',fontSize);
xlabel('X','FontSize',fontSize); ylabel('Y','FontSize',fontSize); zlabel('Z','FontSize',fontSize);
hold on;

gpatch(Fb,V,'kw','none',0.5);
hl=gpatch(F_pressure,V,'rw','r',1);
patchNormPlot(F_pressure,V);

legend(hl,{'Pressure surface'});

axisGeom(gca,fontSize);
camlight headlight;
drawnow;


w=100;
f=[1 2 3 4];
v=w*[-1 -1 0.48; -1 1 0.48; 1 1 0.48; 1 -1 0.48];

p=[0 0 0];
Q=euler2DCM([0 (180/180)*pi 0]);
v=v*Q;
v=v+p;

Vr=V*Q';
Vr=Vr+p;
logicHeadNodes2=Vr(:,3)>30 ;
logicHeadFaces2=all(logicHeadNodes2(Fb),2);
bcLoad_List=unique(Fb(logicHeadFaces2,:));





hf=cFigure;
%title('Boundary conditions','FontSize',fontSize);
xlabel('X','FontSize',fontSize); ylabel('Y','FontSize',fontSize); zlabel('Z','FontSize',fontSize);
hold on;
gpatch(Fb,V,'kw','none',0.5);
hl(1)=plotV(V(bcLoad_List,:),'k.','markerSize',15);
hl(2)=gpatch(F_pressure,V,'rw','r',1);
patchNormPlot(F_pressure,V);

legend(hl,{'BC support','Pressure surface'});

axisGeom(gca,fontSize);
camlight headlight;
drawnow;

% Create a struct to hold all the data
meshData.V = V;
meshData.E1 = E1;
meshData.E2 = E2;
meshData.E3 = E3;
meshData.F_pressure = F_pressure;
meshData.bcLoad_List = bcLoad_List;

% Save the struct as a .mat file
save('meshData.mat', 'meshData');






%Get a template with default settings
[febio_spec]=febioStructTemplate;

%febio_spec version
febio_spec.ATTR.version='4.0';

%Module section
febio_spec.Module.ATTR.type='solid';

%Control section
febio_spec.Control.analysis='STATIC';
febio_spec.Control.time_steps=numTimeSteps;
febio_spec.Control.step_size=1/numTimeSteps;
febio_spec.Control.solver.max_refs=max_refs;
febio_spec.Control.solver.qn_method.max_ups=max_ups;
febio_spec.Control.time_stepper.dtmin=dtmin;
febio_spec.Control.time_stepper.dtmax=dtmax;
febio_spec.Control.time_stepper.max_retries=max_retries;
febio_spec.Control.time_stepper.opt_iter=opt_iter;


%Material section
materialName1='Material1';
febio_spec.Material.material{1}.ATTR.name=materialName1;
febio_spec.Material.material{1}.ATTR.type='Ogden';
febio_spec.Material.material{1}.ATTR.id=1;
febio_spec.Material.material{1}.c1=c1;
febio_spec.Material.material{1}.m1=m1;
febio_spec.Material.material{1}.c2=c1;
febio_spec.Material.material{1}.m2=-m1;
febio_spec.Material.material{1}.k=k;

materialName2='Material2';
febio_spec.Material.material{2}.ATTR.name=materialName2;
febio_spec.Material.material{2}.ATTR.type='Ogden';
febio_spec.Material.material{2}.ATTR.id=2;
febio_spec.Material.material{2}.c1=c2;
febio_spec.Material.material{2}.m1=m2;
febio_spec.Material.material{2}.c2=c2;
febio_spec.Material.material{2}.m2=-m2;
febio_spec.Material.material{2}.k=k2;

materialName3='Material3';
febio_spec.Material.material{3}.ATTR.name=materialName3;
febio_spec.Material.material{3}.ATTR.type='Ogden';
febio_spec.Material.material{3}.ATTR.id=3;
febio_spec.Material.material{3}.c1=c3;
febio_spec.Material.material{3}.m1=m3;
febio_spec.Material.material{3}.c2=c3;
febio_spec.Material.material{3}.m2=-m3;
febio_spec.Material.material{3}.k=k3;

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
febio_spec.LoadData.load_controller{1}.points.pt.VAL=[0 0; 1 1];

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
    hp.MarkerSize=markerSize2;
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
    hp.MarkerSize=markerSize2;
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
