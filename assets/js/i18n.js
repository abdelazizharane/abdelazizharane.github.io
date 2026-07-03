/* ══════════════════════════════════════════════════════════════
   i18n.js — Système trilingue FR / EN / AR
   Abdel-aziz Harane · Chad AI Network
   ══════════════════════════════════════════════════════════════ */

const TRANSLATIONS = {

  /* ── Sidebar / Nav ─────────────────────────────────────────── */
  "nav-about":    { fr: "About",    en: "About",    ar: "نبذة" },
  "nav-blog":     { fr: "Blog",     en: "Blog",     ar: "مدوّنة" },
  "nav-articles": { fr: "Articles", en: "Articles", ar: "مقالات" },

  /* ── Profil ─────────────────────────────────────────────────── */
  "greeting":     {
    fr: "Chercheur & Bâtisseur",
    en: "Researcher & Builder",
    ar: "باحث ومبتكر"
  },
  "bio": {
    fr: `ML/NLP Engineer et fondateur du <strong>Chad AI Network</strong> — je construis l'infrastructure numérique pour les langues africaines sous-dotées, avec un focus sur le Tchad : Speech AI, traduction automatique, documentation linguistique et souveraineté des données communautaires.`,
    en: `ML/NLP Engineer and founder of <strong>Chad AI Network</strong> — I build digital infrastructure for under-resourced African languages, focusing on Chad: Speech AI, machine translation, linguistic documentation, and community data sovereignty.`,
    ar: `مهندس معالجة لغات طبيعية ومؤسس <strong>شبكة تشاد للذكاء الاصطناعي</strong> — أبني البنية التحتية الرقمية للغات الأفريقية المهددة بالاندثار، مع التركيز على تشاد: الذكاء الاصطناعي الصوتي، الترجمة الآلية، التوثيق اللغوي وسيادة البيانات المجتمعية.`
  },
  "location":     { fr: "N'Djaména, Tchad", en: "N'Djamena, Chad", ar: "نجامينا، تشاد" },
  "open-collab":  { fr: "Open to collaborations", en: "Open to collaborations", ar: "متاح للتعاون" },

  /* ── Tags ───────────────────────────────────────────────────── */
  "tag-speech":   { fr: "Speech AI", en: "Speech AI", ar: "ذكاء اصطناعي صوتي" },
  "tag-nlp":      { fr: "NLP", en: "NLP", ar: "معالجة اللغة" },
  "tag-chadian":  { fr: "Langues tchadiennes", en: "Chadian Languages", ar: "لغات تشادية" },
  "tag-riem":     { fr: "Géométrie Riemannienne", en: "Riemannian Geometry", ar: "هندسة ريمانية" },
  "tag-laal":     { fr: "Laal · isolat", en: "Laal · isolate", ar: "لال · لغة معزولة" },
  "tag-open":     { fr: "Open Science", en: "Open Science", ar: "علم مفتوح" },

  /* ── Projet en cours ────────────────────────────────────────── */
  "fp-label":     { fr: "🔭 Projet en cours", en: "🔭 Ongoing project", ar: "🔭 مشروع جارٍ" },
  "fp-title":     { fr: "NLP for Chadian Languages", en: "NLP for Chadian Languages", ar: "معالجة اللغة الطبيعية للغات التشادية" },
  "fp-desc":      {
    fr: "Ressources NLP, corpus et modèles pour les langues tchadiennes — Sara, Laal, Arabe tchadien et 120+ autres langues.",
    en: "NLP resources, corpora and models for Chadian languages — Sara, Laal, Chadian Arabic and 120+ other languages.",
    ar: "موارد معالجة اللغة الطبيعية والمدوّنات والنماذج للغات التشادية — السارا، اللال، العربية التشادية و120+ لغة أخرى."
  },
  "fp-btn":       { fr: "Voir le projet ↗", en: "View project ↗", ar: "عرض المشروع ↗" },

  /* ── Sections Home ──────────────────────────────────────────── */
  "s-research":   { fr: "Domaines de recherche", en: "Research Areas", ar: "مجالات البحث" },
  "s-projects":   { fr: "Projets phares", en: "Featured Projects", ar: "المشاريع الرئيسية" },
  "s-collabs":    { fr: "Collaborations & Partenaires", en: "Collaborations & Partners", ar: "التعاونات والشراكات" },

  /* ── Research cards ─────────────────────────────────────────── */
  "r1-title":  { fr: "Speech AI & ASR", en: "Speech AI & ASR", ar: "الذكاء الاصطناعي الصوتي" },
  "r1-desc":   { fr: "Reconnaissance automatique de la parole pour les langues tonales tchadiennes — Wav2Vec 2.0, Whisper, corpus audio.", en: "Automatic speech recognition for Chadian tonal languages — Wav2Vec 2.0, Whisper, audio corpora.", ar: "التعرف الآلي على الكلام للغات التشادية النغمية — Wav2Vec 2.0 وWhisper والمدوّنات الصوتية." },
  "r2-title":  { fr: "Traduction Automatique", en: "Machine Translation", ar: "الترجمة الآلية" },
  "r2-desc":   { fr: "Systèmes MT pour les paires de langues africaines faiblement dotées : Sara↔Français, Arabe tchadien↔Français.", en: "MT systems for low-resource African language pairs: Sara↔French, Chadian Arabic↔French.", ar: "أنظمة ترجمة آلية لأزواج اللغات الأفريقية شحيحة الموارد: سارا↔فرنسي، عربي تشادي↔فرنسي." },
  "r3-title":  { fr: "Documentation Linguistique", en: "Linguistic Documentation", ar: "التوثيق اللغوي" },
  "r3-desc":   { fr: "Infrastructure numérique pour le Laal (isolat probable, ~750 locuteurs, UNESCO niveau 5).", en: "Digital infrastructure for Laal (probable isolate, ~750 speakers, UNESCO level 5).", ar: "بنية رقمية للغة اللال (لغة معزولة محتملة، ~750 متحدث، المستوى 5 لليونسكو)." },
  "r4-title":  { fr: "NLP & Language Models", en: "NLP & Language Models", ar: "معالجة اللغة والنماذج اللغوية" },
  "r4-desc":   { fr: "Fine-tuning de LLMs pour les langues africaines, tokenisation multilingue, représentations tonales.", en: "LLM fine-tuning for African languages, multilingual tokenization, tonal representations.", ar: "ضبط دقيق للنماذج اللغوية الكبيرة، تقسيم رمزي متعدد اللغات، تمثيلات نغمية." },
  "r5-title":  { fr: "Data Engineering", en: "Data Engineering", ar: "هندسة البيانات" },
  "r5-desc":   { fr: "Pipelines open-source pour la gouvernance des données linguistiques — MinIO, OpenSearch, FAIR/CARE.", en: "Open-source pipelines for linguistic data governance — MinIO, OpenSearch, FAIR/CARE.", ar: "خطوط أنابيب مفتوحة المصدر لحوكمة البيانات اللغوية — MinIO وOpenSearch ومبادئ FAIR/CARE." },
  "r6-title":  { fr: "Éthique & Souveraineté", en: "Ethics & Sovereignty", ar: "الأخلاقيات والسيادة" },
  "r6-desc":   { fr: "Cadres de gouvernance communautaires, droits linguistiques, politiques d'IA responsable pour l'Afrique.", en: "Community governance frameworks, linguistic rights, responsible AI policies for Africa.", ar: "أطر الحوكمة المجتمعية، الحقوق اللغوية، سياسات الذكاء الاصطناعي المسؤول لأفريقيا." },

  /* ── Projects ───────────────────────────────────────────────── */
  "p1-title": { fr: "Laal-Yəw Project", en: "Laal-Yəw Project", ar: "مشروع لال-يو" },
  "p1-desc":  { fr: "Première infrastructure numérique complète pour le Laal (ISO: gdm), isolat linguistique probable du sud du Tchad (~750 locuteurs). Lexique, corpus audio, ASR baseline via géométrie riemannienne.", en: "First complete digital infrastructure for Laal (ISO: gdm), a probable language isolate in southern Chad (~750 speakers). Lexicon, audio corpus, ASR baseline via Riemannian geometry.", ar: "أول بنية رقمية كاملة للغة اللال (رمز ISO: gdm)، لغة معزولة محتملة في جنوب تشاد (~750 متحدث). معجم وتسجيلات وخط أساس للتعرف الصوتي عبر الهندسة الريمانية." },
  "p2-title": { fr: "Atlas Linguistique Interactif du Tchad", en: "Interactive Linguistic Atlas of Chad", ar: "الأطلس اللغوي التفاعلي لتشاد" },
  "p2-desc":  { fr: "Application web Leaflet.js cartographiant 127 langues tchadiennes avec clustering géographique.", en: "Leaflet.js web app mapping 127 Chadian languages with geographic clustering and regional filters.", ar: "تطبيق ويب بـLeaflet.js يرسم خريطة لـ127 لغة تشادية مع تجميع جغرافي وفلاتر إقليمية." },
  "p3-title": { fr: "KalamBot — Assistant Linguistique Sara", en: "KalamBot — Sara Language Assistant", ar: "كلام بوت — مساعد لغة سارا" },
  "p3-desc":  { fr: "Assistant mobile IA pour les dialectes Sara (Ngambaye, Kaba, Mbaye, Gor, Laka). Architecture offline-first pour appareils Android bas de gamme.", en: "Mobile AI assistant for Sara dialects (Ngambaye, Kaba, Mbaye, Gor, Laka). Offline-first for low-end Android devices.", ar: "مساعد ذكاء اصطناعي للأجهزة المحمولة لهجات سارا (نغامباي، كابا، مباي، غور، لاكا). بنية تعمل دون اتصال على أجهزة أندرويد المتواضعة." },
  "p4-title": { fr: "TchadData Explorer", en: "TchadData Explorer", ar: "مستكشف بيانات تشاد" },
  "p4-desc":  { fr: "Moteur de recherche open-source pour les données tchadiennes. MiniSearch, TF-IDF custom, NLP multilingue FR/EN/AR.", en: "Open-source search engine for Chadian data. MiniSearch, custom TF-IDF, multilingual NLP FR/EN/AR.", ar: "محرك بحث مفتوح المصدر لبيانات تشاد. MiniSearch وTF-IDF مخصص ومعالجة لغوية متعددة اللغات." },
  "p5-title": { fr: "Kalam-na — Corpus Speech Sara", en: "Kalam-na — Sara Speech Corpus", ar: "كلام-نا — مدوّنة صوتية سارا" },
  "p5-desc":  { fr: "~37 000 utterances audio, 12 langues Sara, 16 dialectes, ~19 heures, 16-bit/16kHz.", en: "~37,000 audio utterances, 12 Sara languages, 16 dialects, ~19 hours, 16-bit/16kHz.", ar: "~37,000 تسجيل صوتي، 12 لغة سارا، 16 لهجة، ~19 ساعة، 16-بت/16كيلوهرتز." },

  /* ── Badges projets ─────────────────────────────────────────── */
  "badge-ongoing": { fr: "En cours", en: "Ongoing", ar: "جارٍ" },
  "badge-active":  { fr: "Actif",    en: "Active",  ar: "نشط" },
  "badge-design":  { fr: "Design",   en: "Design",  ar: "تصميم" },
  "badge-oss":     { fr: "Open Source", en: "Open Source", ar: "مفتوح المصدر" },
  "badge-corpus":  { fr: "Corpus",   en: "Corpus",  ar: "مدوّنة" },
  "btn-code":      { fr: "Code ↗",   en: "Code ↗",  ar: "الكود ↗" },
  "btn-data":      { fr: "Données ↗", en: "Data ↗", ar: "البيانات ↗" },

  /* ── Collaborations ─────────────────────────────────────────── */
  "c1-name": { fr: "Dr. Florian Lionnet — Princeton University", en: "Dr. Florian Lionnet — Princeton University", ar: "د. فلوريان ليونيه — جامعة برينستون" },
  "c1-desc": { fr: "Principal expert mondial du Laal — collaboration sur la documentation phonologique et la structuration du corpus audio.", en: "World's leading expert on Laal — collaboration on phonological documentation and audio corpus structuring.", ar: "الخبير العالمي الأول في لغة اللال — تعاون في التوثيق الصوتي وهيكلة المدوّنة الصوتية." },
  "c2-name": { fr: "Prof. Pascal Boyeldieu — CNRS/LLACAN", en: "Prof. Pascal Boyeldieu — CNRS/LLACAN", ar: "أ.د. باسكال بوايلديو — CNRS/LLACAN" },
  "c2-desc": { fr: "Linguiste de référence sur les langues tchadiennes ; partenaire pour les données typologiques.", en: "Reference linguist on Chadian languages; partner for typological data and scientific validation.", ar: "المرجع اللغوي في اللغات التشادية؛ شريك للبيانات التصنيفية والتحقق العلمي." },
  "c3-name": { fr: "ELAR / SOAS University of London", en: "ELAR / SOAS University of London", ar: "ELAR / جامعة SOAS لندن" },
  "c3-desc": { fr: "Partenaire d'archivage pour la préservation long-terme des ressources linguistiques du Laal.", en: "Archiving partner for the long-term preservation of Laal linguistic resources.", ar: "شريك أرشفة للحفاظ طويل الأمد على الموارد اللغوية للغة اللال." },
  "c4-name": { fr: "Masakhane Research Foundation", en: "Masakhane Research Foundation", ar: "مؤسسة ماساخاني للبحث" },
  "c4-desc": { fr: "Candidature Lingua Africa pour le Projet Laal-Yəw ; communauté AfricaNLP pour la recherche NLP africaine ouverte.", en: "Lingua Africa application for the Laal-Yəw Project; AfricaNLP community for open African NLP research.", ar: "ترشح Lingua Africa لمشروع لال-يو؛ مجتمع AfricaNLP للبحث المفتوح في اللغات الأفريقية." },
  "c5-name": { fr: "Université de N'Djaména / INSH", en: "University of N'Djamena / INSH", ar: "جامعة نجامينا / INSH" },
  "c5-desc": { fr: "Partenaire institutionnel pour la recherche linguistique et la collecte de données communautaires au Tchad.", en: "Institutional partner for linguistic research and community data collection in Chad.", ar: "شريك مؤسسي للبحث اللغوي وجمع البيانات المجتمعية في تشاد." },

  /* ── Blog ───────────────────────────────────────────────────── */
  "blog-title":    { fr: "Blog", en: "Blog", ar: "المدوّنة" },
  "blog-subtitle": { fr: "Notes de recherche, réflexions sur l'IA africaine, tutoriels techniques.", en: "Research notes, reflections on African AI, technical tutorials.", ar: "ملاحظات بحثية، تأملات حول الذكاء الاصطناعي الأفريقي، دروس تقنية." },
  "search-ph":     { fr: "Rechercher…", en: "Search…", ar: "بحث…" },
  "filter-all":    { fr: "Tout", en: "All", ar: "الكل" },
  "read-more":     { fr: "min de lecture", en: "min read", ar: "دقائق قراءة" },

  /* ── Articles ───────────────────────────────────────────────── */
  "articles-title":    { fr: "Publications scientifiques", en: "Scientific Publications", ar: "المنشورات العلمية" },
  "articles-subtitle": { fr: "Articles, rapports techniques et travaux de recherche.", en: "Papers, technical reports and research work.", ar: "مقالات وتقارير تقنية وأعمال بحثية." },
  "abstract-read":     { fr: "▸ Abstract", en: "▸ Abstract", ar: "▸ الملخص" },
  "abstract-close":    { fr: "▾ Abstract", en: "▾ Abstract", ar: "▾ الملخص" },

  /* ── Footer ─────────────────────────────────────────────────── */
  "footer-built": { fr: "Construit avec", en: "Built with", ar: "مبني بـ" },
};

