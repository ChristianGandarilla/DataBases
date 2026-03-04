
-- Base de Datos de One Piece (Optimizada para MySQL)

CREATE DATABASE IF NOT EXISTS one_piece_db;
USE one_piece_db;

-- TABLAS

CREATE TABLE frutas_del_diablo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo ENUM('Paramecia', 'Zoan', 'Logia') NOT NULL,
    descripcion TEXT
);

CREATE TABLE lugares (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50),
    descripcion TEXT
);

CREATE TABLE habilidades (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
);

CREATE TABLE tripulaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    barco VARCHAR(100),
    lider VARCHAR(100)
);

CREATE TABLE personajes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apodo VARCHAR(100),
    recompensa DECIMAL(15,2),
    fruta_del_diablo_id INT,
    tripulacion_id INT,
    genero ENUM('Masculino', 'Femenino', 'Otro'),
    origen_id INT,
    es_protagonista BOOLEAN,
    FOREIGN KEY (fruta_del_diablo_id) REFERENCES frutas_del_diablo(id),
    FOREIGN KEY (tripulacion_id) REFERENCES tripulaciones(id),
    FOREIGN KEY (origen_id) REFERENCES lugares(id)
);

CREATE TABLE enemigos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    organizacion VARCHAR(100),
    fruta_del_diablo_id INT,
    recompensa DECIMAL(15,2),
    FOREIGN KEY (fruta_del_diablo_id) REFERENCES frutas_del_diablo(id)
);

CREATE TABLE batallas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    personaje_id INT,
    enemigo_id INT,
    lugar_id INT,
    resultado ENUM('Victoria', 'Derrota', 'Empate'),
    fecha DATE,
    FOREIGN KEY (personaje_id) REFERENCES personajes(id),
    FOREIGN KEY (enemigo_id) REFERENCES enemigos(id),
    FOREIGN KEY (lugar_id) REFERENCES lugares(id)
);

CREATE TABLE episodios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200),
    numero INT,
    sinopsis TEXT,
    fecha_emision DATE
);

CREATE TABLE personajes_episodios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    personaje_id INT,
    episodio_id INT,
    FOREIGN KEY (personaje_id) REFERENCES personajes(id),
    FOREIGN KEY (episodio_id) REFERENCES episodios(id)
);

-- INSERTS BASES

INSERT INTO tripulaciones (nombre, barco, lider) VALUES
('Sombrero de Paja', 'Thousand Sunny', 'Monkey D. Luffy'),
('Heart Pirates', 'Polar Tang', 'Trafalgar D. Water Law');

INSERT INTO frutas_del_diablo (nombre, tipo, descripcion) VALUES
('Him no Mi', 'Zoan', 'Ball control let admit sure physical only.'),
('Reflect no Mi', 'Paramecia', 'American themselves now everyone.'),
('Apply no Mi', 'Paramecia', 'Receive court attack.'),
('Loss no Mi', 'Zoan', 'Measure whether war hope black.'),
('Small no Mi', 'Logia', 'Require leader data set issue measure.'),
('Institution no Mi', 'Paramecia', 'Scientist major brother state.'),
('Defense no Mi', 'Paramecia', 'Travel site author stage energy approach consider.'),
('Question no Mi', 'Logia', 'Course hold represent husband artist among listen.'),
('Voice no Mi', 'Paramecia', 'Foot husband mean successful role traditional tough.'),
('Seven no Mi', 'Logia', 'Factor character yard which these give door standard.'),
('Front no Mi', 'Paramecia', 'Professional high risk.'),
('Benefit no Mi', 'Paramecia', 'Be she able record care mean.'),
('Region no Mi', 'Paramecia', 'Girl kitchen natural follow material give.'),
('Thousand no Mi', 'Logia', 'Politics church ability generation work rather full.'),
('Type no Mi', 'Logia', 'Detail design stay single ok approach organization.'),
('Writer no Mi', 'Zoan', 'Property girl price project.'),
('Six no Mi', 'Paramecia', 'Few world yet difference have standard.'),
('Run no Mi', 'Paramecia', 'Player main east.'),
('Station no Mi', 'Zoan', 'Item interview dark speech learn.'),
('Challenge no Mi', 'Logia', 'Around market house political.'),
('Education no Mi', 'Logia', 'Job another say.'),
('Identify no Mi', 'Logia', 'Ok have fight food.'),
('Scene no Mi', 'Zoan', 'Serve road many down yeah paper.'),
('Religious no Mi', 'Zoan', 'Hour herself with once list current.'),
('Painting no Mi', 'Paramecia', 'Tonight cold any certainly name company.'),
('Instead no Mi', 'Paramecia', 'Increase forget care goal tree.');

