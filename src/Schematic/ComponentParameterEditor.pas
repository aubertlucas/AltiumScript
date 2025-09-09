{..............................................................................}
{ Summary: Component Parameter Editor for Altium Designer Schematic Libraries   }
{          Allows browsing components and editing Manufacturer parameters      }
{          with automatic detection and correction of misspelled parameters    }
{                                                                             }
{ Version: 2.0                                                                }
{ Date: 2024                                                                  }
{..............................................................................}

Var
    FormEditParams : TForm;
    LabelComponent, LabelProgress, LabelManuf, LabelManufPN, LabelOther : TLabel;
    EditManuf, EditManufPN : TEdit;
    MemoOtherParams : TMemo;
    ButtonPrevious, ButtonNext, ButtonSave, ButtonClose, ButtonAutoFix : TButton;
    CheckBoxOnlyMissing : TCheckBox;
    GroupBoxParams : TGroupBox;
    StatusBar : TStatusBar;

    CurrentLib     : ISch_Lib;
    ComponentList  : TList;
    CurrentIndex   : Integer;

{..............................................................................}
Function FindParameterVariant(LibComp: ISch_Component; BaseParamName: String; Var ExistingParam: ISch_Parameter): Boolean;
Var
    PIterator  : ISch_Iterator;
    Parameter  : ISch_Parameter;
    ParamName  : String;
    Variants   : TStringList;
    i          : Integer;
Begin
    Result := False;
    ExistingParam := Nil;
    Variants := TStringList.Create;
    
    // Add common variants for Manufacturer
    If UpperCase(BaseParamName) = 'MANUFACTURER' Then
    Begin
        Variants.Add('MANUFACTURER');
        Variants.Add('MANUFACT');
        Variants.Add('MANUF');
        Variants.Add('MFG');
        Variants.Add('MFR');
        Variants.Add('VENDOR');
        Variants.Add('FABRICANT');
    End
    // Add common variants for Manufacturer_PN
    Else If UpperCase(BaseParamName) = 'MANUFACTURER_PN' Then
    Begin
        Variants.Add('MANUFACTURER_PN');
        Variants.Add('MANUFACTURER_PART_NUMBER');
        Variants.Add('MANUFACTURER PART NUMBER');
        Variants.Add('MANUFACT_PN');
        Variants.Add('MANUF_PN');
        Variants.Add('MFG_PN');
        Variants.Add('MFG_PART_NUMBER');
        Variants.Add('MFR_PN');
        Variants.Add('MPN');
        Variants.Add('PART_NUMBER');
        Variants.Add('PARTNUMBER');
        Variants.Add('PN');
    End;
    
    Try
        PIterator := LibComp.SchIterator_Create;
        PIterator.AddFilter_ObjectSet(MkSet(eParameter));
        Try
            Parameter := PIterator.FirstSchObject;
            While Parameter <> Nil Do
            Begin
                ParamName := UpperCase(Parameter.Name);
                
                // Check all variants
                For i := 0 To Variants.Count - 1 Do
                Begin
                    If ParamName = UpperCase(Variants[i]) Then
                    Begin
                        ExistingParam := Parameter;
                        Result := True;
                        Exit;
                    End;
                End;
                
                Parameter := PIterator.NextSchObject;
            End;
        Finally
            LibComp.SchIterator_Destroy(PIterator);
        End;
    Finally
        Variants.Free;
    End;
End;

