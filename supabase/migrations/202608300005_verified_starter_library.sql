begin;

alter table public.books add column if not exists source_url text;
alter table public.books add column if not exists license_name text;
alter table public.books add column if not exists cover_source_url text;
alter table public.books add column if not exists cover_path text;
alter table public.books add column if not exists catalog_visible boolean not null default true;

insert into public.books
  (id, title, author, publisher, year, pages, layout, scene, stock_index, genre,
   source_url, license_name, cover_source_url, cover_path, catalog_visible)
values
  ('alfleila','ألف ليلة وليلة','تراث شعبي','نسخة تراثية','قديم',600,'full',null,1,'رواية','https://commons.wikimedia.org/wiki/File:ألف_ليلة_وليلة.djvu','Public domain','https://commons.wikimedia.org/wiki/File:ألف_ليلة_وليلة.djvu','assets/covers/alf-leila.jpg',true),
  ('ghufran','رسالة الغفران','أبو العلاء المعري','المكتبة التجارية، القاهرة','1923',260,'full',null,5,'أدب','https://commons.wikimedia.org/wiki/File:Resalat_Al-Ghufran_book_cover,_Commerial_library_edition_(1923).jpg','Public domain','https://commons.wikimedia.org/wiki/File:Resalat_Al-Ghufran_book_cover,_Commerial_library_edition_(1923).jpg','assets/covers/risalat-ghufran.jpg',true),
  ('muqaddimah','مقدمة ابن خلدون','ابن خلدون','المطبعة الأدبية، بيروت','1900',596,'full',null,0,'تاريخ','https://commons.wikimedia.org/wiki/File:مقدمة_ابن_خلدون_(المطبعة_الأدبية،_1900).pdf','Public domain','https://commons.wikimedia.org/wiki/File:مقدمة_ابن_خلدون_(المطبعة_الأدبية،_1900).pdf','assets/covers/muqaddimah.jpg',true),
  ('iqd','العقد الفريد','ابن عبد ربه','مطبعة الاستقامة','1953',690,'full',null,9,'ثقافة','https://commons.wikimedia.org/wiki/File:العقد_الفريد_ج.1-2_(1953).pdf','Public domain','https://commons.wikimedia.org/wiki/File:العقد_الفريد_ج.1-2_(1953).pdf','assets/covers/iqd.jpg',true),
  ('maqamat','مقامات الهمذاني','بديع الزمان الهمذاني','المكتبة الأزهرية','1923',220,'full',null,10,'أدب','https://commons.wikimedia.org/wiki/File:مقامات_بديع_الزمان_الهمذاني_(المكتبة_الأزهرية،_1923).pdf','Public domain','https://commons.wikimedia.org/wiki/File:مقامات_بديع_الزمان_الهمذاني_(المكتبة_الأزهرية،_1923).pdf','assets/covers/maqamat.jpg',true),
  ('mutanabbi','ديوان المتنبي','المتنبي','شرح الواحدي','1861',480,'full',null,7,'أدب','https://commons.wikimedia.org/wiki/File:ديوان_المتنبي_بشرح_الواحدي_-_1861.pdf','Public domain','https://commons.wikimedia.org/wiki/File:ديوان_المتنبي_بشرح_الواحدي_-_1861.pdf','assets/covers/mutanabbi.jpg',true),
  ('tawq','طوق الحمامة','ابن حزم الأندلسي','نسخة تراثية',null,220,'full',null,3,'أدب','https://commons.wikimedia.org/wiki/File:طوق_الحمامة_في_الأُلفَةِ_والأُلَّاف.pdf','Public domain','https://commons.wikimedia.org/wiki/File:طوق_الحمامة_في_الأُلفَةِ_والأُلَّاف.pdf','assets/covers/tawq.jpg',true),
  ('kamil','الكامل','المبرّد','نسخة تراثية',null,796,'full',null,4,'أدب','https://commons.wikimedia.org/wiki/File:الكامل_للمبرد.pdf','Public domain','https://commons.wikimedia.org/wiki/File:الكامل_للمبرد.pdf','assets/covers/kamil.jpg',true),
  ('adabkabir','الأدب الكبير','ابن المقفّع','نسخة تراثية',null,164,'full',null,6,'فكر','https://commons.wikimedia.org/wiki/File:الأدب_الكبير.pdf','Public domain','https://commons.wikimedia.org/wiki/File:الأدب_الكبير.pdf','assets/covers/adab-kabir.jpg',true),
  ('masalik','المسالك والممالك','ابن خرداذبه','مطبعة بريل','1889',336,'full',null,8,'تاريخ','https://commons.wikimedia.org/wiki/File:المسالك_والممالك_(مطبعة_بريل،_1889م).pdf','Public domain','https://commons.wikimedia.org/wiki/File:المسالك_والممالك_(مطبعة_بريل،_1889م).pdf','assets/covers/masalik.jpg',true)
on conflict (id) do update set
  title=excluded.title,
  author=excluded.author,
  publisher=excluded.publisher,
  year=excluded.year,
  pages=excluded.pages,
  layout=excluded.layout,
  scene=excluded.scene,
  stock_index=excluded.stock_index,
  genre=excluded.genre,
  source_url=excluded.source_url,
  license_name=excluded.license_name,
  cover_source_url=excluded.cover_source_url,
  cover_path=excluded.cover_path,
  catalog_visible=true;

update public.books
set catalog_visible=false
where id not in ('alfleila','ghufran','muqaddimah','iqd','maqamat','mutanabbi','tawq','kamil','adabkabir','masalik');

commit;