INSERT INTO lugares (nombre, tipo, descripcion) VALUES
('Mitchelltown', 'Mar', 'Without information sit past.'),
('West Paige', 'Ciudad', 'Evening tree occur spring wear forward foreign.'),
('Matthewville', 'Ciudad', 'Agree war appear trial property particular.'),
('Lake Michellefort', 'Mar', 'Suffer court way.'),
('Greenberg', 'Reino', 'Player issue himself make various center.'),
('South Toddshire', 'Isla', 'Attention ever around exist six.'),
('East Audreyfurt', 'Reino', 'Computer maintain determine financial news.'),
('New Matthewton', 'Reino', 'Meet central section she night guy.'),
('North Robertview', 'Mar', 'By baby total bar significant ten space.'),
('Aaronton', 'Reino', 'Sometimes major night measure.'),
('New Sharonview', 'Isla', 'Mean moment third hit spend pattern.'),
('Jonathanberg', 'Isla', 'My lose debate education gun change perhaps.'),
('Jacquelinetown', 'Isla', 'Personal any image.'),
('Ricetown', 'Mar', 'She available offer direction.'),
('Jeremyside', 'Mar', 'Find report court good eat hospital.'),
('Shannonfort', 'Isla', 'Feeling entire blue girl off.'),
('Joville', 'Isla', 'Chair live approach look.'),
('South Shirley', 'Isla', 'Theory change recently.'),
('East Gregorystad', 'Mar', 'Beautiful brother series above citizen several.'),
('Sharpborough', 'Isla', 'Truth safe can stand candidate gun by.'),
('Calebfurt', 'Ciudad', 'Wear reveal region relate.'),
('Port Debra', 'Ciudad', 'Blood care point matter modern leg.'),
('Samuelshire', 'Reino', 'Look Mr admit guy leave office happen.'),
('Fernandezville', 'Mar', 'Trouble will reach recognize.'),
('Blevinsstad', 'Isla', 'Reason member decide effect under.'),
('Cruzhaven', 'Ciudad', 'Share road own attack picture mother.');

INSERT INTO habilidades (nombre, descripcion) VALUES
('From', 'Out system during.'),
('Building', 'Tax range gun during election five.'),
('Most', 'Hospital international money two.'),
('Then', 'American prepare field else soon and.'),
('Born', 'Month room back hour onto culture more.'),
('Military', 'Sell shake space serve protect.'),
('Citizen', 'Resource consumer near up.'),
('Wish', 'School head dog.'),
('Bag', 'Develop likely such president avoid.'),
('Direction', 'Inside hot yes stock.'),
('Else', 'Budget shake budget media.'),
('Find', 'Activity hospital may pattern.'),
('Student', 'Floor rather clearly why national back.'),
('Hear', 'Box standard best clearly life.'),
('Low', 'Them deep world card admit full month.'),
('Author', 'Attack once step.'),
('Party', 'Relationship lay three her plan.'),
('Lose', 'Determine source father itself.'),
('Mother', 'Anything source between law difficult.'),
('Structure', 'Candidate become from outside fill.'),
('Require', 'Sea defense rate.'),
('Right', 'Give growth sense series with.'),
('Leader', 'Baby bad summer size together trouble.'),
('Shake', 'Process detail establish surface war.'),
('Everyone', 'Under college chance goal.'),
('Win', 'Big past likely.'),
('Suggest', 'Play public this put.'),
('Bill', 'Star sound despite power.'),
('Full', 'Head end manage forget someone six.'),
('Difference', 'Major teacher the indeed theory.');

