Attribute VB_Name = "AFDRS_General"
Public Sub set_defaults()
    For Each class In Array("Forest", "Grass", "Woodland", "Heath", "Pine", "Mallee", "Spinifex", "Buttongrass")
        Range("Class" & class).Value = "default"
    Next class
    
    set_defaults_Other
    
End Sub

Public Sub set_defaults_Forest()

    Dim param_dict As Object
    Set param_dict = CreateObject("Scripting.Dictionary")
    param_dict.Add "fl_b_forest", "FL_b_forest"
    param_dict.Add "fl_e_forest", "FL_e_forest"
    param_dict.Add "fl_ns_forest", "FL_ns_forest"
    param_dict.Add "fl_o_forest", "FL_o_forest"
    param_dict.Add "fl_s_forest", "FL_s_forest"
    param_dict.Add "fhs_s", "FHS_s_forest"
    param_dict.Add "fhs_ns", "FHS_ns_forest"
    param_dict.Add "h_e_forest", "H_el_forest"
    param_dict.Add "h_ns_forest", "H_ns_forest"
    param_dict.Add "h_o_forest", "H_o_forest"
    param_dict.Add "waf_forest", "WRF_forest"
    param_dict.Add "submodel_forest", "submodel_forest"
    
    set_defaults_from_LUT param_dict

End Sub

Public Sub set_defaults_Grass()
    Dim param_dict As Object
    Set param_dict = CreateObject("Scripting.Dictionary")
    param_dict.Add "curing_grass", "curing"
    param_dict.Add "state_grass", "state"
    
    set_defaults_from_LUT param_dict

End Sub

Public Sub set_defaults_Woodland()
    Dim param_dict As Object
    Set param_dict = CreateObject("Scripting.Dictionary")
    param_dict.Add "state_woodland", "state"
    param_dict.Add "curing_woodland", "curing"
    param_dict.Add "waf_woodland", "WF_Sav"
    
    set_defaults_from_LUT param_dict
    
End Sub

Public Sub set_defaults_Buttongrass()
    Dim param_dict As Object
    Set param_dict = CreateObject("Scripting.Dictionary")
    param_dict.Add "productivity_buttongrass", "Prod_BG"
    
    set_defaults_from_LUT param_dict
    
End Sub

Public Sub set_defaults_Heath()
    Dim param_dict As Object
    Set param_dict = CreateObject("Scripting.Dictionary")
    param_dict.Add "waf_heath", "WF_Heath"
    param_dict.Add "h_el_heath", "H_el_heath"
    param_dict.Add "fl_heath", "FL_heath"
    
    set_defaults_from_LUT param_dict

End Sub

Public Sub set_defaults_Mallee()
    Dim param_dict As Object
    Set param_dict = CreateObject("Scripting.Dictionary")
    param_dict.Add "cov_o_mallee", "Cov_o_mallee"
    param_dict.Add "fl_o_mallee", "FL_o_mallee"
    param_dict.Add "fl_s_mallee", "FL_s_mallee"
    param_dict.Add "h_o_mallee", "H_o_mallee"
    
    set_defaults_from_LUT param_dict

End Sub

Public Sub set_defaults_Spinifex()
    Dim param_dict As Object
    Set param_dict = CreateObject("Scripting.Dictionary")
    param_dict.Add "subtype_spinifex", "submodel_spinifex"
    param_dict.Add "waf_spinifex", "WF_spinifex"
    
    set_defaults_from_LUT param_dict

End Sub

Public Sub set_defaults_Pine()

End Sub

Public Sub set_defaults_Other()
    Dim param_dict As Object
    Set param_dict = CreateObject("Scripting.Dictionary")
    param_dict.Add "AWAP_uf", "AWAP"
    param_dict.Add "temp_row1", "temp"
    param_dict.Add "rh_row1", "RH"
    param_dict.Add "wind_dir_row1", "wind_direction"
    param_dict.Add "wind_mag_row1", "U_10"
    param_dict.Add "kbdi", "KBDI"
    param_dict.Add "tsf", "tsf"
    param_dict.Add "df_row1", "DF"
    param_dict.Add "rain", "rain"
    param_dict.Add "tsr", "tsr"
    
    set_defaults_from_LUT param_dict

