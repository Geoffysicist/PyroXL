Sub link_python_excel()
 
' link_python_excel Macro
' Declare all variables
Dim objShell As Object
Dim PythonExe, PythonScript As String
     
    'Create a new Shell Object
    Set objShell = VBA.CreateObject("Wscript.shell")
         
    'Provide the file path to the Python Exe
    PythonExe = """C:\Users\lbl59\AppData\Local\Programs\Python\Python39\python.exe"""
         
    'Provide the file path to the Python script
    PythonScript = "C:\Users\lbl59\Desktop\run_python_in_excel\process_iris_data.py"
         
    'Run the Python script
    objShell.Run PythonExe & PythonScript
    Application.Goto Reference:="link_python_excel"
     
End Sub