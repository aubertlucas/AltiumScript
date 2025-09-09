# Guide des Scripts Altium Designer

## Comprendre les Scripts Altium

### 1. Point d'entrée principal

Dans Altium Designer, les scripts Pascal utilisent des procédures comme points d'entrée. Le nom de la procédure principale est celui qui apparaîtra dans le menu des scripts.

```pascal
Procedure NomDuScript;  // Ceci apparaîtra dans le menu Altium
Begin
    // Code du script
End;
```

### 2. Structure de base d'un script

```pascal
{..............................................................................}
{ En-tête avec description                                                     }
{..............................................................................}

// Variables globales
Var
    MaVariable : Type;

// Procédures auxiliaires
Procedure MaProcedure;
Begin
    // Code
End;

// Point d'entrée principal
Procedure MonScriptPrincipal;
Begin
    // Code principal
End;
```

### 3. APIs principales pour les bibliothèques schématiques

#### Accès au serveur schématique
```pascal
SchServer : ISchServer  // Serveur principal des schématiques
```

#### Types principaux
- `ISch_Lib` : Bibliothèque schématique
- `ISch_Component` : Composant dans la bibliothèque
- `ISch_Parameter` : Paramètre d'un composant
- `ISch_Iterator` : Pour parcourir les objets

#### Processus de modification
```pascal
SchServer.ProcessControl.PreProcess(CurrentLib, '');
// Faire les modifications
SchServer.ProcessControl.PostProcess(CurrentLib, '');
CurrentLib.GraphicallyInvalidate;  // Rafraîchir l'affichage
```

## Problèmes identifiés dans votre script

### 1. Liaison des événements
Le problème principal était que les événements n'étaient pas correctement liés. Dans Altium, on ne peut pas utiliser de chaînes pour les événements :
```pascal
// Incorrect
ButtonSave.OnClick := 'ButtonSaveClick';

// Correct
ButtonSave.OnClick := @ButtonSaveClick;
```

### 2. Propriétés des contrôles
Certaines propriétés doivent être définies différemment :
```pascal
// Pour les styles de police
Font.Style := [fsBold];  // Utiliser un ensemble

// Pour fermer un formulaire modal
ButtonClose.ModalResult := mrCancel;
```

## Script amélioré : ComponentParameterEditor.pas

### Fonctionnalités ajoutées

1. **Détection automatique des variantes** : Le script détecte automatiquement les variantes communes des paramètres (ex: MPN, Manufacturer_Part_Number, etc.)

2. **Correction automatique** : Un bouton "Auto-Corriger" permet de renommer automatiquement les paramètres mal orthographiés

3. **Indicateurs visuels** : Les champs deviennent rouge clair quand un paramètre avec une variante est détecté

4. **Barre de statut** : Affiche des informations sur les actions en cours

5. **Rapport de paramètres** : Une fonction bonus `GenerateParameterReport` génère un rapport détaillé

### Utilisation

1. **Installation** :
   - Copier le fichier `ComponentParameterEditor.pas` dans votre dossier de scripts Altium
   - Dans Altium : DXP → Run Script → Sélectionner le script

2. **Points d'entrée disponibles** :
   - `LaunchParameterEditor` : Lance l'éditeur de paramètres
   - `EditComponentParameters` : Alias pour compatibilité
   - `GenerateParameterReport` : Génère un rapport des paramètres
   - `SimpleParameterCheck` : Test simple pour vérifier la connexion

3. **Utilisation de l'interface** :
   - Ouvrir une bibliothèque schématique (.SchLib)
   - Lancer le script
   - Naviguer entre les composants avec Précédent/Suivant
   - Éditer les valeurs Manufacturer et Manufacturer_PN
   - Cliquer "Auto-Corriger" pour corriger les noms
   - Cliquer "Sauvegarder" pour enregistrer les changements

### Variantes reconnues

**Pour Manufacturer** :
- MANUFACTURER
- MANUFACT
- MANUF
- MFG
- MFR
- VENDOR
- FABRICANT

**Pour Manufacturer_PN** :
- MANUFACTURER_PN
- MANUFACTURER_PART_NUMBER
- MANUFACTURER PART NUMBER
- MANUFACT_PN
- MANUF_PN
- MFG_PN
- MFG_PART_NUMBER
- MFR_PN
- MPN
- PART_NUMBER
- PARTNUMBER
- PN

## Conseils pour le développement de scripts Altium

1. **Toujours vérifier les objets nil** :
   ```pascal
   If SchServer = Nil Then Exit;
   If CurrentLib = Nil Then Exit;
   ```

2. **Utiliser Try/Finally pour les itérateurs** :
   ```pascal
   Try
       // Utiliser l'itérateur
   Finally
       CurrentLib.SchIterator_Destroy(Iterator);
   End;
   ```

3. **Encapsuler les modifications** :
   ```pascal
   SchServer.ProcessControl.PreProcess(CurrentLib, '');
   Try
       // Modifications
   Finally
       SchServer.ProcessControl.PostProcess(CurrentLib, '');
   End;
   ```

4. **Test progressif** : Commencer avec des scripts simples comme `SimpleParameterCheck.pas` pour vérifier que la connexion fonctionne

## Dépannage

Si le formulaire apparaît vide :
1. Vérifier que vous avez bien ouvert une bibliothèque schématique
2. Utiliser le script simple pour tester
3. Vérifier les messages d'erreur dans la console Altium

Si les modifications ne sont pas sauvegardées :
1. Vérifier les appels PreProcess/PostProcess
2. Appeler GraphicallyInvalidate après les modifications
3. Sauvegarder le document manuellement si nécessaire