End Sub

Public Sub set_defaults_from_LUT(param_dict As Object)
    Dim param As Variant
    For Each param In param_dict.Keys
        Range(param).Value = LookupValueInTable(param_dict(param), "parameter", "value", "lookup_tables", "Default_Values")
    Next param
End Sub


Public Function FBI(ByVal intensity As Double, Optional fuel As String = "forest") As Single
    '''  returns FBI.
    '''
    ''' args
    '''   intensity: file line intensity (kW/m)
    '''   fuel: the fuel type

    
    Dim intensity_b() As Variant 'bounds for intensity classes
    Dim fbi_b() As Variant 'bounds for fba classes
    Dim intensity_ha As Double 'arbitrary high anchor for intensity
    Dim fbi_ha As Integer 'arbitrary high anchor for fbi
    Dim intensity_la, intensity_ua, fbi_la, fbi_ua As Integer 'upper and lower anchors for intensity and fbi
  
    'use same fbi bounds, fbi high anchor and intensity high anchor for all classes
    fbi_b = Array(0, 6, 12, 24, 50, 100)
    fbi_ha = 200
    intensity_ha = 90000
    
    'make case insensitive
    fuel = LCase(fuel)
  
    'set the intensity bounds according to fuel type
    Select Case fuel
        Case "forest"
            intensity_b = Array(0, 100, 750, 4000, 10000, 30000) 'intensity_b and fbi_b must have same dimensions
        Case "grass"
            intensity_b = Array(0, 100, 3000, 9000, 17500, 25000) 'intensity_b and fbi_b must have same dimensions
        Case "heath"
            'actually uses ROS (m/h) but uses the same process so for simplicity label it here as intensity
            intensity_b = Array(0, 1250, 2300, 3800, 7000, 14000)
        Case "savannah", "woodland"
            intensity_b = Array(0, 100, 3000, 9000, 17500, 25000) 'intensity_b and fbi_b must have same dimensions
        Case "pine"
            intensity_b = Array(0, 100, 750, 4000, 10000, 30000) 'intensity_b and fbi_b must have same dimensions
        Case "spinifex"
            'actually uses ROS (m/h) but uses the same process so for simplicity label it here as intensity
            intensity_b = Array(0, 0.1, 50, 1300, 7500, 10750)
            intensity_ha = 20000
        Case Else
            MsgBox "invalid fuel type"
            Exit Function
    End Select
    
    'determine FBI
    Select Case intensity
        Case Is < intensity_b(0)
            FBI = -9999
            Exit Function
        Case Is >= intensity_b(UBound(intensity_b))
            intensity_ua = intensity_ha
            fbi_ua = fbi_ha
            intensity_la = intensity_b(UBound(intensity_b))
            fbi_la = fbi_b(UBound(fbi_b))
        Case Else
            For i = 1 To UBound(intensity_b)
                If intensity < intensity_b(i) Then
                    fbi_la = fbi_b(i - 1)
                    fbi_ua = fbi_b(i)
                    intensity_la = intensity_b(i - 1)
                    intensity_ua = intensity_b(i)
                    Exit For
                End If
            Next i
    End Select
    
    FBI = fbi_la + (fbi_ua - fbi_la) * (intensity - intensity_la) / (intensity_ua - intensity_la)
    FBI = Int(FBI) 'FBI needs to be truncated for National consistency

End Function

Public Function intensity(ByVal ROS As Double, ByVal fuel_load As Single) As Double
    ''' returns the fireline intensity (kW/m) based on Byram 1959
    '''
    ''' args
    '''   ROS: forward rate of spread (km/h)
    '''   fuel_load: fine fuel load (t/ha)
    
    'convert units
    ROS = ROS / 3600 'm/s
    fuel_load = fuel_load / 10 'kg/m^2
    
    intensity = 18600 * ROS * fuel_load
End Function

