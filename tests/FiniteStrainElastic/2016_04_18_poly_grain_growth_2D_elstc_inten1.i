[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 20
  ny = 20
  nz = 0
  xmax = 100
  ymax = 100
  zmax = 0
  #skip_partitioning = true
  elem_type = QUAD4
  uniform_refine = 2
[]

[GlobalParams]
  op_num = 10
  var_name_base = gr
  grain_num = 20
  use_displaced_mesh = true
[]

[Variables]
  [./PolycrystalVariables]
  [../]
  [./disp_x]
    order = FIRST
    family = LAGRANGE
  [../]
  [./disp_y]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[ICs]
  [./PolycrystalICs]
    [./PolycrystalVoronoiIC]
      rand_seed = 23654
    [../]
  [../]
[]

[AuxVariables]
  [./bnds]
    order = FIRST
    family = LAGRANGE
  [../]
  [./elastic_strain11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./elastic_strain22]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./elastic_strain12]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./unique_grains]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./var_indices]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vonmises_stress]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./C1111]
    order = CONSTANT
    family = MONOMIAL
  [../]
  #[./peeq]
  #  order = CONSTANT
  #  family = MONOMIAL
  #  block = 0
  #[../]
  #[./fp_yy]
  #  order = CONSTANT
  #  family = MONOMIAL
  #  block = 0
  #[../]
  [./stress_yy]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./euler_angle]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  [./PolycrystalKernel]
  [../]
  [./PolycrystalElasticDrivingForce]
  [../]
  [./TensorMechanics]
    displacements = 'disp_x disp_y'
  [../]
[]

[AuxKernels]
  [./BndsCalc]
    type = BndsCalcAux
    variable = bnds
    execute_on = timestep_end
  [../]
  [./elastic_strain11]
    type = RankTwoAux
    variable = elastic_strain11
    rank_two_tensor = elastic_strain
    index_i = 0
    index_j = 0
    execute_on = timestep_end
  [../]
  [./elastic_strain22]
    type = RankTwoAux
    variable = elastic_strain22
    rank_two_tensor = elastic_strain
    index_i = 1
    index_j = 1
    execute_on = timestep_end
  [../]
  [./elastic_strain12]
    type = RankTwoAux
    variable = elastic_strain12
    rank_two_tensor = elastic_strain
    index_i = 0
    index_j = 1
    execute_on = timestep_end
  [../]
  [./unique_grains]
    type = FeatureFloodCountAux
    variable = unique_grains
    execute_on = timestep_end
    bubble_object = grain_tracker
    field_display = UNIQUE_REGION
  [../]
  [./var_indices]
    type = FeatureFloodCountAux
    variable = var_indices
    execute_on = timestep_end
    bubble_object = grain_tracker
    field_display = VARIABLE_COLORING
  [../]
  [./C1111]
    type = RankFourAux
    variable = C1111
    rank_four_tensor = elasticity_tensor
    index_l = 0
    index_j = 0
    index_k = 0
    index_i = 0
    execute_on = timestep_end
  [../]
  [./vonmises_stress]
    type = RankTwoScalarAux
    variable = vonmises_stress
    rank_two_tensor = stress
    scalar_type = VonMisesStress
  [../]
  #[./peeq]
  #  type = MaterialRealAux
  #  variable = peeq
  #  property = ep_eqv
  #  execute_on = timestep_end
  #  block = 0
  #[../]
  #[./fp_yy]
  #  type = RankTwoAux
  #  variable = fp_yy
  #  rank_two_tensor = fp
  #  index_j = 1
  #  index_i = 1
  #  execute_on = timestep_end
  #  block = 0
  #[../]
  [./stress_yy]
    type = RankTwoAux
    variable = stress_yy
    rank_two_tensor = stress
    index_j = 1
    index_i = 1
    execute_on = timestep_end
    block = 0
  [../]
  [./euler_angle]
    type = OutputEulerAngles
    variable = euler_angle
    euler_angle_provider = euler_angle_file
    GrainTracker_object = grain_tracker
    output_euler_angle = 'phi1'
  [../]
[]

[BCs]
  [./Periodic]
    [./All]
      auto_direction = 'x'
      variable = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
    [../]
  [../]
  [./top_displacement]
    type = PresetBC
    variable = disp_y
    boundary = top
    value = -5.0
  [../]
  [./x_anchor]
    type = PresetBC
    variable = disp_x
    boundary = bottom
    value = 0.0
  [../]
  [./y_anchor]
    type = PresetBC
    variable = disp_y
    boundary = bottom
    value = 0.0
  [../]
[]

