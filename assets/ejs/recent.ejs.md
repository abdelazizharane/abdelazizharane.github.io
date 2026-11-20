<%
/* « Écrits récents » de l'accueil : les derniers textes, tous types confondus.
   Même structure que les autres listes éditoriales du site (.eitem). */
const esc = (s) => String(s == null ? "" : s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
const MOIS = ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"];
const escp = (s) => esc(String(s == null ? "" : s).replace(/'/g, "\u2019")); // texte affiché : apostrophe typographique
const bi = (fr, en) => fr; // site écrit en français ; la traduction (EN, AR…) est faite automatiquement
const stamp = (it) => { const n = Number(it.sortableValues && it.sortableValues.date); return isNaN(n) ? 0 : n; };
const iso = (t) => (t ? new Date(t).toISOString().slice(0, 10) : "");
const nice = (s) => { const m = /^(\d+)-(\d+)-(\d+)$/.exec(s); return m ? (Number(m[3]) === 1 ? "1er" : Number(m[3])) + " " + MOIS[Number(m[2]) - 1] + " " + m[1] : s; };
const slugOf = (it) => String(it.outputHref || "").replace(/(\/index)?\.html$/, "");
const trs = (it) => (Array.isArray(it.translations) ? it.translations.map(String) : []);
const dirOf = (l) => (l === "ar" ? "rtl" : "ltr");
const KIND = { tutoriel: ["Tutoriel", "Tutorial"], note: ["Note de recherche", "Research note"], annonce: ["Annonce", "Announcement"], essai: ["Essai", "Essay"] };
const kind = (ty) => { const k = KIND[ty] || ["Article", "Article"]; return bi(k[0], k[1]); };
const shown = items.slice(0, 3);
%>

```{=html}
<div class="elist wrecent" data-wrecent>
<% for (const it of shown) { const d = iso(stamp(it)); %>
  <div class="eitem" data-item data-lang="<%= esc(it.lang) %>" data-slug="<%= esc(slugOf(it)) %>" data-tr="<%= esc(trs(it).join(",")) %>">
    <div class="eitem-head">
      <a class="eitem-title" href="<%= it.path %>" lang="<%= esc(it.lang) %>" dir="<%= esc(dirOf(it.lang)) %>"><%= escp(it.title) %></a>
      <span class="eitem-meta"><time datetime="<%= esc(d) %>" data-date><%= esc(nice(d)) %></time> · <span class="post-cat"><%= kind(it.type) %></span></span>
    </div>
    <p class="eitem-desc" lang="<%= esc(it.lang) %>" dir="<%= esc(dirOf(it.lang)) %>"><%= escp(it.description) %></p>
    <span class="wbadge" data-badge hidden></span>
  </div>
<% } %>
</div>
```
