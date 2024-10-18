Attribute VB_Name = "Sandbox"
Public Function ROS_heath_raw(U_10, h_el, mc As Double, overstorey As Boolean) As Double
    ''' returns forward rate of spread (m/h) [range: 0-6000 m/h]
    ''' Anderson, W. R., et al. (2015). "A generic, empirical-based model for predicting rate of fire
    ''' spread in shrublands." International Journal of Wildland Fire 24(4): 443-460.
    '''
    ''' args
    '''   U_10: 10 m wind speed (km/h)
    '''   h_el: elevated fuel height (m)
    '''   mc: fuel moisture content (%)
    '''   overstorey: presence or absence of woodland overstorey (true/false)
    
    Dim mf As Double 'fuel moisture factor
    mf = Mf_heath(mc)
    
    'wrf depends on presence or absence of woodland overstorey
    Dim wrf As Double: wrf = 0.667
     
    If overstorey = True Then
        wrf = 0.35
    End If
    
    
    ROS_heath = 5.6715 * (wrf * U_10) ^ 0.912 * h_el ^ 0.227 * mf * 60
End Function



Sub test()
    Call update_from_LUT_Forest
End Sub
