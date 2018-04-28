CREATE EXTENSION pg_tsparser;

SELECT * FROM ts_token_type('tsparser');

SELECT * FROM ts_parse('tsparser', '345 qwe@efd.r '' http://www.com/ http://aew.werc.ewr/?ad=qwe&dw 1aew.werc.ewr/?ad=qwe&dw 2aew.werc.ewr http://3aew.werc.ewr/?ad=qwe&dw http://4aew.werc.ewr http://5aew.werc.ewr:8100/?  ad=qwe&dw 6aew.werc.ewr:8100/?ad=qwe&dw 7aew.werc.ewr:8100/?ad=qwe&dw=%20%32 +4.0e-10 qwe qwe qwqwe 234.435 455 5.005 teodor@stack.net teodor@123-stack.net 123_teodor@stack.net 123-teodor@stack.net qwe-wer asdf <fr>qwer jf sdjk<we hjwer <werrwe> ewr1> ewri2 <a href="qwe<qwe>">
/usr/local/fff /awdf/dwqe/4325 rewt/ewr wefjn /wqe-324/ewr gist.h gist.h.c gist.c. readline 4.2 4.2. 4.2, readline-4.2 readline-4.2. 234
<i <b> wow  < jqw <> qwerty');

-- Test text search configuration with parser
CREATE TEXT SEARCH CONFIGURATION english_ts (
    PARSER = tsparser
);

ALTER TEXT SEARCH CONFIGURATION english_ts
    ADD MAPPING FOR
	numword,
		numhword, hword_numpart,
		numuword, uword_numpart,
	url, url_path, host, email,
	float, sfloat,
	int, uint,
	version,
	file
    WITH simple;

ALTER TEXT SEARCH CONFIGURATION english_ts
    ADD MAPPING FOR
	asciiword,
		asciihword, hword_asciipart,
		asciiuword, uword_asciipart,
    word,
		hword, hword_part,
		uword, uword_part
    WITH english_stem;


/* test urls */
SELECT to_tsvector('english_ts', 'test2.com');
SELECT * FROM ts_debug('english_ts', 'test.com');

/* test hyphens */
SELECT to_tsvector('english_ts', '12-abc, ill-posed');
SELECT * FROM ts_debug('english_ts', 'pg-index, 12-pg, pg-12, 123-456, abc-def-egh');

/* test underscores */
SELECT to_tsvector('english_ts', '12_abc, pg_class');
SELECT * FROM ts_debug('english_ts', 'pg_class, 12_pg, pg_12, 123_456, abc_def_egh');

/* test combinations */
SELECT to_tsvector('english_ts', 'pg_class-oriented approach');
SELECT to_tsvector('english_ts', 'pg_class-oriented approach') @@ to_tsquery('english_ts', 'pg_class');
SELECT to_tsvector('english_ts', 'pg_class-oriented approach') @@ to_tsquery('english_ts', 'pg_class-oriented');
SELECT to_tsvector('english_ts', 'Those dark before-pg_class-was-invented ages');
SELECT to_tsvector('english_ts', 'Those dark before-pg_class-was-invented ages') @@ to_tsquery('english_ts', 'pg_class');
SELECT to_tsvector('english_ts', 'Those dark before-pg_class-was-invented ages') @@ to_tsquery('english_ts', 'before-pg_class');
SELECT to_tsvector('english_ts', 'Those dark before-pg_class-was-invented ages') @@ to_tsquery('english_ts', 'before-pg_class-was-invented');


/* full-featured test */
SELECT ts_headline('english_ts',
				   'I love pg_class, pg_index, pg-pool, pg and classes so much I _ cannot _ contain myself',
				   to_tsquery('english_ts', 'pg_class'),
				   'HighlightAll=true');

SELECT ts_headline('english_ts',
				   'This is a new pg_class-oriented kind of approach (also suitable for pg_index)',
				   to_tsquery('english_ts', 'pg_class'));

SELECT ts_headline('english_ts',
				   'It''s hard to provide complete tests for pg_class, pg_index, pg-pool etc',
				   to_tsquery('english_ts', 'pg_class'),
				   'HighlightAll=false, MinWords=3, MaxWords=4');
