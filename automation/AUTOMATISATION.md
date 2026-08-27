# Automatisation — comment ça marche, et ce qu'il reste à faire

## Ce qui a été construit

```
scripts/run_publication.sh   → point d'entrée (déclenché par launchd)
scripts/notify_author.sh     → envoi SMS/MMS via l'API Twilio (curl, sans dépendance)
automation/PIPELINE.md       → procédure suivie par Claude à chaque run automatique
automation/com.fabien.blogphoto.publication.plist → définition du job launchd
automation/state/last_run.txt → mémorise la dernière semaine déjà publiée (anti-doublon)
automation/logs/              → logs de chaque run + sorties JSON de Claude Code
.env.example                  → gabarit des identifiants Twilio (jamais commité)
```

`run_publication.sh` :
1. Vérifie si une publication est due (dimanche courant, ou dimanche manqué
   non traité — rattrapage automatique si le Mac était éteint/endormi).
2. Si `themes.md` est vide, notifie l'auteur et s'arrête.
3. Invoque `claude -p` en tâche de fond (authentification par abonnement,
   déjà testée en environnement minimal type launchd — voir plus bas),
   jusqu'à 3 tentatives en cas d'échec.
4. Une fois la preview prête, envoie un SMS via Twilio et marque la semaine
   comme traitée.
5. Ne publie jamais rien en ligne — le pipeline s'arrête à la preview,
   conformément au garde-fou de `CLAUDE.md`.

**Vérifications déjà faites dans cette session** (sur ce Mac mini) :
- `claude -p` fonctionne avec l'authentification par abonnement actuelle,
  y compris dans un environnement dépouillé (PATH minimal, pas de variables
  héritées d'un shell interactif) — proche de ce que verra launchd. Pas
  besoin de clé API séparée ni de compte payant additionnel.
- `--permission-mode acceptEdits` suffit pour que Claude édite des fichiers
  et exécute des commandes Bash (curl, git…) sans blocage sur une invite de
  confirmation — testé avec une écriture de fichier réelle et une commande
  Bash réelle.
- La logique de rattrapage/anti-doublon (`last_run.txt`) a été testée : le
  script détecte correctement qu'une semaine est déjà traitée et ne relance
  rien.

**Non testé** : un run complet de bout en bout déclenché par le script (par
souci de ne pas consommer un thème de `themes.md` pour un test), et le
déclenchement réel par launchd (nécessite de charger le job — voir ci-dessous).

## Ce qu'il reste à faire (ne peut pas être fait par l'agent)

1. **Créer un compte Twilio** (console.twilio.com), acheter un numéro
   d'envoi, récupérer `Account SID` et `Auth Token`. Coût marginal accepté
   par `CLAUDE.md` (quelques centimes/mois) malgré la contrainte de
   gratuité appliquée au reste de la stack — mais reste une démarche avec
   création de compte et moyen de paiement, donc à faire par toi.
2. Copier `.env.example` en `.env` à la racine du projet et renseigner les
   4 variables Twilio (`TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`,
   `TWILIO_FROM_NUMBER`, `TWILIO_TO_NUMBER`). Ce fichier est ignoré par git
   (`.gitignore`), il ne sera jamais commité ni vu par l'agent.
3. **Décider comment gérer la photo dans le SMS.** Twilio exige une URL
   publique pour joindre une image (MMS) — impossible de joindre un fichier
   local directement. Deux options, à trancher par toi :
   - **SMS texte seul** (par défaut si `PREVIEW_PUBLIC_BASE_URL` reste vide
     dans `.env`) : tu reçois juste le nom de la publication et son chemin,
     à consulter directement sur le Mac mini.
   - **SMS + image** : suppose d'exposer temporairement le dossier
     `publications/` sur une URL publique (par exemple via un tunnel type
     Cloudflare Tunnel/ngrok, ou un petit hébergement d'images dédié). Je
     n'ai rien mis en place ici — publier quoi que ce soit publiquement,
     même une simple image de preview, relève de la mise en ligne, donc
     de ta décision explicite (garde-fou CLAUDE.md), pas d'un choix que je
     peux prendre seul.
4. **Charger le job launchd** — je ne l'ai pas activé moi-même : installer
   une tâche qui s'exécute automatiquement chaque semaine est un changement
   permanent de configuration, à valider explicitement. Une fois prêt :
   ```bash
   cp "automation/com.fabien.blogphoto.publication.plist" ~/Library/LaunchAgents/
   launchctl load ~/Library/LaunchAgents/com.fabien.blogphoto.publication.plist
   ```
   Pour vérifier qu'il est bien enregistré : `launchctl list | grep blogphoto`.
   Pour le désactiver : `launchctl unload ~/Library/LaunchAgents/com.fabien.blogphoto.publication.plist`.
5. **Décider de la suite après la réponse SMS.** `CLAUDE.md` décrit la
   validation comme "réponse au SMS reçu", mais l'agent n'a explicitement
   pas accès aux identifiants de mise en ligne (garde-fou dédié) : recevoir
   la réponse (lire les messages entrants Twilio) et déclencher la
   publication ensuite n'est pas construit dans cette session — cela
   demande de choisir un mécanisme (interroger l'API Twilio, ou un webhook,
   ce qui suppose une URL publique) et surtout de décider si l'agent a le
   droit de déclencher la mise en ligne tout seul dès qu'il voit "oui", ou
   si tu préfères garder ce déclenchement toi-même. À trancher ensemble
   avant de construire cette dernière brique.

## Test manuel recommandé avant d'activer le job

Pour tester le pipeline complet sans attendre dimanche, une fois `.env`
rempli :
```bash
rm automation/state/last_run.txt   # force le script à considérer un run comme dû
bash scripts/run_publication.sh
```
⚠️ Cela consommera réellement le prochain thème de `themes.md` et générera
une vraie publication (photos comprises) — à faire en connaissance de
cause, pas comme un test anodin.
