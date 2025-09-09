{..............................................................................}
{ Simple Parameter Checker - Version simplifiée pour test                      }
{..............................................................................}

Procedure SimpleParameterCheck;
Var
    CurrentLib      : ISch_Lib;
    LibraryIterator : ISch_Iterator;
    LibComp         : ISch_Component;
    PIterator       : ISch_Iterator;
    Parameter       : ISch_Parameter;
    Count           : Integer;
    MissingCount    : Integer;
Begin
    If SchServer = Nil Then Exit;
    
    CurrentLib := SchServer.GetCurrentSchDocument;
    If CurrentLib = Nil Then
    Begin
        ShowMessage('Aucun document ouvert');
        Exit;
    End;

    If CurrentLib.ObjectID <> eSchLib Then
    Begin
        ShowMessage('Ce n''est pas une bibliothèque schématique');
        Exit;
    End;

    Count := 0;
    MissingCount := 0;

    LibraryIterator := CurrentLib.SchLibIterator_Create;
    LibraryIterator.AddFilter_ObjectSet(MkSet(eSchComponent));
    
    Try
        LibComp := LibraryIterator.FirstSchObject;
        While LibComp <> Nil Do
        Begin
            Inc(Count);
            
            // Vérifier si Manufacturer et Manufacturer_PN existent
            PIterator := LibComp.SchIterator_Create;
            PIterator.AddFilter_ObjectSet(MkSet(eParameter));
            Try
                Parameter := PIterator.FirstSchObject;
                While Parameter <> Nil Do
                Begin
                    ShowMessage('Composant: ' + LibComp.LibReference + #13#10 + 
                              'Paramètre: ' + Parameter.Name + ' = ' + Parameter.Text);
                    Parameter := PIterator.NextSchObject;
                End;
            Finally
                LibComp.SchIterator_Destroy(PIterator);
            End;
            
            LibComp := LibraryIterator.NextSchObject;
        End;
    Finally
        CurrentLib.SchIterator_Destroy(LibraryIterator);
    End;
    
    ShowMessage('Total: ' + IntToStr(Count) + ' composants analysés');
End;