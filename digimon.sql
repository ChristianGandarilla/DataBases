-- ============================================================
--  DIGIMON DATABASE SCHEMA
--  Entities: 15 | Triggers: Audit Log | Sample Queries
-- ============================================================
--
--  ENTITIES:
--    1.  digimon           - Core Digimon registry
--    2.  digimon_types     - Data, Vaccine, Virus, Free, Unknown
--    3.  attributes        - Fire, Water, Wind, Earth, Thunder, etc.
--    4.  stages            - Fresh, In-Training, Rookie, Champion, Ultimate, Mega, Ultra
--    5.  evolutions        - Evolution paths between Digimon
--    6.  attacks           - Moves and special abilities
--    7.  digimon_attacks   - Many-to-many: Digimon <-> Attacks
--    8.  tamers            - Human partners / tamers
--    9.  tamer_digimon     - Many-to-many: Tamers <-> Digimon (partnership)
--   10.  digivices         - Device used by tamers
--   11.  regions           - Digital World regions
--   12.  habitats          - Where each Digimon lives
--   13.  battles           - Recorded battles between Digimon
--   14.  battle_participants - Digimon involved in each battle
--   15.  audit_log         - CRUD tracking via triggers
-- ============================================================


-- ============================================================
--  1. DIGIMON_TYPES
-- ============================================================
CREATE TABLE digimon_types (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(50) NOT NULL UNIQUE,  -- Data, Vaccine, Virus, Free, Unknown
    description TEXT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
--  2. ATTRIBUTES
-- ============================================================
CREATE TABLE attributes (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(50) NOT NULL UNIQUE,  -- Fire, Water, Wind, Earth, Thunder, Ice, Light, Dark, Neutral
    description TEXT,
    color_hex   VARCHAR(7),                   -- visual reference e.g. '#FF4500'
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
--  3. STAGES
-- ============================================================
CREATE TABLE stages (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(50) NOT NULL UNIQUE,  -- Fresh, In-Training, Rookie, Champion, Ultimate, Mega, Ultra
    level_order INT NOT NULL UNIQUE,          -- 1 = Fresh ... 7 = Ultra
    description TEXT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
--  4. DIGIMON
-- ============================================================
CREATE TABLE digimon (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    name            VARCHAR(100) NOT NULL UNIQUE,
    stage_id        INT NOT NULL,
    type_id         INT NOT NULL,
    attribute_id    INT NOT NULL,
    hp              INT NOT NULL DEFAULT 100,
    mp              INT NOT NULL DEFAULT 100,
    attack          INT NOT NULL DEFAULT 10,
    defense         INT NOT NULL DEFAULT 10,
    speed           INT NOT NULL DEFAULT 10,
    description     TEXT,
    image_url       VARCHAR(255),
    is_legendary    BOOLEAN DEFAULT FALSE,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (stage_id)     REFERENCES stages(id),
    FOREIGN KEY (type_id)      REFERENCES digimon_types(id),
    FOREIGN KEY (attribute_id) REFERENCES attributes(id)
);

-- ============================================================
--  5. EVOLUTIONS
-- ============================================================
CREATE TABLE evolutions (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    from_digimon_id INT NOT NULL,
    to_digimon_id   INT NOT NULL,
    condition       VARCHAR(255),             -- e.g. 'Level 20+, Friendship 80%'
    is_natural      BOOLEAN DEFAULT TRUE,     -- FALSE = Warp/Dark evolution
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_digimon_id) REFERENCES digimon(id),
    FOREIGN KEY (to_digimon_id)   REFERENCES digimon(id),
    UNIQUE (from_digimon_id, to_digimon_id)
);

-- ============================================================
--  6. ATTACKS
-- ============================================================
CREATE TABLE attacks (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    power       INT NOT NULL DEFAULT 10,
    mp_cost     INT NOT NULL DEFAULT 5,
    attribute_id INT,                         -- elemental affinity (nullable)
    is_special   BOOLEAN DEFAULT FALSE,       -- signature / super move
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (attribute_id) REFERENCES attributes(id)
);

-- ============================================================
--  7. DIGIMON_ATTACKS  (many-to-many)
-- ============================================================
CREATE TABLE digimon_attacks (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    digimon_id  INT NOT NULL,
    attack_id   INT NOT NULL,
    is_default  BOOLEAN DEFAULT FALSE,        -- signature move of this Digimon
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (digimon_id) REFERENCES digimon(id),
    FOREIGN KEY (attack_id)  REFERENCES attacks(id),
    UNIQUE (digimon_id, attack_id)
);

-- ============================================================
--  8. TAMERS
-- ============================================================
CREATE TABLE tamers (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100) NOT NULL,
    age         INT,
    hometown    VARCHAR(100),
    crest       VARCHAR(100),                 -- e.g. Courage, Friendship, Love
    description TEXT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
--  9. TAMER_DIGIMON  (many-to-many partnership)
-- ============================================================
CREATE TABLE tamer_digimon (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    tamer_id        INT NOT NULL,
    digimon_id      INT NOT NULL,
    bond_level      INT DEFAULT 50,           -- 0-100 friendship/bond score
    partnership_date DATE,
    notes           TEXT,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tamer_id)   REFERENCES tamers(id),
    FOREIGN KEY (digimon_id) REFERENCES digimon(id),
    UNIQUE (tamer_id, digimon_id)
);

-- ============================================================
--  10. DIGIVICES
-- ============================================================
CREATE TABLE digivices (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    tamer_id    INT NOT NULL,
    model       VARCHAR(100) NOT NULL,        -- e.g. 'Digivice v1', 'D-3', 'D-Power'
    color       VARCHAR(50),
    acquired_at DATE,
    active      BOOLEAN DEFAULT TRUE,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tamer_id) REFERENCES tamers(id)
);

