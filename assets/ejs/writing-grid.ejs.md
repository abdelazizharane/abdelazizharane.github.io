<%
/* Liste du Blog : cartes uniformes + recherche + listes déroulantes (type, thème, année) + pagination.
   Tout le HTML utile est produit à la compilation : sans JavaScript la page reste lisible
   (tous les articles, dans l'ordre chronologique inverse). assets/js/writing.js ajoute ensuite
   filtres combinables, recherche plein texte et pagination.

   Le français est la langue source : les textes fixes sont écrits en français, avec leur version
   anglaise dans un <span class="bi"> (voir assets/css/writing.css). Les champs du front matter
   sont lus tels quels : type, lang, categories, featured, translations. Les traductions
   (<slug>/<en|fr|ar>/) ne sont jamais listées : la carte de l'original les signale.
   Un article `featured: true` garde sa place dans la liste (même carte que les autres),
   seule l'étiquette « À la une » le distingue. */
const esc = (s) => String(s == null ? "" : s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
const escp = (s) => esc(String(s == null ? "" : s).replace(/'/g, "\u2019")); // texte affiché : apostrophe typographique
const bi = (fr, en) => fr; // site écrit en français ; la traduction (EN, AR…) est faite automatiquement
const MOIS = ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"];
const stamp = (it) => { const ms = Number(it.sortableValues && it.sortableValues.date); return isNaN(ms) ? 0 : ms; };
const isoOf = (it) => { const t = stamp(it); return t ? new Date(t).toISOString().slice(0, 10) : ""; };
const nice = (iso) => { const m = /^(\d+)-(\d+)-(\d+)$/.exec(iso); return m ? (Number(m[3]) === 1 ? "1er" : Number(m[3])) + " " + MOIS[Number(m[2]) - 1] + " " + m[1] : iso; };
const slugOf = (it) => String(it.outputHref || "").replace(/(\/index)?\.html$/, "");
const cats = (it) => (Array.isArray(it.categories) ? it.categories.map(String) : []);
const trs = (it) => (Array.isArray(it.translations) ? it.translations.map(String) : []);
const dirOf = (l) => (l === "ar" ? "rtl" : "ltr");

const TYPES = [
  { id: "tutoriel", fr: "Tutoriels", en: "Tutorials", oneFr: "Tutoriel", oneEn: "Tutorial" },
  { id: "note", fr: "Notes de recherche", en: "Research notes", oneFr: "Note de recherche", oneEn: "Research note" },
  { id: "annonce", fr: "Annonces", en: "Announcements", oneFr: "Annonce", oneEn: "Announcement" },
];
const typeOne = (id) => { const t = TYPES.find((x) => x.id === id); return t ? bi(t.oneFr, t.oneEn) : bi("Article", "Article"); };

const all = items;
const countBy = (fn) => { const m = new Map(); all.forEach((i) => fn(i).forEach((k) => m.set(k, (m.get(k) || 0) + 1))); return m; };
const byType = countBy((i) => [i.type]);
const byCat = countBy(cats);
const byYear = countBy((i) => [isoOf(i).slice(0, 4)]);
const usedTypes = TYPES.filter((t) => byType.get(t.id) > 0); // pas de choix « (0) »
const catList = Array.from(byCat.keys()).sort((a, b) => a.localeCompare(b, "fr"));
const yearList = Array.from(byYear.keys()).sort().reverse();

const attrs = (i) => 'data-item data-type="' + esc(i.type) + '" data-cats="' + esc(cats(i).join("|")) + '" data-year="' + esc(isoOf(i).slice(0, 4)) + '" data-ts="' + stamp(i) + '" data-lang="' + esc(i.lang) + '" data-slug="' + esc(slugOf(i)) + '" data-tr="' + esc(trs(i).join(",")) + '"';

const opt = (value, fr, en, n) => '<option value="' + esc(value) + '" data-fr="' + esc(fr) + '" data-en="' + esc(en) + '" data-n="' + n + '">' + esc(fr) + " (" + n + ")</option>";
const select = (facet, labelKey, labelFr, allKey, allFr, options) =>
  '<label class="wfield wsel"><span class="wfield-l" data-t="' + labelKey + '">' + labelFr + "</span>" +
  '<span class="wsel-box"><select data-facet="' + facet + '"><option value="all" data-t="' + allKey + '">' + allFr + "</option>" + options + "</select></span></label>";
const SEARCH_ICO = '<svg class="wq-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>';
%>

```{=html}
<div class="wlist" data-wlist data-page-size="9">

<div class="wtools" role="search">
  <div class="wrow">
    <div class="wfield wsearch">
      <label class="wfield-l" for="wq" data-t="f_search">Rechercher</label>
      <span class="wq-box"><%= SEARCH_ICO %><input id="wq" type="search" class="wq" translate="no" data-t-ph="search_ph" placeholder="Titre, thème ou texte intégral…" autocomplete="off" enterkeyhint="search"></span>
    </div>
    <% if (usedTypes.length > 1) { %><%= select("type", "f_type", "Type", "all_types", "Tous", usedTypes.map((t) => opt(t.id, t.fr, t.en, byType.get(t.id))).join("")) %><% } %>
    <%= select("cat", "f_theme", "Thème", "all_themes", "Tous", catList.map((c) => opt(c, c, c, byCat.get(c))).join("")) %>
    <%= select("year", "f_year", "Année", "all_years", "Toutes", yearList.map((y) => opt(y, y, y, byYear.get(y))).join("")) %>
    <button type="button" class="wreset" data-reset hidden data-t="reset">Réinitialiser</button>
  </div>
  <p class="wstatus" role="status" aria-live="polite" data-status></p>
</div>

<div class="grid wgrid" data-items>
<% for (const it of all) { %>
<a class="gcard wcard" href="<%= it.path %>" <%= attrs(it) %><%= it.featured === true ? " data-featured" : "" %>>
  <div class="gcard-eyebrow-row">
    <span class="gcard-cat"><%= typeOne(it.type) %></span>
    <% if (it.featured === true) { %><span class="feat-pill"><%= bi("À la une", "Featured") %></span><% } %>
  </div>
  <h3 lang="<%= esc(it.lang) %>" dir="<%= esc(dirOf(it.lang)) %>" translate="no"><%= escp(it.title) %></h3>
  <p lang="<%= esc(it.lang) %>" dir="<%= esc(dirOf(it.lang)) %>" translate="no"><%= escp(it.description) %></p>
  <div class="wcard-meta"><time datetime="<%= esc(isoOf(it)) %>" data-date><%= esc(nice(isoOf(it))) %></time><% if (cats(it).length) { %><span class="wcard-cats"><% cats(it).forEach(function (c) { %><span class="wcard-cat" data-cat="<%= esc(c) %>"><%= esc(c) %></span><% }); %></span><% } %></div>
  <span class="wbadge" data-badge hidden></span>
  <span class="gcard-more"><%= bi("Lire l’article", "Read the article") %> <span class="arrow">&rarr;</span></span>
</a>
<% } %>
</div>

<div class="wempty" data-empty hidden>
  <p data-t="none">Aucun article ne correspond à ces filtres.</p>
  <button type="button" class="pbtn" data-reset data-t="reset">Réinitialiser</button>
</div>

<nav class="pagination" data-pager aria-label="Pagination"></nav>

</div>
```
