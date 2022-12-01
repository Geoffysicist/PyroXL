## Sandbox

### Public Function ROS_heath_raw(U_10, h_el, mc As Double, overstorey As Boolean) As Double
     returns forward rate of spread (m/h) [range: 0-6000 m/h]
     Anderson, W. R., et al. (2015). "A generic, empirical-based model for predicting rate of fire
     spread in shrublands." International Journal of Wildland Fire 24(4): 443-460.
     args
       U_10: 10 m wind speed (km/h)
       h_el: elevated fuel height (m)
       mc: fuel moisture content (%)
       overstorey: presence or absence of woodland overstorey (true/false)
