Attribute VB_Name = "Vesta2"

Public Function FMC_Vesta2(temp, rh As Single, date_ As Date, time As Date, Optional submodel = "dry") As Double
    ''' return the fine fuel moisture content (%)
    '''
    ''' args
    '''   temp: air temperature (C)
    '''   rh: relative humidity (%)
    '''   date_: (underscore due to VBA Date objects)
    '''   time:
    
    Dim start_peak_month, end_peak_month As Integer
    Dim start_afternoon, end_afternoon As Integer
    Dim sunrise, sunset As Integer
    
    start_peak_month = 10 'October
    end_peak_month = 3 'March
    start_afternoon = 12
    end_afternoon = 17
    sunrise = 6
    sunset = 19
    
    If (Month(date_) >= start_peak_month Or Month(date_) <= end_peak_month) And _
        (Hour(time) >= start_afternoon And Hour(time) <= end_afternoon And _
        submodel = "dry") Then
        FMC_Vesta2 = 2.76 + 0.124 * rh - 0.0187 * temp
    ElseIf Hour(time) <= sunrise Or Hour(time) >= sunset Then
        FMC_Vesta2 = 3.08 + 0.198 * rh - 0.0483 * temp
    Else
        FMC_Vesta2 = 3.6 + 0.169 * rh - 0.045 * temp
    End If
End Function

Public Function Mf_Vesta2(fmc As Single) As Single
    ''' returns the forest fuel moisture factor
    '''
    ''' args
    '''   fmc: fine fule moisture content (%)
    
    Select Case fmc
        Case Is <= 4.1
        Mf_Vesta2 = 1
        Case Is > 24
        Mf_Vesta2 = 0
        Case Else
        Mf_Vesta2 = 0.9082 + 0.1206 * fmc - 0.03106 * fmc ^ 2 + 0.001853 * fmc ^ 3 - 0.00003467 * fmc ^ 4
    End Select
End Function

Public Function fuel_availability_Vesta2(DF, Optional DI = 100, Optional waf = 3, Optional submodel = "dry") As Double
    ''' returns the fuel availability - proportion of fuel available to be burnt
    '''
    ''' TODO: implement slope/aspect effect
    '''
    ''' args
    '''   DF: Drought factor
    '''   DI: drought index - KBDI except SDI in Tas
    '''   WAF: wind adjustment factor between 3 and 5
    '''   submodel: dry or wet
    
    If submodel = "wet" Then
        C1 = (0.0046 * Power(waf, 2) - 0.0079 * waf - 0.0175) * DI + (-0.9167 * Power(waf, 2) + 1.5833 * waf + 13.5)
        C2 = 0 'TODO: implement slope/aspect effect
        DF = DF * WorksheetFunction.Max(C1 + C2, 0) / 10
        DF = WorksheetFunction.Min(DF, 10)
        DF = WorksheetFunction.Max(DF, 0)
    End If
    fuel_availability_Vesta2 = 1.008 / (1 + 104.9 * exp(-0.9306 * DF))
End Function

Public Function fme_Vesta2(mf, fa) As Single
    ''' returns the fuel moisture effect function
    ''' Cruz 2021 Eq 8
    '''
    ''' args
    '''   mf: fine dead fuel moicture content factor
    '''   fa: fuel availability
    
    fme_Vesta2 = mf * fa
End Function

Public Function prob_phase2(U_10, waf, fme, fls) As Single
    ''' returns the probability of transition to phase 2
    ''' Cruz 2021 Eqn 9 and 10
    '''
    ''' args
    '''   U_10: 10m wind speed (km/h)
    '''   waf: wind adjustment factor between 3 and 5
    '''   fme: fuel moisture effect function
    '''   fls: surface fuel load (t/ha)

    Select Case fls
        Case Is < 1
            prob_phase2 = 0
        Case Else
            g_x = -23.9315 + 1.7033 * U_10 / waf + 12.0822 * fme + 0.95236 * fls
            prob_phase2 = 1 / (1 + exp(-g_x))
    End Select
End Function