Public Function fuel_amount(fuel_param_max, tsf, k) As Double
    ''' returns the adjusted fuel parameter based on time since fire and fuel accumulation curve parameter
    '''
    ''' args
    '''   fuel_param_max: the steady state value for the fuel parameter
    '''   tsf: time since fire (y)
    '''   k: fuel accumulation curve parameter
    
    fuel_amount = Round(fuel_param_max * (1 - exp(-1 * tsf * k)), 1)
End Function

Public Function fl_to_fhs(layer As String, fuel_load As Single)
    ''' converts a fuel load to a VESTA fuel hazard score
    '''
    ''' args
    '''   layer: fuel layer (surface, near surface, elevated, bark)
    '''   fuel_load: (t/ha)
    
    Dim fhs_dict 'fuel hazard score
    Set fhs_dict = CreateObject("Scripting.Dictionary")
    fhs_dict.Add "surface", Array(1, 2, 3, 3.5, 4)
    fhs_dict.Add "near surface", Array(1, 2, 3, 3.5, 4)
    fhs_dict.Add "elevated", Array(1, 2, 3, 3.5, 4)
    fhs_dict.Add "bark", Array(0, 1, 2, 3, 4)
    
    Dim fl_dict 'fuel load class boundaries t/ha
    Set fl_dict = CreateObject("Scripting.Dictionary")
    fl_dict.Add "surface", Array(4, 9, 13, 18)
    fl_dict.Add "near surface", Array(2, 3, 4, 6)
    fl_dict.Add "elevated", Array(1, 2, 3, 5)
    fl_dict.Add "bark", Array(0, 1, 2, 5)
    
    fl_to_fhs = fhs_dict(layer)(UBound(fhs_dict(layer)))
    
    For i = UBound(fl_dict(layer)) To 0 Step -1
        If fuel_load <= fl_dict(layer)(i) Then
            fl_to_fhs = fhs_dict(layer)(i)
        End If
    Next i
End Function

Public Function dewpoint(temp, rh) As Single
    ''' returns the dew point temperature based on the Magnus formula with the the Arden Buck modification
    '''
    ''' args
    '''   temp: air temperature (C)
    '''   rh: relative humidity (%)

    a = 6.1121 'hPa
    b = 18.678
    c = 257.14 '°C
    d = 234.5 '°C

    Gamma = Log((rh / 100) * exp((b - temp / d) * (temp / (c + temp))))
    dewpoint = c * Gamma / (b - Gamma)

End Function