/* ── Langue courante ─────────────────────────────────────────── */
let LANG = localStorage.getItem('h-lang') || 'fr';

/* ── Appliquer les traductions ───────────────────────────────── */
function applyLang(lang) {
  LANG = lang;
  localStorage.setItem('h-lang', lang);
  document.documentElement.lang = lang;
  document.documentElement.dir  = lang === 'ar' ? 'rtl' : 'ltr';
  document.body.classList.toggle('h-rtl', lang === 'ar');

  // Traduire tous les éléments [data-i18n]
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.dataset.i18n;
    if (TRANSLATIONS[key] && TRANSLATIONS[key][lang]) {
      el.innerHTML = TRANSLATIONS[key][lang];
    }
  });

  // Traduire les placeholders [data-i18n-ph]
  document.querySelectorAll('[data-i18n-ph]').forEach(el => {
    const key = el.dataset.i18nPh;
    if (TRANSLATIONS[key] && TRANSLATIONS[key][lang]) {
      el.placeholder = TRANSLATIONS[key][lang];
    }
  });

  // Mettre à jour les boutons langue
  document.querySelectorAll('.h-lang-btn').forEach(btn => {
    btn.classList.toggle('h-lang-active', btn.dataset.lang === lang);
  });
}

/* ── Sélecteur de langue ─────────────────────────────────────── */
function buildLangSwitcher() {
  const sw = document.createElement('div');
  sw.className = 'h-lang-switcher';
  sw.innerHTML = `
    <button class="h-lang-btn" data-lang="fr" onclick="applyLang('fr')" title="Français">FR</button>
    <button class="h-lang-btn" data-lang="en" onclick="applyLang('en')" title="English">EN</button>
    <button class="h-lang-btn" data-lang="ar" onclick="applyLang('ar')" title="العربية">ع</button>
  `;
  // Injecter dans la sidebar Quarto ou en haut à droite
  const target = document.querySelector('#quarto-sidebar') || document.querySelector('.navbar') || document.body;
  const anchor = document.querySelector('#quarto-sidebar .sidebar-tools-main') ||
                 document.querySelector('#quarto-sidebar');
  if (anchor) {
    anchor.insertAdjacentElement('afterbegin', sw);
  } else {
    document.body.insertAdjacentElement('afterbegin', sw);
  }
}

/* ── Init ────────────────────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', () => {
  buildLangSwitcher();
  applyLang(LANG);
});