{..............................................................................}
Procedure CreateForm;
Begin
    FormEditParams := TForm.Create(Nil);
    With FormEditParams Do
    Begin
        Caption := 'Éditeur de Paramètres de Composants';
        Width := 650;
        Height := 550;
        Position := poScreenCenter;
        BorderStyle := bsDialog;
    End;

    // Label du composant actuel
    LabelComponent := TLabel.Create(FormEditParams);
    With LabelComponent Do
    Begin
        Parent := FormEditParams;
        Left := 16;
        Top := 16;
        Caption := 'Composant: ';
        Font.Style := [fsBold];
        Font.Size := 10;
    End;

    // Label de progression
    LabelProgress := TLabel.Create(FormEditParams);
    With LabelProgress Do
    Begin
        Parent := FormEditParams;
        Left := 16;
        Top := 40;
        Caption := '1 / 1';
    End;

    // Checkbox pour filtrer
    CheckBoxOnlyMissing := TCheckBox.Create(FormEditParams);
    With CheckBoxOnlyMissing Do
    Begin
        Parent := FormEditParams;
        Left := 440;
        Top := 16;
        Width := 180;
        Caption := 'Seulement incomplets';
        Checked := True;
    End;

    // GroupBox pour les paramètres
    GroupBoxParams := TGroupBox.Create(FormEditParams);
    With GroupBoxParams Do
    Begin
        Parent := FormEditParams;
        Left := 16;
        Top := 70;
        Width := 610;
        Height := 370;
        Caption := ' Paramètres du composant ';
    End;

    // Label et Edit pour Manufacturer
    LabelManuf := TLabel.Create(FormEditParams);
    With LabelManuf Do
    Begin
        Parent := GroupBoxParams;
        Left := 16;
        Top := 30;
        Caption := 'Manufacturer:';
    End;

    EditManuf := TEdit.Create(FormEditParams);
    With EditManuf Do
    Begin
        Parent := GroupBoxParams;
        Left := 130;
        Top := 27;
        Width := 460;
    End;

    // Label et Edit pour Manufacturer_PN
    LabelManufPN := TLabel.Create(FormEditParams);
    With LabelManufPN Do
    Begin
        Parent := GroupBoxParams;
        Left := 16;
        Top := 60;
        Caption := 'Manufacturer_PN:';
    End;

    EditManufPN := TEdit.Create(FormEditParams);
    With EditManufPN Do
    Begin
        Parent := GroupBoxParams;
        Left := 130;
        Top := 57;
        Width := 460;
    End;

    // Bouton Auto-Fix
    ButtonAutoFix := TButton.Create(FormEditParams);
    With ButtonAutoFix Do
    Begin
        Parent := GroupBoxParams;
        Left := 490;
        Top := 90;
        Width := 100;
        Caption := 'Auto-Corriger';
        Hint := 'Détecte et corrige automatiquement les paramètres mal orthographiés';
        ShowHint := True;
    End;

    // Label pour autres paramètres
    LabelOther := TLabel.Create(FormEditParams);
    With LabelOther Do
    Begin
        Parent := GroupBoxParams;
        Left := 16;
        Top := 120;
        Caption := 'Autres paramètres:';
    End;

    // Memo pour afficher les autres paramètres
    MemoOtherParams := TMemo.Create(FormEditParams);
    With MemoOtherParams Do
    Begin
        Parent := GroupBoxParams;
        Left := 16;
        Top := 140;
        Width := 574;
        Height := 210;
        ReadOnly := True;
        ScrollBars := ssBoth;
        Font.Name := 'Courier New';
        Font.Size := 9;
    End;

    // Boutons de navigation et actions
    ButtonPrevious := TButton.Create(FormEditParams);
    With ButtonPrevious Do
    Begin
        Parent := FormEditParams;
        Left := 16;
        Top := 450;
        Width := 100;
        Caption := '< Précédent';
    End;

    ButtonNext := TButton.Create(FormEditParams);
    With ButtonNext Do
    Begin
        Parent := FormEditParams;
        Left := 130;
        Top := 450;
        Width := 100;
        Caption := 'Suivant >';
    End;

    ButtonSave := TButton.Create(FormEditParams);
    With ButtonSave Do
    Begin
        Parent := FormEditParams;
        Left := 360;
        Top := 450;
        Width := 120;
        Caption := 'Sauvegarder';
        Font.Style := [fsBold];
    End;

    ButtonClose := TButton.Create(FormEditParams);
    With ButtonClose Do
    Begin
        Parent := FormEditParams;
        Left := 494;
        Top := 450;
        Width := 120;
        Caption := 'Fermer';
        ModalResult := mrCancel;
    End;

    // Status Bar
    StatusBar := TStatusBar.Create(FormEditParams);
    With StatusBar Do
    Begin
        Parent := FormEditParams;
        SimplePanel := True;
        SimpleText := 'Prêt';
    End;