Public Function vp_deficit(air_temperature, relative_humidity) As Single
    ''' returns the vapour pressure deficit in hPa, calculated using Tetens (1930)
    '''
    ''' args
    '''   temp: air temperature (C)
    '''   rh: relative humidity (%)
    
    Dim es, ea As Double
    es = 610.78 / 1000 * exp((17.269 * air_temperature) / (237.3 + air_temperature))
    ea = (relative_humidity * es / 100)
    
    vp_deficit = es - ea
End Function

Public Sub ListAFDRSClasses(lower As Single, upper As Single)
    ''' create list of AFDRS classes based on FTno range
    
    Dim ws_LUT As Worksheet 'AFDRS LUT worksheet
    Dim ws_List As Worksheet 'worksheet to contain lists
    Dim ws_spreadModels As Worksheet 'ROS and FB worksheet
    Dim lut As ListObject
    Dim rng As Range
    Dim cell As Range
    Dim fuelClass As Variant

    Dim fuelClassList As Collection
    Dim FTno_List As Collection
    ' Dim dropdownCell As Range
    Dim item As Variant
    Dim ctr As Long
    
    ' Set the worksheet and table
    Set ws_LUT = ThisWorkbook.Sheets("AFDRS Fuel LUT")
    Set ws_List = ThisWorkbook.Sheets("lookup_tables")
    Set ws_spreadModels = ThisWorkbook.Sheets("SpreadModels")
    Set lut = ws_LUT.ListObjects("AFDRS_LUT")
    
    ' Initialize the collection to store filtered items
    Set fuelClassList = New Collection
    Set FTno_List = New Collection
    
    
    ' dictionary to loop through fuel types and models
    Dim fuelClassDict As Object
    Set fuelClassDict = CreateObject("Scripting.Dictionary")
    
    ' Add items to the dictionary
    fuelClassDict.Add "Forest", Array("Forest", "Wet_forest")
    fuelClassDict.Add "Grass", Array("Chenopod_shrubland", "Crop", "Grass", "Low_wetland", "Pasture")
    fuelClassDict.Add "Woodland", Array("Acacia_woodland", "Gamba", "Rural", "Urban", "Woodland", "Woody_horticulture")
    fuelClassDict.Add "Buttongrass", Array("Buttongrass")
    fuelClassDict.Add "Heath", Array("Heath", "Wet_heath")
    fuelClassDict.Add "Mallee", Array("Mallee")
    fuelClassDict.Add "Pine", Array("Pine")
    fuelClassDict.Add "Spinifex", Array("Spinifex", "Spinifex_woodland")
    
    For Each fuelClass In fuelClassDict.Keys
        ' Empty the collections
        Do While fuelClassList.Count > 0
            fuelClassList.Remove 1
        Loop
        
        Do While FTno_List.Count > 0
            FTno_List.Remove 1
        Loop
        
        'add default values
        fuelClassList.Add "default"
        FTno_List.Add 9999
    
        ' Loop through the table and filter based on criteria
        For Each cell In lut.ListColumns("Fuel_Name").DataBodyRange
            ' If cell.Offset(0, 1).Value = fuelClassDict(fuelClass) And
            If Not IsError(Application.Match(cell.Offset(0, 2).Value, fuelClassDict(fuelClass), 0)) And _
               cell.Offset(0, 3).Value >= lower And _
               cell.Offset(0, 3).Value < upper Then
                On Error Resume Next
                fuelClassList.Add cell.Value
                FTno_List.Add cell.Offset(0, 3).Value
                On Error GoTo 0
            End If
        Next cell
        
        ' Debug: Check if fuelclassList is empty
        'If fuelClassList.Count = 0 Then
        '    MsgBox "No items found in the filtered list.", vbExclamation
        '    Exit Sub
        'End If
        
        ' Clear the entire column before setting the validation range
        Range("Classes_" & fuelClass).ClearContents
        Range("FTno_" & fuelClass).ClearContents
        
        ' Place the filtered list in a range
        ' On Error Resume Next
        ' Set validationRange = ws_List.Range("V2").Resize(fuelclassList.Count)
        Set validationRange = Range("Classes_" & fuelClass)
        Set FTno_Range = Range("FTno_" & fuelClass)
        
        'If Err.Number <> 0 Then
        '    MsgBox "Error setting validation range: " & Err.Description, vbCritical
        '    Exit Sub
        'End If
        'On Error GoTo 0
        
        ctr = 1
        For Each item In fuelClassList
            validationRange.Cells(ctr, 1).Value = item
            ctr = ctr + 1
        Next item
        
        ctr = 1
        For Each item In FTno_List
            FTno_Range.Cells(ctr, 1).Value = item
            ctr = ctr + 1
        Next item

        ' Add data validation
        Range("Class" & fuelClass).Value = validationRange.Cells(1, 1).Value
        With Range("Class" & fuelClass).Validation ' Replace with the cell or range where you want to apply validation
            .Delete
            .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Operator:= _
                xlBetween, Formula1:="='" & ws_List.Name & "'!" & validationRange.Address
            .IgnoreBlank = True
            .InCellDropdown = True
            .ShowInput = True
            .ShowError = True
        End With
        

    Next fuelClass

End Sub

