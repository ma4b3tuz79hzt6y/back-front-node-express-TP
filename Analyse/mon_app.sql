-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mon_app
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `mon_app` ;

-- -----------------------------------------------------
-- Schema mon_app
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mon_app` DEFAULT CHARACTER SET big5 ;
USE `mon_app` ;

-- -----------------------------------------------------
-- Table `mon_app`.`users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mon_app`.`users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nom` VARCHAR(45) NOT NULL,
  `prenom` VARCHAR(45) NOT NULL,
  `email` VARCHAR(200) NULL DEFAULT NULL,
  `phone` VARCHAR(45) NULL DEFAULT NULL,
  `adresse` VARCHAR(200) NULL DEFAULT 'INCONNUE',
  PRIMARY KEY (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 13
DEFAULT CHARACTER SET = big5;

CREATE UNIQUE INDEX `email_UNIQUE` ON `mon_app`.`users` (`email` ASC) VISIBLE;

CREATE UNIQUE INDEX `phone_UNIQUE` ON `mon_app`.`users` (`phone` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `mon_app`.`commandes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mon_app`.`commandes` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `date_cmd` DATE NULL DEFAULT NULL,
  `tva` DECIMAL(4,2) NOT NULL,
  `montant_ht` DOUBLE(10,2) NULL DEFAULT '0.00',
  `montant_ttc` DOUBLE(10,2) NULL DEFAULT '0.00',
  `numero_facture` VARCHAR(45) NULL DEFAULT 'AUCUNE',
  `paye` VARCHAR(3) NULL DEFAULT 'NON',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_commandes_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `mon_app`.`users` (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 180
DEFAULT CHARACTER SET = big5;

CREATE INDEX `fk_commandes_users_idx` ON `mon_app`.`commandes` (`user_id` ASC) VISIBLE;

USE `mon_app` ;

-- -----------------------------------------------------
-- procedure Ajouter_commande
-- -----------------------------------------------------

DELIMITER $$
USE `mon_app`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Ajouter_commande`(
    IN p_user_id int, 
    IN p_date_cmd date,
    IN p_tva double(4,2)
    
)
BEGIN
    DECLARE user_count INT;
    
    SELECT COUNT(*) INTO user_count FROM users WHERE id = p_user_id;
    
    IF user_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur : Cet utilisateur n\'existe pas';
    ELSE
        
        INSERT INTO commandes (user_id, date_cmd, tva) 
        VALUES (p_user_id, p_date_cmd, p_tva);
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure Ajouter_user
-- -----------------------------------------------------

DELIMITER $$
USE `mon_app`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Ajouter_user`(
    IN p_nom VARCHAR(45), 
    IN p_prenom VARCHAR(45),
    IN p_email VARCHAR(200),
    IN p_phone VARCHAR(10)
)
BEGIN
    DECLARE user_count INT;
    
    
    SELECT COUNT(*) INTO user_count FROM users WHERE (email = p_email)
     OR (phone = p_phone);
    
    IF user_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur : Cet utilisateur existe déjà.';
    ELSE
        
        INSERT INTO users (nom, prenom, email, phone) 
        VALUES (p_nom, p_prenom, p_email, p_phone);
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure Modifier_commande
-- -----------------------------------------------------

DELIMITER $$
USE `mon_app`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Modifier_commande`(
    IN p_id INT,
    IN p_user_id int, 
    IN p_date_cmd date,
    IN p_tva double(4,2)
)
BEGIN
    
    DECLARE commande_count INT;
    
    SELECT COUNT(*) INTO commande_count FROM commandes 
     WHERE (id = p_id)  and  (user_id = p_user_id);

    IF commande_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur : La Commande  avec cet ID n\'existe pas.';
    ELSE
        
        UPDATE commandes 
        SET user_id = p_user_id, date_cmd = p_date_cmd, tva = p_tva
        WHERE id = p_id;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure Modifier_user
-- -----------------------------------------------------

DELIMITER $$
USE `mon_app`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Modifier_user`(
    IN p_id INT,
    IN p_nom VARCHAR(45), 
    IN p_prenom VARCHAR(45),
    IN p_email VARCHAR(200),
    IN p_phone VARCHAR(10)
)
BEGIN
    DECLARE user_count INT;

    
    SELECT COUNT(*) INTO user_count FROM users WHERE id = p_id;

    IF user_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur : L\'utilisateur avec cet ID n\'existe pas.';
    ELSE
        
        UPDATE users 
        SET nom = p_nom, prenom = p_prenom, email = p_email, phone = p_phone
        WHERE id = p_id;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure Supprimer_commande
-- -----------------------------------------------------

DELIMITER $$
USE `mon_app`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Supprimer_commande`(IN p_id INT)
BEGIN
    DECLARE commande_count INT;
    
    SELECT COUNT(*) INTO commande_count FROM commandes WHERE id = p_id;

    IF commande_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur : La Commande avec cet ID n\'existe pas.';
    
        ELSE
            
            DELETE FROM commandes WHERE id = p_id;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure Supprimer_user
-- -----------------------------------------------------

DELIMITER $$
USE `mon_app`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Supprimer_user`(IN p_id INT)
BEGIN
    DECLARE user_count INT;
    DECLARE integrity_violation INT;

    
    SELECT COUNT(*) INTO user_count FROM users WHERE id = p_id;

    IF user_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur : L\'utilisateur avec cet ID n\'existe pas.';
    ELSE
        
        SELECT COUNT(*) INTO integrity_violation FROM commandes WHERE user_id = p_id;

        IF integrity_violation > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erreur : Impossible de supprimer cet utilisateur car des enregistrements associés existent.';
        ELSE
            
            DELETE FROM users WHERE id = p_id;
        END IF;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure all_commandes
-- -----------------------------------------------------

DELIMITER $$
USE `mon_app`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `all_commandes`(OUT status INT)
BEGIN
    DECLARE commande_count INT;
    
    
    SELECT COUNT(*) INTO commande_count FROM commandes;
    
    
    IF commande_count = 0 THEN
        SET status = 0;
    ELSE
        SET status = 1;
        
        SELECT * FROM commandes;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure all_users
-- -----------------------------------------------------

DELIMITER $$
USE `mon_app`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `all_users`(OUT status INT)
BEGIN
    DECLARE user_count INT;
    
    
    SELECT COUNT(*) INTO user_count FROM users;
    
    
    IF user_count = 0 THEN
        SET status = 0;
    ELSE
        SET status = 1;
        
        SELECT * FROM users;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure et Fonction utilitaires
-- generation numero automatique de la facture
-- calcul sommation des facrures
-- Calcul montants payée
-- Autre selon besoin
-- -----------------------------------------------------
-- -----------------------------------------------------
-- procedure generate_numero_facture
-- -----------------------------------------------------

DELIMITER $$
USE `mon_app`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_numero_facture`(p_id INT)
BEGIN
    Declare facture_date DATE;
    Declare user INT;
    Declare facture_existe VARCHAR(45); 
    
    select user_id, numero_facture ,date_cmd into user,
    facture_existe,facture_date from commandes  
    where id = p_id;
    
    IF facture_existe = "AUCUNE"  THEN 
    
    SET facture_existe = CONCAT('FAC-', user, '-', DATE_FORMAT(facture_date, '%Y%m%d'), '-', DATE_FORMAT(CURRENT_TIME(), '%H%i%s'));
    END IF;
    update  commandes set  numero_facture = facture_existe where id = p_id;
END$$

DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