End;

{..............................................................................}
Procedure LoadComponents;
Var
    LibraryIterator : ISch_Iterator;
    LibComp         : ISch_Component;
    ExistingParam   : ISch_Parameter;
    HasManuf        : Boolean;
    HasManufPN      : Boolean;
Begin
    ComponentList.Clear;

    LibraryIterator := CurrentLib.SchLibIterator_Create;
    LibraryIterator.AddFilter_ObjectSet(MkSet(eSchComponent));

    Try
        LibComp := LibraryIterator.FirstSchObject;
        While LibComp <> Nil Do
        Begin
            If CheckBoxOnlyMissing.Checked Then
            Begin
                // Use the new function to check for variants
                HasManuf := FindParameterVariant(LibComp, 'MANUFACTURER', ExistingParam);
                HasManufPN := FindParameterVariant(LibComp, 'MANUFACTURER_PN', ExistingParam);

                If Not (HasManuf And HasManufPN) Then
                    ComponentList.Add(LibComp);
            End
            Else
                ComponentList.Add(LibComp);

            LibComp := LibraryIterator.NextSchObject;
        End;
    Finally
        CurrentLib.SchIterator_Destroy(LibraryIterator);
    End;

    StatusBar.SimpleText := 'Chargé ' + IntToStr(ComponentList.Count) + ' composants';
End;

{..............................................................................}
Procedure DisplayComponent;
Var
    LibComp     : ISch_Component;
    PIterator   : ISch_Iterator;
    Parameter   : ISch_Parameter;
    ParamName   : String;
    OtherParams : String;
    ExistingParam : ISch_Parameter;
Begin
    If ComponentList.Count = 0 Then
    Begin
        LabelComponent.Caption := 'Aucun composant à afficher';
        EditManuf.Text := '';
        EditManufPN.Text := '';
        MemoOtherParams.Clear;
        ButtonPrevious.Enabled := False;
        ButtonNext.Enabled := False;
        ButtonSave.Enabled := False;
        ButtonAutoFix.Enabled := False;
        Exit;
    End;

    If (CurrentIndex < 0) Or (CurrentIndex >= ComponentList.Count) Then
        CurrentIndex := 0;

    LibComp := ComponentList.Items[CurrentIndex];

    LabelComponent.Caption := 'Composant: ' + LibComp.LibReference;
    LabelProgress.Caption := IntToStr(CurrentIndex + 1) + ' / ' + IntToStr(ComponentList.Count);

    EditManuf.Text := '';
    EditManufPN.Text := '';
    OtherParams := '';

    // Check for Manufacturer with variants
    If FindParameterVariant(LibComp, 'MANUFACTURER', ExistingParam) Then
    Begin
        EditManuf.Text := ExistingParam.Text;
        If UpperCase(ExistingParam.Name) <> 'MANUFACTURER' Then
            EditManuf.Color := $00E0E0FF  // Light red to indicate variant
        Else
            EditManuf.Color := clWindow;
    End
    Else
        EditManuf.Color := clWindow;

    // Check for Manufacturer_PN with variants
    If FindParameterVariant(LibComp, 'MANUFACTURER_PN', ExistingParam) Then
    Begin
        EditManufPN.Text := ExistingParam.Text;
        If UpperCase(ExistingParam.Name) <> 'MANUFACTURER_PN' Then
            EditManufPN.Color := $00E0E0FF  // Light red to indicate variant
        Else
            EditManufPN.Color := clWindow;
    End
    Else
        EditManufPN.Color := clWindow;

    // Get all other parameters
    PIterator := LibComp.SchIterator_Create;
    PIterator.AddFilter_ObjectSet(MkSet(eParameter));
    Try
        Parameter := PIterator.FirstSchObject;
        While Parameter <> Nil Do
        Begin
            ParamName := UpperCase(Parameter.Name);
            
            // Skip the standard parameters we're already showing
            If Not FindParameterVariant(LibComp, 'MANUFACTURER', ExistingParam) Or 
               (ExistingParam <> Parameter) Then
            Begin
                If Not FindParameterVariant(LibComp, 'MANUFACTURER_PN', ExistingParam) Or 
                   (ExistingParam <> Parameter) Then
                Begin
                    OtherParams := OtherParams + Parameter.Name + ' = ' + Parameter.Text + #13#10;
                End;
            End;

            Parameter := PIterator.NextSchObject;
        End;
    Finally
        LibComp.SchIterator_Destroy(PIterator);
    End;

    MemoOtherParams.Text := OtherParams;
    ButtonPrevious.Enabled := CurrentIndex > 0;
    ButtonNext.Enabled := CurrentIndex < ComponentList.Count - 1;
    ButtonSave.Enabled := True;
    ButtonAutoFix.Enabled := True;
