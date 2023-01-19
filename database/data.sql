START TRANSACTION;

CREATE DATABASE easelive_demo;
USE easelive_demo;
CREATE TABLE words (id int NOT NULL AUTO_INCREMENT, word varchar(255) NOT NULL, PRIMARY KEY (id));

INSERT INTO words (word) VALUES ("Friends");

COMMIT;
