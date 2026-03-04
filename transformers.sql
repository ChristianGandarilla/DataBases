-- ============================================================
--  DATABASE: TRANSFORMERS UNIVERSE
--  Description: Relational schema of the Transformers universe
-- ============================================================

CREATE DATABASE IF NOT EXISTS transformers_universe;
USE transformers_universe;

-- ============================================================
-- TABLE 1: FACTIONS
-- Stores factions (Autobots, Decepticons, etc.)
-- ============================================================
CREATE TABLE factions (
    faction_id      INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    current_leader  VARCHAR(100),
    origin          VARCHAR(100) DEFAULT 'Cybertron',
    goal            TEXT,
    emblem_color    VARCHAR(50),
    active          BOOLEAN DEFAULT TRUE,
    founded_year    INT,  -- Year in Cybertronian cycles
    CONSTRAINT uq_faction_name UNIQUE (name)
);

-- ============================================================
-- TABLE 2: TRANSFORMERS (characters)
-- ============================================================
CREATE TABLE transformers (
    transformer_id  INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    alias           VARCHAR(100),
    faction_id      INT NOT NULL,
    rank            ENUM('Soldier','Lieutenant','Commander','Leader','Prime Minister','Prime') DEFAULT 'Soldier',
    class           VARCHAR(80),                  -- e.g. Warrior, Scout, Medic...
    home_planet     VARCHAR(100) DEFAULT 'Cybertron',
    status          ENUM('Active','Fallen','Missing','Reformatted') DEFAULT 'Active',
    power_level     INT CHECK (power_level BETWEEN 1 AND 100),
    max_speed       DECIMAL(8,2),                 -- km/h in vehicle mode
    description     TEXT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transformer_faction FOREIGN KEY (faction_id) REFERENCES factions(faction_id) ON DELETE RESTRICT
);