End;

{..............................................................................}
Procedure ButtonAutoFixClick(Sender: TObject);
Var
    LibComp       : ISch_Component;
    ExistingParam : ISch_Parameter;
    NewParam      : ISch_Parameter;
    FixedCount    : Integer;
    OldName       : String;
Begin
    If ComponentList.Count = 0 Then Exit;

    LibComp := ComponentList.Items[CurrentIndex];
    FixedCount := 0;
    
    SchServer.ProcessControl.PreProcess(CurrentLib, '');
    Try
        // Fix Manufacturer parameter
        If FindParameterVariant(LibComp, 'MANUFACTURER', ExistingParam) Then
        Begin
            If UpperCase(ExistingParam.Name) <> 'MANUFACTURER' Then
            Begin
                OldName := ExistingParam.Name;
                ExistingParam.Name := 'Manufacturer';
                Inc(FixedCount);
                StatusBar.SimpleText := 'Corrigé: ' + OldName + ' -> Manufacturer';
            End;
        End;

        // Fix Manufacturer_PN parameter
        If FindParameterVariant(LibComp, 'MANUFACTURER_PN', ExistingParam) Then
        Begin
            If UpperCase(ExistingParam.Name) <> 'MANUFACTURER_PN' Then
            Begin
                OldName := ExistingParam.Name;
                ExistingParam.Name := 'Manufacturer_PN';
                Inc(FixedCount);
                StatusBar.SimpleText := StatusBar.SimpleText + ', ' + OldName + ' -> Manufacturer_PN';
            End;
        End;

        If FixedCount > 0 Then
        Begin
            SchServer.ProcessControl.PostProcess(CurrentLib, '');
            CurrentLib.GraphicallyInvalidate;
            ShowMessage(IntToStr(FixedCount) + ' paramètre(s) corrigé(s) pour ' + LibComp.LibReference);
            DisplayComponent; // Refresh display
        End
        Else
            ShowMessage('Aucune correction nécessaire pour ' + LibComp.LibReference);
    Except
        SchServer.ProcessControl.PostProcess(CurrentLib, '');
        ShowMessage('Erreur lors de la correction automatique');
    End;
End;

{..............................................................................}
Procedure ButtonSaveClick(Sender: TObject);
Var
    LibComp       : ISch_Component;
    ExistingParam : ISch_Parameter;
    NewParam      : ISch_Parameter;
    Changed       : Boolean;
