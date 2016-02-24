CREATE TABLE players (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  manager_id INTEGER,

  FOREIGN KEY(manager_id) REFERENCES manager(id)
);

CREATE TABLE managers (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  team_id INTEGER,

  FOREIGN KEY(team_id) REFERENCES manager(id)
);

CREATE TABLE teams (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

INSERT INTO
  teams (id, name)
VALUES
  (1, "Mets"), (2, "Yankees");

INSERT INTO
  managers (id, fname, lname, team_id)
VALUES
  (1, "Terry", "Collins", 1),
  (2, "Joe", "Girardi", 1),
  (3, "Dusty", "Baker", 2),
  (4, "Fredi", "Gonzalez", NULL),
  (5, "Dan", "Warthen", 1);

INSERT INTO
  players (id, name, manager_id)
VALUES
  (1, "Degrom", 1),
  (2, "A-Rod", 2),
  (3, "Harper", 3),
  (4, "Scherzer", 3),
  (5, "Desmond", NULL);