-- ============================================================
-- TABLE 3: ALTERNATE MODES
-- Each Transformer can have one or more transformation modes
-- ============================================================
CREATE TABLE alternate_modes (
    mode_id         INT AUTO_INCREMENT PRIMARY KEY,
    transformer_id  INT NOT NULL,
    mode_type       ENUM('Vehicle','Animal','Weapon','Spacecraft','Robot','Object') NOT NULL,
    description     VARCHAR(200),                 -- e.g. "Peterbilt 379 Semi Truck"
    primary_color   VARCHAR(50),
    secondary_color VARCHAR(50),
    speed           DECIMAL(8,2),
    extra_armament  BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_mode_transformer FOREIGN KEY (transformer_id) REFERENCES transformers(transformer_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE 4: PLANETS
-- Key planets in the Transformers universe
-- ============================================================
CREATE TABLE planets (
    planet_id       INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    galaxy          VARCHAR(100),
    distance_earth  BIGINT,                       -- In light years
    type            ENUM('Metallic','Organic','Mixed','Artificial','Destroyed') DEFAULT 'Organic',
    est_population  BIGINT,
    controlled_by   INT,                          -- FK to controlling faction (nullable)
    description     TEXT,
    CONSTRAINT uq_planet_name UNIQUE (name),
    CONSTRAINT fk_planet_faction FOREIGN KEY (controlled_by) REFERENCES factions(faction_id) ON DELETE SET NULL
);

-- ============================================================
-- TABLE 5: BATTLES
-- Historical record of battles in the universe
-- ============================================================
CREATE TABLE battles (
    battle_id       INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(200) NOT NULL,
    planet_id       INT,
    battle_date     VARCHAR(50),                  -- e.g. "4 million B.C."
    winning_faction INT,
    estimated_casualties INT DEFAULT 0,
    description     TEXT,
    outcome         ENUM('Autobot Victory','Decepticon Victory','Draw','Inconclusive') DEFAULT 'Inconclusive',
    CONSTRAINT fk_battle_planet  FOREIGN KEY (planet_id)       REFERENCES planets(planet_id)   ON DELETE SET NULL,
    CONSTRAINT fk_battle_faction FOREIGN KEY (winning_faction) REFERENCES factions(faction_id) ON DELETE SET NULL
);

-- ============================================================
-- TABLE 6: WEAPONS & ABILITIES
-- Special weapons and abilities for each Transformer
-- ============================================================
CREATE TABLE weapons_abilities (
    weapon_id       INT AUTO_INCREMENT PRIMARY KEY,
    transformer_id  INT NOT NULL,
    name            VARCHAR(150) NOT NULL,
    type            ENUM('Weapon','Ability','Shield','Combination') NOT NULL,
    damage_power    INT CHECK (damage_power BETWEEN 0 AND 1000),
    description     TEXT,
    energy_required INT DEFAULT 0,               -- In Energon units
    CONSTRAINT fk_weapon_transformer FOREIGN KEY (transformer_id) REFERENCES transformers(transformer_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE 7: BATTLE PARTICIPANTS (junction table)
-- ============================================================
CREATE TABLE battle_participants (
    participation_id INT AUTO_INCREMENT PRIMARY KEY,
    battle_id        INT NOT NULL,
    transformer_id   INT NOT NULL,
    side             ENUM('Attacker','Defender','Neutral') DEFAULT 'Attacker',
    survived         BOOLEAN DEFAULT TRUE,
    injuries         ENUM('None','Minor','Severe','Destroyed') DEFAULT 'None',
    CONSTRAINT fk_bp_battle      FOREIGN KEY (battle_id)      REFERENCES battles(battle_id)               ON DELETE CASCADE,
    CONSTRAINT fk_bp_transformer FOREIGN KEY (transformer_id) REFERENCES transformers(transformer_id)     ON DELETE CASCADE,
    CONSTRAINT uq_participation  UNIQUE (battle_id, transformer_id)
);

-- ============================================================
-- TABLE 8: ARTIFACTS (Universe relics)
-- ============================================================
CREATE TABLE artifacts (
    artifact_id     INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(150) NOT NULL,
    type            ENUM('Energy','Weapon','Knowledge','Control','Creation') NOT NULL,
    power_level     INT CHECK (power_level BETWEEN 1 AND 10),
    current_location INT,                         -- FK planet
    current_holder   INT,                         -- FK transformer
    description     TEXT,
    CONSTRAINT uq_artifact_name UNIQUE (name),
    CONSTRAINT fk_artifact_planet      FOREIGN KEY (current_location) REFERENCES planets(planet_id)               ON DELETE SET NULL,
    CONSTRAINT fk_artifact_transformer FOREIGN KEY (current_holder)   REFERENCES transformers(transformer_id)     ON DELETE SET NULL
);

-- ============================================================
-- SAMPLE DATA
-- ============================================================

-- Factions
INSERT INTO factions (name, current_leader, goal, emblem_color) VALUES
('Autobots',    'Optimus Prime', 'Protect all life forms and restore Cybertron',           'Red'),
('Decepticons', 'Megatron',      'Dominate the universe and enslave inferior races',        'Purple'),
('Predacons',   'Predaking',     'Conquer territories for the Predacon race',              'Dark Green'),
('Maximals',    'Optimus Primal','Preserve organic life and maintain peace in the universe','Blue'),
('Neutrals',    NULL,            'Survive outside of factional conflicts',                  'Gray');

-- Planets
INSERT INTO planets (name, galaxy, type, description) VALUES
('Cybertron',  'Milky Way',     'Metallic',    'Home planet of the Transformers, built entirely of metal'),
('Earth',      'Milky Way',     'Organic',     'Organic planet where many key battles take place'),
('Velocitron', 'Milky Way',     'Metallic',    'Planet dedicated to high-speed racing'),
('Gigantion',  'Andromeda',     'Metallic',    'Planet of giant Transformers'),
('Unicron',    'Intergalactic', 'Artificial',  'Planet-sized robot that devours worlds, enemy of all');

-- Transformers
INSERT INTO transformers (name, alias, faction_id, rank, class, power_level, max_speed, description) VALUES
('Optimus Prime', 'Prime',            1, 'Prime',       'Leader',         95, 200.00, 'Leader of the Autobots, bearer of the Matrix of Leadership'),
('Bumblebee',     'Bee',              1, 'Soldier',     'Scout',          70, 280.00, 'Scout and guardian of humans'),
('Ironhide',      NULL,               1, 'Lieutenant',  'Warrior',        80, 150.00, 'Weapons specialist of the Autobots'),
('Ratchet',       NULL,               1, 'Lieutenant',  'Medic',          60, 130.00, 'Chief medic and scientist of the Autobots'),
('Jazz',          NULL,               1, 'Lieutenant',  'Special Ops',    75, 260.00, 'Special operations expert'),
('Megatron',      'The Conqueror',    2, 'Prime',       'Leader',         98, 320.00, 'Leader of the Decepticons, bearer of the fusion cannon'),
('Starscream',    NULL,               2, 'Commander',   'Seeker',         82, 480.00, 'Second in command, treacherous by nature'),
('Soundwave',     NULL,               2, 'Commander',   'Communications', 85, 220.00, 'Decepticon communications officer, loyal to Megatron'),
('Shockwave',     NULL,               2, 'Commander',   'Scientist',      90, 180.00, 'Chief scientist of the Decepticons, pure logic'),
('Devastator',    'The Devastator',   2, 'Leader',      'Combiner',       99,  80.00, 'Combination of the 6 Constructicons, a massively destructive force');

-- Alternate modes
INSERT INTO alternate_modes (transformer_id, mode_type, description, primary_color, secondary_color) VALUES
(1, 'Vehicle',    'Peterbilt 379 Semi Truck with trailer', 'Red',    'Blue'),
(2, 'Vehicle',    'Yellow 2009 Chevrolet Camaro',          'Yellow', 'Black'),
(3, 'Vehicle',    'Black GMC Topkick C5500',               'Black',  'Gray'),
(4, 'Vehicle',    'Hummer H2 Ambulance',                   'White',  'Red'),
(6, 'Vehicle',    'Silver war tank / Fusion jet',          'Silver', 'Purple'),
(7, 'Spacecraft', 'F-22 Raptor combat jet',                'Gray',   'Red'),
(8, 'Vehicle',    'Satellite dish / Communications vehicle','Blue',   'Black');

-- Battles
INSERT INTO battles (name, planet_id, battle_date, outcome, description) VALUES
('Fall of Cybertron',    1, '4 million B.C.', 'Draw',               'First great civil war between Autobots and Decepticons on Cybertron'),
('Battle of Mission City',2, '2007',          'Autobot Victory',    'First battle on Earth over the AllSpark cube'),
('Battle of Egypt',      2, '2009',           'Autobot Victory',    'Confrontation at the pyramids over the Sun Harvester'),
('Battle of Chicago',    2, '2011',           'Autobot Victory',    'Decepticons attempt to transport Cybertron to Earth'),
('Battle of Hong Kong',  2, '2014',           'Autobot Victory',    'Lockdown and the Creators hunt down surviving Transformers');

-- Weapons & Abilities
INSERT INTO weapons_abilities (transformer_id, name, type, damage_power, description) VALUES
(1, 'Ion Blaster',         'Weapon',   850, 'Long-range ion rifle, Optimus Prime''s primary weapon'),
(1, 'Energon Swords',      'Weapon',   780, 'Energy blades that emerge from his forearms'),
(1, 'Matrix of Leadership','Ability',  999, 'Sacred artifact of the Primes, capable of destroying cosmic threats'),
(2, 'Plasma Cannon',       'Weapon',   600, 'Plasma cannon mounted on his arm'),
(6, 'Fusion Cannon',       'Weapon',   950, 'Megatron''s supreme weapon, capable of destroying in a single shot'),
(6, 'Dark Sword',          'Weapon',   870, 'Ancient blade forged in the core of Cybertron'),
(7, 'Null Missiles',       'Weapon',   700, 'Missiles that temporarily neutralize enemies'),
(8, 'Spy Cassettes',       'Ability',  500, 'Deploys Mini-Cassettes like Ravage and Laserbeak as spies'),
(9, 'Particle Cannon',     'Weapon',   920, 'Single-eye particle cannon, extremely precise');

-- Artifacts
INSERT INTO artifacts (name, type, power_level, description) VALUES
('AllSpark Cube',          'Creation', 10, 'Source of life for all Transformers, can create or destroy'),
('Matrix of Leadership',   'Energy',   10, 'Sacred artifact passed down among the Primes'),
('Sun Harvester',          'Energy',    9, 'Ancient machine capable of draining the energy of a star'),
('Staff of the Primes',    'Control',   9, 'Command staff of the original Primes'),
('Key of Vector Sigma',    'Creation',  8, 'Key that grants life and a soul to new Transformers');

-- Battle participants
INSERT INTO battle_participants (battle_id, transformer_id, side, survived, injuries) VALUES
(2, 1, 'Defender', TRUE,  'Minor'),
(2, 2, 'Defender', TRUE,  'Minor'),
(2, 6, 'Attacker', FALSE, 'Destroyed'),
(3, 1, 'Defender', TRUE,  'Severe'),
(3, 6, 'Attacker', FALSE, 'Destroyed'),
(4, 1, 'Defender', TRUE,  'Severe'),
(4, 7, 'Attacker', TRUE,  'Minor'),
(5, 1, 'Defender', TRUE,  'None'),
(5, 9, 'Attacker', TRUE,  'None');
