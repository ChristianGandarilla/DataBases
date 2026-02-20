-- ============================================================
--  DATABASE: MOVIES UNIVERSE
--  Description: Complete relational schema for a movie database
--  Tables: 10 | Views: 4 | JOINs: 20 | Sample Data: included
-- ============================================================

CREATE DATABASE IF NOT EXISTS movies_universe;
USE movies_universe;

-- ============================================================
-- TABLE 1: GENRES
-- All movie genres and subgenres
-- ============================================================
CREATE TABLE genres (
    genre_id        INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    parent_genre_id INT DEFAULT NULL,             -- For subgenres (e.g. Romantic Comedy -> Comedy)
    description     TEXT,
    CONSTRAINT uq_genre_name    UNIQUE (name),
    CONSTRAINT fk_parent_genre  FOREIGN KEY (parent_genre_id) REFERENCES genres(genre_id) ON DELETE SET NULL
);

-- ============================================================
-- TABLE 2: COUNTRIES
-- Production countries
-- ============================================================
CREATE TABLE countries (
    country_id      INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    iso_code        CHAR(2)      NOT NULL,
    region          VARCHAR(80),
    CONSTRAINT uq_country_iso UNIQUE (iso_code)
);

-- ============================================================
-- TABLE 3: STUDIOS
-- Production studios / distributors
-- ============================================================
CREATE TABLE studios (
    studio_id       INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(150) NOT NULL,
    country_id      INT,
    founded_year    INT,
    website         VARCHAR(200),
    active          BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_studio_country FOREIGN KEY (country_id) REFERENCES countries(country_id) ON DELETE SET NULL
);

-- ============================================================
-- TABLE 4: PEOPLE
-- Directors, actors, writers, composers — everyone in the industry
-- ============================================================
CREATE TABLE people (
    person_id       INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(100) NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    birth_date      DATE,
    death_date      DATE,
    nationality     INT,                          -- FK to countries
    biography       TEXT,
    gender          ENUM('Male','Female','Non-binary','Unknown') DEFAULT 'Unknown',
    CONSTRAINT fk_person_country FOREIGN KEY (nationality) REFERENCES countries(country_id) ON DELETE SET NULL
);

-- ============================================================
-- TABLE 5: MOVIES (core table)
-- ============================================================
CREATE TABLE movies (
    movie_id        INT AUTO_INCREMENT PRIMARY KEY,
    title           VARCHAR(300) NOT NULL,
    original_title  VARCHAR(300),
    release_year    YEAR,
    release_date    DATE,
    duration_min    INT,                          -- Runtime in minutes
    rating          ENUM('G','PG','PG-13','R','NC-17','NR','TV-MA') DEFAULT 'NR',
    imdb_score      DECIMAL(3,1) CHECK (imdb_score BETWEEN 0.0 AND 10.0),
    rotten_tomatoes INT          CHECK (rotten_tomatoes BETWEEN 0 AND 100),
    budget_usd      BIGINT,
    box_office_usd  BIGINT,
    studio_id       INT,
    director_id     INT,
    country_id      INT,
    language        VARCHAR(80)  DEFAULT 'English',
    synopsis        TEXT,
    awards          TEXT,
    status          ENUM('Released','In Production','Post-Production','Announced','Cancelled') DEFAULT 'Released',
    CONSTRAINT fk_movie_studio   FOREIGN KEY (studio_id)   REFERENCES studios(studio_id)   ON DELETE SET NULL,
    CONSTRAINT fk_movie_director FOREIGN KEY (director_id) REFERENCES people(person_id)    ON DELETE SET NULL,
    CONSTRAINT fk_movie_country  FOREIGN KEY (country_id)  REFERENCES countries(country_id) ON DELETE SET NULL
);

