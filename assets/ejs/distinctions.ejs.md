<%
/* Distinctions (data/distinctions.yml) : une grande carte par prix, la plus récente en premier. */
const esc = (s) => String(s == null ? "" : s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
const escp = (s) => esc(String(s == null ? "" : s).replace(/'/g, "’"));
const MOIS = ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"];
const dstr = (d) => { const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(d || "")); return m ? (Number(m[3]) === 1 ? "1er" : Number(m[3])) + " " + MOIS[Number(m[2]) - 1] + " " + m[1] : ""; };
const list = items.slice().sort((a, b) => String(b.annee || "").localeCompare(String(a.annee || "")));
const ARROW = '<svg viewBox="0 0 16 16" aria-hidden="true"><path d="M6 3h7v7M13 3 6.5 9.5M11 9.5V13H3V5h3.5" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>';
const MEDAL = '<svg viewBox="0 0 48 48" aria-hidden="true"><path d="M16 4h16l-5 13h-6z" fill="currentColor" opacity=".35"/><circle cx="24" cy="29" r="13" fill="none" stroke="currentColor" stroke-width="2"/><circle cx="24" cy="29" r="8.5" fill="currentColor" opacity=".18"/><path d="m24 23.5 1.7 3.5 3.8.5-2.8 2.6.7 3.8-3.4-1.8-3.4 1.8.7-3.8-2.8-2.6 3.8-.5z" fill="currentColor"/></svg>';
%>

```{=html}
<div class="aw-list">
<% for (const it of list) { %>
  <article class="aw">
    <div class="aw-badge">
      <span class="aw-medal"><%= MEDAL %></span>
      <span class="aw-year"><%= esc(it.annee) %></span>
    </div>
    <div class="aw-body">
      <p class="aw-rank"><%= escp(it.rang) %></p>
      <h3 class="aw-title"><%= escp(it.title) %></h3>
      <p class="aw-org"><%= escp(it.org) %><% if (it.annonce) { %> · annoncé le <%= esc(dstr(it.annonce)) %><% } %></p>
      <% if (it.lieu) { %><p class="aw-place"><%= escp(it.lieu) %></p><% } %>
      <% if (it.description) { %><p class="aw-desc"><%= escp(it.description) %></p><% } %>
      <% if (it.citation) { %><blockquote class="aw-quote"><%= escp(it.citation) %></blockquote><% } %>
      <% if (it.liens && it.liens.length) { %>
      <ul class="aw-links">
        <% for (const l of it.liens) { %><li><a href="<%= esc(l.url) %>" target="_blank" rel="noopener"><span class="aw-l"><%= escp(l.label) %></span><%= ARROW %></a></li><% } %>
      </ul>
      <% } %>
    </div>
    <% if (it.image) { %><img class="aw-img" src="<%= esc(it.image) %>" alt="" loading="lazy"><% } %>
  </article>
<% } %>
</div>
```