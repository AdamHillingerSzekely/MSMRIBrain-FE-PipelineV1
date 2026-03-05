# MSMRIBrain-FE-PipelineV1
This a computational pipeline through which pointclouds extracted from patient-specific MRI of MS patients (using a 3D Slicer and Paraview) and their respective lesion segmentations can be converted in an FE-model so that mechanical tissue properties can be extracted and analysed. Three scripts are contained. The full PointcloudToModelFullPipeline requires the .ply files in the zipped folder in order to run: from pointcloud to mesh. The remaining two scripts contain a pre-meshed brain ready for finite element analysis (FEA). Details of analysis using and implementation of this pipeline can found in the cited publication [1].
## Requirements

MATLAB 2023b, FEBioStudio (studio version 2.4, solver version 4.4) and GIBBON are all required for simulations to run. Install instructions can be found at the following address: https://www.gibboncode.org/Installation/.  
<p align="Left">
  <img src="Images/MATLABlogo.png" width="300">
  <img src="Images/Febio.jpeg" width="450">
  <img src="Images/GIBBON.jpeg" width="150">
</p>
This pipeline requires manual thresholding of white matter MRI scans achieved by simple application of thresholding (Figure 1a), the same process is applied for grey matter (using the whole brain) and the lesions (using accompanying segmentation masks). These images are saved as NRRD files and passed into Paraview, a future aim is to automate these processes into the full automated pipeline (PointcloudToModelFullPipeline.m). 

<p align="center">
  <img src="Images/MRI-Thresholding.png" width="330">
  <img src="Images/NRRDpoint.png" width="450">
</p>
<p align="center">
  <em>Figure 1: a) LHS shows thresholding process using Slicer b) RHS depicts pointcloud result conversion result using Paraview ready for input into the pipeline (see plyFiles.zip for the pipeline).</em>
</p>

## The Pipeline
The pipeline (PointcloudToModelFullPipeline.m) takes three pointcloud inputs corresponding to grey matter, white matter and lesional tissues, converting each of them into surface mesh (and in the case of the lesions, meshes) (Figure 2). These can then be combined, exploiting positional consistency between the pointclouds. To access examples, please unzip plyFiles.zip and place them in the same directory as the PointcloudToModelFullPipeline.m script.
<p align="center">
  <img src="Images/21MeshesCombinedImage.jpg" width="1000">
</p>
<p align="center">
  <em>Figure 2: Combined brain surface meshes: grey matter is depicted in black, white matter in aqua and lesions in red. </em>
</p>
The "Tetgen" function, native to GIBBON, is then used to convert the surface mesh into a volumetric tetrahedral mesh using Delaunay tetrahedralisation, by taking the boundary geometry and filling the interior of each of the composite regions with tetrahedral elements. 
<p align="center">
  <img src="Images/22TetGenMeshCombinedImageblack.jpg" width="2000">
</p>
<p align="center">
  <em>Figure 3: The 3D mesh post-application of 'tetgen', using the same colour scheme as above. </em>
</p>

During the study we sped up our process by saving the 3D meshes as .mat files (see file tree). The meshDataQ0.mat, meshDataQ1.mat and meshDataQ2.mat are the same meshes of different 
Tissue properties, loading/pressure parameters can be then be applied. The Ogden hyperelastic model is u default tissue properties for each of thare based on those found in literature (see referenced study) [1]. 

## Citation

If you use this work, please cite:

[1] Szekely-Kohn AC, De Oliveira DC, Castellani M, Douglas M, Ahmed Z, Espino DM.  
*A semi-automated modelling pipeline to predict the mechanics of multiple sclerosis lesion afflicted brains from magnetic resonance images.*  
Computers in Biology and Medicine, 204:111519, 2026.

```bibtex
@article{szekely2026semi,
  title={A semi-automated modelling pipeline to predict the mechanics of multiple sclerosis lesion afflicted brains from magnetic resonance images},
  author={Szekely-Kohn, Adam C and De Oliveira, Diana Cruz and Castellani, Marco and Douglas, Michael and Ahmed, Zubair and Espino, Daniel M},
  journal={Computers in Biology and Medicine},
  volume={204},
  pages={111519},
  year={2026},
  publisher={Elsevier}
}