Begin
    If ComponentList.Count = 0 Then Exit;

    LibComp := ComponentList.Items[CurrentIndex];
    Changed := False;
    
    SchServer.ProcessControl.PreProcess(CurrentLib, '');
    Try
        // Handle Manufacturer parameter
        If EditManuf.Text <> '' Then
        Begin
            If FindParameterVariant(LibComp, 'MANUFACTURER', ExistingParam) Then
            Begin
                // Update existing parameter (may have wrong name)
                ExistingParam.Name := 'Manufacturer';
                ExistingParam.Text := EditManuf.Text;
                Changed := True;
            End
            Else
            Begin
                // Create new parameter
                NewParam := SchServer.SchObjectFactory(eParameter, eCreate_Default);
                If NewParam <> Nil Then
                Begin
                    NewParam.Name := 'Manufacturer';
                    NewParam.Text := EditManuf.Text;
                    NewParam.IsHidden := False;
                    LibComp.AddSchObject(NewParam);
                    Changed := True;
                End;
            End;
        End;

        // Handle Manufacturer_PN parameter
        If EditManufPN.Text <> '' Then
        Begin
            If FindParameterVariant(LibComp, 'MANUFACTURER_PN', ExistingParam) Then
            Begin
                // Update existing parameter (may have wrong name)
                ExistingParam.Name := 'Manufacturer_PN';
                ExistingParam.Text := EditManufPN.Text;
                Changed := True;
            End
            Else
            Begin
                // Create new parameter
                NewParam := SchServer.SchObjectFactory(eParameter, eCreate_Default);
                If NewParam <> Nil Then
                Begin
                    NewParam.Name := 'Manufacturer_PN';
                    NewParam.Text := EditManufPN.Text;
                    NewParam.IsHidden := False;
                    LibComp.AddSchObject(NewParam);
                    Changed := True;
                End;
            End;
        End;

        If Changed Then
        Begin
            SchServer.ProcessControl.PostProcess(CurrentLib, '');
            CurrentLib.GraphicallyInvalidate;
            StatusBar.SimpleText := 'Paramètres sauvegardés pour ' + LibComp.LibReference;
            ShowMessage('Paramètres sauvegardés pour ' + LibComp.LibReference);
            
            // Refresh display
            DisplayComponent;
        End
        Else
            ShowMessage('Aucun changement à sauvegarder');
    Except
        SchServer.ProcessControl.PostProcess(CurrentLib, '');
        ShowMessage('Erreur lors de la sauvegarde');
    End;
End;

{..............................................................................}
Procedure ButtonPreviousClick(Sender: TObject);
Begin
    If CurrentIndex > 0 Then
    Begin
        Dec(CurrentIndex);
        DisplayComponent;
    End;
End;

{..............................................................................}
Procedure ButtonNextClick(Sender: TObject);
Begin
    If CurrentIndex < ComponentList.Count - 1 Then
    Begin
        Inc(CurrentIndex);
        DisplayComponent;
    End;
End;

{..............................................................................}
Procedure CheckBoxOnlyMissingClick(Sender: TObject);
Begin
    LoadComponents;
    CurrentIndex := 0;
    DisplayComponent;
End;

{..............................................................................}
Procedure ButtonCloseClick(Sender: TObject);
Begin
    FormEditParams.Close;
End;

{..............................................................................}
Procedure SetupEventHandlers;
Begin
    ButtonPrevious.OnClick := @ButtonPreviousClick;
    ButtonNext.OnClick := @ButtonNextClick;
    ButtonSave.OnClick := @ButtonSaveClick;
    ButtonClose.OnClick := @ButtonCloseClick;
    ButtonAutoFix.OnClick := @ButtonAutoFixClick;
    CheckBoxOnlyMissing.OnClick := @CheckBoxOnlyMissingClick;
End;

{..............................................................................}
// Point d'entrée principal - doit être appelé depuis Altium
Procedure LaunchParameterEditor;
Begin
    If SchServer = Nil Then Exit;
    
    CurrentLib := SchServer.GetCurrentSchDocument;
    If CurrentLib = Nil Then
    Begin
        ShowError('Aucun document ouvert.');
        Exit;
    End;

    If CurrentLib.ObjectID <> eSchLib Then
    Begin
        ShowError('Veuillez ouvrir une bibliothèque schématique.');
        Exit;
    End;

    ComponentList := TList.Create;
    Try
        CurrentIndex := 0;

        CreateForm;
        SetupEventHandlers;
        LoadComponents;
        DisplayComponent;

        FormEditParams.ShowModal;
    Finally
        ComponentList.Free;
        FormEditParams.Free;
    End;
End;

{..............................................................................}
// Point d'entrée alternatif pour compatibilité
Procedure EditComponentParameters;
Begin
    LaunchParameterEditor;
