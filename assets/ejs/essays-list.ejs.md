<%
/* Liste des Essais.
   Chaque essai montre sa date de publication ET sa dernière mise à jour. */
const esc = (s) => String(s == null ? "" : s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
const escp = (s) => esc(String(s == null ? "" : s).replace(/'/g, "\u2019")); // texte affiché : apostrophe typographique
const bi = (fr, en) => fr; // site écrit en français ; la traduction (EN, AR…) est faite automatiquement
const MOIS = ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"];
const num = (v) => { const n = Number(v); return isNaN(n) ? 0 : n; };
const stamp = (it) => num(it.sortableValues && it.sortableValues.date);
const stampMod = (it) => num(it.sortableValues && it.sortableValues["date-modified"]);
const iso = (t) => (t ? new Date(t).toISOString().slice(0, 10) : "");
const nice = (s) => { const m = /^(\d+)-(\d+)-(\d+)$/.exec(s); return m ? (Number(m[3]) === 1 ? "1er" : Number(m[3])) + " " + MOIS[Number(m[2]) - 1] + " " + m[1] : s; };
const slugOf = (it) => String(it.outputHref || "").replace(/(\/index)?\.html$/, "");
const cats = (it) => (Array.isArray(it.categories) ? it.categories.map(String) : []);
const trs = (it) => (Array.isArray(it.translations) ? it.translations.map(String) : []);
const dirOf = (l) => (l === "ar" ? "rtl" : "ltr");

const all = items;
const countBy = (fn) => { const m = new Map(); all.forEach((i) => fn(i).forEach((k) => m.set(k, (m.get(k) || 0) + 1))); return m; };
const byCat = countBy(cats);
const byYear = countBy((i) => [iso(stamp(i)).slice(0, 4)]);
const catList = Array.from(byCat.keys()).sort((a, b) => a.localeCompare(b, "fr"));
const yearList = Array.from(byYear.keys()).sort().reverse();

const opt = (value, label, n) => '<option value="' + esc(value) + '" data-fr="' + esc(label) + '" data-en="' + esc(label) + '" data-n="' + n + '">' + esc(label) + " (" + n + ")</option>";
const select = (facet, labelKey, labelFr, allKey, allFr, options) =>
  '<label class="wfield wsel"><span class="wfield-l" data-t="' + labelKey + '">' + labelFr + "</span>" +
  '<span class="wsel-box"><select data-facet="' + facet + '"><option value="all" data-t="' + allKey + '">' + allFr + "</option>" + options + "</select></span></label>";
const SEARCH_ICO = '<svg class="wq-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>';
%>

```{=html}
<div class="wlist wlist-essays" data-wlist data-page-size="8">

<div class="wtools" role="search">
  <div class="wrow">
    <div class="wfield wsearch">
      <label class="wfield-l" for="wq" data-t="f_search">Rechercher</label>
      <span class="wq-box"><%= SEARCH_ICO %><input id="wq" type="search" class="wq" translate="no" data-t-ph="search_ph" placeholder="Titre, thème ou texte intégral…" autocomplete="off" enterkeyhint="search"></span>
    </div>
    <% if (catList.length > 1) { %><%= select("cat", "f_theme", "Thème", "all_themes", "Tous", catList.map((c) => opt(c, c, byCat.get(c))).join("")) %><% } %>
    <% if (yearList.length > 1) { %><%= select("year", "f_year", "Année", "all_years", "Toutes", yearList.map((y) => opt(y, y, byYear.get(y))).join("")) %><% } %>
    <button type="button" class="wreset" data-reset hidden data-t="reset">Réinitialiser</button>
  </div>
  <p class="wstatus" role="status" aria-live="polite" data-status></p>
</div>

<div class="essay-list" data-items>
<% for (const it of all) {
     const pub = iso(stamp(it));
     const mod = iso(stampMod(it));
%>
<article class="essay-item" data-item data-type="essai" data-cats="<%= esc(cats(it).join("|")) %>" data-year="<%= esc(pub.slice(0, 4)) %>" data-ts="<%= esc(stamp(it)) %>" data-lang="<%= esc(it.lang) %>" data-slug="<%= esc(slugOf(it)) %>" data-tr="<%= esc(trs(it).join(",")) %>">
  <p class="essay-meta">
    <span class="essay-date"><span data-t="published">Publié le</span> <time datetime="<%= esc(pub) %>" data-date><%= esc(nice(pub)) %></time></span>
    <% if (mod && mod !== pub) { %><span class="essay-date"><span data-t="updated">Mis à jour le</span> <time datetime="<%= esc(mod) %>" data-date><%= esc(nice(mod)) %></time></span><% } %>
    <% if (cats(it).length) { %><span class="essay-cats"><% cats(it).forEach(function (c, n) { %><%= n ? " · " : "" %><span class="essay-cat" data-cat="<%= esc(c) %>"><%= esc(c) %></span><% }); %></span><% } %>
    <% if (it.featured === true) { %><span class="feat-pill"><%= bi("À la une", "Featured") %></span><% } %>
  </p>
  <h2 class="essay-title" lang="<%= esc(it.lang) %>" dir="<%= esc(dirOf(it.lang)) %>" translate="no"><a href="<%= it.path %>"><%= escp(it.title) %></a></h2>
  <% if (it.subtitle) { %><p class="essay-sub" lang="<%= esc(it.lang) %>" dir="<%= esc(dirOf(it.lang)) %>" translate="no"><%= escp(it.subtitle) %></p><% } %>
  <% const dsc = String(it.description || "").replace(/[.\s]+$/, ""); const sub = String(it.subtitle || "").replace(/[.\s]+$/, ""); %>
  <% if (dsc && dsc !== sub) { %><p class="essay-desc" lang="<%= esc(it.lang) %>" dir="<%= esc(dirOf(it.lang)) %>" translate="no"><%= escp(it.description) %></p><% } %>
  <p class="essay-foot">
    <span class="wbadge" data-badge hidden></span>
    <a class="gcard-more" href="<%= it.path %>" data-readmore><%= bi("Lire l’essai", "Read the essay") %> <span class="arrow">&rarr;</span></a>
  </p>
</article>
<% } %>
</div>

<div class="wempty" data-empty hidden>
  <p data-t="none">Aucun article ne correspond à ces filtres.</p>
  <button type="button" class="pbtn" data-reset data-t="reset">Réinitialiser</button>
</div>

<nav class="pagination" data-pager aria-label="Pagination"></nav>

</div>
```
