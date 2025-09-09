'
' @file               ComponentParameterEditor.vbs
' @author             Script Central Integration
' @created            2024
' @last-modified      2024
' @brief              VBScript wrapper for ComponentParameterEditor.pas functionality
' @details
'                     Provides a bridge to call the Pascal script from VBScript interface

' Forces us to explicitly define all variables before using them
Option Explicit

Private ModuleName
ModuleName = "ComponentParameterEditor.vbs"

' @brief        Main entry point that calls the Pascal script
' @param        DummyVar        Dummy variable, not used
Sub ComponentParameterEditor(DummyVar)
    ' Call the Pascal script's main procedure
    ' The Pascal script should be compiled and available in Altium's script system
    ' Using the relative path from the project root
    RunScriptFile "src\Schematic\ComponentParameterEditor.pas", "LaunchParameterEditor"
End Sub

' Alternative entry point for direct access
Sub EditComponentParameters(DummyVar)
    ComponentParameterEditor(DummyVar)
End Sub