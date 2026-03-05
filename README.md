# MSMRIBrain-FE-PipelineV1
This a computational pipeline through which pointclouds extracted from patient-specific MRI of MS patients (using a 3D Slicer and Paraview) and their respective lesion segmentations can be converted in an FE-model so that mechanical tissue properties can be extracted and analysed. Three scripts are contained. The full PointcloudToModelFullPipeline requires the .ply files in the zipped folder in order to run: from pointcloud to mesh. The remaining two scripts contain a pre-meshed brain ready for finite element analysis. MATLAB 2023b, FEBioStudio (studio version 2.4, solver version 4.4) and GIBBON are all required for simulations to run. Install instructions can be found at the following address: https://www.gibboncode.org/Installation/. 



