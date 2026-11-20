<%
/* Galerie Photos (data/photos.yml)
   Comportement : initGallery() dans assets/html/foot.html. Styles : « Galerie Photos » dans writing.css.
   Formats : large | tall | wide | portrait | standard | half | full. */
const esc = (s) => String(s == null ? "" : s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
const escp = (s) => esc(String(s == null ? "" : s).replace(/'/g, "’"));
const MOIS = ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"];
const dstr = (d) => {
  const s = String(d == null ? "" : d), m = /^(\d{4})(?:-(\d{2}))?(?:-(\d{2}))?/.exec(s);
  if (!m) return "";
  if (m[3]) return Number(m[3]) + (Number(m[3]) === 1 ? "er" : "") + " " + MOIS[Number(m[2]) - 1] + " " + m[1];
  if (m[2]) return MOIS[Number(m[2]) - 1] + " " + m[1];
  return m[1];
};
const year = (d) => { const m = /^(\d{4})/.exec(String(d == null ? "" : d)); return m ? m[1] : ""; };
const list = items.filter((it) => it.src && it.title);
/* Composition par rangées complètes (12 colonnes) : grande + haute, trois moyennes,
   panoramique + portrait, puis les mêmes en miroir. S'il reste 1 ou 2 photos à la fin,
   elles prennent une rangée entière (pleine largeur, ou deux moitiés) : jamais de trou. */
const ROWS = [["large", "tall"], ["standard", "standard", "standard"], ["wide", "portrait"],
              ["tall", "large"], ["standard", "standard", "standard"], ["portrait", "wide"]];
const auto = [];
for (let r = 0; auto.length < list.length; r++) {
  const row = ROWS[r % ROWS.length], left = list.length - auto.length;
  if (left < row.length) { auto.push(...(left === 1 ? ["full"] : left === 2 ? ["half", "half"] : row.slice(0, left))); break; }
  auto.push(...row);
}
const fmtOf = (it, i) => it.format || auto[i];
const nEx = list.filter((it) => it.exemple === true).length;
%>

```{=html}
<div class="gal" data-gallery>
<% if (nEx) { %>

<% } %>
  <ol class="gal-grid">
<% list.forEach((it, i) => { const f = fmtOf(it, i), meta = [it.event, dstr(it.quand)].filter(Boolean).join(" · "), n = String(i + 1).padStart(2, "0"); %>
    <li class="gal-item is-<%= f %>">
      <button type="button" class="gal-btn" data-index="<%= i %>"
              data-src="<%= esc(it.large || it.src) %>" data-title="<%= escp(it.title) %>"
              data-meta="<%= escp(meta) %>" data-place="<%= escp(it.place || "") %>"
              data-desc="<%= escp(it.description || "") %>" data-alt="<%= escp(it.alt || it.title) %>"
              aria-label="<%= escp(it.title) %><%= meta ? " — " + escp(meta) : "" %> : agrandir la photo">
        <img src="<%= esc(it.src) %>" alt="<%= escp(it.alt || it.title) %>" loading="<%= i < 2 ? "eager" : "lazy" %>" decoding="async">
        <span class="gal-cap" aria-hidden="true">
          <span class="gal-meta"><span class="gal-n"><%= n %></span><% if (meta) { %><span><%= escp(meta) %></span><% } %></span>
          <span class="gal-title"><%= escp(it.title) %></span>
        </span>
<% if (it.exemple === true) { %>        <span class="gal-ex" aria-hidden="true">Exemple</span>
<% } %>      </button>
    </li>
<% }); %>
  </ol>
</div>

<dialog class="gal-lb" aria-label="Photo en grand format" data-lightbox>
  <div class="gal-lb-inner">
    <button type="button" class="gal-lb-close" data-lb="close" aria-label="Fermer"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg></button>
    <button type="button" class="gal-lb-nav gal-lb-prev" data-lb="prev" aria-label="Photo précédente"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M15 5l-7 7 7 7" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg></button>
    <figure class="gal-lb-fig">
      <div class="gal-lb-frame"><img class="gal-lb-img" alt=""></div>
      <figcaption class="gal-lb-cap">
        <span class="gal-lb-count" aria-live="polite"></span>
        <span class="gal-lb-meta"></span>
        <strong class="gal-lb-title"></strong>
        <span class="gal-lb-desc"></span>
      </figcaption>
    </figure>
    <button type="button" class="gal-lb-nav gal-lb-next" data-lb="next" aria-label="Photo suivante"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 5l7 7-7 7" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg></button>
  </div>
</dialog>
```