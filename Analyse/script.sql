DELIMITER $$
CREATE PROCEDURE all_users(OUT status INT)
BEGIN
    DECLARE user_count INT;
    -- Compter le nombre d'utilisateurs
    SELECT COUNT(*) INTO user_count FROM users;
    
    -- Vérifier si la table est vide
    IF user_count = 0 THEN
        SET status = 0;
    ELSE
        SET status = 1;
        -- Retourner la liste des utilisateurs
        SELECT * FROM users;
    END IF;
END $$

DELIMITER $$

CREATE PROCEDURE Ajouter_user_si_existe(
    IN p_nom VARCHAR(45), 
    IN p_prenom VARCHAR(45),
    IN p_email VARCHAR(200),
    IN p_phone VARCHAR(10)
)
BEGIN
    DECLARE user_count INT;

    -- Vérifier si l'utilisateur existe
    SELECT COUNT(*) INTO user_count FROM users WHERE email = p_email;

    IF user_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur : Impossible d\'ajouter, cet utilisateur n\'existe pas.';
    ELSE
        -- Ajouter un nouvel enregistrement
        INSERT INTO users (nom, prenom, email, phone) 
        VALUES (p_nom, p_prenom, p_email, p_phone);
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE Modifier_user(
    IN p_id INT,
    IN p_nom VARCHAR(45), 
    IN p_prenom VARCHAR(45),
    IN p_email VARCHAR(200),
    IN p_phone VARCHAR(10)
)
BEGIN
    DECLARE user_count INT;
    DECLARE email_count INT;
    DECLARE reference_count INT;

    -- Vérifier si l'utilisateur existe
    SELECT COUNT(*) INTO user_count FROM users WHERE id = p_id;

    IF user_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur : L\'utilisateur avec cet ID n\'existe pas.';
    ELSE
        -- Vérifier si l'email est déjà utilisé par un autre utilisateur
        SELECT COUNT(*) INTO email_count FROM users WHERE email = p_email AND id <> p_id;

        IF email_count > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erreur : Cet email est déjà utilisé par un autre utilisateur.';
        ELSE
            -- Vérifier les références dans d'autres tables (exemple : commandes)
            SELECT COUNT(*) INTO reference_count FROM commandes WHERE user_id = p_id;

            IF reference_count > 0 THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Erreur : Impossible de modifier cet utilisateur car il est référencé dans des commandes.';
            ELSE
                -- Mettre à jour les informations de l'utilisateur
                UPDATE users 
                SET nom = p_nom, prenom = p_prenom, email = p_email, phone = p_phone
                WHERE id = p_id;
            END IF;
        END IF;
    END IF;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE Supprimer_user(IN p_id INT)
BEGIN
    DECLARE user_count INT;
    DECLARE integrity_violation INT;

    -- Vérifier si l'utilisateur existe
    SELECT COUNT(*) INTO user_count FROM users WHERE id = p_id;

    IF user_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur : L\'utilisateur avec cet ID n\'existe pas.';
    ELSE
        -- Vérifier si l'utilisateur est référencé dans d'autres tables
        SELECT COUNT(*) INTO integrity_violation FROM commandes WHERE user_id = p_id;

        IF integrity_violation > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erreur : Impossible de supprimer cet utilisateur car il est référencé dans la table commandes.';
        ELSE
            -- Supprimer l'utilisateur si aucune contrainte d'intégrité n'est violée
            DELETE FROM users WHERE id = p_id;
        END IF;
    END IF;
END $$

DELIMITER ;