Public Sub ListNSWClasses(Optional lower = 0, Optional upper = 76)
    ''' create list of AFDRS classes based on FTno range
    
    Dim ws_LUT As Worksheet 'AFDRS LUT worksheet
    Dim ws_List As Worksheet 'worksheet to contain lists
    Dim ws_spreadModels As Worksheet 'ROS and FB worksheet
    Dim lut As ListObject
    Dim rng As Range
    Dim cell As Range
    Dim fuelClass As Variant

    Dim fuelClassList As Collection
    Dim FTno_List As Collection
    ' Dim dropdownCell As Range
    Dim item As Variant
    Dim ctr As Long
    
    ' Set the worksheet and table
    Set ws_LUT = ThisWorkbook.Sheets("NSW_Fuel_v402_LUT")
    Set ws_List = ThisWorkbook.Sheets("lookup_tables")
    Set ws_spreadModels = ThisWorkbook.Sheets("SpreadModels")
    Set lut = ws_LUT.ListObjects("NSW_fuel_LUT")
    
    ' Initialize the collection to store filtered items
    Set fuelClassList = New Collection
    Set FTno_List = New Collection
    
    
    ' dictionary to loop through fuel types and models
    Dim fuelClassDict As Object
    Set fuelClassDict = CreateObject("Scripting.Dictionary")
    
    ' Add items to the dictionary
    fuelClassDict.Add "Forest", Array("Forest", "Wet_forest")
    fuelClassDict.Add "Grass", Array("Chenopod_shrubland", "Crop", "Grass", "Low_wetland", "Pasture")
    fuelClassDict.Add "Woodland", Array("Acacia_woodland", "Arid_woodland", "Rural", "Urban", "Woodland", "Woody_horticulture")
    fuelClassDict.Add "Buttongrass", Array("Buttongrass")
    fuelClassDict.Add "Heath", Array("Heath", "Wet_heath")
    fuelClassDict.Add "Mallee", Array("Mallee")
    fuelClassDict.Add "Pine", Array("Pine")
    fuelClassDict.Add "Spinifex", Array("Spinifex", "Spinifex woodland")
    
    For Each fuelClass In fuelClassDict.Keys
        ' Empty the collections
        Do While fuelClassList.Count > 0
            fuelClassList.Remove 1
        Loop
        
        Do While FTno_List.Count > 0
            FTno_List.Remove 1
        Loop
        
        'add default values
        fuelClassList.Add "default"
        FTno_List.Add 9999
    
        ' Loop through the table and filter based on criteria
        For Each cell In lut.ListColumns("Fuel name").DataBodyRange
            ' If cell.Offset(0, 1).Value = fuelClassDict(fuelClass) And
            If Not IsError(Application.Match(cell.Offset(0, 2).Value, fuelClassDict(fuelClass), 0)) And _
               cell.Offset(0, -2).Value >= lower And _
               cell.Offset(0, -2).Value <= upper Then
                On Error Resume Next
                fuelClassList.Add cell.Value
                FTno_List.Add cell.Offset(0, -2).Value
                On Error GoTo 0
            End If
        Next cell
        
        ' Debug: Check if fuelclassList is empty
        'If fuelClassList.Count = 0 Then
        '    MsgBox "No items found in the filtered list.", vbExclamation
        '    Exit Sub
        'End If
        
        ' Clear the entire column before setting the validation range
        Range("Classes_" & fuelClass).ClearContents
        Range("FTno_" & fuelClass).ClearContents
        
        ' Place the filtered list in a range
        ' On Error Resume Next
        ' Set validationRange = ws_List.Range("V2").Resize(fuelclassList.Count)
        Set validationRange = Range("Classes_" & fuelClass)
        Set FTno_Range = Range("FTno_" & fuelClass)
        
        'If Err.Number <> 0 Then
        '    MsgBox "Error setting validation range: " & Err.Description, vbCritical
        '    Exit Sub
        'End If
        'On Error GoTo 0
        
        ctr = 1
        For Each item In fuelClassList
            validationRange.Cells(ctr, 1).Value = item
            ctr = ctr + 1
        Next item
        
        ctr = 1
        For Each item In FTno_List
            FTno_Range.Cells(ctr, 1).Value = item
            ctr = ctr + 1
        Next item

        ' Add data validation
        Range("Class" & fuelClass).Value = validationRange.Cells(1, 1).Value
        With Range("Class" & fuelClass).Validation ' Replace with the cell or range where you want to apply validation
            .Delete
            .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Operator:= _
                xlBetween, Formula1:="='" & ws_List.Name & "'!" & validationRange.Address
            .IgnoreBlank = True
            .InCellDropdown = True
            .ShowInput = True
            .ShowError = True
        End With
        

    Next fuelClass

End Sub

Public Sub test()
    ListNSWClasses
End Sub

