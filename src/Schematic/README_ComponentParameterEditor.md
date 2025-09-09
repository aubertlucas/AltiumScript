# Éditeur de Paramètres de Composants

## Description
L'éditeur de paramètres de composants est un outil pour Altium Designer qui permet de parcourir et éditer facilement les paramètres Manufacturer et Manufacturer_PN dans une bibliothèque schématique.

## Fonctionnalités
- Navigation entre les composants d'une bibliothèque
- Édition des paramètres Manufacturer et Manufacturer_PN
- Détection automatique des variantes d'orthographe (MFG, MFR, MPN, etc.)
- Correction automatique des noms de paramètres mal orthographiés
- Filtrage pour afficher uniquement les composants incomplets
- Rapport des paramètres manquants ou mal orthographiés

## Installation et Configuration

### Méthode 1: Utilisation directe du script Pascal
1. Ouvrez votre projet de scripts Altium
2. Ajoutez le fichier `ComponentParameterEditor.pas` au projet
3. Compilez le projet (clic droit > Compile)
4. Ouvrez une bibliothèque schématique (.SchLib)
5. Allez dans DXP > Run Script
6. Sélectionnez `LaunchParameterEditor` et cliquez sur Run

### Méthode 2: Intégration dans Script Central
Le fichier `ComponentParameterEditor.vbs` affiche actuellement un message d'instruction car il n'est pas possible d'appeler directement un script Pascal depuis VBScript dans Altium.

## Utilisation
1. **Ouvrir une bibliothèque**: Assurez-vous d'avoir une bibliothèque schématique ouverte
2. **Lancer l'éditeur**: Exécutez `LaunchParameterEditor`
3. **Navigation**: Utilisez les boutons Précédent/Suivant pour parcourir les composants
4. **Édition**: Modifiez les valeurs dans les champs Manufacturer et Manufacturer_PN
5. **Sauvegarde**: Cliquez sur Sauvegarder pour enregistrer les modifications
6. **Auto-correction**: Utilisez le bouton Auto-Corriger pour standardiser les noms de paramètres

## Variantes reconnues
### Manufacturer
- MANUFACTURER
- MANUFACT
- MANUF
- MFG
- MFR
- VENDOR
- FABRICANT

### Manufacturer_PN
- MANUFACTURER_PN
- MANUFACTURER_PART_NUMBER
- MANUFACT_PN
- MANUF_PN
- MFG_PN
- MFR_PN
- MPN
- PART_NUMBER
- PN

## Notes importantes
- Le script détecte automatiquement les variantes et les affiche avec un fond rouge clair
- La fonction Auto-Corriger standardise les noms en "Manufacturer" et "Manufacturer_PN"
- Les modifications sont appliquées directement dans la bibliothèque