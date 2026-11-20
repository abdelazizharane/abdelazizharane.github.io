<%
/* Page Médias : une ligne par article / annonce (data/medias.yml), du plus récent au plus ancien.
   Filtres : année, type, origine (Tchad / International) + recherche, gérés par assets/js/writing.js
   (mêmes mécanismes que la liste du Blog : data-item, data-type, data-cats, data-year). */
const esc = (s) => String(s == null ? "" : s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
const escp = (s) => esc(String(s == null ? "" : s).replace(/'/g, "’"));
const MOIS = ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"];
const isoOf = (it) => { const m = /(\d{4})-(\d{2})-(\d{2})/.exec(String(it.date || "")); return m ? m[0] : ""; };
const nice = (it) => {
  const m = /^(\d+)-(\d+)-(\d+)$/.exec(isoOf(it));
  if (!m) return "";
  if (it.precision === "mois") return MOIS[Number(m[2]) - 1] + " " + m[1];
  return (Number(m[3]) === 1 ? "1er" : Number(m[3])) + " " + MOIS[Number(m[2]) - 1] + " " + m[1];
};
const host = (u) => { const m = /^https?:\/\/(?:www\.)?([^/]+)/.exec(String(u || "")); return m ? m[1] : ""; };
const all = items.slice().sort((a, b) => (isoOf(b) || "0").localeCompare(isoOf(a) || "0"));
const countBy = (fn) => { const m = new Map(); all.forEach((i) => { const k = fn(i); if (k) m.set(k, (m.get(k) || 0) + 1); }); return m; };
const byType = countBy((i) => i.type);
const byOrig = countBy((i) => i.origine);
const byYear = countBy((i) => isoOf(i).slice(0, 4));
const ORDER = ["Presse", "Vidéo", "Distinction", "Annonce", "Rapport", "Réseaux sociaux"];
const typeList = Array.from(byType.keys()).sort((a, b) => (ORDER.indexOf(a) + 99 * (ORDER.indexOf(a) < 0)) - (ORDER.indexOf(b) + 99 * (ORDER.indexOf(b) < 0)));
const origList = ["Tchad", "International"].filter((o) => byOrig.get(o)).concat(Array.from(byOrig.keys()).filter((o) => o !== "Tchad" && o !== "International"));
const yearList = Array.from(byYear.keys()).sort().reverse();
const opt = (v, n) => '<option value="' + esc(v) + '" data-fr="' + esc(v) + '" data-en="' + esc(v) + '" data-n="' + n + '">' + esc(v) + " (" + n + ")</option>";
const select = (facet, label, allFr, options) =>
  '<label class="wfield wsel"><span class="wfield-l">' + label + '</span><span class="wsel-box"><select data-facet="' + facet + '"><option value="all">' + allFr + "</option>" + options + "</select></span></label>";
const SEARCH_ICO = '<svg class="wq-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>';
const EXT = '<svg class="media-ext" viewBox="0 0 16 16" aria-hidden="true"><path d="M6 3h7v7M13 3 6.5 9.5M11 9.5V13H3V5h3.5" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>';
%>

```{=html}
<div class="wlist mlist" data-wlist data-page-size="12" data-unit="publication|publications">

<div class="wtools" role="search">
  <div class="wrow">
    <div class="wfield wsearch">
      <label class="wfield-l" for="wq">Rechercher</label>
      <span class="wq-box"><%= SEARCH_ICO %><input id="wq" type="search" class="wq" placeholder="Média, sujet, événement…" autocomplete="off" enterkeyhint="search"></span>
    </div>
    <%= select("year", "Année", "Toutes", yearList.map((y) => opt(y, byYear.get(y))).join("")) %>
    <% if (typeList.length > 1) { %><%= select("type", "Type", "Tous", typeList.map((t) => opt(t, byType.get(t))).join("")) %><% } %>
    <% if (origList.length > 1) { %><%= select("cat", "Origine", "Toutes", origList.map((o) => opt(o, byOrig.get(o))).join("")) %><% } %>
    <button type="button" class="wreset" data-reset hidden>Réinitialiser</button>
  </div>
  <p class="wstatus" role="status" aria-live="polite" data-status></p>
</div>

<ol class="media-list" data-items>
<% for (const it of all) { const y = isoOf(it).slice(0, 4); %>
<li class="media-item" data-item data-type="<%= esc(it.type) %>" data-cats="<%= esc(it.origine) %>" data-year="<%= esc(y) %>" data-lang="fr">
  <div class="media-side">
    <% if (isoOf(it)) { %><time datetime="<%= esc(isoOf(it)) %>"><%= esc(nice(it)) %></time><% } else { %><span class="media-nodate">Date à préciser</span><% } %>
    <span class="media-orig<%= it.origine === "Tchad" ? " is-td" : "" %>"><%= esc(it.origine) %></span>
  </div>
  <div class="media-main">
    <div class="media-eyebrow">
      <span class="media-source"><%= esc(it.source) %></span>
      <span class="media-type"><% if (it.type === "Vidéo") { %><svg class="media-play" viewBox="0 0 16 16" aria-hidden="true"><path d="M5 3.5v9l7.5-4.5z" fill="currentColor"/></svg><% } %><%= esc(it.type) %></span>
      <% if (it.featured === true) { %><span class="feat-pill">À la une</span><% } %>
    </div>
    <h3 class="media-title"><a href="<%= esc(it.path) %>" target="_blank" rel="noopener" lang="<%= esc(it.lang || "fr") %>"><%= escp(it.title) %></a></h3>
    <% if (it.description) { %><p class="media-desc"><%= escp(it.description) %></p><% } %>
    <a class="media-link" href="<%= esc(it.path) %>" target="_blank" rel="noopener"><%= it.type === "Vidéo" ? "Regarder sur" : "Lire sur" %> <%= esc(host(it.path)) %> <%= EXT %></a>
  </div>
</li>
<% } %>
</ol>

<div class="wempty" data-empty hidden>
  <p>Aucune entrée ne correspond à ces filtres.</p>
  <button type="button" class="pbtn" data-reset>Réinitialiser</button>
</div>

<nav class="pagination" data-pager aria-label="Pagination"></nav>

</div>
```
