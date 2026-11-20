--[[
  article.lua — gabarits d'articles pour blog/ et essais/

  Ce filtre ne touche QUE les articles :
    blog/<slug>.qmd  et  essais/<slug>.qmd          (forme normale : un fichier par article)
    blog/<slug>/index.qmd, essais/<slug>/index.qmd  (ancienne forme : un dossier par article,
                                                     toujours acceptée, avec ses traductions
                                                     <slug>/<en|fr|ar>/index.qmd)
  Toutes les autres pages du site passent sans modification.

  Ce qu'il produit autour du texte de l'article :
    - en-tête : lien retour, type, titre, chapeau, auteur, dates de publication
      et de mise à jour, temps de lecture, langue, traductions disponibles ;
    - tutoriel : encadrés « Prérequis » et « Ce que vous allez apprendre »,
      épisode précédent / suivant d'une série ;
    - note de recherche : fiche (projet, langue étudiée, statut) et liens
      PDF / dataset / code / BibTeX quand ils existent ;
    - essai : « Sources et références », « Corrections et mises à jour » ;
    - tous : partage (LinkedIn, X, copier le lien), « Voir aussi »,
      articles liés, données structurées schema.org/Article, hreflang,
      Open Graph (locale, dates) ;
    - le texte est enveloppé dans un bloc portant sa propre langue (lang/dir)
      et marqué translate="no" : jamais de traduction automatique silencieuse.

  Il VÉRIFIE aussi le front matter et arrête le rendu, avec un message
  explicite, quand un champ obligatoire manque (essai sans sources, tutoriel
  sans prérequis, projet inconnu, traduction orpheline…).

  Les libellés de l'article sont dans la langue de l'article (tables L ci-dessous),
  jamais dans celle de l'interface : un essai en français garde une page entièrement
  en français quel que soit le bouton EN/FR/AR choisi par le visiteur.
]]

local utils = pandoc.utils
local stringify = utils.stringify
local sys = pandoc.system

local SECTIONS = { blog = true, essais = true }
local LANGS = { en = true, fr = true, ar = true }
local DEFAULT_AUTHOR = "Abdel-aziz Harane Abounounou"
local WPM = 200 -- mots par minute pour le temps de lecture

---------------------------------------------------------------------------
-- Libellés par langue d'article
---------------------------------------------------------------------------
local L = {
  en = {
    published = "Published", updated = "Updated", min_read = "min read",
    tutorial = "Tutorial", note = "Research note", announcement = "Announcement", essay = "Essay",
    prerequisites = "Prerequisites", learn = "What you will learn",
    level = "Level", beginner = "Beginner", intermediate = "Intermediate", advanced = "Advanced",
    project = "Project", languages = "Languages studied", status = "Status",
    ongoing = "Ongoing", completed = "Completed", preprint = "Preprint", draft = "Draft",
    pdf = "PDF", dataset = "Dataset", code = "Code", bibtex = "BibTeX", repo = "Repository",
    share = "Share", copy_link = "Copy link", copied = "Link copied",
    see_also = "See also", related = "Related articles", read = "Read article",
    notes = "Notes", back_to_text = "Back to text",
    sources = "Sources and references", corrections = "Corrections and updates",
    series = "Series", episode = "Episode", of = "of",
    prev_ep = "Previous episode", next_ep = "Next episode",
    translation = "Translation", also_in = "Also available in:",
    translation_of = "This is a translation of the original article, written in %s.",
    read_original = "Read the original", human = "Human translation",
    machine = "Machine translation, reviewed by the author",
    by = "Translated by %s", table = "Scrollable table",
    kind_project = "Project", kind_publication = "Publication", kind_essay = "Essay",
    kind_article = "Article", kind_external = "Link", kind_page = "Page",
    back_blog = "Blog", back_essais = "Essays", event = "Event",
    contents = "Contents",
    author = "Author", categories = "Categories", reading = "Reading time",
    prev = "Previous", next = "Next", share_on = "Share on", share_native = "Share…", mail = "Email",
  },
  fr = {
    published = "Publié le", updated = "Mis à jour le", min_read = "min de lecture",
    tutorial = "Tutoriel", note = "Note de recherche", announcement = "Annonce", essay = "Essai",
    prerequisites = "Prérequis", learn = "Ce que vous allez apprendre",
    level = "Niveau", beginner = "Débutant", intermediate = "Intermédiaire", advanced = "Avancé",
    project = "Projet", languages = "Langues étudiées", status = "Statut",
    ongoing = "En cours", completed = "Terminée", preprint = "Préprint", draft = "Brouillon",
    pdf = "PDF", dataset = "Jeu de données", code = "Code", bibtex = "BibTeX", repo = "Dépôt",
    share = "Partager", copy_link = "Copier le lien", copied = "Lien copié",
    see_also = "Voir aussi", related = "Articles liés", read = "Lire l’article",
    notes = "Notes", back_to_text = "Retour au texte",
    sources = "Sources et références", corrections = "Corrections et mises à jour",
    series = "Série", episode = "Épisode", of = "sur",
    prev_ep = "Épisode précédent", next_ep = "Épisode suivant",
    translation = "Traduction", also_in = "Aussi disponible en\u{00A0}:",
    translation_of = "Ceci est la traduction de l’article original, rédigé en %s.",
    read_original = "Lire l’original", human = "Traduction humaine",
    machine = "Traduction automatique relue par l’auteur",
    by = "Traduit par %s", table = "Tableau défilant",
    kind_project = "Projet", kind_publication = "Publication", kind_essay = "Essai",
    kind_article = "Article", kind_external = "Lien", kind_page = "Page",
    back_blog = "Blog", back_essais = "Essais", event = "Événement",
    contents = "Sommaire",
    author = "Auteur", categories = "Catégories", reading = "Lecture",
    prev = "Précédent", next = "Suivant", share_on = "Partager sur", share_native = "Partager…", mail = "E-mail",
  },
  ar = {
    published = "نُشر في", updated = "حُدِّث في", min_read = "دقائق للقراءة",
    tutorial = "درس تطبيقي", note = "مذكرة بحثية", announcement = "إعلان", essay = "مقال",
    prerequisites = "المتطلبات المسبقة", learn = "ما ستتعلّمه",
    level = "المستوى", beginner = "مبتدئ", intermediate = "متوسط", advanced = "متقدم",
    project = "المشروع", languages = "اللغات المدروسة", status = "الحالة",
    ongoing = "قيد التنفيذ", completed = "مكتمل", preprint = "نسخة أولية", draft = "مسودة",
    pdf = "PDF", dataset = "مجموعة البيانات", code = "الشيفرة", bibtex = "BibTeX", repo = "المستودع",
    share = "مشاركة", copy_link = "نسخ الرابط", copied = "تم نسخ الرابط",
    see_also = "انظر أيضًا", related = "مقالات ذات صلة", read = "قراءة المقال",
    notes = "الهوامش", back_to_text = "العودة إلى النص",
    sources = "المصادر والمراجع", corrections = "التصحيحات والتحديثات",
    series = "سلسلة", episode = "الحلقة", of = "من",
    prev_ep = "الحلقة السابقة", next_ep = "الحلقة التالية",
    translation = "ترجمة", also_in = "متوفر أيضًا باللغة:",
    translation_of = "هذه ترجمة للمقال الأصلي المكتوب باللغة %s.",
    read_original = "قراءة النص الأصلي", human = "ترجمة بشرية",
    machine = "ترجمة آلية راجعها المؤلف",
    by = "ترجمة: %s", table = "جدول قابل للتمرير",
    kind_project = "مشروع", kind_publication = "منشور", kind_essay = "مقال",
    kind_article = "مقال", kind_external = "رابط", kind_page = "صفحة",
    back_blog = "المدونة", back_essais = "مقالات", event = "فعالية",
    contents = "المحتويات",
    author = "الكاتب", categories = "التصنيفات", reading = "مدة القراءة",
    prev = "السابق", next = "التالي", share_on = "مشاركة عبر", share_native = "مشاركة…", mail = "البريد الإلكتروني",
  },
}

-- Nom de chaque langue, écrit dans chaque langue d'article.
local LANGNAME = {
  en = { en = "English", fr = "French", ar = "Arabic" },
  fr = { en = "anglais", fr = "français", ar = "arabe" },
  ar = { en = "الإنجليزية", fr = "الفرنسية", ar = "العربية" },
}
-- Nom d'une langue dans sa propre langue (pour l'attribut lang du lien).
local ENDONYM = { en = "English", fr = "Français", ar = "العربية" }
local OG_LOCALE = { en = "en_US", fr = "fr_FR", ar = "ar_AR" }