Public Function prob_phase3(U_10, ros2, fme) As Single
    ''' returns the probability of transition to phase 2
    ''' Cruz 2021 Eqn 9 and 10
    '''
    ''' args
    '''   U_10: 10m wind speed (km/h)
    '''   ros2: phase 2 rate of spread km/h
    '''   fme: fuel moisture effect function


    Select Case ros2
        Case Is < 0.3
            prob_phase3 = 0
        Case Else
            g_x = -32.3074 + 0.2951 * U_10 + 26.8734 * fme
            prob_phase3 = 1 / (1 + exp(-g_x))
    End Select
End Function

Public Function sf_Vesta2(slope) As Single
    ''' returns the slope function
    ''' based on on A.G. McArthur slope effect rule of thumb for upslope fires and the
    ''' Kataburn down slope effect refinement from Sullivan et al. (2014)
    ''' Cruz 2021 eqn 13
    
    Select Case slope
        Case Is > 0
            sf_Vesta2 = Power(2, slope / 10)
        Case Is < 0
            sf_Vesta2 = Power(2, -slope / 10) / (2 * Power(2, -slope / 10) - 1)
        Case Else
            sf_Vesta2 = 1
    End Select
End Function

Public Function ros1_Vesta2(U_10, waf, fls, fme, sf) As Single
    ''' returns the phase 1 forwards rate of spread (km/h)
    ''' Cruz 2021 eqn 14a and b
    '''
    ''' args
    '''   U_10: 10m wind speed (km/h)
    '''   waf: wind adjustment factor between 3 and 5
    '''   fls: surface fuel load (t/ha)
    '''   fuel moisture effect
    '''   slope factor    u = U_10 / waf
    
    If u > 2 Then
        ros1_Vesta2 = 0.03 + 0.05024 * Power(u - 1, 0.92628) * Power(fls / 10, 0.79928)
    Else
        ros1_Vesta2 = 0.03
    End If
    ros1_Vesta2 = ros1_Vesta2 * fme * sf
End Function

Public Function ros2_Vesta2(U_10, waf, fls, h_u, fme, sf) As Single
    ''' returns the phase 2 forwards rate of spread (km/h)
    ''' Cruz 2021 eqn 15
    '''
    ''' args
    '''   U_10: 10m wind speed (km/h)
    '''   waf: wind adjustment factor between 3 and 5
    '''   fls: surface fuel load (t/ha)
    '''   h_u: average understorey height (m)
    '''   fuel moisture effect
    '''   slope factor
    
    u = U_10 / waf
    ros2_Vesta2 = 0.19591 * Power(u, 0.8257) * Power(fls / 10, 0.4672) * Power(h_u, 0.495)
    ros2_Vesta2 = ros2_Vesta2 * fme * sf
End Function

Public Function ros3_Vesta2(U_10, waf, fls, h_u, fme, sf) As Single
    ''' returns the phase 2 forwards rate of spread (km/h)
    ''' Cruz 2021 eqn 16
    '''
    ''' args
    '''   U_10: 10m wind speed (km/h)
    '''   fuel moisture effect
    '''   slope factor
    
    ros3_Vesta2 = 0.05235 * Power(U_10, 1.19128)
    ros3_Vesta2 = ros3_Vesta2 * fme * sf
End Function

Public Function ros_Vesta2(ros1, ros2, ros3, p2, p3) As Single
    ''' returns the ovral forward rate of spread (km/h)
    ''' Cruz 2021 eqn 17
    '''
    ''' args
    '''   ros1: the phase 1 forward rate of spread (km/h)
    '''   ros2: the phase 2 forward rate of spread (km/h)
    '''   ros3: the phase 3 forward rate of spread (km/h)
    '''   p2: probability of transitioning to phase 2
    '''   p3: probability of transitioning to phase 3
    
    If p2 < 0.5 Then
        ros_Vesta2 = ros1 * (1 - p2) + ros2 * p2
    Else
        ros_Vesta2 = ros1 * (1 - p2) + ros2 * p2 * (1 - p3) + ros3 * p3
    End If
End Function