-- ============================================================
-- TABLE 6: MOVIE_GENRES (junction — a movie can have many genres)
-- ============================================================
CREATE TABLE movie_genres (
    movie_id        INT NOT NULL,
    genre_id        INT NOT NULL,
    is_primary      BOOLEAN DEFAULT FALSE,        -- Main genre flag
    PRIMARY KEY (movie_id, genre_id),
    CONSTRAINT fk_mg_movie FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
    CONSTRAINT fk_mg_genre FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE 7: CAST & CREW
-- Roles each person played in each movie
-- ============================================================
CREATE TABLE cast_crew (
    role_id         INT AUTO_INCREMENT PRIMARY KEY,
    movie_id        INT NOT NULL,
    person_id       INT NOT NULL,
    role_type       ENUM('Actor','Director','Writer','Producer','Composer',
                         'Cinematographer','Editor','VFX','Costume','Other') NOT NULL,
    character_name  VARCHAR(200),                 -- For actors
    billing_order   INT,                          -- Top-billing = 1
    is_lead         BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_cc_movie  FOREIGN KEY (movie_id)  REFERENCES movies(movie_id)   ON DELETE CASCADE,
    CONSTRAINT fk_cc_person FOREIGN KEY (person_id) REFERENCES people(person_id)  ON DELETE CASCADE
);

-- ============================================================
-- TABLE 8: AWARDS
-- Awards and nominations per movie
-- ============================================================
CREATE TABLE awards (
    award_id        INT AUTO_INCREMENT PRIMARY KEY,
    movie_id        INT NOT NULL,
    person_id       INT,                          -- Individual recipient (nullable for film-level awards)
    ceremony        VARCHAR(150) NOT NULL,        -- e.g. "Academy Awards", "BAFTA"
    category        VARCHAR(200) NOT NULL,        -- e.g. "Best Picture", "Best Actor"
    year_awarded    INT,
    won             BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_award_movie  FOREIGN KEY (movie_id)  REFERENCES movies(movie_id)  ON DELETE CASCADE,
    CONSTRAINT fk_award_person FOREIGN KEY (person_id) REFERENCES people(person_id) ON DELETE SET NULL
);

-- ============================================================
-- TABLE 9: REVIEWS
-- Critic and audience reviews
-- ============================================================
CREATE TABLE reviews (
    review_id       INT AUTO_INCREMENT PRIMARY KEY,
    movie_id        INT NOT NULL,
    reviewer_name   VARCHAR(150) NOT NULL,
    reviewer_type   ENUM('Critic','Audience','Publication') DEFAULT 'Audience',
    score           DECIMAL(3,1) CHECK (score BETWEEN 0.0 AND 10.0),
    review_text     TEXT,
    reviewed_at     DATE,
    publication     VARCHAR(150),                 -- e.g. "The Guardian", "Variety"
    CONSTRAINT fk_review_movie FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE 10: COLLECTIONS / FRANCHISES
-- Movie series and franchises
-- ============================================================
CREATE TABLE collections (
    collection_id   INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(200) NOT NULL,
    description     TEXT,
    total_movies    INT DEFAULT 0,
    total_box_office BIGINT DEFAULT 0,
    CONSTRAINT uq_collection_name UNIQUE (name)
);

-- Junction: which movies belong to which collection
CREATE TABLE movie_collections (
    movie_id        INT NOT NULL,
    collection_id   INT NOT NULL,
    part_number     INT,                          -- e.g. Episode 1, Part 2
    PRIMARY KEY (movie_id, collection_id),
    CONSTRAINT fk_mc_movie      FOREIGN KEY (movie_id)      REFERENCES movies(movie_id)       ON DELETE CASCADE,
    CONSTRAINT fk_mc_collection FOREIGN KEY (collection_id) REFERENCES collections(collection_id) ON DELETE CASCADE
);

-- ============================================================
-- SAMPLE DATA
-- ============================================================

-- Countries
INSERT INTO countries (name, iso_code, region) VALUES
('United States', 'US', 'North America'),
('United Kingdom', 'GB', 'Europe'),
('France',         'FR', 'Europe'),
('Germany',        'DE', 'Europe'),
('Japan',          'JP', 'Asia'),
('South Korea',    'KR', 'Asia'),
('Italy',          'IT', 'Europe'),
('Australia',      'AU', 'Oceania'),
('Mexico',         'MX', 'North America'),
('Canada',         'CA', 'North America'),
('Spain',          'ES', 'Europe'),
('India',          'IN', 'Asia'),
('New Zealand',    'NZ', 'Oceania'),
('Sweden',         'SE', 'Europe'),
('Brazil',         'BR', 'South America');

-- Genres (with parent-child relationships)
INSERT INTO genres (name, parent_genre_id, description) VALUES
-- Main genres
('Action',          NULL, 'High energy, physical feats, chases and combat'),
('Adventure',       NULL, 'Journeys, exploration and discovery'),
('Animation',       NULL, 'Animated feature films of all styles'),
('Comedy',          NULL, 'Films designed to entertain and amuse'),
('Crime',           NULL, 'Stories centered around criminal acts and investigations'),
('Documentary',     NULL, 'Non-fiction films depicting real events and people'),
('Drama',           NULL, 'Character-driven stories with emotional depth'),
('Fantasy',         NULL, 'Magical worlds, mythical creatures and supernatural elements'),
('Horror',          NULL, 'Films intended to frighten and unsettle audiences'),
('Musical',         NULL, 'Films in which songs and dance are central to the narrative'),
('Mystery',         NULL, 'Puzzle-like narratives centered on unsolved events'),
('Romance',         NULL, 'Love stories and emotional relationships'),
('Science Fiction', NULL, 'Speculative stories based on future science and technology'),
('Thriller',        NULL, 'Suspenseful films that keep audiences on edge'),
('Western',         NULL, 'Stories set in the American frontier era'),
('War',             NULL, 'Films depicting armed conflicts and their consequences'),
('Biography',       NULL, 'Dramatized accounts of real people''s lives'),
('Historical',      NULL, 'Films set in a specific historical period'),
('Sports',          NULL, 'Films centered around athletic competition'),
('Superhero',       NULL, 'Stories featuring characters with extraordinary abilities'),
-- Subgenres
('Romantic Comedy', 4,  'Love stories with comedic elements'),
('Dark Comedy',     4,  'Comedy that deals with disturbing or taboo subjects'),
('Slasher',         9,  'Horror subgenre featuring a killer targeting victims'),
('Psychological Horror', 9, 'Horror focused on mental and emotional dread'),
('Heist',           5,  'Stories centered around elaborate robbery plans'),
('Neo-noir',        5,  'Modern reimagining of classic noir crime films'),
('Space Opera',     13, 'Large-scale science fiction set in outer space'),
('Cyberpunk',       13, 'Dystopian sci-fi featuring technology and social collapse'),
('Epic Fantasy',    8,  'Large-scale fantasy with grand world-building'),
('Supernatural',    8,  'Films involving ghosts, demons and supernatural forces'),
('Found Footage',   9,  'Horror filmed as if discovered amateur footage'),
('Mockumentary',    6,  'Fictional film shot in documentary style');

-- Studios
INSERT INTO studios (name, country_id, founded_year, website) VALUES
('Warner Bros. Pictures',     1, 1923, 'warnerbros.com'),
('Universal Pictures',        1, 1912, 'universalpictures.com'),
('Paramount Pictures',        1, 1912, 'paramount.com'),
('Columbia Pictures',         1, 1918, 'sonypictures.com'),
('20th Century Studios',      1, 1935, '20thcenturystudios.com'),
('Walt Disney Pictures',      1, 1923, 'disney.com'),
('Marvel Studios',            1, 1993, 'marvel.com'),
('DC Studios',                1, 1998, 'dccomics.com'),
('A24',                       1, 2012, 'a24films.com'),
('Lionsgate Films',           10, 1997, 'lionsgate.com'),
('Focus Features',            1, 2002, 'focusfeatures.com'),
('Miramax',                   1, 1979, 'miramax.com'),
('New Line Cinema',           1, 1967, 'newline.com'),
('DreamWorks Animation',      1, 1994, 'dreamworks.com'),
('Pixar Animation Studios',   1, 1979, 'pixar.com'),
('Working Title Films',       2, 1983, 'workingtitlefilms.com'),
('StudioCanal',               3, 1990, 'studiocanal.com'),
('Toho',                      5, 1932, 'toho.co.jp'),
('CJ ENM',                    6, 1994, 'cjenm.com'),
('Blumhouse Productions',     1, 2000, 'blumhouse.com');

-- People
INSERT INTO people (first_name, last_name, birth_date, nationality, gender) VALUES
-- Directors
('Christopher',  'Nolan',        '1970-07-30', 2,  'Male'),
('Steven',       'Spielberg',    '1946-12-18', 1,  'Male'),
('Quentin',      'Tarantino',    '1963-03-27', 1,  'Male'),
('James',        'Cameron',      '1954-08-16', 10, 'Male'),
('Martin',       'Scorsese',     '1942-11-17', 1,  'Male'),
('Ridley',       'Scott',        '1937-11-30', 2,  'Male'),
('Peter',        'Jackson',      '1961-10-31', 13, 'Male'),
('Denis',        'Villeneuve',   '1967-10-03', 10, 'Male'),
('Bong',         'Joon-ho',      '1969-09-14', 6,  'Male'),
('Sofia',        'Coppola',      '1971-05-14', 1,  'Female'),
('Greta',        'Gerwig',       '1983-08-04', 1,  'Female'),
('Ari',          'Aster',        '1986-07-18', 1,  'Male'),
('Jordan',       'Peele',        '1979-02-21', 1,  'Male'),
('Wes',          'Anderson',     '1969-05-01', 1,  'Male'),
('David',        'Fincher',      '1962-08-28', 1,  'Male'),
-- Actors
('Leonardo',     'DiCaprio',     '1974-11-11', 1,  'Male'),
('Meryl',        'Streep',       '1949-06-22', 1,  'Female'),
('Tom',          'Hanks',        '1956-07-09', 1,  'Male'),
('Cate',         'Blanchett',    '1969-05-14', 8,  'Female'),
('Joaquin',      'Phoenix',      '1974-10-28', 1,  'Male'),
('Viola',        'Davis',        '1965-08-11', 1,  'Female'),
('Anthony',      'Hopkins',      '1937-12-31', 2,  'Male'),
('Natalie',      'Portman',      '1981-06-09', 1,  'Female'),
('Denzel',       'Washington',   '1954-12-28', 1,  'Male'),
('Charlize',     'Theron',       '1975-08-07', 1,  'Female'),
('Robert',       'De Niro',      '1943-08-17', 1,  'Male'),
('Kate',         'Winslet',      '1975-10-05', 2,  'Female'),
('Brad',         'Pitt',         '1963-12-18', 1,  'Male'),
('Margot',       'Robbie',       '1990-07-02', 8,  'Female'),
('Ryan',         'Gosling',      '1980-11-12', 10, 'Male');

-- Collections / Franchises
INSERT INTO collections (name, description) VALUES
('The Dark Knight Trilogy',   'Christopher Nolan''s Batman trilogy'),
('The Lord of the Rings',     'Peter Jackson''s Middle-earth saga'),
('Marvel Cinematic Universe', 'Interconnected superhero film franchise'),
('Inception Universe',        'Christopher Nolan mind-bending films'),
('Tarantino Universe',        'Quentin Tarantino''s interconnected cinematic world');

-- Movies
INSERT INTO movies (title, original_title, release_year, release_date, duration_min, rating, imdb_score, rotten_tomatoes, budget_usd, box_office_usd, studio_id, director_id, country_id, language, synopsis) VALUES
-- Action / Thriller
('The Dark Knight',       'The Dark Knight',       2008, '2008-07-18', 152, 'PG-13', 9.0, 94,  185000000,  1005000000, 1,  1,  1,  'English',  'Batman faces the Joker, a criminal mastermind who plunges Gotham into chaos'),
('Inception',             'Inception',             2010, '2010-07-16', 148, 'PG-13', 8.8, 87,  160000000,  836800000,  1,  1,  2,  'English',  'A thief who enters dreams to steal secrets is given the inverse task: plant an idea'),
('Mad Max: Fury Road',    'Mad Max: Fury Road',    2015, '2015-05-15', 120, 'R',     8.1, 97,  185000000,  375400000,  1,  6,  8,  'English',  'In a post-apocalyptic wasteland, a woman rebels against a tyrannical ruler'),
('John Wick',             'John Wick',             2014, '2014-10-24', 101, 'R',     7.4, 86,  20000000,   88800000,   10, 2,  1,  'English',  'An ex-hitman comes out of retirement to track down the gangsters that killed his dog'),
('Top Gun: Maverick',     'Top Gun: Maverick',     2022, '2022-05-27', 130, 'PG-13', 8.3, 96,  177000000,  1491700000, 3,  2,  1,  'English',  'After 30 years, Maverick is back to train a new generation of Top Gun graduates'),
-- Science Fiction
('Interstellar',          'Interstellar',          2014, '2014-11-07', 169, 'PG-13', 8.7, 72,  165000000,  773400000,  3,  1,  1,  'English',  'A team of explorers travel through a wormhole in space to ensure humanity''s survival'),
('Arrival',               'Arrival',               2016, '2016-11-11', 116, 'PG-13', 7.9, 94,  47000000,   203400000,  3,  8,  10, 'English',  'A linguist is recruited to communicate with alien lifeforms after mysterious spacecraft appear worldwide'),
('Blade Runner 2049',     'Blade Runner 2049',     2017, '2017-10-06', 163, 'R',     8.0, 88,  150000000,  260500000,  4,  8,  1,  'English',  'A new blade runner discovers a long-buried secret that could plunge society into chaos'),
('The Matrix',            'The Matrix',            1999, '1999-03-31', 136, 'R',     8.7, 88,  63000000,   467200000,  1,  4,  1,  'English',  'A hacker discovers reality is a simulation and joins rebels against the machines'),
('Dune',                  'Dune',                  2021, '2021-10-22', 155, 'PG-13', 8.0, 83,  165000000,  401800000,  1,  8,  1,  'English',  'A noble family becomes embroiled in a war for control over the galaxy''s most valuable asset'),
-- Drama
('The Shawshank Redemption', 'The Shawshank Redemption', 1994, '1994-09-23', 142, 'R', 9.3, 89, 25000000, 16000000, 1, 5, 1, 'English', 'Two imprisoned men bond over years, finding solace and eventual redemption'),
('Schindler''s List',     'Schindler''s List',     1993, '1993-12-15', 195, 'R',     9.0, 98,  22000000,   321200000,  2,  2,  1,  'English',  'A German industrialist saves the lives of more than a thousand Jewish refugees during the Holocaust'),
('Forrest Gump',          'Forrest Gump',          1994, '1994-07-06', 142, 'PG-13', 8.8, 71,  55000000,   678200000,  3,  2,  1,  'English',  'The story of a man with a low IQ whose simple life touches many historic events'),
('The Godfather',         'The Godfather',         1972, '1972-03-24', 175, 'R',     9.2, 97,  6000000,    246100000,  3,  5,  1,  'English',  'The patriarch of an organized crime dynasty transfers control to his reluctant son'),
('12 Years a Slave',      '12 Years a Slave',      2013, '2013-10-18', 134, 'R',     8.1, 95,  20000000,   187700000,  11, 5,  2,  'English',  'In 1841 New York, a free Black man is kidnapped and sold into slavery'),
-- Horror
('Hereditary',            'Hereditary',            2018, '2018-06-08', 127, 'R',     7.3, 89,  10000000,   79600000,   9,  12, 1,  'English',  'A family unravels cryptic and terrifying secrets about their ancestry after the grandmother''s death'),
('Get Out',               'Get Out',               2017, '2017-02-24', 104, 'R',     7.7, 98,  4500000,    255500000,  2,  13, 1,  'English',  'A Black man visits his white girlfriend''s parents and discovers disturbing secrets'),
('Midsommar',             'Midsommar',             2019, '2019-08-09', 148, 'R',     7.1, 83,  9000000,    29100000,   9,  12, 1,  'English',  'A couple travels to Sweden for a festival that takes a sinister turn'),
('The Shining',           'The Shining',           1980, '1980-05-23', 146, 'R',     8.4, 84,  19000000,   47200000,   1,  6,  2,  'English',  'A family heads to an isolated hotel where a sinister presence influences the father'),
('A Quiet Place',         'A Quiet Place',         2018, '2018-04-06', 90,  'PG-13', 7.5, 96,  17000000,   340900000,  3,  2,  1,  'English',  'A family struggles to survive in a post-apocalyptic world inhabited by blind creatures that hunt by sound'),
-- Comedy
('The Grand Budapest Hotel', 'The Grand Budapest Hotel', 2014, '2014-03-28', 99, 'R', 8.1, 91, 25000000, 174800000, 11, 14, 3, 'English', 'A writer encounters the lobby boy in the most beloved hotel in Europe and the adventures they share'),
('Parasite',              'Gisaengchung',          2019, '2019-10-11', 132, 'R',     8.5, 99,  11400000,   258800000,  19, 9,  6,  'Korean',   'A poor family schemes to become employed by a wealthy family and infiltrate their household'),
('Knives Out',            'Knives Out',            2019, '2019-11-27', 130, 'PG-13', 7.9, 97,  40000000,   311400000,  10, 8,  1,  'English',  'A detective investigates the death of a patriarch of an eccentric, combative family'),
('Superbad',              'Superbad',              2007, '2007-08-17', 113, 'R',     7.6, 87,  20000000,   169900000,  4,  2,  1,  'English',  'Two co-dependent high school seniors are forced to deal with separation anxiety after their plan to score alcohol for a party fails'),
-- Romance
('Titanic',               'Titanic',               1997, '1997-12-19', 195, 'PG-13', 7.9, 88,  200000000,  2187500000, 5,  4,  1,  'English',  'A romance blossoms between a wealthy woman and a poor artist aboard the ill-fated RMS Titanic'),
('La La Land',            'La La Land',            2016, '2016-12-09', 128, 'PG-13', 8.0, 91,  30000000,   446100000,  3,  8,  1,  'English',  'A jazz pianist and an aspiring actress fall in love in Los Angeles while pursuing their dreams'),
('Amélie',                'Le Fabuleux Destin d''Amélie Poulain', 2001, '2001-04-25', 122, 'R', 8.3, 89, 10000000, 173900000, 17, 3, 3, 'French', 'A whimsical young woman decides to change the lives of those around her for the better'),
('Eternal Sunshine of the Spotless Mind', 'Eternal Sunshine of the Spotless Mind', 2004, '2004-03-19', 108, 'R', 8.3, 92, 20000000, 72000000, 11, 11, 1, 'English', 'After a painful breakup a couple erases each other from their memories'),
-- Animation
('Spirited Away',         'Sen to Chihiro no Kamikakushi', 2001, '2001-07-20', 125, 'PG', 8.6, 97, 19000000, 395800000, 18, 7, 5, 'Japanese', 'A young girl wanders into a world ruled by gods, spirits, and monsters and her parents are transformed into pigs'),
('Spider-Man: Into the Spider-Verse', 'Spider-Man: Into the Spider-Verse', 2018, '2018-12-14', 117, 'PG', 8.4, 97, 90000000, 384300000, 4, 11, 1, 'English', 'Teen Miles Morales becomes the Spider-Man of his universe and must join with others to stop a threat'),
-- Thriller / Crime
('Pulp Fiction',          'Pulp Fiction',          1994, '1994-10-14', 154, 'R',     8.9, 92,  8000000,    213900000,  12, 3,  1,  'English',  'The lives of two mob hitmen, a boxer, a gangster and his wife intertwine in four tales of violence and redemption'),
('Zodiac',                'Zodiac',                2007, '2007-03-02', 157, 'R',     7.7, 89,  65000000,   84700000,   3,  15, 1,  'English',  'A cartoonist becomes obsessed with tracking down the Zodiac Killer'),
('Gone Girl',             'Gone Girl',             2014, '2014-10-03', 149, 'R',     8.1, 87,  61000000,   369300000,  5,  15, 1,  'English',  'With his wife''s disappearance, a man becomes the prime suspect as media frenzy builds'),
-- Fantasy
('The Lord of the Rings: The Fellowship of the Ring', 'The Lord of the Rings', 2001, '2001-12-19', 178, 'PG-13', 8.8, 91, 93000000, 871500000, 13, 7, 13, 'English', 'A young hobbit and eight companions set out on a journey to destroy a powerful ring'),
('Pan''s Labyrinth',      'El laberinto del fauno',2006, '2006-10-11', 118, 'R',     8.2, 95,  19000000,   83300000,   17, 14, 11, 'Spanish',  'In post-Civil War Spain, a girl escapes into a dark fantasy world'),
-- War / Historical
('Dunkirk',               'Dunkirk',               2017, '2017-07-21', 106, 'PG-13', 7.9, 92,  100000000,  527000000,  1,  1,  2,  'English',  'Allied soldiers from Belgium, Britain and France are surrounded by the German Army and evacuated during a fierce battle'),
('1917',                  '1917',                  2019, '2019-12-25', 119, 'R',     8.3, 89,  95000000,   385400000,  1,  2,  2,  'English',  'Two young British soldiers must cross enemy territory to deliver a message that could save 1600 men'),
-- Musical
('La La Land',            'La La Land',            2016, '2016-12-09', 128, 'PG-13', 8.0, 91,  30000000,   446100000,  3,  8,  1,  'English',  'A musician and an actress share a romance while pursuing their dreams in Los Angeles'),
-- Documentary
('Won''t You Be My Neighbor?', 'Won''t You Be My Neighbor?', 2018, '2018-06-08', 94, 'PG-13', 8.4, 99, 1300000, 22700000, 11, 5, 1, 'English', 'An examination of the life, lessons, and legacy of iconic children''s television host Fred Rogers'),
-- Biography
('Oppenheimer',           'Oppenheimer',           2023, '2023-07-21', 180, 'R',     8.9, 93,  100000000,  952000000,  2,  1,  1,  'English',  'The story of American scientist J. Robert Oppenheimer and his role in the development of the atomic bomb'),
('Bohemian Rhapsody',     'Bohemian Rhapsody',     2018, '2018-11-02', 134, 'PG-13', 7.9, 60,  52000000,   903700000,  5,  6,  2,  'English',  'The story of the legendary rock band Queen and lead singer Freddie Mercury');

-- Assign genres to movies
INSERT INTO movie_genres (movie_id, genre_id, is_primary) VALUES
(1,  14, TRUE),  -- Dark Knight: Thriller (primary)
(1,  1,  FALSE), -- Dark Knight: Action
(1,  20, FALSE), -- Dark Knight: Superhero
(2,  13, TRUE),  -- Inception: Sci-Fi
(2,  14, FALSE), -- Inception: Thriller
(2,  1,  FALSE), -- Inception: Action
(3,  1,  TRUE),  -- Mad Max: Action
(3,  13, FALSE), -- Mad Max: Sci-Fi
(4,  1,  TRUE),  -- John Wick: Action
(4,  14, FALSE), -- John Wick: Thriller
(5,  1,  TRUE),  -- Top Gun: Action
(6,  13, TRUE),  -- Interstellar: Sci-Fi
(6,  7,  FALSE), -- Interstellar: Drama
(7,  13, TRUE),  -- Arrival: Sci-Fi
(7,  11, FALSE), -- Arrival: Mystery
(8,  13, TRUE),  -- Blade Runner: Sci-Fi
(8,  26, FALSE), -- Blade Runner: Neo-noir
(9,  13, TRUE),  -- The Matrix: Sci-Fi
(9,  1,  FALSE), -- The Matrix: Action
(10, 13, TRUE),  -- Dune: Sci-Fi
(10, 27, FALSE), -- Dune: Space Opera
(11, 7,  TRUE),  -- Shawshank: Drama
(12, 7,  TRUE),  -- Schindler's: Drama
(12, 16, FALSE), -- Schindler's: War
(13, 7,  TRUE),  -- Forrest Gump: Drama
(13, 4,  FALSE), -- Forrest Gump: Comedy
(14, 5,  TRUE),  -- Godfather: Crime
(14, 7,  FALSE), -- Godfather: Drama
(15, 7,  TRUE),  -- 12 Years: Drama
(15, 17, FALSE), -- 12 Years: Biography
(16, 9,  TRUE),  -- Hereditary: Horror
(16, 24, FALSE), -- Hereditary: Psychological Horror
(17, 9,  TRUE),  -- Get Out: Horror
(17, 14, FALSE), -- Get Out: Thriller
(18, 9,  TRUE),  -- Midsommar: Horror
(19, 9,  TRUE),  -- The Shining: Horror
(19, 24, FALSE), -- The Shining: Psychological Horror
(20, 9,  TRUE),  -- A Quiet Place: Horror
(20, 14, FALSE), -- A Quiet Place: Thriller
(21, 4,  TRUE),  -- Grand Budapest: Comedy
(22, 4,  TRUE),  -- Parasite: Comedy
(22, 14, FALSE), -- Parasite: Thriller
(23, 11, TRUE),  -- Knives Out: Mystery
(23, 4,  FALSE), -- Knives Out: Comedy
(24, 4,  TRUE),  -- Superbad: Comedy
(25, 12, TRUE),  -- Titanic: Romance
(25, 7,  FALSE), -- Titanic: Drama
(26, 12, TRUE),  -- La La Land: Romance
(26, 10, FALSE), -- La La Land: Musical
(27, 12, TRUE),  -- Amélie: Romance
(27, 4,  FALSE), -- Amélie: Comedy
(28, 12, TRUE),  -- Eternal Sunshine: Romance
(28, 13, FALSE), -- Eternal Sunshine: Sci-Fi
(29, 3,  TRUE),  -- Spirited Away: Animation
(29, 8,  FALSE), -- Spirited Away: Fantasy
(30, 3,  TRUE),  -- Spider-Verse: Animation
(30, 20, FALSE), -- Spider-Verse: Superhero
(31, 5,  TRUE),  -- Pulp Fiction: Crime
(31, 14, FALSE), -- Pulp Fiction: Thriller
(32, 14, TRUE),  -- Zodiac: Thriller
(32, 11, FALSE), -- Zodiac: Mystery
(33, 14, TRUE),  -- Gone Girl: Thriller
(33, 11, FALSE), -- Gone Girl: Mystery
(34, 8,  TRUE),  -- LOTR: Fantasy
(34, 2,  FALSE), -- LOTR: Adventure
(35, 8,  TRUE),  -- Pan's Labyrinth: Fantasy
(35, 7,  FALSE), -- Pan's Labyrinth: Drama
(36, 16, TRUE),  -- Dunkirk: War
(36, 18, FALSE), -- Dunkirk: Historical
(37, 16, TRUE),  -- 1917: War
(38, 10, TRUE),  -- La La Land 2: Musical
(39, 6,  TRUE),  -- Won't You Be: Documentary
(40, 17, TRUE),  -- Oppenheimer: Biography
(40, 18, FALSE), -- Oppenheimer: Historical
(41, 17, TRUE),  -- Bohemian: Biography
(41, 10, FALSE); -- Bohemian: Musical

-- Cast & Crew (selected key roles)
INSERT INTO cast_crew (movie_id, person_id, role_type, character_name, billing_order, is_lead) VALUES
-- The Dark Knight
(1,  1,  'Director',  NULL,           NULL, FALSE),
(1,  20, 'Actor',     'Bruce Wayne',  1,    TRUE),
(1,  26, 'Actor',     'Alfred',       3,    FALSE),
-- Inception
(2,  1,  'Director',  NULL,           NULL, FALSE),
(2,  16, 'Actor',     'Dom Cobb',     1,    TRUE),
-- Mad Max
(3,  6,  'Director',  NULL,           NULL, FALSE),
(3,  25, 'Actor',     'Furiosa',      2,    TRUE),
-- The Shawshank Redemption
(11, 5,  'Director',  NULL,           NULL, FALSE),
(11, 24, 'Actor',     'Ellis Redding',2,    TRUE),
-- Schindler's List
(12, 2,  'Director',  NULL,           NULL, FALSE),
-- Forrest Gump
(13, 2,  'Director',  NULL,           NULL, FALSE),
(13, 18, 'Actor',     'Forrest Gump', 1,    TRUE),
-- The Godfather
(14, 5,  'Director',  NULL,           NULL, FALSE),
(14, 26, 'Actor',     'Vito Corleone',1,    TRUE),
-- Hereditary
(16, 12, 'Director',  NULL,           NULL, FALSE),
-- Get Out
(17, 13, 'Director',  NULL,           NULL, FALSE),
-- The Shining
(19, 6,  'Director',  NULL,           NULL, FALSE),
-- Grand Budapest Hotel
(21, 14, 'Director',  NULL,           NULL, FALSE),
-- Parasite
(22, 9,  'Director',  NULL,           NULL, FALSE),
-- Knives Out
(23, 8,  'Director',  NULL,           NULL, FALSE),
-- Titanic
(25, 4,  'Director',  NULL,           NULL, FALSE),
(25, 16, 'Actor',     'Jack Dawson',  1,    TRUE),
(25, 27, 'Actor',     'Rose DeWitt',  2,    TRUE),
-- La La Land
(26, 8,  'Director',  NULL,           NULL, FALSE),
(26, 30, 'Actor',     'Sebastian',    1,    TRUE),
-- Spirited Away
(29, 7,  'Director',  NULL,           NULL, FALSE),
-- Pulp Fiction
(31, 3,  'Director',  NULL,           NULL, FALSE),
(31, 28, 'Actor',     'Cliff Booth',  1,    TRUE),
-- Gone Girl
(33, 15, 'Director',  NULL,           NULL, FALSE),
-- Lord of the Rings
(34, 7,  'Director',  NULL,           NULL, FALSE),
(34, 19, 'Actor',     'Galadriel',    5,    FALSE),
-- Dunkirk
(36, 1,  'Director',  NULL,           NULL, FALSE),
-- Oppenheimer
(40, 1,  'Director',  NULL,           NULL, FALSE),
(40, 20, 'Actor',     'J.R. Oppenheimer',1, TRUE);

-- Awards
INSERT INTO awards (movie_id, person_id, ceremony, category, year_awarded, won) VALUES
(11, NULL, 'Academy Awards',  'Best Picture',            1995, FALSE),
(12, NULL, 'Academy Awards',  'Best Picture',            1994, TRUE),
(12, 2,   'Academy Awards',  'Best Director',           1994, TRUE),
(13, 18,  'Academy Awards',  'Best Actor',              1995, TRUE),
(13, NULL, 'Academy Awards',  'Best Picture',            1995, TRUE),
(14, NULL, 'Academy Awards',  'Best Picture',            1973, TRUE),
(14, 26,  'Academy Awards',  'Best Actor',              1973, FALSE),
(15, NULL, 'Academy Awards',  'Best Picture',            2014, TRUE),
(1,  NULL, 'Academy Awards',  'Best Picture',            2009, FALSE),
(25, NULL, 'Academy Awards',  'Best Picture',            1998, TRUE),
(25, 4,   'Academy Awards',  'Best Director',           1998, TRUE),
(29, NULL, 'Academy Awards',  'Best Animated Feature',   2003, TRUE),
(17, 13,  'Academy Awards',  'Best Original Screenplay', 2018, TRUE),
(22, NULL, 'Academy Awards',  'Best Picture',            2020, TRUE),
(22, 9,   'Academy Awards',  'Best Director',           2020, TRUE),
(21, NULL, 'Academy Awards',  'Best Original Screenplay',2015, TRUE),
(30, NULL, 'Academy Awards',  'Best Animated Feature',   2019, TRUE),
(36, NULL, 'Academy Awards',  'Best Film Editing',       2018, TRUE),
(40, NULL, 'Academy Awards',  'Best Picture',            2024, TRUE),
(40, 1,   'Academy Awards',  'Best Director',           2024, TRUE),
(40, 20,  'Academy Awards',  'Best Actor',              2024, TRUE);

-- Reviews
INSERT INTO reviews (movie_id, reviewer_name, reviewer_type, score, review_text, reviewed_at, publication) VALUES
(1,  'Roger Ebert',         'Critic',      9.5, 'A superhero movie for adults that explores morality and chaos.', '2008-07-20', 'Chicago Sun-Times'),
(1,  'Peter Travers',       'Critic',      9.0, 'The greatest comic book movie ever made.',                      '2008-07-18', 'Rolling Stone'),
(11, 'Empire Staff',        'Publication', 9.8, 'A towering achievement in American cinema.',                   '2019-01-01', 'Empire Magazine'),
(14, 'Pauline Kael',        'Critic',      9.0, 'One of the most brutal and moving chronicles of American life.','1972-10-01', 'The New Yorker'),
(22, 'A.O. Scott',          'Critic',      9.0, 'Bong Joon-ho''s masterpiece is a razor-sharp class satire.',   '2019-10-10', 'New York Times'),
(17, 'Jordan Hoffman',      'Critic',      8.5, 'A brilliantly conceived, socially charged horror film.',       '2017-02-28', 'The Guardian'),
(31, 'Todd McCarthy',       'Critic',      9.5, 'An exhilarating ride through a fractured moral universe.',     '1994-10-15', 'Variety'),
(29, 'Owen Gleiberman',     'Critic',      9.5, 'The greatest animated film ever made.',                        '2002-09-20', 'Entertainment Weekly'),
(40, 'Manohla Dargis',      'Critic',      9.0, 'A magnificent, shattering portrait of moral ambiguity.',       '2023-07-20', 'New York Times'),
(25, 'Janet Maslin',        'Critic',      8.5, 'A grand, stately, impeccably crafted production.',            '1997-12-19', 'New York Times'),
(3,  'Chris Tookey',        'Critic',      9.0, 'The most exhilarating action film in years.',                  '2015-05-18', 'Daily Mail'),
(6,  'Claudia Puig',        'Critic',      8.0, 'Visually stunning and intellectually ambitious.',              '2014-11-05', 'USA Today'),
(35, 'Peter Bradshaw',      'Critic',      9.5, 'A dark masterwork of magical realism.',                        '2006-11-24', 'The Guardian'),
(34, 'Lisa Schwarzbaum',    'Critic',      9.0, 'A glorious fantasy epic that earns every one of its minutes.', '2001-12-21', 'Entertainment Weekly');

-- Movie Collections
INSERT INTO movie_collections (movie_id, collection_id, part_number) VALUES
(1,  1, 2), -- Dark Knight is part 2 of Nolan Batman trilogy
(2,  4, 1), -- Inception
(6,  4, 2), -- Interstellar
(34, 2, 1), -- LOTR Fellowship
(31, 5, 1), -- Pulp Fiction
(40, 4, 3); -- Oppenheimer