local MONTHS = {
  en = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" },
  fr = { "janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre" },
  ar = { "يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو", "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر" },
}

---------------------------------------------------------------------------
-- Utilitaires
---------------------------------------------------------------------------
local function esc(s)
  s = tostring(s or "")
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;")
  return s
end

-- Texte affiché : apostrophes droites -> typographiques (’), puis échappement HTML.
-- (Ne pas l'utiliser pour des identifiants ou des attributs comparés à une valeur brute.)
local function escp(s)
  return esc((tostring(s or ""):gsub("'", "\u{2019}")))
end

-- JSON : échappe une chaîne ; "</" devient "<\/" pour ne pas fermer le <script>.
local function jstr(s)
  s = tostring(s or "")
  s = s:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", ""):gsub("\t", " "):gsub("</", "<\\/")
  return '"' .. s .. '"'
end

local function plain(v)
  local t = utils.type(v)
  if t == "string" or t == "boolean" or t == "number" then
    return v
  elseif t == "Inlines" or t == "Blocks" or t == "Inline" or t == "Block" then
    return stringify(v)
  elseif t == "List" then
    local r = {}
    for i, x in ipairs(v) do r[i] = plain(x) end
    return r
  elseif t == "table" or t == "Meta" then
    local r = {}
    for k, x in pairs(v) do r[k] = plain(x) end
    return r
  end
  return v
end

local function is_list(v)
  return type(v) == "table" and (v[1] ~= nil or next(v) == nil)
end

local function as_list(v)
  if v == nil or v == "" then return {} end
  if is_list(v) then return v end
  return { v }
end

local function read_file(path)
  local f = io.open(path, "rb")
  if not f then return nil end
  local t = f:read("a")
  f:close()
  -- Fichiers enregistrés sous Windows (fins de ligne CRLF) : on les ramène à LF.
  return (t:gsub("\r\n", "\n"))
end

local function dirname(p) return (p:gsub("/[^/]*$", "")) end

-- Front matter YAML d'un .qmd → table Lua. "markdown-smart" : pas de guillemets
-- typographiques ni de tirets automatiques dans les titres.
local function parse_yaml_block(body)
  local ok, doc = pcall(pandoc.read, "---\n" .. body .. "\n---\n", "markdown-smart")
  if not ok or not doc then return {} end
  return plain(doc.meta) or {}
end

local function front_matter(text)
  if not text then return {} end
  local body = text:match("^%-%-%-[ \t]*\r?\n(.-)\r?\n%-%-%-[ \t]*\r?\n") or text:match("^%-%-%-[ \t]*\r?\n(.-)\r?\n%-%-%-[ \t]*$")
  if not body then return {} end
  return parse_yaml_block(body)
end

local function find_root(file)
  local dir = dirname(file)
  for _ = 1, 8 do
    if read_file(dir .. "/_quarto.yml") then return dir end
    local up = dirname(dir)
    if up == dir or up == "" then break end
    dir = up
  end
  return nil
end

local function fail(ctx, msg)
  local text = "\n\n[article.lua] " .. ctx.rel .. "\n  → " .. msg .. "\n"
  -- Un simple error() est avalé par Quarto : il affiche le message mais publie quand même
  -- l'article non validé, avec un code de sortie 0 (donc un déploiement CI réussi).
  -- On arrête donc le rendu pour de bon : code de sortie non nul, rien n'est publié.
  io.stderr:write(text)
  io.stderr:flush()
  os.exit(1)
end

---------------------------------------------------------------------------
-- Contexte : suis-je dans un article ?
---------------------------------------------------------------------------
-- Chemin du fichier en cours, normalisé : Windows donne « C:\Users\…\index.qmd » (barres
-- inverses, lettre de lecteur) ; on travaille partout avec des « / ».
local function abs_input(input)
  input = tostring(input):gsub("\\", "/")
  local absolute = input:sub(1, 1) == "/" or input:match("^%a:/") ~= nil
  if not absolute then
    input = tostring(sys.get_working_directory()):gsub("\\", "/"):gsub("/+$", "") .. "/" .. input
  end
  return input
end

local function article_context()
  local input = nil
  if quarto and quarto.doc and quarto.doc.input_file then input = quarto.doc.input_file end
  if not input and PANDOC_STATE and PANDOC_STATE.input_files then input = PANDOC_STATE.input_files[1] end
  if not input then return nil end
  input = abs_input(input)
  local root = find_root(input)
  if not root then return nil end
  local rel = input:sub(#root + 2)
  local parts = {}
  for seg in rel:gmatch("[^/]+") do parts[#parts + 1] = seg end
  if not SECTIONS[parts[1]] then return nil end
  -- Article en un seul fichier : blog/<slug>.qmd (Quarto peut passer <slug>.knit.md…).
  if #parts == 2 and not parts[2]:match("^index%.") and not parts[2]:match("^[_%.]") then
    local slug = parts[2]:match("^(.-)%.[^/]*$") or parts[2]
    slug = slug:gsub("%.knit$", "")
    rel = parts[1] .. "/" .. slug .. ".qmd"
    local ctx = { input = root .. "/" .. rel, root = root, rel = rel, section = parts[1], slug = slug, flat = true }
    ctx.depth = 1
    ctx.up = "../"
    ctx.back_up = ""
    return ctx
  end
  if not parts[#parts]:match("^index%.") then return nil end
  -- Quarto peut passer un fichier temporaire (index.knit.md…) : on relit le .qmd.
  parts[#parts] = "index.qmd"
  rel = table.concat(parts, "/")
  input = root .. "/" .. rel
  local ctx = { input = input, root = root, rel = rel, section = parts[1] }
  if #parts == 3 then
    ctx.slug = parts[2]
  elseif #parts == 4 and LANGS[parts[3]] then
    ctx.slug = parts[2]
    ctx.tlang = parts[3]
  else
    return nil
  end
  ctx.depth = #parts - 1 -- blog/slug → 2 ; blog/slug/en → 3
  ctx.up = string.rep("../", ctx.depth)
  ctx.back_up = string.rep("../", ctx.depth - 1)
  return ctx
end

local function site_url(root)
  local txt = read_file(root .. "/_quarto.yml") or ""
  local u = txt:match('site%-url:%s*"?([^"\r\n]+)"?')
  if u then u = u:gsub("%s+$", ""):gsub("/+$", "") end
  return u
end

---------------------------------------------------------------------------
-- Index des articles du site (front matter de chaque article)
---------------------------------------------------------------------------
local function record_from(section, slug, fm, flat)
  local ty = fm.type
  if not ty and section == "essais" then ty = "essai" end
  local series = nil
  if type(fm.series) == "table" and fm.series.id then
    series = { id = tostring(fm.series.id), part = tonumber(fm.series.part) or 0, title = fm.series.title }
  end
  local cats = {}
  for _, c in ipairs(as_list(fm.categories)) do cats[#cats + 1] = tostring(c) end
  return {
    section = section, slug = slug, rel = section .. "/" .. slug, flat = flat,
    -- adresse de la page publiée, depuis la racine du site
    href = section .. "/" .. slug .. (flat and ".html" or "/index.html"),
    title = fm.title, subtitle = fm.subtitle, description = fm.description,
    date = fm.date and tostring(fm.date) or "", lang = fm.lang or "fr", type = ty,
    categories = cats, featured = fm.featured == true, draft = fm.draft == true,
    series = series, translations = as_list(fm.translations),
    image = fm.image,
  }
end

local function scan_articles(root)
  local out = {}
  for sec in pairs(SECTIONS) do
    local ok, entries = pcall(sys.list_directory, root .. "/" .. sec)
    if ok then
      for _, name in ipairs(entries) do
        if name:sub(1, 1) ~= "_" and name:sub(1, 1) ~= "." then
          local slug, txt, flat = name, nil, false
          if name:match("%.qmd$") then
            if name ~= "index.qmd" then
              slug, flat = name:gsub("%.qmd$", ""), true
              txt = read_file(root .. "/" .. sec .. "/" .. name)
            end
          else
            txt = read_file(root .. "/" .. sec .. "/" .. name .. "/index.qmd")
          end
          if txt then
            local rec = record_from(sec, slug, front_matter(txt), flat)
            if not rec.draft and rec.title then out[#out + 1] = rec end
          end
        end
      end
    end
  end
  table.sort(out, function(a, b)
    if a.date ~= b.date then return a.date > b.date end
    return a.rel < b.rel
  end)
  return out
end

-- Libellés des thèmes (catégories) par langue : data/categories.yml. Le français est la langue
-- source : un thème absent du fichier s'affiche tel quel, dans toutes les langues.
local function load_cats(root)
  local txt = read_file(root .. "/data/categories.yml")
  if not txt then return {} end
  return parse_yaml_block(txt)
end

local function cat_label(cats, c, lang)
  local e = cats[c]
  if type(e) == "table" and e[lang] and e[lang] ~= "" then return tostring(e[lang]) end
  return c
end

local function url_enc(s)
  -- Classe ASCII explicite : sous Windows, %w dépend de la langue du système et laissait passer
  -- des octets UTF-8 (« à », « é ») non encodés → URL invalide (avertissements de Quarto).
  return (tostring(s):gsub("[^A-Za-z0-9%-_%.~]", function(ch) return string.format("%%%02X", ch:byte()) end))
end

local function load_refs(root)
  local txt = read_file(root .. "/data/refs.yml")
  if not txt then return {} end
  return parse_yaml_block(txt)
end

---------------------------------------------------------------------------
-- Validation du front matter
---------------------------------------------------------------------------
local BLOG_TYPES = { tutoriel = true, note = true, annonce = true }

local function bib_has_entry(path)
  local t = read_file(path)
  return t ~= nil and t:find("@%a+%s*{") ~= nil
end

local function validate(ctx, fm, orig_fm, refs, articles)
  -- strict : le champ doit figurer dans CE fichier (une traduction ne doit pas
  -- hériter d'un texte rédigé dans une autre langue : prérequis, sources…).
  local function need(key, human, strict)
    local v = strict and rawget(fm, key) or fm[key]
    if v == nil or v == "" or (type(v) == "table" and next(v) == nil) then
      fail(ctx, "champ obligatoire manquant : " .. key .. (human and (" (" .. human .. ")") or ""))
    end
    return v
  end

  need("title", nil, true)
  need("description", "1 à 2 phrases : card, SEO, partage", true)
  if not LANGS[fm.lang or ""] then fail(ctx, "lang doit valoir en, fr ou ar (reçu : " .. tostring(fm.lang) .. ")") end
  local d = tostring(need("date", "AAAA-MM-JJ"))
  if not d:match("^%d%d%d%d%-%d%d%-%d%d$") then fail(ctx, "date doit être au format AAAA-MM-JJ (reçu : " .. d .. ")") end
  if fm["date-modified"] then
    local m = tostring(fm["date-modified"])
    if not m:match("^%d%d%d%d%-%d%d%-%d%d$") then fail(ctx, "date-modified doit être au format AAAA-MM-JJ") end
    if m < d then fail(ctx, "date-modified (" .. m .. ") est antérieure à date (" .. d .. ")") end
  end
  need("categories", "au moins un thème, en français : TAL, Parole, Langues africaines… (voir data/categories.yml)")

  local ty = fm.type or (ctx.section == "essais" and "essai" or nil)
  if ctx.section == "blog" then
    if not BLOG_TYPES[ty or ""] then
      fail(ctx, "type doit valoir tutoriel, note ou annonce dans blog/ (reçu : " .. tostring(ty) .. ")")
    end
  elseif ty ~= "essai" then
    fail(ctx, "type doit valoir essai dans essais/ (reçu : " .. tostring(ty) .. ")")
  end

  if ty == "tutoriel" then
    need("prerequisites", "liste ; écrire « Aucun prérequis particulier » si besoin", true)
    need("learning-outcomes", "liste de ce que le lecteur saura faire", true)
  elseif ty == "note" then
    local p = need("project", "clé définie dans data/refs.yml")
    if not refs[p] then fail(ctx, "project « " .. tostring(p) .. " » est absent de data/refs.yml") end
    need("languages-studied", "liste, ex. [Sara]")
  elseif ty == "essai" then
    need("date-modified", "obligatoire pour un essai : AAAA-MM-JJ")
    local bib = need("bibliography", "fichier .bib des sources", true)
    if not bib_has_entry(dirname(ctx.input) .. "/" .. tostring(bib)) then
      fail(ctx, "un essai exige une section « Sources et références » : " .. tostring(bib) .. " est introuvable ou ne contient aucune entrée")
    end
  end

  if fm.lang == "ar" and fm.language == nil and quarto and quarto.log and quarto.log.warning then
    quarto.log.warning("[article.lua] " .. ctx.rel .. " : article en arabe sans `language:` — le bloc « Citation » de Quarto restera en anglais. Ajouter : language: " .. string.rep("../", ctx.depth) .. "assets/i18n/ar.yml")
  end

  if fm.series ~= nil then
    if type(fm.series) ~= "table" or not fm.series.id or not tonumber(fm.series.part) then
      fail(ctx, "series doit contenir id et part (nombre), ex. series: {id: asr-sara, title: \"ASR sara\", part: 2}")
    end
  end

  for _, item in ipairs(as_list(fm["see-also"])) do
    if type(item) ~= "table" then fail(ctx, "see-also : chaque entrée est un objet {ref: …} ou {article: …} ou {title:, href:}") end
    if item.ref then
      if not refs[item.ref] then fail(ctx, "see-also : ref « " .. tostring(item.ref) .. " » est absent de data/refs.yml") end
    elseif item.article then
      local found = false
      for _, a in ipairs(articles) do if a.rel == item.article then found = true end end
      if not found then fail(ctx, "see-also : article « " .. tostring(item.article) .. " » introuvable (forme attendue : blog/mon-slug, sans .qmd)") end
    elseif not (item.title and item.href) then
      fail(ctx, "see-also : renseigner ref, article, ou title + href")
    end
  end

  if ctx.tlang then
    if not orig_fm or not orig_fm.title then fail(ctx, "traduction sans article original : " .. ctx.section .. "/" .. ctx.slug .. "/index.qmd est introuvable") end
    if fm.lang ~= ctx.tlang then fail(ctx, "lang (" .. tostring(fm.lang) .. ") doit correspondre au dossier de traduction (" .. ctx.tlang .. ")") end
    if (orig_fm.lang or "fr") == fm.lang then fail(ctx, "la traduction a la même langue que l'original") end
    local tr = fm.translation
    local method = type(tr) == "table" and tr.method or nil
    if method ~= "human" and method ~= "machine-reviewed" then
      fail(ctx, "translation.method doit valoir human ou machine-reviewed : une traduction doit toujours dire comment elle a été faite")
    end
  else
    if ctx.flat and #as_list(fm.translations) > 0 then
      fail(ctx, "translations : un article en un seul fichier est traduit automatiquement ; retirer « translations: » (les traductions écrites à la main demandent la forme en dossier <slug>/index.qmd + <slug>/<en|ar>/index.qmd)")
    end
    for _, code in ipairs(as_list(fm.translations)) do
      if not LANGS[code] or code == fm.lang then fail(ctx, "translations : « " .. tostring(code) .. " » n'est pas une langue de traduction valide") end
      if not read_file(ctx.root .. "/" .. ctx.section .. "/" .. ctx.slug .. "/" .. code .. "/index.qmd") then
        fail(ctx, "translations liste « " .. code .. " » mais " .. ctx.section .. "/" .. ctx.slug .. "/" .. code .. "/index.qmd n'existe pas")
      end
    end
  end

  return ty
end

---------------------------------------------------------------------------
-- Mise en forme
---------------------------------------------------------------------------
local function fmt_date(iso, lang)
  local y, m, d = tostring(iso):match("^(%d+)-(%d+)-(%d+)")
  if not y then return tostring(iso) end
  m, d = tonumber(m), tonumber(d)
  if lang == "fr" then return (d == 1 and "1er" or tostring(d)) .. " " .. MONTHS.fr[m] .. " " .. y end
  if lang == "ar" then return d .. " " .. MONTHS.ar[m] .. " " .. y end
  return MONTHS.en[m] .. " " .. d .. ", " .. y
end

local function reading_minutes(doc)
  local words = 0
  doc:walk({
    Str = function(s) if s.text:find("[^%p%s]") then words = words + 1 end end,
    CodeBlock = function(cb) words = words + math.floor(#cb.text / 40) end,
  })
  return math.max(1, math.ceil(words / WPM))
end

local function span(cls, inner, attrs)
  return '<span class="' .. cls .. '"' .. (attrs or "") .. ">" .. inner .. "</span>"
end

-- URL relative depuis la page courante vers un chemin de la racine du site.
local function rel_to(ctx, target)
  if target:match("^%a[%w+.-]*:") or target:sub(1, 2) == "//" or target:sub(1, 1) == "#" then return target end
  return ctx.up .. target
end

local function ext_attrs(href)
  if href:match("^https?://") then return ' target="_blank" rel="noopener"' end
  return ""
end

local ICON_PDF = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><path d="M6 3h9l4 4v14H6z"/><path d="M15 3v5h5"/></svg>'
local ICON_DATA = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><ellipse cx="12" cy="6" rx="7" ry="3"/><path d="M5 6v6c0 1.7 3.1 3 7 3s7-1.3 7-3V6M5 12v6c0 1.7 3.1 3 7 3s7-1.3 7-3v-6"/></svg>'
local ICON_CODE = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><path d="m8 8-5 4 5 4M16 8l5 4-5 4M14 5l-4 14"/></svg>'
local ICON_BIB = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><path d="M5 4h11a3 3 0 0 1 3 3v13H8a3 3 0 0 1-3-3V4z"/><path d="M9 9h6M9 13h6"/></svg>'

---------------------------------------------------------------------------
-- Cartes (même structure que les cartes de la liste du Blog)
---------------------------------------------------------------------------
local function type_label(lbl, ty)
  if ty == "tutoriel" then return lbl.tutorial end
  if ty == "note" then return lbl.note end
  if ty == "annonce" then return lbl.announcement end
  return lbl.essay
end

local function card_html(ctx, lbl, rec)
  local href = ctx.up .. rec.href
  local pills = {}
  for _, k in ipairs(rec.categories) do pills[#pills + 1] = '<span class="wcard-cat">' .. esc(cat_label(ctx.cats, k, rec.lang)) .. "</span>" end
  return table.concat({
    '<a class="gcard wcard" href="', esc(href), '">',
    '<div class="gcard-eyebrow-row"><span class="gcard-cat">', esc(type_label(lbl, rec.type)), "</span></div>",
    '<h3 lang="', rec.lang, '">', escp(rec.title), "</h3>",
    '<p lang="', rec.lang, '">', escp(rec.description or ""), "</p>",
    '<div class="wcard-meta"><time datetime="', esc(rec.date), '">', esc(fmt_date(rec.date, rec.lang)), "</time>",
    #pills > 0 and ('<span class="wcard-cats">' .. table.concat(pills) .. "</span>") or "", "</div>",
    '<span class="gcard-more">', esc(lbl.read), ' <span class="arrow">&rarr;</span></span>',
    "</a>",
  })
end

---------------------------------------------------------------------------
-- Blocs HTML
---------------------------------------------------------------------------
local function list_html(items, cls)
  local li = {}
  for _, it in ipairs(items) do li[#li + 1] = "<li>" .. escp(it) .. "</li>" end
  return '<ul class="' .. cls .. '">' .. table.concat(li) .. "</ul>"
end

local function header_html(c)
  local lbl, fm = c.lbl, c.fm
  local h = {}
  h[#h + 1] = '<header class="art-head">'
  local back = c.section == "essais" and lbl.back_essais or lbl.back_blog
  h[#h + 1] = '<nav class="art-crumb" aria-label="' .. esc(back) .. '"><a href="' .. c.back_up .. 'index.html">' .. (c.rtl and "→ " or "← ") .. esc(back) .. "</a></nav>"

  -- type · série
  local kicker = { '<span class="post-cat">' .. esc(type_label(lbl, c.ty)) .. "</span>" }
  if c.series then
    local s = c.series
    local txt = lbl.series .. " « " .. (s.title or s.id) .. " »"
    if s.total and s.total > 1 then txt = txt .. " — " .. lbl.episode .. " " .. s.part .. " " .. lbl.of .. " " .. s.total end
    kicker[#kicker + 1] = '<span class="art-series">' .. esc(txt) .. "</span>"
  end
  h[#h + 1] = '<p class="art-kicker">' .. table.concat(kicker) .. "</p>"

  h[#h + 1] = '<h1 class="title art-title">' .. escp(fm.title) .. "</h1>"
  if fm.subtitle and fm.subtitle ~= "" then h[#h + 1] = '<p class="art-subtitle">' .. escp(fm.subtitle) .. "</p>" end

  -- Catégories : badges juste sous le titre (chaque badge ouvre la liste filtrée).
  local cats = as_list(fm.categories)
  if #cats > 0 then
    local pills = {}
    for _, cat in ipairs(cats) do
      local name = tostring(cat)
      pills[#pills + 1] = '<a class="art-cat" href="' .. c.back_up .. "index.html#cat=" .. url_enc(name) .. '">' .. esc(cat_label(c.cats, name, c.lang)) .. "</a>"
    end
    h[#h + 1] = '<p class="art-cats art-cats-top" aria-label="' .. esc(lbl.categories) .. '">' .. table.concat(pills) .. "</p>"
  end

  -- Bandeau d'informations, comme le bloc titre de Quarto : auteur · date · lecture · catégories.
  local function item(label, value, cls)
    return '<div class="art-by' .. (cls and (" " .. cls) or "") .. '"><span class="art-by-l">' .. esc(label) .. '</span><span class="art-by-v">' .. value .. "</span></div>"
  end
  local by = {}
  local author_html = esc(c.author)
  if c.author == DEFAULT_AUTHOR then
    author_html = '<a class="art-author" href="' .. c.up .. 'index.html">' .. author_html .. "</a>"
  else
    author_html = '<span class="art-author">' .. author_html .. "</span>"
  end
  local avatar = ""
  if c.author == DEFAULT_AUTHOR then
    avatar = '<img class="art-avatar" src="' .. c.up .. 'assets/img/AbdelH-176.webp" alt="" width="40" height="40" loading="lazy" decoding="async">'
  end
  by[#by + 1] = '<div class="art-by art-by-author">' .. avatar .. '<div class="art-by-text"><span class="art-by-l">' .. esc(lbl.author) .. '</span><span class="art-by-v">' .. author_html .. "</span></div></div>"
  by[#by + 1] = item(lbl.published, '<time datetime="' .. c.date .. '">' .. esc(fmt_date(c.date, c.lang)) .. "</time>")
  if c.modified and c.modified ~= c.date then
    by[#by + 1] = item(lbl.updated, '<time datetime="' .. c.modified .. '">' .. esc(fmt_date(c.modified, c.lang)) .. "</time>")
  end
  by[#by + 1] = item(lbl.reading, c.minutes .. " " .. esc(lbl.min_read))
  h[#h + 1] = '<div class="art-byline">' .. table.concat(by) .. "</div>"

  -- traductions
  if c.is_translation then
    local o = c.orig
    local human = (fm.translation and fm.translation.method == "human")
    local txt = string.format(lbl.translation_of, LANGNAME[c.lang][o.lang] or o.lang)
    local how = human and lbl.human or lbl.machine
    if fm.translation and fm.translation.by then how = how .. " — " .. string.format(lbl.by, fm.translation.by) end
    h[#h + 1] = '<div class="art-translation" role="note"><span class="art-translation-t">' .. esc(lbl.translation) .. "</span> " .. esc(txt) .. " " .. esc(how) .. '. <a href="../index.html" hreflang="' .. o.lang .. '">' .. esc(lbl.read_original) .. "</a></div>"
  elseif #c.translations > 0 then
    local links = {}
    for _, code in ipairs(c.translations) do
      links[#links + 1] = '<a href="' .. code .. '/index.html" hreflang="' .. code .. '" lang="' .. code .. '">' .. ENDONYM[code] .. "</a>"
    end
    h[#h + 1] = '<p class="art-also">' .. esc(lbl.also_in) .. " " .. table.concat(links, " · ") .. "</p>"
  end

  h[#h + 1] = "</header>"
  return table.concat(h)
end

local function tutorial_boxes_html(c)
  local lbl, fm = c.lbl, c.fm
  local out = { '<div class="art-boxes">' }
  local pre = as_list(fm.prerequisites)
  local learn = as_list(fm["learning-outcomes"])
  out[#out + 1] = '<div class="art-box"><p class="art-box-label">' .. esc(lbl.prerequisites) .. "</p>" .. list_html(pre, "art-box-list") .. "</div>"
  out[#out + 1] = '<div class="art-box"><p class="art-box-label">' .. esc(lbl.learn) .. "</p>" .. list_html(learn, "art-box-list") .. "</div>"
  out[#out + 1] = "</div>"
  local extra = {}
  if fm.level then
    local lv = ({ ["débutant"] = "beginner", beginner = "beginner", ["intermédiaire"] = "intermediate", intermediate = "intermediate", ["avancé"] = "advanced", advanced = "advanced" })[tostring(fm.level):lower()]
    extra[#extra + 1] = '<span class="art-fact"><span class="art-fact-k">' .. esc(lbl.level) .. "</span> " .. esc(lv and lbl[lv] or fm.level) .. "</span>"
  end
  if fm.repo then
    extra[#extra + 1] = '<a class="link-btn" href="' .. esc(fm.repo) .. '" target="_blank" rel="noopener">' .. ICON_CODE .. esc(lbl.repo) .. "</a>"
  end
  if #extra > 0 then out[#out + 1] = '<p class="art-facts">' .. table.concat(extra) .. "</p>" end
  return table.concat(out)
end

local function note_fiche_html(c)
  local lbl, fm, refs = c.lbl, c.fm, c.refs
  local rows = {}
  local p = refs[fm.project]
  rows[#rows + 1] = '<div><dt>' .. esc(lbl.project) .. '</dt><dd><a href="' .. esc(rel_to(c, p.href)) .. '"' .. ext_attrs(p.href) .. ">" .. escp(p["title-" .. c.lang] or p.title) .. "</a></dd></div>"
  local langs = {}
  for _, l in ipairs(as_list(fm["languages-studied"])) do langs[#langs + 1] = esc(l) end
  rows[#rows + 1] = "<div><dt>" .. esc(lbl.languages) .. "</dt><dd>" .. table.concat(langs, ", ") .. "</dd></div>"
  if fm.status then
    local st = lbl[tostring(fm.status)] or tostring(fm.status)
    rows[#rows + 1] = "<div><dt>" .. esc(lbl.status) .. "</dt><dd>" .. esc(st) .. "</dd></div>"
  end
  local out = { '<div class="art-fiche"><dl>' .. table.concat(rows) .. "</dl>" }
  local links = type(fm.links) == "table" and fm.links or {}
  local btns = {}
  local function btn(key, icon, label)
    local href = links[key]
    if href and href ~= "" then
      -- fichier local : chemin relatif à l'article ; lien externe : tel quel
      btns[#btns + 1] = '<a class="link-btn" href="' .. esc(href) .. '"' .. ext_attrs(tostring(href)) .. ">" .. icon .. esc(label) .. "</a>"
    end
  end
  btn("pdf", ICON_PDF, lbl.pdf)
  btn("dataset", ICON_DATA, lbl.dataset)
  btn("code", ICON_CODE, lbl.code)
  btn("bibtex", ICON_BIB, lbl.bibtex)
  if #btns > 0 then out[#out + 1] = '<div class="link-btn-row">' .. table.concat(btns) .. "</div>" end
  out[#out + 1] = "</div>"
  return table.concat(out)
end

local function annonce_fiche_html(c)
  local lbl, fm = c.lbl, c.fm
  local ev = fm.event
  local out = {}
  if type(ev) == "table" and ev.name then
    local rows = { "<div><dt>" .. esc(lbl.event) .. "</dt><dd>" .. esc(ev.name) .. "</dd></div>" }
    if ev.date then rows[#rows + 1] = '<div><dt></dt><dd><time datetime="' .. esc(ev.date) .. '">' .. esc(fmt_date(ev.date, c.lang)) .. "</time>" .. (ev.place and (" — " .. esc(ev.place)) or "") .. "</dd></div>" end
    out[#out + 1] = '<div class="art-fiche"><dl>' .. table.concat(rows) .. "</dl></div>"
  end
  return table.concat(out)
end

local function updates_html(c)
  local ups = as_list(c.fm.updates)
  if #ups == 0 then return "" end
  local li = {}
  for _, u in ipairs(ups) do
    if type(u) == "table" and u.date and u.note then
      li[#li + 1] = '<li><time datetime="' .. esc(u.date) .. '">' .. esc(fmt_date(u.date, c.lang)) .. "</time> — " .. escp(u.note) .. "</li>"
    end
  end
  if #li == 0 then return "" end
  return '<section class="art-updates" aria-labelledby="corrections"><h2 id="corrections" class="art-h2">' .. esc(c.lbl.corrections) .. "</h2><ul>" .. table.concat(li) .. "</ul></section>"
end

local SH_ICON = {
  linkedin = '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M20.45 20.45h-3.56v-5.57c0-1.33-.02-3.04-1.85-3.04-1.86 0-2.14 1.45-2.14 2.94v5.67H9.34V9h3.42v1.56h.05c.48-.9 1.64-1.85 3.38-1.85 3.61 0 4.28 2.38 4.28 5.47v6.27ZM5.34 7.43a2.07 2.07 0 1 1 0-4.14 2.07 2.07 0 0 1 0 4.14ZM7.12 20.45H3.56V9h3.56v11.45Z"/></svg>',
  x = '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>',
  whatsapp = '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12.04 2a9.9 9.9 0 0 0-8.4 15.1L2 22l5.05-1.6A9.9 9.9 0 1 0 12.04 2Zm0 18.1c-1.5 0-2.9-.4-4.1-1.1l-.3-.2-3 .9.9-2.9-.2-.3a8.1 8.1 0 1 1 6.7 3.6Zm4.5-6c-.25-.12-1.46-.72-1.69-.8-.23-.09-.39-.12-.56.12-.16.25-.64.8-.78.97-.14.16-.29.18-.53.06-.25-.12-1.04-.38-1.98-1.22-.73-.65-1.22-1.46-1.37-1.7-.14-.25-.02-.38.1-.5.11-.11.25-.29.37-.43.12-.15.16-.25.25-.41.08-.17.04-.31-.02-.43-.06-.12-.56-1.34-.76-1.84-.2-.48-.4-.41-.56-.42h-.47c-.16 0-.43.06-.65.31-.23.25-.86.84-.86 2.05s.88 2.38 1 2.55c.12.16 1.73 2.64 4.2 3.7.59.26 1.05.41 1.4.52.59.19 1.13.16 1.55.1.47-.07 1.46-.6 1.66-1.17.2-.58.2-1.07.14-1.17-.06-.1-.23-.16-.47-.29Z"/></svg>',
  facebook = '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M13.5 22v-8.2h2.8l.42-3.2H13.5V8.56c0-.93.26-1.56 1.6-1.56h1.7V4.14A22.6 22.6 0 0 0 14.33 4C11.9 4 10.25 5.48 10.25 8.2v2.4H7.5v3.2h2.75V22h3.25Z"/></svg>',
  mail = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round" aria-hidden="true"><path d="M4 5h16v14H4z"/><path d="m4 6 8 7 8-7"/></svg>',
  link = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M10 14a4 4 0 0 0 5.66 0l3-3a4 4 0 0 0-5.66-5.66l-1 1"/><path d="M14 10a4 4 0 0 0-5.66 0l-3 3a4 4 0 0 0 5.66 5.66l1-1"/></svg>',
  share = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="18" cy="5" r="2.6"/><circle cx="6" cy="12" r="2.6"/><circle cx="18" cy="19" r="2.6"/><path d="m8.3 10.7 7.4-4.3M8.3 13.3l7.4 4.3"/></svg>',
}

-- Partage : réseaux sociaux, e-mail, copie du lien. `compact` = icônes seules (colonne du sommaire).
local function share_html(c, compact)
  local lbl = c.lbl
  local url = c.canonical
  local enc = url_enc(url)
  local ttl = url_enc(c.fm.title)
  local function net(key, name, href)
    return '<a class="sb sb-net sb-' .. key .. '" href="' .. href .. '" target="_blank" rel="noopener" aria-label="' .. esc(lbl.share_on .. " " .. name) .. '" title="' .. esc(name) .. '">' .. SH_ICON[key] .. '<span class="sb-t">' .. esc(name) .. "</span></a>"
  end
  return table.concat({
    '<nav class="sbar art-share', compact and " art-share-compact" or "", '" role="none" data-copied="', esc(lbl.copied), '">',
    '<span class="sbar-label"><strong>', esc(lbl.share), "</strong></span>",
    '<button class="sb sb-native" type="button" hidden data-title="', esc(c.fm.title), '" data-url="', esc(url), '">', SH_ICON.share, '<span class="sb-t">', esc(lbl.share_native), "</span></button>",
    net("linkedin", "LinkedIn", "https://www.linkedin.com/sharing/share-offsite/?url=" .. enc),
    net("x", "X", "https://twitter.com/intent/tweet?text=" .. ttl .. "&amp;url=" .. enc),
    net("whatsapp", "WhatsApp", "https://wa.me/?text=" .. ttl .. "%20" .. enc),
    net("facebook", "Facebook", "https://www.facebook.com/sharer/sharer.php?u=" .. enc),
    net("mail", lbl.mail, "mailto:?subject=" .. ttl .. "&amp;body=" .. enc),
    '<button class="sb sb-copy" type="button" data-url="', esc(url), '" title="', esc(lbl.copy_link), '">', SH_ICON.link, '<span class="sb-t">', esc(lbl.copy_link), "</span></button>",
    "</nav>",
  })
end

-- Précédent / Suivant, aux deux extrémités : épisodes d'une série, sinon articles de la même
-- rubrique dans l'ordre chronologique (précédent = publié avant, suivant = publié après).
-- Une traduction pointe vers la traduction du voisin quand elle existe.
local function neighbours(c)
  local prev, next_ = nil, nil
  local label_p, label_n = c.lbl.prev, c.lbl.next
  if c.series and (c.series.prev or c.series.next) then
    prev, next_ = c.series.prev, c.series.next
    label_p, label_n = c.lbl.prev_ep, c.lbl.next_ep
  else
    local sect = {}
    for _, a in ipairs(c.articles) do if a.section == c.section then sect[#sect + 1] = a end end
    -- c.articles est trié par date décroissante : le voisin « suivant » (plus récent) est avant.
    for i, a in ipairs(sect) do
      if a.rel == c.section .. "/" .. c.slug then
        next_ = sect[i - 1]
        prev = sect[i + 1]
        break
      end
    end
  end
  return prev, next_, label_p, label_n
end

local function pager_html(c)
  local prev, next_, label_p, label_n = neighbours(c)
  if not prev and not next_ then return "" end
  local la, ra = "&larr; ", " &rarr;"
  if c.rtl then la, ra = "&rarr; ", " &larr;" end
  local function item(rec, label, is_next)
    if not rec then return '<div class="pn-empty"></div>' end
    local lang, href = rec.lang, c.up .. rec.href
    local ttl = rec.title
    -- traduction du voisin dans la langue de cette page, si elle existe
    if c.lang ~= rec.lang then
      for _, code in ipairs(rec.translations) do
        if code == c.lang then
          local tfm = front_matter(read_file(c.ctx.root .. "/" .. rec.rel .. "/" .. code .. "/index.qmd"))
          if tfm.title then lang, href, ttl = code, c.up .. rec.rel .. "/" .. code .. "/index.html", tfm.title end
        end
      end
    end
    local arrowed = is_next and (esc(label) .. ra) or (la .. esc(label))
    return '<a class="pn' .. (is_next and " pn-r" or "") .. '" href="' .. esc(href) .. '" rel="' .. (is_next and "next" or "prev") .. '"><span class="pn-l">' .. arrowed .. '</span><strong lang="' .. lang .. '">' .. escp(ttl) .. "</strong></a>"
  end
  return '<nav class="pnav art-pnav" aria-label="' .. esc(c.lbl.prev .. " / " .. c.lbl.next) .. '">' .. item(prev, label_p, false) .. item(next_, label_n, true) .. "</nav>"
end

local function see_also_html(c)
  local items = as_list(c.fm["see-also"])
  if #items == 0 then return "" end
  local lbl, refs = c.lbl, c.refs
  local li = {}
  for _, it in ipairs(items) do
    local kind, title, href, tlang
    if it.ref then
      local r = refs[it.ref]
      kind = lbl["kind_" .. (r.kind or "external")] or lbl.kind_external
      title, href = r["title-" .. c.lang] or r.title, rel_to(c, r.href)
    elseif it.article then
      for _, a in ipairs(c.articles) do
        if a.rel == it.article then
          kind = a.type == "essai" and lbl.kind_essay or lbl.kind_article
          title, href, tlang = a.title, c.up .. a.href, a.lang
        end
      end
    else
      kind = lbl.kind_external
      title, href = it.title, rel_to(c, it.href)
    end
    if title then
      li[#li + 1] = '<li><span class="art-kind">' .. esc(kind) .. '</span><a href="' .. esc(href) .. '"' .. ext_attrs(href) .. (tlang and (' lang="' .. tlang .. '"') or "") .. ">" .. escp(title) .. "</a></li>"
    end
  end
  if #li == 0 then return "" end
  return '<nav class="art-seealso" role="none"><h2 id="seealso" class="art-h2">' .. esc(lbl.see_also) .. '</h2><ul class="art-seealso-list">' .. table.concat(li) .. "</ul></nav>"
end

local function related_html(c)
  local mine = {}
  for _, k in ipairs(as_list(c.fm.categories)) do mine[tostring(k)] = true end
  local scored = {}
  for _, a in ipairs(c.articles) do
    if a.rel ~= c.section .. "/" .. c.slug then
      local s = 0
      for _, k in ipairs(a.categories) do if mine[k] then s = s + 2 end end
      if s > 0 then
        if a.type == c.ty then s = s + 1 end
        scored[#scored + 1] = { rec = a, score = s }
      end
    end
  end
  if #scored == 0 then return "" end
  table.sort(scored, function(x, y)
    if x.score ~= y.score then return x.score > y.score end
    return x.rec.date > y.rec.date
  end)
  local cards = {}
  for i = 1, math.min(3, #scored) do cards[#cards + 1] = card_html(c, c.lbl, scored[i].rec) end
  return '<nav class="art-related" role="none"><h2 id="related" class="art-h2">' .. esc(c.lbl.related) .. '</h2><div class="grid art-related-grid">' .. table.concat(cards) .. "</div></nav>"
end

-- Sommaire latéral collant : construit ici (pas par Quarto) pour que la
-- mise en page, les libellés et le comportement RTL soient les mêmes quelle
-- que soit la version de Quarto. Actif par défaut (≥ 3 intertitres) ; `contents: false` le retire.
local function collect_headings(doc)
  local items = {}
  doc:walk({
    Header = function(h)
      if (h.level == 2 or h.level == 3) and h.identifier ~= "" and not h.classes:includes("unlisted") then
        items[#items + 1] = { level = h.level, id = h.identifier, text = stringify(h.content) }
      end
    end,
  })
  return items
end

local function toc_html(c, items)
  local li = {}
  for _, it in ipairs(items) do
    li[#li + 1] = '<li class="lv' .. it.level .. '"><a href="#' .. esc(it.id) .. '">' .. esc(it.text) .. "</a></li>"
  end
  -- <details> : toujours ouvert sur grand écran (writing.js), replié par défaut sur téléphone et tablette.
  return '<div class="art-toc-wrap"><div class="art-toc-sticky"><nav class="art-toc" aria-label="' .. esc(c.lbl.contents) .. '"><details open><summary class="art-toc-title">' .. esc(c.lbl.contents) .. "</summary><ol>" .. table.concat(li) .. "</ol></details></nav>" .. share_html(c, true) .. "</div></div>"
end

---------------------------------------------------------------------------
-- En-tête <head> : schema.org, hreflang, Open Graph
---------------------------------------------------------------------------
local function head_html(c)
  local h = {}
  local url = c.canonical
  -- La page est dans la langue de l'article, pas dans celle de l'interface :
  -- on (re)pose lang/dir sur <html> après le script qui restaure la langue
  -- d'interface, et on le signale à foot.html (window.__articleLang).
  h[#h + 1] = '<script>(function(d){d.setAttribute("lang","' .. c.lang .. '");d.setAttribute("dir","' .. (c.rtl and "rtl" or "ltr") .. '");window.__articleLang="' .. c.lang .. '";})(document.documentElement);</script>'
  h[#h + 1] = '<link rel="canonical" href="' .. esc(url) .. '">'
  h[#h + 1] = '<meta property="og:locale" content="' .. OG_LOCALE[c.lang] .. '">'
  local alts = {}
  if c.is_translation then
    alts[#alts + 1] = c.orig.lang
    for _, code in ipairs(c.orig_translations) do alts[#alts + 1] = code end
  else
    for _, code in ipairs(c.translations) do alts[#alts + 1] = code end
  end
  local base = c.site .. "/" .. c.section .. "/" .. c.slug .. (c.ctx.flat and ".html" or "/")
  local self_lang = c.lang
  local orig_lang = c.is_translation and c.orig.lang or c.lang
  h[#h + 1] = '<link rel="alternate" hreflang="' .. orig_lang .. '" href="' .. esc(base) .. '">'
  local all = c.is_translation and c.orig_translations or c.translations
  for _, code in ipairs(all) do
    h[#h + 1] = '<link rel="alternate" hreflang="' .. code .. '" href="' .. esc(base .. code .. "/") .. '">'
  end
  h[#h + 1] = '<link rel="alternate" hreflang="x-default" href="' .. esc(base) .. '">'
  for _, code in ipairs(alts) do
    if code ~= self_lang then h[#h + 1] = '<meta property="og:locale:alternate" content="' .. OG_LOCALE[code] .. '">' end
  end
  h[#h + 1] = '<meta property="article:published_time" content="' .. c.date .. '">'
  if c.modified then h[#h + 1] = '<meta property="article:modified_time" content="' .. c.modified .. '">' end
  h[#h + 1] = '<meta property="article:author" content="' .. esc(c.author) .. '">'
  for _, k in ipairs(as_list(c.fm.categories)) do h[#h + 1] = '<meta property="article:tag" content="' .. esc(k) .. '">' end

  local ld = {
    '"@context":"https://schema.org"', '"@type":"Article"',
    '"headline":' .. jstr(c.fm.title),
    '"description":' .. jstr(c.fm.description),
    '"inLanguage":' .. jstr(c.lang),
    '"datePublished":' .. jstr(c.date),
    '"dateModified":' .. jstr(c.modified or c.date),
    '"mainEntityOfPage":' .. jstr(url),
    '"url":' .. jstr(url),
    '"author":{"@type":"Person","name":' .. jstr(c.author) .. ',"url":' .. jstr(c.site) .. "}",
    '"publisher":{"@type":"Person","name":' .. jstr(DEFAULT_AUTHOR) .. ',"url":' .. jstr(c.site) .. "}",
  }
  local kw = {}
  for _, k in ipairs(as_list(c.fm.categories)) do kw[#kw + 1] = jstr(k) end
  ld[#ld + 1] = '"keywords":[' .. table.concat(kw, ",") .. "]"
  if c.fm.image and c.fm.image ~= "" then
    local img = tostring(c.fm.image)
    if not img:match("^https?://") then img = base .. img end
    ld[#ld + 1] = '"image":' .. jstr(img)
  else
    -- Même image par défaut que l'aperçu Open Graph (_quarto.yml) : Google la demande pour un `Article`.
    ld[#ld + 1] = '"image":' .. jstr(c.site .. "/assets/img/og-default.png")
  end
  if c.is_translation then ld[#ld + 1] = '"translationOfWork":{"@type":"Article","url":' .. jstr(base) .. "}" end
  h[#h + 1] = '<script type="application/ld+json">{' .. table.concat(ld, ",") .. "}</script>"
  return table.concat(h, "\n")
end

---------------------------------------------------------------------------
-- Pages de liste (accueil, blog/, essais/) : traductions disponibles
--
-- Les cartes de liste affichent l'original. Quand une traduction existe dans la
-- langue de l'interface, writing.js remplace titre/résumé/lien par ceux de la
-- traduction ; sinon il signale « Disponible en EN/FR ». Les titres et résumés
-- traduits sont donc fournis ici, au rendu, dans un bloc JSON.
---------------------------------------------------------------------------
local LISTING_PAGES = { ["index.qmd"] = true, ["blog/index.qmd"] = true, ["essais/index.qmd"] = true }

local function listing_context()
  local input = nil
  if quarto and quarto.doc and quarto.doc.input_file then input = quarto.doc.input_file end
  if not input then return nil end
  input = abs_input(input)
  local root = find_root(input)
  if not root then return nil end
  local rel = input:sub(#root + 2)
  rel = rel:gsub("index%.[%w%.]+$", "index.qmd")
  if not LISTING_PAGES[rel] then return nil end
  return { root = root, rel = rel }
end

local function translations_json(root)
  local parts = {}
  for _, a in ipairs(scan_articles(root)) do
    if #a.translations > 0 then
      local tr = {}
      for _, code in ipairs(a.translations) do
        local fm = front_matter(read_file(root .. "/" .. a.rel .. "/" .. code .. "/index.qmd"))
        if fm.title then
          tr[#tr + 1] = jstr(code) .. ":{" .. '"t":' .. jstr(fm.title) .. ',"d":' .. jstr(fm.description or "") .. "}"
        end
      end
      if #tr > 0 then
        parts[#parts + 1] = jstr(a.rel) .. ":{" .. '"lang":' .. jstr(a.lang) .. ',"tr":{' .. table.concat(tr, ",") .. "}}"
      end
    end
  end
  -- Libellés des thèmes (data/categories.yml) : clé réservée « _cats ».
  local cats = load_cats(root)
  local cp = {}
  for name, e in pairs(cats) do
    if type(e) == "table" then
      local ls = {}
      for code, label in pairs(e) do ls[#ls + 1] = jstr(code) .. ":" .. jstr(label) end
      table.sort(ls)
      cp[#cp + 1] = jstr(name) .. ":{" .. table.concat(ls, ",") .. "}"
    end
  end
  table.sort(cp)
  parts[#parts + 1] = '"_cats":{' .. table.concat(cp, ",") .. "}"
  return "{" .. table.concat(parts, ",") .. "}"
end

local function listing_pass(doc, lctx)
  local blocks = {}
  for _, b in ipairs(doc.blocks) do blocks[#blocks + 1] = b end
  blocks[#blocks + 1] = pandoc.RawBlock("html", '<script type="application/json" id="writing-i18n">' .. translations_json(lctx.root) .. "</script>")
  -- L'auteur par défaut de blog/ et essais/ (_metadata.yml) est destiné aux articles :
  -- sur les pages de liste il imprimerait un « bloc auteur » sous le titre.
  local meta = doc.meta
  meta.author = nil
  return pandoc.Pandoc(blocks, meta)
end

---------------------------------------------------------------------------
-- Filtre principal
---------------------------------------------------------------------------

-- Pages écrites en blocs HTML bruts (Accueil, Recherche, Projets, CV…) : pandoc n'y applique pas
-- la typographie. On remplace l'apostrophe droite par ’ dans le texte seulement (jamais dans
-- les balises, <script>, <style>, <code>, <pre>), pour que le français soit typographié partout.
local RAW_SKIP = { script = true, style = true, pre = true, code = true, textarea = true }
local function typo_html(html)
  local out, pos, skip = {}, 1, 0
  while pos <= #html do
    local a, b = html:find("<[^>]*>", pos)
    local text = html:sub(pos, (a or (#html + 1)) - 1)
    if skip == 0 then text = text:gsub("([%w\128-\255])'", "%1\u{2019}") end
    out[#out + 1] = text
    if not a then break end
    local tag = html:sub(a, b)
    out[#out + 1] = tag
    local closing, name = tag:match("^<(/?)([%w]+)")
    if name and RAW_SKIP[name:lower()] and not tag:match("/>$") then
      if closing == "/" then skip = math.max(0, skip - 1) else skip = skip + 1 end
    end
    pos = b + 1
  end
  return table.concat(out)
end

local function typo_doc(doc)
  return doc:walk({
    RawBlock = function(el)
      if el.format == "html" and el.text:find("'", 1, true) then
        return pandoc.RawBlock("html", typo_html(el.text))
      end
    end,
  })
end

function Pandoc(doc)
  local ctx = article_context()
  if not ctx then
    local lctx = listing_context()
    if lctx then return typo_doc(listing_pass(doc, lctx)) end
    return typo_doc(doc)
  end

  local refs = load_refs(ctx.root)
  local articles = scan_articles(ctx.root)
  local fm = front_matter(read_file(ctx.input))

  -- Traduction : on hérite du front matter de l'original pour ce qui manque.
  local orig_fm = nil
  if ctx.tlang then
    orig_fm = front_matter(read_file(ctx.root .. "/" .. ctx.section .. "/" .. ctx.slug .. "/index.qmd"))
    -- Seuls les champs « neutres » (dates, thèmes, projet, liens…) sont hérités.
    -- Titre, résumé, prérequis, sources, journal de corrections : à fournir dans la langue.
    local INHERIT = { date = 1, ["date-modified"] = 1, type = 1, categories = 1, image = 1, project = 1,
      ["languages-studied"] = 1, level = 1, links = 1, repo = 1, status = 1, ["see-also"] = 1,
      author = 1, event = 1 }
    setmetatable(fm, { __index = function(_, k)
      if INHERIT[k] then return orig_fm[k] end
      return nil
    end })
  end

  local ty = validate(ctx, fm, orig_fm, refs, articles)

  -- Un essai doit citer au moins une source (ou en lister via `nocite`) : sinon la section
  -- « Sources et références » serait publiée vide.
  if ty == "essai" then
    local cited = (doc.meta.nocite ~= nil)
    if not cited then
      doc:walk({ Cite = function() cited = true end })
    end
    if not cited then
      fail(ctx, "l'essai ne cite aucune source : citer dans le texte avec [@cle] (clés de sources.bib) ou lister des sources avec `nocite:`")
    end
  end

  local lang = fm.lang
  local c = {
    ctx = ctx, section = ctx.section, slug = ctx.slug, up = ctx.up, back_up = ctx.back_up, rel = ctx.rel,
    fm = fm, lang = lang, lbl = L[lang], rtl = (lang == "ar"), ty = ty,
    refs = refs, articles = articles, cats = load_cats(ctx.root),
    author = fm.author and tostring(fm.author) or DEFAULT_AUTHOR,
    date = tostring(fm.date), modified = fm["date-modified"] and tostring(fm["date-modified"]) or nil,
    minutes = reading_minutes(doc),
    translations = as_list(fm.translations),
    is_translation = ctx.tlang ~= nil,
    site = site_url(ctx.root) or "",
  }
  if c.is_translation then
    c.orig = { lang = orig_fm.lang or "fr" }
    c.orig_translations = as_list(orig_fm.translations)
  end
  if ctx.flat then
    c.canonical = c.site .. "/" .. ctx.section .. "/" .. ctx.slug .. ".html"
  else
    c.canonical = c.site .. "/" .. ctx.section .. "/" .. ctx.slug .. "/" .. (ctx.tlang and (ctx.tlang .. "/") or "")
  end

  -- Série : épisode précédent / suivant, et nombre total d'épisodes.
  if fm.series and not c.is_translation then
    local sid = tostring(fm.series.id)
    local eps = {}
    for _, a in ipairs(articles) do
      if a.series and a.series.id == sid and a.lang == lang then eps[#eps + 1] = a end
    end
    table.sort(eps, function(x, y) return x.series.part < y.series.part end)
    local me = tonumber(fm.series.part)
    local s = { id = sid, title = fm.series.title, part = me, total = #eps }
    for _, a in ipairs(eps) do
      if a.series.part < me then s.prev = a end
      if a.series.part > me and not s.next then s.next = a end
    end
    c.series = s
  end

  -- Notes de bas de page : Quarto les rejette hors de l'article (sous « Articles liés »,
  -- sur toute la largeur). On les rassemble ici, dans une section « Notes » placée à la
  -- fin du texte, dans la colonne de lecture.
  local notes = {}
  doc = doc:walk({
    Note = function(n)
      local k = #notes + 1
      notes[k] = n.content
      return pandoc.Superscript({
        pandoc.Link({ pandoc.Str(tostring(k)) }, "#fn-" .. k, "",
          pandoc.Attr("fnref-" .. k, { "footnote-ref" }, { role = "doc-noteref" })),
      })
    end,
  })

  -- Tableaux : conteneur défilant, focalisable au clavier.
  local tlabel = c.lbl.table
  doc = doc:walk({
    Table = function(t)
      return {
        pandoc.RawBlock("html", '<div class="table-scroll" tabindex="0" role="region" aria-label="' .. esc(tlabel) .. '">'),
        t,
        pandoc.RawBlock("html", "</div>"),
      }
    end,
    Div = function(d)
      if d.classes:includes("pullquote") then
        d.attributes.role = "note"
        return d
      end
    end,
  })

  local out = {}
  local function raw(s) if s and s ~= "" then out[#out + 1] = pandoc.RawBlock("html", s) end end

  -- Sommaire à droite : par défaut pour tout article qui a au moins 3 intertitres ;
  -- `contents: false` le retire. On y ajoute les sections finales (notes, sources, corrections, voir aussi).
  local toc_items = {}
  if fm.contents ~= false then
    toc_items = collect_headings(doc)
    if #toc_items < 3 then
      toc_items = {}
    else
      if #notes > 0 then toc_items[#toc_items + 1] = { level = 2, id = "notes-h", text = c.lbl.notes } end
      if doc.meta.bibliography ~= nil then toc_items[#toc_items + 1] = { level = 2, id = "sources", text = c.lbl.sources } end
      if #as_list(fm.updates) > 0 then toc_items[#toc_items + 1] = { level = 2, id = "corrections", text = c.lbl.corrections } end
      if #as_list(fm["see-also"]) > 0 then toc_items[#toc_items + 1] = { level = 2, id = "seealso", text = c.lbl.see_also } end
    end
  end
  raw('<div class="article-body art-' .. ty .. (#toc_items > 0 and " has-toc" or "") .. '" lang="' .. lang .. '" dir="' .. (c.rtl and "rtl" or "ltr") .. '" translate="no" data-article-lang="' .. lang .. '" data-article-type="' .. ty .. '" data-translations="' .. table.concat(c.is_translation and { c.orig.lang } or c.translations, ",") .. '" data-section="' .. ctx.section .. '">')
  raw(header_html(c))
  if not c.is_translation then
    raw('<div class="lang-note" role="note" hidden></div>')
  end
  if ty == "tutoriel" then raw(tutorial_boxes_html(c)) end
  if ty == "note" then raw(note_fiche_html(c)) end
  if ty == "annonce" then raw(annonce_fiche_html(c)) end
  if #toc_items > 0 then raw(toc_html(c, toc_items)) end

  raw('<div class="art-content">')
  for _, b in ipairs(doc.blocks) do out[#out + 1] = b end
  raw("</div>")

  if #notes > 0 then
    raw('<section class="art-notes" aria-labelledby="notes-h"><h2 id="notes-h" class="art-h2">' .. esc(c.lbl.notes) .. "</h2><ol>")
    for k, blocks in ipairs(notes) do
      local bl = pandoc.List(blocks)
      local back = pandoc.Link({ pandoc.Str("\u{21A9}\u{FE0E}") }, "#fnref-" .. k, "",
        pandoc.Attr("", { "footnote-back" }, { role = "doc-backlink", ["aria-label"] = c.lbl.back_to_text }))
      local last = bl[#bl]
      if last and (last.t == "Para" or last.t == "Plain") then
        last.content:insert(pandoc.Space())
        last.content:insert(back)
      else
        bl:insert(pandoc.Plain({ back }))
      end
      raw('<li id="fn-' .. k .. '">')
      for _, b in ipairs(bl) do out[#out + 1] = b end
      raw("</li>")
    end
    raw("</ol></section>")
  end

  if doc.meta.bibliography ~= nil then
    raw('<section class="art-sources" aria-labelledby="sources"><h2 id="sources" class="art-h2">' .. esc(c.lbl.sources) .. "</h2>")
    out[#out + 1] = pandoc.Div({}, pandoc.Attr("refs", {}, {}))
    raw("</section>")
  end
  raw(updates_html(c))
  raw(share_html(c, false))
  raw(pager_html(c))
  raw(see_also_html(c))
  raw(related_html(c))
  raw("</div>")

  if quarto and quarto.doc and quarto.doc.include_text then
    quarto.doc.include_text("in-header", head_html(c))
  end

  -- Le bloc titre natif (titre / chapeau / auteur / date) est remplacé par notre
  -- en-tête : on retire ces clés du modèle pandoc pour ne pas le dupliquer.
  -- `pagetitle` garde le <title> de l'onglet.
  -- On garde `title` : Quarto s'en sert pour <title>, la recherche et le titre
  -- de chaque entrée des flux RSS (il le lit dans #title-block-header h1.title).
  -- Ce bloc natif est masqué en CSS (writing.css) : notre en-tête le remplace.
  local meta = doc.meta
  if meta.title ~= nil then meta.pagetitle = meta.pagetitle or meta.title end
  meta.subtitle, meta.author, meta.date = nil, nil, nil
  return pandoc.Pandoc(out, meta)
end
