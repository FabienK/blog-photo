# Journal des designs

Une ligne par publication : palette, typographie et style de mise en page utilisés.
Consulté et complété à l'étape 4 d'`automation/PIPELINE.md`, pour garantir qu'aucune
publication ne répète le design (couleurs + typographie) de la précédente — voir
`CLAUDE.md` > Garde-fous > Design.

| Date | Thème | Palette | Typographie | Mise en page | Inspiration |
|---|---|---|---|---|---|
| 2026-08-27 | Liberté | Palette globale par défaut (`global.css` : papier `#f6f3ee`, encre `#1a1714`, accent doré `#a8791f`) — jamais individualisée avant ce correctif | Fraunces (titres) + Work Sans (texte), globale par défaut | Titres droits, composition linéaire, sans grille | Aucune |
| 2026-08-30 | Élégance | Identique à Liberté (palette globale, non individualisée) | Identique à Liberté (globale) | Titres en italique centrés, composition plus aérée | Aucune |
| 2026-09-06 | Idée | Identique à Liberté/Élégance (palette globale, non individualisée) | Identique à Liberté/Élégance (globale) | Grille deux colonnes alternée, numérotation monospace | Aucune |
| 2026-09-13 | Espoir | Palette individualisée (override scopé) : fond quasi noir bleuté `#12151a`, texte crème `#f3ede4`, accent braise `#e8734a` / `#ff8c5a` | Bricolage Grotesque (titres, sans-serif géométrique) + Newsreader (texte, serif) — inversion du pairing par défaut (serif titres / sans texte) | Images pleine largeur (plein cadre) empilées, texte en colonne centrée étroite sous chaque image, indicateur de progression (3 segments, s'allument au fil des articles) | Aucune |
| 2026-09-20 | Destin | Fond clair parchemin `#ece1c8`, encre brun-noir `#261c14`, accent oxblood `#8a2e26` / `#6e2019` — retour à un fond clair après le sombre d'Espoir | Playfair Display (titres, serif classique à fort contraste, en italique) + Literata (texte, serif de lecture) + IBM Plex Mono (repères catalogue/légendes) — nouveau pairing, aucune police en commun avec Espoir ou le thème par défaut | « Planches » : chaque article encadré d'une double bordure façon page d'atlas ancien, image insérée avec légende italique (« Fig. N »), repère catalogue façon fiche scientifique (« D—01 ») — colonne unique centrée, ni plein cadre (Espoir) ni grille alternée (Idée) | Aucune |
| 2026-09-27 | Dieu | Fond pierre/charbon sombre et neutre `#171410`, texte crème `#efe7d8`, accent or mat façon lueur de cierge `#c9a24b` / `#e3bd6c` — sombre comme Espoir mais teinte neutre chaude, sans bleu ni orange ; net écart avec le parchemin clair de Destin | Space Grotesk (titres, sans-serif géométrique) + IBM Plex Sans (texte) — pairing entièrement sans-serif, aucune police en commun avec Destin (tout serif) ni Espoir (mix sans/serif) | « Cellules » : chaque article en pleine section verticale, repère en chiffre romain (I/II/III) discret, image en vignette centrée entourée d'un large espace négatif, texte en colonne étroite sous l'image — ni plein cadre empilé (Espoir), ni grille alternée (Idée), ni planches encadrées en colonne (Destin) | Aucune |

**Point de départ pour la prochaine publication** : "Dieu" est sombre (pierre/charbon
neutre) avec un accent or mat, une paire 100% sans-serif (Space Grotesk + IBM Plex
Sans), et une mise en page en "cellules" verticales à large espace négatif. La
prochaine publication doit s'écarter de cette base sur la palette **et** la
typographie — par exemple un fond clair ou plus saturé, une police serif ou un
pairing mixte, et une mise en page qui n'utilise pas la succession de cellules
verticales centrées utilisée ici.
