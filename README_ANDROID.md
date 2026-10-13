# Configuration Android

Le manifeste Android et le `minSdk` (23 au minimum) sont déjà configurés pour
Internet, l’appareil photo, les scanners et les liens externes.

Pour démarrer dans Android Studio, ouvrez le dossier `tpsupabase`, puis
choisissez **Run > Edit Configurations > Additional run args** et ajoutez :

```text
--dart-define=SUPABASE_URL=https://VOTRE-PROJET.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=VOTRE_CLE_PUBLIQUE
# ou pour un projet historique :
--dart-define=SUPABASE_URL=https://VOTRE-PROJET.supabase.co --dart-define=SUPABASE_ANON_KEY=VOTRE_CLE_ANON
```

Remplacez les valeurs par celles de votre projet Supabase. N’utilisez pas la
clé `service_role`. Pour créer les tables et les politiques de lecture, suivez
le fichier `README.md`.
