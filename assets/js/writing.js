/* ================================================================
   comportements de la plateforme d'écriture
  sans JS nos listes montrent tous les
   articles, les articles restent lisibles, le sommaire et les liens
   fonctionnent. Ce fichier ajoute :

     1. lien d'évitement ;
     2. listes (Blog, Essais) : filtres combinables, recherche plein texte
        (index search.json de Quarto), pagination Précédent/Suivant ;
     3. langue : dates, textes d'interface, badges « Disponible en EN/FR »,
        remplacement par la traduction quand elle existe ;
     4. articles : copier le lien, sommaire actif, barre de progression,
        blocs de code focalisables.

   Langue d'interface = localStorage "sl" (fr | en | ar ; français par défaut),
   la même que le sélecteur FR/EN/AR de foot.html, qui nous prévient par
   l'événement "sitelang".
   ================================================================ */
(function () {
  "use strict";

  var doc = document;

  /* ----------------------------------------------------------------
     Textes d'interface propres à ce fichier (les libellés déjà gérés par
     le dictionnaire de foot.html — puces, cartes, boutons — n'y sont pas).
     L'arabe est à faire relire par un locuteur natif avant publication.
     ---------------------------------------------------------------- */
  var T = {
    en: {
      skip: "Skip to content",
      search_ph: "Title, theme or full text…",
      none: "No article matches these filters.",
      published: "Published",
      updated: "Updated",
      research_title: "Research",
      projects_title: "Projects",
      blog_title: "Blog",
      blog_lede:
        "Tutorials, research notes and announcements on NLP, speech, African languages and research infrastructure.",
      essays_title: "Essays",
      essays_sub: "Reflections",
      essays_lede:
        "Argued texts on the state of development in Chad. Every essay lists its sources and keeps a public record of its corrections.",
      prev: "Previous",
      next: "Next",
      page: "Page",
      pagination: "Pagination",
      one: "1 article",
      many: "{n} articles",
      of_total: "{n} of {t} articles",
      avail: "Available in",
      avail_note: "This article is written in {orig}. Available in: {langs}.",
      only_in: "This article is only available in {orig}.",
      read_in: "Read it in {lang}",
      copy: "Copy",
      copied: "Copied",
      copy_fail: "Copy failed",
      searching: "Searching…",
      f_search: "Search",
      f_type: "Type",
      f_theme: "Theme",
      f_year: "Year",
      all_types: "All",
      all_themes: "All",
      all_years: "All",
      reset: "Reset filters",
      articles_all: "{t} articles",
      articles_of: "{n} of {t} articles",
      article_one: "1 article",
    },
    fr: {
      skip: "Aller au contenu",
      search_ph: "Titre, thème ou texte intégral…",
      none: "Aucun article ne correspond à ces filtres.",
      published: "Publié le",
      updated: "Mis à jour le",
      research_title: "Recherche",
      projects_title: "Projets",
      blog_title: "Blog",
      blog_lede:
        "Tutoriels, notes de recherche et annonces sur le traitement des langues, la parole, les langues africaines et l’infrastructure de recherche.",
      essays_title: "Essais",
      essays_sub: "Réflexions",
      essays_lede:
        "Des textes argumentés sur l’état du développement au Tchad. Chaque essai cite ses sources et garde une trace publique de ses corrections.",
      prev: "Précédent",
      next: "Suivant",
      page: "Page",
      pagination: "Pagination",
      one: "1 article",
      many: "{n} articles",
      of_total: "{n} articles sur {t}",
      avail: "Disponible en",
      avail_note: "Cet article est rédigé en {orig}. Disponible en : {langs}.",
      only_in: "Cet article n’est disponible qu’en {orig}.",
      read_in: "Lire en {lang}",
      copy: "Copier",
      copied: "Copié",
      copy_fail: "Échec de la copie",
      searching: "Recherche…",
      f_search: "Rechercher",
      f_type: "Type",
      f_theme: "Thème",
      f_year: "Année",
      all_types: "Tous",
      all_themes: "Tous",
      all_years: "Toutes",
      reset: "Réinitialiser",
      articles_all: "{t} articles",
      articles_of: "{n} sur {t} articles",
      article_one: "1 article",
    },
    ar: {
      skip: "انتقل إلى المحتوى",
      search_ph: "العنوان أو الموضوع أو النص الكامل…",
      none: "لا يوجد مقال يطابق هذه التصفية.",
      published: "نُشر في",
      updated: "حُدِّث في",
      research_title: "البحوث",
      projects_title: "المشاريع",
      blog_title: "المدونة",
      blog_lede:
        "دروس تطبيقية ومذكرات بحثية وإعلانات حول معالجة اللغات والكلام واللغات الإفريقية والبنية التحتية للبحث.",
      essays_title: "مقالات",
      essays_sub: "تأملات",
      essays_lede:
        "نصوص حجاجية حول حالة التنمية في تشاد. يذكر كل مقال مصادره ويحتفظ بسجل علني لتصحيحاته.",
      prev: "السابق",
      next: "التالي",
      page: "صفحة",
      pagination: "ترقيم الصفحات",
      one: "مقال واحد",
      many: "{n} مقالات",
      of_total: "{n} من {t} مقالات",
      avail: "متوفر باللغة",
      avail_note: "كُتب هذا المقال باللغة {orig}. متوفر باللغات: {langs}.",
      only_in: "هذا المقال متوفر باللغة {orig} فقط.",
      read_in: "القراءة باللغة {lang}",
      copy: "نسخ",
      copied: "تم النسخ",
      copy_fail: "تعذّر النسخ",
      searching: "جارٍ البحث…",
      f_search: "بحث",
      f_type: "النوع",
      f_theme: "الموضوع",
      f_year: "السنة",
      all_types: "الكل",
      all_themes: "الكل",
      all_years: "الكل",
      reset: "إعادة التعيين",
      articles_all: "{t} مقالات",
      articles_of: "{n} من {t} مقالات",
      article_one: "مقال واحد",
    },
  };
  var LANGNAME = {
    en: { en: "English", fr: "French", ar: "Arabic" },
    fr: { en: "anglais", fr: "français", ar: "arabe" },
    ar: { en: "الإنجليزية", fr: "الفرنسية", ar: "العربية" },
  };
  var ENDONYM = { en: "English", fr: "français", ar: "العربية" };
  var LOCALE = { en: "en-US", fr: "fr-FR", ar: "ar-u-nu-latn" };

  function tr(key, lang, vars) {
    var d = T[lang] || T.en;
    var s = d[key] != null ? d[key] : T.en[key];
    if (s == null) return key;
    if (vars) for (var k in vars) s = s.replace("{" + k + "}", vars[k]);
    return s;
  }

  /* Le site est écrit en français, interface comprise. Les autres langues (EN, AR…) sont
     produites par la traduction automatique (assets/html/foot.html) : les libellés restent
     donc toujours en français ici, et c'est le traducteur qui les rend dans la langue choisie. */
  function uiLang() {
    return "fr";
  }
  var lang = uiLang();

  function $(sel, root) {
    return (root || doc).querySelector(sel);
  }
  function $$(sel, root) {
    return Array.prototype.slice.call((root || doc).querySelectorAll(sel));
  }
  function norm(s) {
    return String(s || "")
      .normalize("NFD")
      .replace(/[̀-ͯ]/g, "")
      .toLowerCase();
  }
  function offset() {
    var m = $('meta[name="quarto:offset"]');
    return m ? m.getAttribute("content") || "./" : "./";
  }

  var isArticle = !!$(".article-body");

  /* ----------------------------------------------------------------
     1. Lien d'évitement
     ---------------------------------------------------------------- */
  function initSkip() {
    var main = $("main#quarto-document-content") || $("main");
    if (!main || $(".skip-link")) return;
    if (!main.id) main.id = "quarto-document-content";
    main.setAttribute("tabindex", "-1");
    var a = doc.createElement("a");
    a.className = "skip-link notranslate";
    a.setAttribute("translate", "no");
    a.href = "#" + main.id;
    a.setAttribute("data-t", "skip");
    a.textContent = tr("skip", lang);
    doc.body.insertBefore(a, doc.body.firstChild);
    a.addEventListener("click", function () {
      setTimeout(function () {
        main.focus({ preventScroll: false });
      }, 0);
    });
  }

  /* ----------------------------------------------------------------
     2. Textes d'interface (data-t, data-t-ph) et dates
     ---------------------------------------------------------------- */
  function labelOptions() {
    /* Listes déroulantes : « libellé (n) ». <option> ne peut pas contenir de balises, donc le texte est posé ici. */
    $$("select[data-facet] option").forEach(function (o) {
      var base;
      if (o.hasAttribute("data-t")) base = tr(o.getAttribute("data-t"), lang);
      else if (o.getAttribute("data-fr") != null) {
        var raw =
          lang === "en" ? o.getAttribute("data-en") : o.getAttribute("data-fr");
        base =
          o.closest("select").getAttribute("data-facet") === "cat"
            ? catLabel(o.getAttribute("data-fr"), lang === "en" ? "en" : "fr")
            : raw;
      } else return;
      o.textContent = o.hasAttribute("data-n")
        ? base + " (" + o.getAttribute("data-n") + ")"
        : base;
    });
    $$("[data-cat]").forEach(function (el) {
      el.textContent = catLabel(
        el.getAttribute("data-cat"),
        lang === "en" ? "en" : "fr",
      );
    });
  }

  function applyT() {
    $$("[data-t]").forEach(function (el) {
      if (el.tagName !== "OPTION")
        el.textContent = tr(el.getAttribute("data-t"), lang);
    });
    labelOptions();
    $$("[data-t-ph]").forEach(function (el) {
      el.setAttribute("placeholder", tr(el.getAttribute("data-t-ph"), lang));
    });
    $$("[data-pager]").forEach(function (p) {
      p.setAttribute("aria-label", tr("pagination", lang));
    });
  }

  function fmtDate(iso, L) {
    var m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(iso || "");
    if (!m) return null;
    var d = new Date(Date.UTC(+m[1], +m[2] - 1, +m[3]));
    var opt = {
      timeZone: "UTC",
      day: "numeric",
      month: L === "en" ? "short" : "long",
      year: "numeric",
    };
    try {
      var s = new Intl.DateTimeFormat(LOCALE[L] || "en-US", opt).format(d);
      if (L === "fr" && +m[3] === 1) s = s.replace(/^1 /, "1er ");
      return s;
    } catch (e) {
      return null;
    }
  }
  function applyDates() {
    $$("time[data-date]").forEach(function (t) {
      var s = fmtDate(t.getAttribute("datetime"), lang);
      if (s) t.textContent = s;
    });
  }

  /* ----------------------------------------------------------------
     3. Langue des contenus : traduction disponible ? badge ?
     ---------------------------------------------------------------- */
  var I18N = {};
  (function () {
    var s = $("#writing-i18n");
    if (!s) return;
    try {
      I18N = JSON.parse(s.textContent) || {};
    } catch (e) {
      I18N = {};
    }
  })();
  /* Thèmes : le français est la langue source ; les libellés des autres langues viennent de
     data/categories.yml (clé réservée « _cats » du JSON). Un thème absent s'affiche tel quel. */
  function catLabel(c, L) {
    var e = I18N._cats && I18N._cats[c];
    return e && e[L] ? e[L] : c;
  }

  function itemParts(el) {
    return {
      title: $("h3, .essay-title a, a.eitem-title", el),
      desc: $(".essay-desc, .eitem-desc, p[lang]", el),
      links: el.matches("a[href]") ? [el] : $$("a[href]", el),
      badge: $("[data-badge]", el),
    };
  }

  function applyItemLang(el) {
    var p = itemParts(el);
    if (!el._orig) {
      el._orig = {
        title: p.title ? p.title.textContent : "",
        desc: p.desc ? p.desc.textContent : "",
        hrefs: p.links.map(function (a) {
          return a.getAttribute("href");
        }),
      };
    }
    var o = el._orig;
    var aLang = el.getAttribute("data-lang") || "en";
    var trs = (el.getAttribute("data-tr") || "").split(",").filter(Boolean);
    var slug = el.getAttribute("data-slug");
    var tdata = I18N[slug] && I18N[slug].tr && I18N[slug].tr[lang];

    /* Retour à l'original avant toute décision. */
    function setText(node, txt, l) {
      if (!node) return;
      node.textContent = txt;
      node.setAttribute("lang", l);
      node.setAttribute("dir", l === "ar" ? "rtl" : "ltr");
      var holder = node.closest("h2,h3,p");
      if (holder && holder !== node) {
        holder.setAttribute("lang", l);
        holder.setAttribute("dir", l === "ar" ? "rtl" : "ltr");
      }
    }

    if (aLang === lang) {
      restore();
      hideBadge();
    } else if (tdata) {
      /* Une traduction existe dans la langue de l'interface : on la montre. */
      setText(p.title, tdata.t, lang);
      setText(p.desc, tdata.d, lang);
      p.links.forEach(function (a, i) {
        var h = o.hrefs[i] || "";
        a.setAttribute(
          "href",
          h.replace(/index\.html(#.*)?$/, lang + "/index.html$1"),
        );
        a.setAttribute("hreflang", lang);
      });
      hideBadge();
    } else {
      restore();
      showBadge();
    }

    function restore() {
      setText(p.title, o.title, aLang);
      setText(p.desc, o.desc, aLang);
      p.links.forEach(function (a, i) {
        a.setAttribute("href", o.hrefs[i]);
        a.removeAttribute("hreflang");
      });
    }
    function hideBadge() {
      if (p.badge) p.badge.hidden = true;
    }
    function showBadge() {
      if (!p.badge) return;
      var all = [aLang].concat(trs);
      p.badge.textContent =
        tr("avail", lang) +
        " " +
        all
          .map(function (c) {
            return c.toUpperCase();
          })
          .join("/");
      p.badge.setAttribute("lang", lang);
      p.badge.setAttribute("dir", lang === "ar" ? "rtl" : "ltr");
      p.badge.hidden = false;
    }
  }
  function applyItemsLang() {
    $$("[data-item]").forEach(applyItemLang);
  }

  /* Page d'article : « Cet article est rédigé en… » quand la langue d'interface diffère. */
  function applyArticleNote() {
    var body = $(".article-body");
    var note = body && $(".lang-note", body);
    if (!note) return;
    var aLang = body.getAttribute("data-article-lang");
    var trs = (body.getAttribute("data-translations") || "")
      .split(",")
      .filter(Boolean);
    /* Texte traduit automatiquement (foot.html) ou même langue : pas de note. */
    if (aLang === lang || window.__mtArticle) {
      note.hidden = true;
      note.textContent = "";
      return;
    }
    var all = [aLang]
      .concat(trs)
      .map(function (c) {
        return c.toUpperCase();
      })
      .join(" / ");
    note.textContent = "";
    note.setAttribute("lang", lang);
    note.setAttribute("dir", lang === "ar" ? "rtl" : "ltr");
    note.appendChild(
      doc.createTextNode(
        tr(trs.length ? "avail_note" : "only_in", lang, {
          orig: LANGNAME[lang][aLang],
          langs: all,
        }) + " ",
      ),
    );
    if (trs.indexOf(lang) !== -1) {
      var a = doc.createElement("a");
      a.href = lang + "/index.html";
      a.setAttribute("hreflang", lang);
      a.setAttribute("lang", lang);
      a.textContent = tr("read_in", lang, { lang: LANGNAME[lang][lang] });
      note.appendChild(a);
    }
    note.hidden = false;
  }

  /* ----------------------------------------------------------------
     4. Listes : filtres, recherche, pagination
     ---------------------------------------------------------------- */
  var ftIndex = null,
    ftLoading = null;
  function loadFullText() {
    if (ftIndex) return Promise.resolve(ftIndex);
    if (ftLoading) return ftLoading;
    ftLoading = fetch(offset() + "search.json", { credentials: "same-origin" })
      .then(function (r) {
        return r.ok ? r.json() : [];
      })
      .then(function (rows) {
        var byPath = {};
        rows.forEach(function (r) {
          var path = String(r.href || "")
            .split("#")[0]
            .replace(/(\/index)?\.html$/, "")
            .replace(/\/$/, "");
          if (!path) return;
          byPath[path] =
            (byPath[path] || "") +
            " " +
            norm(
              (r.title || "") + " " + (r.section || "") + " " + (r.text || ""),
            );
        });
        ftIndex = byPath;
        return ftIndex;
      })
      .catch(function () {
        ftIndex = {};
        return ftIndex;
      });
    return ftLoading;
  }

  function initList(root) {
    var pageSize = parseInt(root.getAttribute("data-page-size"), 10) || 6;
    var items = $$("[data-item]", root);
    var container = $("[data-items]", root);
    var pager = $("[data-pager]", root);
    var statusEl = $("[data-status]", root);
    var emptyEl = $("[data-empty]", root);
    var input = $(".wq", root);
    var resetBtns = $$("[data-reset]", root);
    var selects = $$("select[data-facet]", root);
    var state = { type: "all", cat: "all", year: "all", q: "", page: 1 };

    /* État dans l'URL : lien partageable, bouton Retour fidèle. */
    function readHash() {
      var h = location.hash.replace(/^#/, "");
      if (!h) return;
      h.split("&").forEach(function (kv) {
        var i = kv.indexOf("=");
        if (i < 0) return;
        var k = kv.slice(0, i),
          v = decodeURIComponent(kv.slice(i + 1).replace(/\+/g, " "));
        if (k === "type" || k === "cat" || k === "year") state[k] = v;
        if (k === "q") state.q = v;
        if (k === "page") state.page = Math.max(1, parseInt(v, 10) || 1);
      });
    }
    function writeHash() {
      var parts = [];
      ["type", "cat", "year"].forEach(function (k) {
        if (state[k] !== "all")
          parts.push(k + "=" + encodeURIComponent(state[k]));
      });
      if (state.q) parts.push("q=" + encodeURIComponent(state.q));
      if (state.page > 1) parts.push("page=" + state.page);
      var h = parts.length ? "#" + parts.join("&") : "";
      try {
        history.replaceState(null, "", location.pathname + location.search + h);
      } catch (e) {}
    }

    function syncSelects() {
      selects.forEach(function (s) {
        var k = s.getAttribute("data-facet");
        /* Valeur d'URL inconnue (option absente) : retour à « Tous ». */
        var ok = Array.prototype.some.call(s.options, function (o) {
          return o.value === state[k];
        });
        if (!ok) state[k] = "all";
        s.value = state[k];
        s.classList.toggle("is-set", state[k] !== "all");
      });
      /* Un facette sans liste (ex. « type » dans les Essais) ne filtre rien. */
      ["type", "cat", "year"].forEach(function (k) {
        if (!$('select[data-facet="' + k + '"]', root)) state[k] = "all";
      });
    }

    function matches(el, tokens) {
      if (state.type !== "all" && el.getAttribute("data-type") !== state.type)
        return false;
      if (
        state.cat !== "all" &&
        (el.getAttribute("data-cats") || "").split("|").indexOf(state.cat) ===
          -1
      )
        return false;
      if (state.year !== "all" && el.getAttribute("data-year") !== state.year)
        return false;
      if (tokens.length) {
        var hay = norm(
          el.textContent + " " + (el.getAttribute("data-cats") || ""),
        );
        var full = (ftIndex && ftIndex[el.getAttribute("data-slug")]) || "";
        for (var i = 0; i < tokens.length; i++) {
          if (hay.indexOf(tokens[i]) === -1 && full.indexOf(tokens[i]) === -1)
            return false;
        }
      }
      return true;
    }

    function render(scroll) {
      var tokens = norm(state.q).split(/\s+/).filter(Boolean);
      var hits = items.filter(function (el) {
        return matches(el, tokens);
      });
      var pages = Math.max(1, Math.ceil(hits.length / pageSize));
      if (state.page > pages) state.page = pages;
      var first = (state.page - 1) * pageSize;
      var visible = hits.slice(first, first + pageSize);

      items.forEach(function (el) {
        el.hidden = visible.indexOf(el) === -1;
      });
      /* Ordre : les éléments déjà dans le DOM sont triés par date décroissante. */
      if (emptyEl) emptyEl.hidden = hits.length > 0;
      if (container) container.hidden = visible.length === 0;

      var n = hits.length,
        total = items.length;
      var filtered =
        !!state.q ||
        state.type !== "all" ||
        state.cat !== "all" ||
        state.year !== "all";
      /* data-unit="publication|publications" sur la liste remplace « article(s) » (page Médias). */
      var unit = (root.getAttribute("data-unit") || "").split("|");
      var u1 = unit[0] || "",
        un = unit[1] || "";
      statusEl.textContent =
        n === 0
          ? ""
          : u1
            ? filtered
              ? n + " sur " + total + " " + (total > 1 ? un : u1)
              : total + " " + (total > 1 ? un : u1)
            : filtered
              ? n === 1
                ? tr("article_one", lang)
                : tr("articles_of", lang, { n: n, t: total })
              : total === 1
                ? tr("article_one", lang)
                : tr("articles_all", lang, { t: total });
      if (ftLoading && !ftIndex && tokens.length)
        statusEl.textContent = tr("searching", lang);
      resetBtns.forEach(function (b) {
        if (!b.closest(".wempty")) b.hidden = !filtered;
      });

      renderPager(pages);
      syncSelects();
      writeHash();
      if (scroll) {
        var top = root.getBoundingClientRect().top + window.scrollY - 70;
        window.scrollTo({ top: Math.max(0, top), behavior: "auto" });
      }
      if (window.__i18n) window.__i18n.refresh();
    }

    function renderPager(pages) {
      pager.textContent = "";
      if (pages <= 1) return;
      function btn(label, onclick, opts) {
        var b = doc.createElement("button");
        b.type = "button";
        b.className =
          "pbtn" +
          (opts && opts.num ? " pnum" : "") +
          (opts && opts.on ? " on" : "");
        b.textContent = label;
        if (opts && opts.disabled) b.disabled = true;
        if (opts && opts.on) b.setAttribute("aria-current", "page");
        if (opts && opts.aria) b.setAttribute("aria-label", opts.aria);
        b.addEventListener("click", onclick);
        return b;
      }
      pager.appendChild(
        btn(
          tr("prev", lang),
          function () {
            state.page--;
            render(true);
          },
          { disabled: state.page === 1 },
        ),
      );
      for (var i = 1; i <= pages; i++)
        (function (n) {
          pager.appendChild(
            btn(
              String(n),
              function () {
                state.page = n;
                render(true);
              },
              {
                num: true,
                on: n === state.page,
                aria: tr("page", lang) + " " + n,
              },
            ),
          );
        })(i);
      pager.appendChild(
        btn(
          tr("next", lang),
          function () {
            state.page++;
            render(true);
          },
          { disabled: state.page === pages },
        ),
      );
    }

    selects.forEach(function (s) {
      s.addEventListener("change", function () {
        state[s.getAttribute("data-facet")] = s.value;
        state.page = 1;
        render(false);
      });
    });
    root.addEventListener("click", function (e) {
      if (e.target.closest && e.target.closest("[data-reset]")) {
        state = { type: "all", cat: "all", year: "all", q: "", page: 1 };
        if (input) input.value = "";
        render(false);
        if (input && !e.target.closest(".wempty")) input.focus();
      }
    });

    if (input) {
      var timer = null;
      input.addEventListener("focus", loadFullText, { once: true });
      input.addEventListener("input", function () {
        var v = input.value.trim();
        if (v)
          loadFullText().then(function () {
            render(false);
          });
        clearTimeout(timer);
        timer = setTimeout(function () {
          state.q = v;
          state.page = 1;
          render(false);
        }, 120);
      });
      input.addEventListener("keydown", function (e) {
        if (e.key === "Escape" && input.value) {
          input.value = "";
          state.q = "";
          state.page = 1;
          render(false);
        }
      });
    }

    window.addEventListener("hashchange", function () {
      readHash();
      if (input) input.value = state.q;
      render(false);
    });
    root._rerender = function () {
      render(false);
    };

    root.setAttribute("data-ready", "");
    readHash();
    if (input && state.q) {
      input.value = state.q;
      loadFullText().then(function () {
        render(false);
      });
    }
    render(false);
  }

  /* ----------------------------------------------------------------
     5. Articles : copier le lien, sommaire actif, code focalisable
     ---------------------------------------------------------------- */
  function liveRegion(host) {
    var r = $("[data-live]", host);
    if (!r) {
      r = doc.createElement("span");
      r.setAttribute("data-live", "");
      r.setAttribute("role", "status");
      r.className = "sr-only";
      host.appendChild(r);
    }
    return r;
  }

  function copyText(text) {
    if (navigator.clipboard && window.isSecureContext)
      return navigator.clipboard.writeText(text);
    return new Promise(function (ok, ko) {
      var ta = doc.createElement("textarea");
      ta.value = text;
      ta.setAttribute("readonly", "");
      ta.style.position = "fixed";
      ta.style.opacity = "0";
      doc.body.appendChild(ta);
      ta.select();
      try {
        doc.execCommand("copy") ? ok() : ko();
      } catch (e) {
        ko(e);
      } finally {
        doc.body.removeChild(ta);
      }
    });
  }

  function initShare() {
    $$(".art-share").forEach(function (host) {
      var msg = host.getAttribute("data-copied") || "Copied";
      $$(".sb-copy", host).forEach(function (b) {
        var label = $(".sb-t", b);
        var original = label ? label.textContent : b.textContent;
        b.addEventListener("click", function () {
          copyText(
            b.getAttribute("data-url") || location.href.split("#")[0],
          ).then(
            function () {
              if (label) label.textContent = msg;
              else b.textContent = msg;
              b.classList.add("is-done");
              liveRegion(host).textContent = msg;
              setTimeout(function () {
                if (label) label.textContent = original;
                else b.textContent = original;
                b.classList.remove("is-done");
              }, 2200);
            },
            function () {
              liveRegion(host).textContent = tr("copy_fail", lang);
            },
          );
        });
      });
      /* Menu de partage du système (téléphones, tablettes) : le bouton n'apparaît que s'il est pris en charge. */
      var nat = $(".sb-native", host);
      if (nat && navigator.share) {
        nat.hidden = false;
        nat.addEventListener("click", function () {
          navigator
            .share({
              title: nat.getAttribute("data-title") || doc.title,
              url: nat.getAttribute("data-url") || location.href.split("#")[0],
            })
            .catch(function () {});
        });
      }
    });
  }

  /* Barre de progression de lecture (articles) : fine, en haut de la page, sans animation si l'utilisateur les réduit. */
  function initProgress() {
    var body = $(".article-body");
    var content = body && $(".art-content", body);
    if (!content || $(".art-progress")) return;
    var bar = doc.createElement("div");
    bar.className = "art-progress";
    bar.setAttribute("aria-hidden", "true");
    var fill = doc.createElement("div");
    fill.className = "art-progress-fill";
    bar.appendChild(fill);
    doc.body.appendChild(bar);
    var ticking = false;
    function update() {
      ticking = false;
      var r = content.getBoundingClientRect();
      var total = r.height - window.innerHeight * 0.6;
      var done =
        total > 0
          ? Math.min(
              1,
              Math.max(0, (-r.top + window.innerHeight * 0.2) / total),
            )
          : 0;
      fill.style.transform = "scaleX(" + done.toFixed(4) + ")";
    }
    function onScroll() {
      if (!ticking) {
        ticking = true;
        window.requestAnimationFrame(update);
      }
    }
    window.addEventListener("scroll", onScroll, { passive: true });
    window.addEventListener("resize", onScroll);
    update();
  }

  /* Sommaire : toujours déployé sur grand écran (colonne de droite), replié par défaut sur téléphone/tablette. */
  function initTocDetails() {
    var det = $(".art-toc details");
    if (!det || !window.matchMedia) return;
    var mq = window.matchMedia("(min-width: 1100px)");
    function apply() {
      det.open = mq.matches;
    }
    apply();
    if (mq.addEventListener) mq.addEventListener("change", apply);
    else if (mq.addListener) mq.addListener(apply);
    /* Sur grand écran, le titre n'est pas un bouton : il ne se replie pas. */
    det.addEventListener("toggle", function () {
      if (mq.matches && !det.open) det.open = true;
    });
    $$(".art-toc a", det).forEach(function (a) {
      a.addEventListener("click", function () {
        if (!mq.matches)
          setTimeout(function () {
            det.open = false;
          }, 0);
      });
    });
  }

  function initToc() {
    /* Quarto réécrit les liens « #ancre » en adresses absolues au chargement : on ne peut donc pas
       filtrer sur href^="#" ; on lit `a.hash` et on vérifie que le lien pointe bien sur cette page. */
    var here = location.pathname.replace(/index\.html$/, "");
    var links = Array.prototype.filter.call($$(".art-toc a"), function (a) {
      return (
        a.hash.length > 1 && a.pathname.replace(/index\.html$/, "") === here
      );
    });
    if (!links.length || !("IntersectionObserver" in window)) return;
    var map = {};
    var heads = [];
    links.forEach(function (a) {
      var id = decodeURIComponent(a.hash.slice(1));
      var h = doc.getElementById(id);
      if (h) {
        map[id] = a;
        heads.push(h);
      }
    });
    var visible = {};
    function mark() {
      var current = null;
      for (var i = 0; i < heads.length; i++) {
        if (visible[heads[i].id] || heads[i].getBoundingClientRect().top < 120)
          current = heads[i].id;
      }
      links.forEach(function (a) {
        a.classList.remove("is-active");
        a.removeAttribute("aria-current");
      });
      if (current && map[current]) {
        map[current].classList.add("is-active");
        map[current].setAttribute("aria-current", "location");
      }
    }
    var io = new IntersectionObserver(
      function (es) {
        es.forEach(function (e) {
          visible[e.target.id] =
            e.isIntersecting && e.boundingClientRect.top < 200;
        });
        mark();
      },
      { rootMargin: "-80px 0px -60% 0px", threshold: [0, 1] },
    );
    heads.forEach(function (h) {
      io.observe(h);
    });
    window.addEventListener("scroll", mark, { passive: true });
    mark();
  }

  /* Un bloc de code qui défile doit être atteignable au clavier. */
  function initCodeFocus() {
    function upd() {
      $$(".article-body pre, #quarto-appendix pre").forEach(function (pre) {
        var scrolls = pre.scrollWidth > pre.clientWidth + 1;
        if (scrolls) {
          pre.setAttribute("tabindex", "0");
        } else if (pre.getAttribute("tabindex") === "0") {
          pre.removeAttribute("tabindex");
        }
      });
    }
    upd();
    window.addEventListener("resize", upd);
  }

  /* ----------------------------------------------------------------
     Langue d'interface : initialisation et changements
     ---------------------------------------------------------------- */
  function refreshAll() {
    applyT();
    applyDates();
    applyItemsLang();
    applyArticleNote();
    var sk = $(".skip-link");
    if (sk) sk.textContent = tr("skip", lang);
    $$("[data-wlist]").forEach(function (r) {
      if (r._rerender) r._rerender();
    });
  }

  function init() {
    initSkip();
    $$("[data-wlist]").forEach(initList);
    initShare();
    initToc();
    initTocDetails();
    initProgress();
    initCodeFocus();
    refreshAll();
  }

  doc.addEventListener("sitelang", function (e) {
    lang = uiLang();
    refreshAll();
  });

  if (doc.readyState === "loading")
    doc.addEventListener("DOMContentLoaded", init, { once: true });
  else init();
})();
