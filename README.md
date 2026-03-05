# MSMRIBrain-FE-PipelineV1
This a computational pipeline through which pointclouds extracted from patient-specific MRI of MS patients (using a 3D Slicer and Paraview) and their respective lesion segmentations can be converted in an FE-model so that mechanical tissue properties can be extracted and analysed. Three scripts are contained. The full PointcloudToModelFullPipeline requires the .ply files in the zipped folder in order to run: from pointcloud to mesh. The remaining two scripts contain a pre-meshed brain ready for finite element analysis. MATLAB 2023b, FEBioStudio (studio version 2.4, solver version 4.4) and GIBBON are all required for simulations to run. Install instructions can be found at the following address: https://www.gibboncode.org/Installation/. 


<p align="center">
  <img src="Images/MRI-Thresholding.png" width="330">
  <img src="Images/NRRDpoint.png" width="450">
</p>
<p align="center">
  <em>Figure 1: a) LHS shows thresholding process using Slicer b) RHS depicts pointcloud result conversion result using Paraview ready for input into the pipeline (see plyFiles.zip for the pipeline).</em>
</p>


The pipeline (PointcloudToModelFullPipeline.m) takes three pointcloud inputs corresponding to grey matter, white matter and lesional tissues, converting each of them into a mesh (and in the case of the lesions, meshes). 