INSERT INTO personajes (nombre, apodo, recompensa, fruta_del_diablo_id, tripulacion_id, genero, origen_id, es_protagonista) VALUES
('Adam Washington', 'Manager', 1070592327.04, 13, 1, 'Femenino', 8, TRUE),
('Scott Porter', 'Teach', 246678743.70, 13, 2, 'Otro', 25, TRUE),
('Tammy Martinez', 'Tell', 497769509.87, 30, 1, 'Masculino', 20, FALSE),
('Anthony Romero', 'Position', 750136181.42, 7, 2, 'Otro', 27, TRUE),
('Raymond Bautista', 'Mr', 3759892.29, 5, 1, 'Femenino', 29, FALSE),
('Joseph Jimenez', 'Firm', 893099688.73, 28, 2, 'Masculino', 7, TRUE),
('Rose Tate', 'Mother', 257721178.84, 8, 2, 'Masculino', 2, TRUE),
('Julie Woodward', 'Set', 1323950307.84, 16, 2, 'Femenino', 25, TRUE),
('Diana Castillo', 'Her', 101752381.58, 15, 1, 'Femenino', 6, TRUE),
('Kaylee Patel', 'Available', 913882414.55, 2, 2, 'Otro', 2, TRUE),
('John Vazquez', 'Only', 280687278.07, 18, 1, 'Femenino', 13, FALSE),
('Jack Roth', 'Why', 223777036.33, 1, 2, 'Masculino', 26, FALSE),
('Debra Morales', 'Civil', 1428532493.34, 13, 2, 'Masculino', 22, TRUE),
('Bradley Barnes', 'Describe', 386989526.53, 16, 2, 'Masculino', 1, TRUE),
('Stacey Gonzalez', 'Together', 954319650.55, 20, 1, 'Femenino', 6, TRUE),
('Katherine Griffin', 'Nature', 589152465.22, 29, 2, 'Masculino', 8, FALSE),
('Jennifer Padilla', 'First', 1039256472.32, 29, 1, 'Otro', 21, FALSE),
('Michelle Fuller', 'Future', 1134601386.34, 29, 2, 'Masculino', 15, FALSE),
('Laurie Grant', 'Theory', 718276016.31, 1, 2, 'Masculino', 8, TRUE),
('Nicholas Davis', 'Teach', 1062616754.18, 5, 2, 'Femenino', 8, TRUE),
('Tony Adams', 'Newspaper', 1152328073.98, 20, 2, 'Otro', 20, TRUE),
('Tabitha Page', 'Million', 509194810.45, 18, 2, 'Otro', 3, TRUE),
('Gregory Calhoun', 'Minute', 548634230.29, 1, 1, 'Otro', 13, TRUE),
('Heather Bryant', 'Discuss', 745132845.14, 1, 2, 'Femenino', 5, FALSE),
('Jeffrey Harris', 'Pm', 492154535.93, 23, 1, 'Masculino', 6, TRUE),
('Jessica Norris', 'Staff', 802770536.35, 13, 1, 'Otro', 27, TRUE),
('Gail Gentry', 'Picture', 656857751.65, 10, 2, 'Femenino', 25, FALSE),
('Terry York', 'Of', 908953772.98, 8, 1, 'Femenino', 14, FALSE),
('Tammy Williams', 'Door', 326931482.94, 20, 1, 'Femenino', 1, TRUE),
('Jamie Wright', 'Form', 778760642.41, 20, 2, 'Otro', 27, TRUE),
('Dominic Fernandez', 'Purpose', 728667575.83, 23, 2, 'Femenino', 28, FALSE),
('David Lambert', 'Election', 622744851.36, 19, 2, 'Otro', 19, TRUE),
('Lisa Andersen', 'Father', 180100337.48, 4, 2, 'Otro', 1, FALSE),
('Angela Ramsey', 'Different', 139671639.18, 17, 1, 'Femenino', 30, TRUE),
('Joshua Martin', 'Weight', 62876821.35, 18, 2, 'Otro', 8, TRUE),
('Jason Richard', 'Property', 34085861.79, 25, 2, 'Femenino', 11, TRUE),
('Teresa Smith', 'Police', 604516043.85, 1, 1, 'Masculino', 26, FALSE),
('Jasmine Snyder', 'Choice', 811557046.26, 23, 1, 'Femenino', 8, TRUE),
('Jennifer Lee', 'Use', 497372886.65, 6, 2, 'Femenino', 3, TRUE),
('Desiree Atkinson', 'Window', 495332505.59, 5, 1, 'Otro', 6, FALSE),
('Kevin Clark', 'Experience', 216443778.07, 29, 1, 'Masculino', 2, FALSE),
('William Navarro', 'Pull', 398249554.69, 30, 1, 'Masculino', 1, FALSE),
('Theresa Lewis', 'Parent', 179371707.12, 3, 2, 'Otro', 11, FALSE),
('Diane Abbott', 'Want', 1470382378.93, 30, 2, 'Otro', 22, FALSE),
('Jonathan Young', 'Different', 52040327.95, 30, 2, 'Masculino', 27, FALSE),
('Mark Dunlap', 'Increase', 810744138.00, 30, 1, 'Femenino', 2, FALSE);

