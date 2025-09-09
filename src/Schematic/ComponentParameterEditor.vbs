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
    ' Note: Dans Altium, il n'est pas possible d'appeler directement un script Pascal depuis VBScript
    ' Le script Pascal doit être enregistré dans le projet de scripts Altium
    ' Pour utiliser cette fonctionnalité, vous devez :
    ' 1. Ajouter ComponentParameterEditor.pas au projet de scripts Altium
    ' 2. Compiler le projet
    ' 3. Lancer directement "LaunchParameterEditor" depuis le menu Run Script d'Altium
    
    ShowMessage("Pour utiliser l'éditeur de paramètres de composants :" & vbCrLf & vbCrLf & _
                "1. Assurez-vous que ComponentParameterEditor.pas est ajouté au projet de scripts" & vbCrLf & _
                "2. Compilez le projet (clic droit > Compile)" & vbCrLf & _
                "3. Lancez 'LaunchParameterEditor' depuis DXP > Run Script" & vbCrLf & vbCrLf & _
                "Ou appelez directement la procédure depuis le script Pascal.")
End Sub

' Alternative entry point for direct access
Sub EditComponentParameters(DummyVar)
    ComponentParameterEditor(DummyVar)
End Sub