End;

{..............................................................................}
// Procédure pour générer un rapport des paramètres (utilitaire bonus)
Procedure GenerateParameterReport;
Var
    LibraryIterator : ISch_Iterator;
    LibComp         : ISch_Component;
    ExistingParam   : ISch_Parameter;
    ReportInfo      : TStringList;
    MissingCount    : Integer;
    VariantCount    : Integer;
    Document        : IServerDocument;
    ReportPath      : String;
Begin
    If SchServer = Nil Then Exit;
    
    CurrentLib := SchServer.GetCurrentSchDocument;
    If CurrentLib = Nil Then Exit;

    If CurrentLib.ObjectID <> eSchLib Then
    Begin
        ShowError('Veuillez ouvrir une bibliothèque schématique.');
        Exit;
    End;

    ReportInfo := TStringList.Create;
    MissingCount := 0;
    VariantCount := 0;

    Try
        ReportInfo.Add('Rapport des Paramètres de la Bibliothèque');
        ReportInfo.Add('==========================================');
        ReportInfo.Add('Bibliothèque: ' + CurrentLib.DocumentName);
        ReportInfo.Add('Date: ' + DateTimeToStr(Now));
        ReportInfo.Add('');
        
        LibraryIterator := CurrentLib.SchLibIterator_Create;
        LibraryIterator.AddFilter_ObjectSet(MkSet(eSchComponent));
        
        Try
            LibComp := LibraryIterator.FirstSchObject;
            While LibComp <> Nil Do
            Begin
                ReportInfo.Add('Composant: ' + LibComp.LibReference);
                
                // Check Manufacturer
                If FindParameterVariant(LibComp, 'MANUFACTURER', ExistingParam) Then
                Begin
                    If UpperCase(ExistingParam.Name) <> 'MANUFACTURER' Then
                    Begin
                        ReportInfo.Add('  ! Manufacturer trouvé comme: ' + ExistingParam.Name + ' = ' + ExistingParam.Text);
                        Inc(VariantCount);
                    End
                    Else
                        ReportInfo.Add('  ✓ Manufacturer = ' + ExistingParam.Text);
                End
                Else
                Begin
                    ReportInfo.Add('  ✗ Manufacturer MANQUANT');
                    Inc(MissingCount);
                End;
                
                // Check Manufacturer_PN
                If FindParameterVariant(LibComp, 'MANUFACTURER_PN', ExistingParam) Then
                Begin
                    If UpperCase(ExistingParam.Name) <> 'MANUFACTURER_PN' Then
                    Begin
                        ReportInfo.Add('  ! Manufacturer_PN trouvé comme: ' + ExistingParam.Name + ' = ' + ExistingParam.Text);
                        Inc(VariantCount);
                    End
                    Else
                        ReportInfo.Add('  ✓ Manufacturer_PN = ' + ExistingParam.Text);
                End
                Else
                Begin
                    ReportInfo.Add('  ✗ Manufacturer_PN MANQUANT');
                    Inc(MissingCount);
                End;
                
                ReportInfo.Add('');
                LibComp := LibraryIterator.NextSchObject;
            End;
        Finally
            CurrentLib.SchIterator_Destroy(LibraryIterator);
        End;
        
        ReportInfo.Add('==========================================');
        ReportInfo.Add('Résumé:');
        ReportInfo.Add('  Paramètres manquants: ' + IntToStr(MissingCount));
        ReportInfo.Add('  Paramètres mal orthographiés: ' + IntToStr(VariantCount));
        
        // Save report
        ReportPath := 'C:\Temp\ParameterReport_' + ChangeFileExt(ExtractFileName(CurrentLib.DocumentName), '') + '.txt';
        ReportInfo.SaveToFile(ReportPath);
        
        // Open report
        Document := Client.OpenDocument('Text', ReportPath);
        If Document <> Nil Then
            Client.ShowDocument(Document);
            
    Finally
        ReportInfo.Free;
    End;
End;

{..............................................................................}