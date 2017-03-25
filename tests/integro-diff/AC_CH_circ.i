#
# Tests the Rigid Body Motion of grains due to applied forces.
# Concenterated forces and torques have been applied and corresponding
# advection velocities are calculated.
# Grain motion kernels make the grains translate and rotate as a rigidbody,
# applicable to grain movement in porous media
#

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 80
  ny = 40
  nz = 0
  xmin = 0
  xmax = 40
  ymin = 0
  ymax = 20
  zmax = 0
  elem_type = QUAD4
[]

[Variables]
  [./c]
    order = FIRST
    family = LAGRANGE
  [../]
  [./w]
    order = FIRST
    family = LAGRANGE
  [../]
  [./eta]
    order = FIRST
    family = LAGRANGE
 [../]
[]

[AuxVariables]
  #[./eta]
  #[../]
  [./vadvx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vadvy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[BCs]
  [./flux]
    type = CahnHilliardFluxBC
    variable = w
    flux = '0 0 0'
    mob_name = M
    args = 'c eta'
    boundary = 'left right top bottom'
  [../]
[../]

[Kernels]
  [./c_res]
    type = SplitCHParsed
    variable = c
    f_name = F
    kappa_name = kappa_c
    w = w
    args = eta
  [../]
  [./w_res]
    type = SplitCHWRes
    variable = w
    mob_name = M
  [../]
  [./time]
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]
  [./motion]
    # advection kernel corrsponding to CH equation
    type = MultiGrainRigidBodyMotion
    variable = w
    c = c
    v = eta
    grain_tracker_object = grain_center
    grain_force = grain_force
    grain_volumes = grain_volumes
  [../]
  [./eta_dot]
    type = TimeDerivative
    variable = eta
  [../]
  #[./vadv_eta]
  #  # advection kernel corrsponding to AC equation
  #  type = SingleGrainRigidBodyMotion
  #  variable = eta
  #  c = c
  #  v = eta
  #  grain_tracker_object = grain_center
  #  grain_force = grain_force
  #  grain_volumes = grain_volumes
  #[../]
  [./acint_eta]
    type = ACInterface
    variable = eta
    mob_name = M
    args = c
    kappa_name = kappa_eta
  [../]
  [./acbulk_eta]
    type = AllenCahn
    variable = eta
    mob_name = M
    f_name = F
    args = c
  [../]
[]

[AuxKernels]
  [./vadv_x]
    type = GrainAdvectionAux
    component = x
    grain_tracker_object = grain_center
    grain_force = grain_force
    grain_volumes = grain_volumes
    variable = vadvx
  [../]
  [./vadv_y]
    type = GrainAdvectionAux
    component = y
    grain_tracker_object = grain_center
    grain_force = grain_force
    grain_volumes = grain_volumes
    variable = vadvy
  [../]
[]

[Functions]
  [./load_x]
    type = ConstantFunction
    value = 0.001
  [../]
  [./load_y]
    type = ConstantFunction
    value = 0.0005
  [../]
[]

[Materials]
  [./pfmobility]
    type = GenericConstantMaterial
    prop_names = 'M    kappa_c  kappa_eta'
    prop_values = '0.5 0.2      0.1'
  [../]
  [./free_energy]
    type = DerivativeParsedMaterial
    args = 'c eta'
    constant_names = 'barr_height  cv_eq'
    constant_expressions = '0.1          1.0e-2'
    function = 16*barr_height*(c-cv_eq)^2*(1-cv_eq-c)^2+(c-eta)^2
    derivative_order = 2
  [../]
  [./force_density]
    type = ExternalForceDensityMaterial
    c = c
    etas = 'eta'
    k = 0.3
    force_y = load_y
    force_x = load_x
  [../]
[]

[Postprocessors]
  [./elem_c]
    type = ElementIntegralVariablePostprocessor
    variable = c
  [../]
  [./elem_bnds]
    type = ElementIntegralVariablePostprocessor
    variable = eta
  [../]
  #[./total_energy]
  #  type = ElementIntegralVariablePostprocessor
  #  variable = total_en
  #[../]
  [./free_en]
    type = ElementIntegralMaterialProperty
    mat_prop = F
  [../]
  [./dofs]
    type = NumDOFs
    system = NL
  [../]
  [./tstep]
    type = TimestepSize
  [../]
  [./nonlinear_iterations]
    type = NumNonlinearIterations
  [../]
  [./linear_iterations]
    type = NumLinearIterations
  [../]
  [./elapsed_alive]
    type = PerformanceData
    event = 'ALIVE'
  [../]
  [./elapsed_active]
    type = PerformanceData
    event = 'ACTIVE'
  [../]
[]

[VectorPostprocessors]
  [./forces]
    # VectorPostprocessor for outputing grain forces and torques
    type = GrainForcesPostprocessor
    grain_force = grain_force
  [../]
  [./grain_volumes]
    type = FeatureVolumeVectorPostprocessor
    flood_counter = grain_center
    execute_on = 'initial timestep_begin'
  [../]
[]

[UserObjects]
  [./grain_center]
    type = GrainTracker
    variable = eta
    #outputs = none
    outputs = exodus
    compute_var_to_feature_map = true
    execute_on = 'initial timestep_begin'
  [../]
  [./grain_force]
    type = ComputeExternalGrainForceAndTorque
    c = c
    etas = 'eta'
    grain_data = grain_center
    force_density = force_density_ext
    #compute_jacobians = false
    execute_on = 'initial linear nonlinear'
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  nl_max_its = 20
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         31   preonly   lu      1'
  l_max_its = 20
  #l_tol = 1.0e-4
  nl_abs_tol = 1e-10
  nl_rel_tol = 1.0e-8
  #start_time = 0.0
  dt = 10
  end_time = 100.0
  #[./TimeStepper]
  #  type = IterationAdaptiveDT
  #  dt = 20.0
  #  growth_factor = 1.5
  #  cutback_factor = 0.8
  #[../]
[]

[Outputs]
  exodus = true
  print_perf_log = true
  csv = true
  #file_base = rect_2030
  #file_base = rect_local_1530
[]

[ICs]
  #[./rect_c]
  #  y2 = 10.0
  #  y1 = 5.0
  #  inside = 1.0
  #  x2 = 20.0
  #  variable = c
  #  x1 = 10.0
  #  type = BoundingBoxIC
  #[../]
  #[./rect_eta]
  #  y2 = 10.0
  #  y1 = 5.0
  #  inside = 1.0
  #  x2 = 20.0
  #  variable = eta
  #  x1 = 10.0
  #  type = BoundingBoxIC
  #[../]
  [./ic_c]
    int_width = 1.0
    x1 = 10.0
    y1 = 10.0
    radius = 5.0
    outvalue = 0.0
    variable = c
    invalue = 1.0
    type = SmoothCircleIC
  [../]
  [./ic_eta]
    int_width = 1.0
    x1 = 10.0
    y1 = 10.0
    radius = 5.0
    outvalue = 0.0
    variable = eta
    invalue = 1.0
    type = SmoothCircleIC
  [../]
[]