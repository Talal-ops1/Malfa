function run(argv) {
  ObjC.import('Foundation');
  function read(path) {
    return ObjC.unwrap($.NSString.stringWithContentsOfFileEncodingError(path, $.NSUTF8StringEncoding, null));
  }
  function extract(src, name) {
    var start = src.indexOf('function ' + name + '(');
    if (start < 0) throw new Error('missing function: ' + name);
    var brace = src.indexOf('{', start), depth = 0, quote = '', escaped = false;
    for (var i = brace; i < src.length; i++) {
      var c = src[i];
      if (quote) {
        if (escaped) escaped = false;
        else if (c === '\\') escaped = true;
        else if (c === quote) quote = '';
        continue;
      }
      if (c === '"' || c === "'") { quote = c; continue; }
      if (c === '{') depth++;
      if (c === '}' && --depth === 0) return src.slice(start, i + 1);
    }
    throw new Error('unterminated function: ' + name);
  }
  function assert(value, message) { if (!value) throw new Error(message); }

  var html = read(argv[0]);
  // Shared fixture state is assigned WITHOUT `var` (implicit globals) because
  // the extracted functions below are eval'd as function declarations and,
  // in this JXA/JavaScriptCore host, only resolve free variables that live
  // on the global object — matching the pattern already proven to work in
  // test_reading_session_logic.jxa.js.
  AR_MONTHS = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
  ['fmtDate','fmtDur','fmtTotalDur','isCustomBook','myBookView','myJourneyView','localDay',
   'readingDaysForBook','selectedBookKey','mergedJourneyView']
    .forEach(function (name) { eval(extract(html, name)); });

  // ---- fixtures: a tiny catalog + one manual book ----
  B = { alfleila: { t:'ألف ليلة وليلة', a:'تراث شعبي', pages: 600 }, ghufran: { t:'رسالة الغفران', pages: 260 } };
  MY_USER_BOOKS = { 'ub-1': { id:'ub-1', title:'كتابي', author:null, page_count: 100 } };
  MY_PROGRESS = { alfleila: 40, ghufran: 10, 'ub-1': 5 };
  MY_LIB = { reading: ['ghufran','alfleila'], next: [], finished: [], dropped: [] };
  MY_JOURNEY = {};
  MY_READING_SESSIONS = [];
  READING_ACTIVE = null;
  READING_PREF = { daily_goal_minutes: 20, selected_book_id: null, selected_user_book_id: null, weekly_days_goal: null };

  // ---- 1) selected-book priority ----
  // tier 3: most-recently-updated `reading` entry (MY_LIB.reading[0])
  assert(selectedBookKey() === 'ghufran', 'tier 3: falls back to MY_LIB.reading[0]');

  // tier 2: explicit saved selection overrides tier 3
  READING_PREF.selected_book_id = 'alfleila';
  assert(selectedBookKey() === 'alfleila', 'tier 2: explicit selection wins over reading[0]');

  // tier 2 with a custom (manual) book, via selected_user_book_id
  READING_PREF.selected_book_id = null; READING_PREF.selected_user_book_id = 'ub-1';
  assert(selectedBookKey() === 'ub-1', 'tier 2: explicit selection resolves a manual/custom book');

  // an explicit selection pointing at a book that no longer resolves must not be trusted
  READING_PREF.selected_user_book_id = 'does-not-exist';
  assert(selectedBookKey() === 'ghufran', 'tier 2 falls through to tier 3 when the saved pick no longer resolves');
  READING_PREF.selected_book_id = null; READING_PREF.selected_user_book_id = null;

  // tier 1: a running/restored session always wins, even over an explicit pick
  READING_PREF.selected_book_id = 'alfleila';
  READING_ACTIVE = { bookId: 'ghufran', status: 'running' };
  assert(selectedBookKey() === 'ghufran', 'tier 1: running session outranks the explicit selection');
  READING_ACTIVE = null; READING_PREF.selected_book_id = null;

  // tier 4: nothing selected, nothing reading -> no book
  MY_LIB.reading = [];
  assert(selectedBookKey() === null, 'tier 4: no book selected and nothing reading -> null');
  MY_LIB.reading = ['ghufran','alfleila'];

  // unrelated library writes (e.g. adding a book to `next`) must never move the explicit pick
  READING_PREF.selected_book_id = 'alfleila';
  MY_LIB.next.push('ghufran');
  assert(selectedBookKey() === 'alfleila', 'unrelated library writes do not silently change the selection');
  READING_PREF.selected_book_id = null; MY_LIB.next = [];

  // ---- 2) per-book reading-day uniqueness (duration_sec>0 only, no cross-book leak) ----
  var d1 = new Date(2026, 0, 5, 9, 0, 0), d2 = new Date(2026, 0, 5, 21, 0, 0), d3 = new Date(2026, 0, 6, 9, 0, 0);
  MY_READING_SESSIONS = [
    { book_id: 'ghufran', started_at: d1.toISOString(), duration_sec: 600 },   // day 1, book A
    { book_id: 'ghufran', started_at: d2.toISOString(), duration_sec: 300 },   // day 1 again, book A (still 1 day)
    { book_id: 'ghufran', started_at: d3.toISOString(), duration_sec: 0 },     // day 2, but zero duration -> does not count
    { book_id: 'alfleila', started_at: d3.toISOString(), duration_sec: 500 }   // day 2, book B only
  ];
  assert(readingDaysForBook('ghufran') === 1, 'same-day multiple sessions for one book still count as one day');
  assert(readingDaysForBook('alfleila') === 1, 'a session on another book does not leak into this book\'s count');
  assert(readingDaysForBook('does-not-exist') === 0, 'a book with no sessions has zero reading days');

  // ---- 3) merged per-book journey view: entries + sessions, newest first, no duplication ----
  MY_JOURNEY['ghufran'] = [
    { id: 'e1', note: 'ملاحظة أولى', duration_sec: 0, page_from: null, page_to: null, is_start: true, created_at: new Date(2026,0,4,8,0,0).toISOString() },
    { id: 'e2', note: 'ملاحظة ثانية', duration_sec: 30, page_from: 1, page_to: 10, is_start: false, created_at: new Date(2026,0,6,10,0,0).toISOString() }
  ];
  // ghufran has 3 sessions (incl. the zero-duration one from section 2) + 2 entries.
  // The zero-duration session still belongs in the timeline (it's a real saved
  // session with edit/delete controls) even though it never counted as a reading day.
  var merged = mergedJourneyView('ghufran');
  assert(merged.length === 5, 'merged view includes every entry and every session for that book, once each');
  var order = merged.map(function(it){return it.type === 'entry' ? 'e:' + it.e.id : 's:' + it.s.started_at;});
  for (var i = 1; i < merged.length; i++) assert(merged[i-1].ts >= merged[i].ts, 'merged timeline is sorted newest-first: ' + order.join(','));
  assert(merged.filter(function(it){return it.type==='session';}).length === 3, 'all three of this book\'s sessions appear in its merged journey');
  assert(merged.filter(function(it){return it.type==='entry';}).length === 2, 'both journal entries appear alongside the sessions');
  assert(mergedJourneyView('alfleila').length === 1, 'a different book\'s merged journey does not include ghufran\'s rows');

  // ---- 4) tracked migrations exist and encode the required constraints ----
  var prefMig = read(argv[1]);
  assert(prefMig.indexOf('weekly_days_goal') >= 0, 'weekly_days_goal column is migrated');
  assert(prefMig.indexOf('weekly_days_goal >= 1 and weekly_days_goal <= 7') >= 0, 'weekly_days_goal is constrained to 1-7');
  assert(prefMig.indexOf('selected_book_id is null or selected_user_book_id is null') >= 0, 'selected book is one-of, nullable');
  assert(prefMig.indexOf('selected user book does not belong to preference owner') >= 0, 'selected manual book ownership is validated server-side');

  var collMig = read(argv[2]);
  assert(collMig.indexOf('user_book_id') >= 0, 'collection_books gained user_book_id additively');
  assert(collMig.indexOf('(book_id is not null) <> (user_book_id is not null)') >= 0, 'collection_books keeps a one-of check, not a duplicate copy');
  assert(collMig.indexOf('collection book does not belong to collection owner') >= 0, 'collection book ownership is validated server-side');

  return 'LIBRARY/MALFA REORG TESTS OK';
}