-- ============================================================
--  11. REGIONS
-- ============================================================
CREATE TABLE regions (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    climate     VARCHAR(100),
    danger_level ENUM('Safe', 'Low', 'Medium', 'High', 'Extreme') DEFAULT 'Low',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
--  12. HABITATS  (Digimon <-> Region)
-- ============================================================
CREATE TABLE habitats (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    digimon_id  INT NOT NULL,
    region_id   INT NOT NULL,
    is_native   BOOLEAN DEFAULT TRUE,
    population  ENUM('Rare', 'Uncommon', 'Common', 'Abundant') DEFAULT 'Uncommon',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (digimon_id) REFERENCES digimon(id),
    FOREIGN KEY (region_id)  REFERENCES regions(id),
    UNIQUE (digimon_id, region_id)
);

-- ============================================================
--  13. BATTLES
-- ============================================================
CREATE TABLE battles (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    region_id       INT,
    battle_date     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    winner_id       INT,                      -- digimon_id of winner (NULL = draw)
    description     TEXT,
    rounds          INT DEFAULT 1,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (region_id)  REFERENCES regions(id),
    FOREIGN KEY (winner_id)  REFERENCES digimon(id)
);

-- ============================================================
--  14. BATTLE_PARTICIPANTS
-- ============================================================
CREATE TABLE battle_participants (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    battle_id   INT NOT NULL,
    digimon_id  INT NOT NULL,
    hp_start    INT,
    hp_end      INT,
    result      ENUM('Win', 'Loss', 'Draw') NOT NULL,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (battle_id)  REFERENCES battles(id),
    FOREIGN KEY (digimon_id) REFERENCES digimon(id),
    UNIQUE (battle_id, digimon_id)
);

-- ============================================================
--  15. AUDIT_LOG
-- ============================================================
CREATE TABLE audit_log (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    date        DATETIME DEFAULT CURRENT_TIMESTAMP,
    user        VARCHAR(150),
    `table`     VARCHAR(100) NOT NULL,
    operation   ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    record_id   INT,
    old_data    JSON,
    new_data    JSON
);


-- ============================================================
--  SAMPLE DATA - INSERT STATEMENTS
-- ============================================================

-- ---- DIGIMON TYPES ----
INSERT INTO digimon_types (name, description) VALUES
('Vaccine',  'Effective against Virus types; represents justice and protection'),
('Virus',    'Effective against Data types; often associated with chaos and power'),
('Data',     'Effective against Vaccine types; neutral and balanced'),
('Free',     'Not affected by type advantages; unpredictable'),
('Unknown',  'Type not classified; often legendary or mysterious');

-- ---- ATTRIBUTES ----
INSERT INTO attributes (name, description, color_hex) VALUES
('Fire',     'Flame-based attacks and heat resistance',      '#FF4500'),
('Water',    'Water and ice attacks',                        '#1E90FF'),
('Wind',     'Air and storm-based attacks',                  '#98FB98'),
('Earth',    'Ground and rock-based attacks',                '#8B4513'),
('Thunder',  'Lightning and electric attacks',               '#FFD700'),
('Ice',      'Blizzard and freezing attacks',                '#ADD8E6'),
('Light',    'Holy and divine energy attacks',               '#FFFACD'),
('Dark',     'Shadow and corruption-based attacks',          '#4B0082'),
('Neutral',  'No elemental affinity',                        '#C0C0C0');

-- ---- STAGES ----
INSERT INTO stages (name, level_order, description) VALUES
('Fresh',       1, 'Newly born Digimon, very weak and small'),
('In-Training', 2, 'Early growth stage, limited abilities'),
('Rookie',      3, 'First stable battle form, base of most adventure teams'),
('Champion',    4, 'Mid-level evolution with stronger attacks'),
('Ultimate',    5, 'Advanced form with powerful skills'),
('Mega',        6, 'Peak evolution for most Digimon'),
('Ultra',       7, 'Transcendent form beyond Mega, extremely rare');

-- ---- DIGIMON ----
INSERT INTO digimon (name, stage_id, type_id, attribute_id, hp, mp, attack, defense, speed, description, is_legendary) VALUES
-- Fresh
('Botamon',    1, 4, 9,  50,  20,  3,  3,  5, 'A small black blob, the fresh form of Agumon.', FALSE),
('Poyomon',    1, 4, 9,  50,  20,  3,  3,  5, 'A tiny white blob, the fresh form of Patamon.',  FALSE),
-- In-Training
('Koromon',    2, 4, 1,  80,  40,  8,  6, 10, 'Pink ball with big ears; pre-evolution of Agumon.', FALSE),
('Tokomon',    2, 4, 9,  80,  40,  6,  6, 15, 'White ball with sharp teeth; pre-evolution of Patamon.', FALSE),
-- Rookie
('Agumon',     3, 1, 1, 150, 100, 22, 18, 20, 'Classic orange dinosaur Digimon; partner of Tai.', FALSE),
('Gabumon',    3, 1, 6, 140, 110, 20, 22, 18, 'Wolf-like Digimon wearing a pelt; partner of Matt.', FALSE),
('Patamon',    3, 1, 7, 130, 120, 18, 16, 22, 'Small hamster-like creature with wing ears; partner of T.K.', FALSE),
('Terriermon', 3, 1, 9, 145, 115, 21, 17, 24, 'White rabbit-like Digimon; partner of Henry.', FALSE),
('Guilmon',    3, 2, 1, 160, 100, 25, 18, 19, 'Red dinosaur Digimon; partner of Takato.', FALSE),
('Renamon',    3, 2, 9, 140, 130, 23, 15, 28, 'Tall yellow fox Digimon; partner of Rika.', FALSE),
-- Champion
('Greymon',    4, 1, 1, 350, 150, 55, 45, 35, 'Giant blue-striped dinosaur; evolution of Agumon.', FALSE),
('Garurumon',  4, 1, 6, 330, 160, 52, 50, 45, 'Large white wolf Digimon; evolution of Gabumon.', FALSE),
('Angemon',    4, 1, 7, 300, 200, 48, 48, 40, 'Six-winged angel warrior; evolution of Patamon.', FALSE),
('Kyubimon',   4, 2, 1, 310, 180, 54, 40, 50, 'Nine-tailed fox wreathed in flames; evolution of Renamon.', FALSE),
('Growlmon',   4, 2, 1, 360, 140, 58, 42, 30, 'Large red dragon Digimon; evolution of Guilmon.', FALSE),
-- Ultimate
('MetalGreymon', 5, 1, 1, 650, 250, 95, 80, 55, 'Cyborg dinosaur with missile launchers; evolution of Greymon.', FALSE),
('WereGarurumon',5, 1, 6, 600, 270, 92, 75, 75, 'Werewolf-form of Garurumon; master martial artist.', FALSE),
('MagnaAngemon',  5, 1, 7, 560, 350, 88, 90, 65, 'Eight-winged angelic knight; evolution of Angemon.', FALSE),
('Rapidmon',    5, 1, 9, 580, 300, 90, 72, 90, 'Armored rabbit warrior at high speed; evolution of Gargomon.', FALSE),
('WarGrowlmon', 5, 2, 1, 670, 230, 98, 82, 50, 'Gigantic mechanized dragon; evolution of Growlmon.', FALSE),
-- Mega
('WarGreymon',  6, 1, 1, 1200, 400, 180, 150, 110,'Chrome Digizoid-armored dragon warrior; partner of Tai.', FALSE),
('MetalGarurumon',6,1, 6,1150, 420, 175, 165, 120,'Metallic wolf with missile arsenal; partner of Matt.', FALSE),
('Seraphimon', 6, 1, 7, 1000, 600, 160, 180, 100,'Sovereign angel of the Digital World.', TRUE),
('Gallantmon', 6, 2, 7, 1150, 450, 178, 158, 108,'Holy knight born from Guilmon and Takato.', TRUE),
('Sakuyamon',  6, 2, 9, 1050, 520, 170, 145, 115,'Shrine maiden warrior; evolution of Taomon.', FALSE),
-- Ultra
('Omnimon',    7, 5, 7, 2500, 800, 300, 280, 200,'Fusion of WarGreymon and MetalGarurumon; supreme commander.', TRUE),
('Omnimon Alter-B', 7, 5, 8, 2400, 750, 290, 270, 210,'Dark counterpart of Omnimon; immense destructive power.', TRUE);

-- ---- EVOLUTIONS ----
INSERT INTO evolutions (from_digimon_id, to_digimon_id, condition, is_natural) VALUES
(1,  3,  'Natural growth after hatching',         TRUE),
(2,  4,  'Natural growth after hatching',         TRUE),
(3,  5,  'Level 10+',                             TRUE),
(4,  7,  'Level 10+, high bond',                  TRUE),
(5,  11, 'Level 20+, Friendship 60%',             TRUE),
(6,  12, 'Level 20+, Friendship 60%',             TRUE),
(7,  13, 'Level 20+, Courage 70%',                TRUE),
(9,  15, 'Level 20+, Sync Rate 65%',              TRUE),
(10, 14, 'Level 20+, Sync Rate 65%',              TRUE),
(11, 16, 'Level 35+, Crest of Courage activated', TRUE),
(12, 17, 'Level 35+, Crest of Friendship activated', TRUE),
(13, 18, 'Level 35+, Crest of Hope activated',   TRUE),
(15, 20, 'Level 35+, Sync Rate 80%',              TRUE),
(14, 25, 'Level 35+, Sync Rate 80%',              TRUE),
(16, 21, 'Level 50+, Crest fully activated',      TRUE),
(17, 22, 'Level 50+, Crest fully activated',      TRUE),
(18, 23, 'Level 50+, divine bond',                TRUE),
(20, 24, 'Biomerge: Takato + Guilmon fusion',     FALSE),
(25, 25, 'Level 50+, ultimate sync',              FALSE),
(21, 26, 'DNA Digivolution: WarGreymon + MetalGarurumon', FALSE);

-- ---- ATTACKS ----
INSERT INTO attacks (name, description, power, mp_cost, attribute_id, is_special) VALUES
('Pepper Breath',      'Shoots a small fireball from the mouth',                   20,  10, 1, FALSE),
('Nova Blast',         'Releases a massive fireball explosion',                     85,  40, 1, TRUE),
('Terra Force',        'Gathers all surrounding energy into a massive ball',       180,  90, 1, TRUE),
('Blue Blaster',       'Shoots a concentrated stream of blue flame',               22,  10, 6, FALSE),
('Howling Blaster',    'Fires a powerful cold energy beam',                         80,  38, 6, TRUE),
('Metal Wolf Claw',    'Slashes with metallic claws at light speed',              170,  85, 6, TRUE),
('Angel Rod',          'Strikes with a divine staff of light',                      18,  12, 7, FALSE),
('Hand of Fate',       'Seals the enemy in a divine prison',                       100,  55, 7, TRUE),
('Strike of the Seven Stars', 'Fires seven holy orbs simultaneously',             195,  95, 7, TRUE),
('Diamond Storm',      'Fires a volley of razor-sharp shards',                      55,  25, 9, FALSE),
('Fox Tail Inferno',   'Sweeps nine flaming tails at the enemy',                   155,  75, 1, TRUE),
('Pyro Sphere',        'Launches a blazing energy sphere',                          25,  12, 1, FALSE),
('Plasma Shoot',       'Fires plasma balls in rapid succession',                    65,  30, 5, FALSE),
('Atomic Blaster',     'Unleashes full-power nuclear-level blast',                 185,  92, 1, TRUE),
('Particle Cannon',    'Fires a devastating beam from chest cannons',              172,  88, 9, TRUE),
('Royal Saber',        'Slices with the legendary holy sword',                     195,  90, 7, TRUE),
('Shield of the Just', 'Divine shield that reflects attacks',                        0,  45, 7, FALSE),
('Transcendent Sword', 'WarGreymon arm blade cleaves through everything',          190,  92, 1, TRUE),
('Garuru Tomahawk',    'Fires a massive missile shaped like a wolf',               188,  91, 6, TRUE),
('Omega Sword',        'Omnimon''s sword channel the power of both partners',     300, 150, 7, TRUE),
('Supreme Cannon',     'Omnimon fires a cannon of absolute zero energy',           295, 145, 6, TRUE);

-- ---- DIGIMON_ATTACKS ----
INSERT INTO digimon_attacks (digimon_id, attack_id, is_default) VALUES
-- Agumon
(5,  1,  TRUE),
(5,  2,  FALSE),
-- Greymon
(11, 2,  TRUE),
(11, 1,  FALSE),
-- MetalGreymon
(16, 14, TRUE),
(16, 3,  FALSE),
-- WarGreymon
(21, 18, TRUE),
(21, 3,  FALSE),
-- Gabumon
(6,  4,  TRUE),
(6,  5,  FALSE),
-- Garurumon
(12, 5,  TRUE),
(12, 4,  FALSE),
-- MetalGarurumon
(22, 15, TRUE),
(22, 19, FALSE),
-- Patamon
(7,  7,  TRUE),
-- Angemon
(13, 7,  TRUE),
(13, 8,  FALSE),
-- MagnaAngemon
(18, 9,  TRUE),
(18, 8,  FALSE),
-- Seraphimon
(23, 9,  TRUE),
-- Renamon
(10, 10, TRUE),
(10, 13, FALSE),
-- Guilmon
(9,  12, TRUE),
(9,  13, FALSE),
-- Gallantmon
(24, 16, TRUE),
(24, 17, FALSE),
-- Sakuyamon
(25, 11, TRUE),
-- Omnimon
(26, 20, TRUE),
(26, 21, FALSE),
-- Terriermon
(8,  13, TRUE);

-- ---- TAMERS ----
INSERT INTO tamers (first_name, last_name, age, hometown, crest, description) VALUES
('Tai',     'Kamiya',    11, 'Odaiba, Tokyo',  'Courage',      'Leader of the DigiDestined; bold and brave.'),
('Matt',    'Ishida',    11, 'Odaiba, Tokyo',  'Friendship',   'Cool and independent; older brother of T.K.'),
('Sora',    'Takenouchi',11, 'Odaiba, Tokyo',  'Love',         'Caring and nurturing; best friend of Tai.'),
('T.K.',    'Takaishi',  8,  'Odaiba, Tokyo',  'Hope',         'Younger brother of Matt; pure-hearted.'),
('Takato',  'Matsuki',   10, 'Shinjuku, Tokyo','N/A',          'Creative card-game enthusiast who created Guilmon.'),
('Henry',   'Wong',      10, 'Shinjuku, Tokyo','N/A',          'Calm and strategic; half-Chinese tamer.'),
('Rika',    'Nonaka',    10, 'Shinjuku, Tokyo','N/A',          'Fierce and competitive; the Digimon Queen.');

-- ---- TAMER_DIGIMON ----
INSERT INTO tamer_digimon (tamer_id, digimon_id, bond_level, partnership_date, notes) VALUES
(1, 5,  100, '1999-08-01', 'Tai and Agumon — iconic duo; bond evolved into WarGreymon'),
(1, 21, 100, '1999-09-01', 'Agumon''s Mega form; achieved with Crest of Courage'),
(2, 6,  100, '1999-08-01', 'Matt and Gabumon — deep brotherly bond'),
(2, 22, 100, '1999-09-01', 'MetalGarurumon; achieved with Crest of Friendship'),
(4, 7,  95,  '1999-08-01', 'T.K. and Patamon — hope and innocence'),
(4, 13, 95,  '1999-08-15', 'Angemon; sacrificed himself for T.K. in battle'),
(5, 9,  100, '2001-04-01', 'Takato created Guilmon from his drawings'),
(5, 24, 100, '2001-07-01', 'Gallantmon; Takato and Guilmon biomerged'),
(6, 8,  90,  '2001-04-01', 'Henry and Terriermon — calm and steady partnership'),
(7, 10, 88,  '2001-04-01', 'Rika and Renamon — fierce and competitive team');

-- ---- DIGIVICES ----
INSERT INTO digivices (tamer_id, model, color, acquired_at, active) VALUES
(1, 'Digivice v1',  'Grey',        '1999-08-01', TRUE),
(2, 'Digivice v1',  'White/Blue',  '1999-08-01', TRUE),
(3, 'Digivice v1',  'Red',         '1999-08-01', TRUE),
(4, 'Digivice v1',  'Yellow',      '1999-08-01', TRUE),
(5, 'D-Power',      'Red/White',   '2001-04-01', TRUE),
(6, 'D-Power',      'Green/White', '2001-04-01', TRUE),
(7, 'D-Power',      'Purple/White','2001-04-01', TRUE);

-- ---- REGIONS ----
INSERT INTO regions (name, description, climate, danger_level) VALUES
('File Island',      'First Digital World island; ancient and mysterious',             'Temperate',   'Low'),
('Server Continent', 'Vast continent ruled by the Dark Masters',                       'Variable',    'High'),
('Folder Continent', 'Mountainous region home to many Champion Digimon',               'Alpine',      'Medium'),
('Net Ocean',        'Digital ocean teeming with Aquatic Digimon',                     'Tropical',    'Medium'),
('Shinjuku Suburbs', 'Real-world digital pocket; Tamers series main battlefield',      'Urban',       'High'),
('Dark Area',        'Realm of deleted Digimon; extremely dangerous',                  'Void/Eternal','Extreme'),
('Sacred City',      'Holy city protected by Angelic Digimon',                         'Warm',        'Safe'),
('Chrome Mines',     'Underground Chrome Digizoid deposits and mechanized Digimon',    'Industrial',  'High');

-- ---- HABITATS ----
INSERT INTO habitats (digimon_id, region_id, is_native, population) VALUES
(5,  1, TRUE,  'Common'),
(6,  1, TRUE,  'Common'),
(7,  1, TRUE,  'Common'),
(11, 2, TRUE,  'Uncommon'),
(12, 2, TRUE,  'Uncommon'),
(13, 7, TRUE,  'Rare'),
(16, 8, TRUE,  'Rare'),
(17, 2, TRUE,  'Rare'),
(21, 2, FALSE, 'Rare'),
(22, 2, FALSE, 'Rare'),
(23, 7, TRUE,  'Rare'),
(26, 7, TRUE,  'Rare'),
(9,  5, TRUE,  'Uncommon'),
(10, 5, TRUE,  'Uncommon'),
(24, 6, FALSE, 'Rare');

-- ---- BATTLES ----
INSERT INTO battles (region_id, battle_date, winner_id, description, rounds) VALUES
(2, '1999-09-15 14:00:00', 21, 'WarGreymon vs MetalSeadramon — Server Continent showdown',          3),
(5, '2001-06-20 18:30:00', 24, 'Gallantmon vs Beelzemon — decisive battle in Shinjuku',             5),
(7, '1999-09-20 12:00:00', 26, 'Omnimon destroys Diaboromon in the Net — legendary battle',         2),
(6, '2001-07-25 22:00:00', 26, 'Omnimon vs Omnimon Alter-B — clash of light and darkness',          7),
(1, '1999-08-10 10:00:00', 11, 'Greymon first battle on File Island',                               1),
(3, '1999-08-25 16:00:00', 12, 'Garurumon defends the Folder Continent pass',                       2),
(5, '2001-05-15 20:00:00', NULL,'Guilmon vs Renamon — drawn sparring match between tamers',         3),
(2, '1999-09-18 09:00:00', 22, 'MetalGarurumon vs Puppetmon in the forest',                         4);

-- ---- BATTLE_PARTICIPANTS ----
INSERT INTO battle_participants (battle_id, digimon_id, hp_start, hp_end, result) VALUES
-- Battle 1: WarGreymon vs MetalSeadramon
(1, 21, 1200,  320, 'Win'),
-- Battle 2: Gallantmon vs Beelzemon
(2, 24, 1150,  210, 'Win'),
-- Battle 3: Omnimon vs Diaboromon
(3, 26, 2500, 1800, 'Win'),
-- Battle 4: Omnimon vs Omnimon Alter-B
(4, 26, 2500,  450, 'Win'),
(4, 27, 2400,    0, 'Loss'),
-- Battle 5: Greymon on File Island
(5, 11,  350,  180, 'Win'),
-- Battle 6: Garurumon
(6, 12,  330,  200, 'Win'),
-- Battle 7: Guilmon vs Renamon draw
(7, 9,  160,   55, 'Draw'),
(7, 10, 140,   60, 'Draw'),
-- Battle 8: MetalGarurumon vs Puppetmon
(8, 22, 1150,  620, 'Win');