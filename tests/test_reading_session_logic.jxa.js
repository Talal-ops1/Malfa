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
  ['localDay','readingElapsedSeconds','readingMetrics','pauseReadingState','restoreReadingState','readingDayMap','readingStreaks']
    .forEach(function (name) { eval(extract(html, name)); });

  var active = {status:'running', accumulatedSec:10, lastResumedAt:1000, lastTickAt:6000, pauseCount:0};
  assert(readingElapsedSeconds(active, 6000) === 15, 'running elapsed time');
  pauseReadingState(active, 6000, 'background');
  assert(active.status === 'paused' && active.accumulatedSec === 15, 'background pause');
  assert(readingElapsedSeconds(active, 60000) === 15, 'background time must be excluded');

  var crashed = {status:'running', accumulatedSec:4, lastResumedAt:1000, lastTickAt:6000, pauseCount:0};
  restoreReadingState(crashed, 20000);
  assert(crashed.status === 'paused' && crashed.accumulatedSec === 9, 'crash recovery uses last safe tick');
  assert(crashed.pauseReason === 'crash', 'crash recovery reason');

  var metrics = readingMetrics(10, 22, 1080);
  assert(metrics.pages === 12 && metrics.speed === 40, 'pages and speed');
  var noProgress = readingMetrics(12, 12, 30);
  assert(noProgress.pages === 0 && noProgress.speed === 0, 'short session with no page progress');

  var today = new Date(), yesterday = new Date(today); yesterday.setDate(today.getDate()-1);
  var before = new Date(today); before.setDate(today.getDate()-2);
  MY_READING_SESSIONS = [today,yesterday,before].map(function(d,i){return {started_at:d.toISOString(),duration_sec:600,pages_read:i+1,goal_minutes_snapshot:20};});
  var streak = readingStreaks();
  assert(streak.current === 3 && streak.best === 3, 'reading-day streak');

  var migration = read(argv[1]);
  assert(migration.indexOf('goal_minutes_snapshot') >= 0, 'historical goal snapshot');
  assert(migration.indexOf('force row level security') >= 0, 'RLS is forced');
  return 'READING SESSION TESTS OK';
}
