## PyroXL_helpers

### Public Sub export_modules()

### Public Sub disable_test_calculation()

### Public Sub trim_output(input_row1, output_row1 As Range)

### Public Sub list_names()

### Public Function Power(coefficient, exponent) As Double

### Public Function cardinal_to_degrees(ByVal cardinal As String) As Single
     returns a compass direction in degrees
     args
       cardinal: a cardinal direction (N, NNE, NE, ENE, E, ESE, SE, SSE,
                                       S, SSW, SW, WSW, W, WNW, NW, NNW)

### Public Function backbearing(ByVal bearing As Variant) As Single

### Public Function breach_probability(ByVal intensity As Double, ByVal width As Single, Optional trees As Boolean = True) As Single
     returns the probability that a firebreak will be breached
     based on:
     Wilson, A. A. G. (2011). Width of firebreak that is necessary to stop grass fires: Some field experiments.
     Canadian Journal of Forest Research. https://doi.org/10.1139/x88-104
     using logistic function described in:
     Frost, S. M., Alexander, M. E., & Jenkins, M. J. (2022). The Application of Fire Behavior Modeling
     to Fuel Treatment Assessments at Army Garrison Camp Williams, Utah.
     args
       intensity: fireline intensity (kW/m)
       width: firebreak width (m)
       trees: presence or absence of trees