INSERT INTO enemigos (nombre, organizacion, fruta_del_diablo_id, recompensa) VALUES
('Mrs. Elizabeth Morales MD', 'Moore, Brooks and Bennett', 15, 205877998.56),
('Nicholas Hughes', 'May Inc', 14, 732470833.35),
('Randall Wolf', 'Gardner-Stewart', 8, 147361824.31),
('Roberto Santos', 'Weaver-Gray', 9, 597273970.13),
('Jared Russell', 'Schmidt, Carter and Miller', 20, 972172431.63),
('Stacy Cruz', 'Jones-Lee', 28, 704750146.47),
('Alexander Webb', 'Mack-Hurst', 18, 645970479.54),
('Rachel Hull', 'Brown, Morris and Mclean', 8, 559841316.98),
('Phillip Velez', 'Martinez-Grimes', 23, 511910489.61),
('Jessica Day', 'Stone Ltd', 9, 969147940.40),
('Joshua Young', 'Willis LLC', 5, 541902163.81),
('Dillon Carr', 'Snyder-Martinez', 20, 44564077.86),
('Jonathan Martinez', 'Shaw-Santos', 9, 149606275.41),
('Ashley Peters', 'White-Hart', 26, 71907652.09),
('Stephanie Jenkins', 'Wright PLC', 13, 855128815.57),
('Natasha Diaz', 'Mcclure, Johnson and Klein', 27, 486964004.25),
('Charlene Flores', 'Collins, Johnson and Clark', 11, 278966934.74),
('Stephen Sanders', 'Taylor-Browning', 29, 15157632.11),
('Jill Mejia', 'Logan-Webb', 12, 815180180.82),
('Daniel Washington', 'Lopez LLC', 10, 412504706.08),
('Christopher Werner', 'Hernandez and Sons', 11, 78910804.48),
('Gary Hodges', 'Reynolds-Salas', 23, 22295845.79),
('Keith Johnson', 'Carpenter LLC', 7, 370410598.48),
('Kimberly Hood', 'Carey, Herring and Hernandez', 16, 651118859.89),
('Natalie Smith', 'Massey-Gaines', 15, 949639292.81),
('Mitchell Moore', 'Mcknight, Adams and Duran', 11, 718737119.08),
('Justin Hodges', 'Chen, Taylor and Hanson', 21, 774623927.22);