[UserObjects]
  #[./flowstress]
  #  type = HEVPLinearHardening
  #  yield_stress = 100
  #  slope = 10
  #  intvar_prop_name = ep_eqv
  #[../]
  #[./flowrate]
  #  type = HEVPFlowRatePowerLawJ2
  #  reference_flow_rate = 0.0001
  #  flow_rate_exponent = 50.0
  #  flow_rate_tol = 1
  #  strength_prop_name = flowstress
  #[../]
  #[./ep_eqv]
  #   type = HEVPEqvPlasticStrain
  #   intvar_rate_prop_name = ep_eqv_rate
  #[../]
  #[./ep_eqv_rate]
  #   type = HEVPEqvPlasticStrainRate
  #   flow_rate_prop_name = flowrate
  #[../]
  [./grain_tracker]
    type = GrainTracker
    threshold = 0.2
    convex_hull_buffer = 5.0
    use_single_map = false
    enable_var_coloring = true
    condense_map_info = true
    connecting_threshold = 0.05
    compute_op_maps = true
    execute_on = 'initial timestep_begin'
    flood_entity_type = elemental
  [../]
  [./euler_angle_file]
    type = EulerAngleFileReader
    file_name = grn_36_rand_2D.tex
  [../]
[]

[Materials]
  [./Copper]
    type = GBEvolution
    block = 0
    T = 500 # K
    wGB = 2 # nm
    GBmob0 = 2.5e-6 # m^4/(Js) from Schoenfelder 1997
    Q = 0.23 # Migration energy in eV
    GBenergy = 1.0 # GB energy in J/m^2
  [../]
  [./ElasticityTensor]
    type = ComputePolycrystalElasticityTensor
    block = 0
    fill_method = symmetric9
    #reading C_11  C_12  C_13  C_22  C_23  C_33  C_44  C_55  C_66
    #Elastic_constants = '2.8e5 1.2e5 1.2e5 2.8e5 1.2e5 2.8e5 0.8e5 0.8e5 0.8e5'
    Elastic_constants = '1.27e5 0.708e5 0.708e5 1.27e5 0.708e5 1.27e5 0.7355e5 0.7355e5 0.7355e5'
    GrainTracker_object = grain_tracker
    euler_angle_provider = euler_angle_file
  [../]
  #[./strain]
  #  type = ComputeFiniteStrain
  #  block = 0
  #  displacements = 'disp_x disp_y'
  #[../]
  #[./viscop]
  #  type = FiniteStrainHyperElasticViscoPlastic
  #  block = 0
  #  resid_abs_tol = 1e-18
  #  resid_rel_tol = 1e-8
  #  maxiters = 50
  #  max_substep_iteration = 5
  #  flow_rate_user_objects = 'flowrate'
  #  strength_user_objects = 'flowstress'
  #  internal_var_user_objects = 'ep_eqv'
  #  internal_var_rate_user_objects = 'ep_eqv_rate'
  #[../]
  [./strain]
    type = ComputeSmallStrain
    block = 0
    displacements = 'disp_x disp_y'
  [../]
  [./stress]
    type = ComputeLinearElasticStress
    block = 0
  [../]
  [./elastic_en]
    type = ElasticEnergyMaterial
    args = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9'
    outputs = exodus
    derivative_order = 2
    output_properties = 'F'
  [../]
[]

[Postprocessors]
  [./ngrains]
    type = FeatureFloodCount
    variable = bnds
    threshold = 0.7
  [../]
  [./dofs]
    type = NumDOFs
  [../]
  [./dt]
    type = TimestepSize
  [../]
  [./run_time]
    type = RunTime
    time_type = active
  [../]
  [./stress_yy]
    type = ElementAverageValue
    variable = stress_yy
    block = 0
  [../]
  [./fe_22]
    type = ElementAverageValue
    variable = elastic_strain22
    block = 0
  [../]
  [./fe_12]
    type = ElementAverageValue
    variable = elastic_strain12
    block = 0
  [../]
  [./fe_11]
    type = ElementAverageValue
    variable = elastic_strain11
    block = 0
  [../]
  [./von]
    type = ElementAverageValue
    variable = vonmises_stress
    block = 0
  [../]
  #[./peeq]
  #  type = ElementAverageValue
  #  variable = peeq
  #  block = 0
  #[../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    off_diag_row = 'disp_x disp_y'
    off_diag_column = 'disp_y disp_x'
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold'
  petsc_options_value = 'hypre boomeramg 31 0.7'
  l_tol = 1.0e-4
  l_max_its = 30
  nl_max_its = 25
  nl_rel_tol = 1.0e-7
  #start_time = 0.0
  #num_steps = 50
  end_time = 50.0
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1.5
    growth_factor = 1.2
    cutback_factor = 0.8
    optimal_iterations = 8
  [../]
  [./Adaptivity]
    initial_adaptivity = 2
    refine_fraction = 0.8
    coarsen_fraction = 0.05
    max_h_level = 3
  [../]
[]

[Outputs]
  #file_base = poly36_grtracker
  exodus = true
  csv = true
  gnuplot = true
[]