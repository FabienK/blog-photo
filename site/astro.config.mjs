// @ts-check
import { defineConfig } from 'astro/config';

// Hébergement : GitHub Pages, page de projet (pas de domaine personnalisé —
// choix par défaut gratuit, cohérent avec la contrainte de gratuité de
// CLAUDE.md). URL finale : https://fabienk.github.io/blog-photo/
export default defineConfig({
	site: 'https://fabienk.github.io',
	base: '/blog-photo',
});
