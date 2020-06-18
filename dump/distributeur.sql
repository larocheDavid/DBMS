-- phpMyAdmin SQL Dump
-- version 5.0.1
-- https://www.phpmyadmin.net/
--
-- Hôte : db
-- Généré le : jeu. 18 juin 2020 à 12:08
-- Version du serveur :  8.0.19
-- Version de PHP : 7.4.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `distributeur`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`root`@`%` PROCEDURE `achats_assurance` (IN `nom_assurance` VARCHAR(12))  NO SQL
SELECT no_patient, id_distributeur, date, intitule_med, quantite FROM achats
INNER JOIN patients ON achats.no_patient = patients.no_avs
INNER JOIN assurances ON assurances.no = patients.no_assurance
WHERE assurances.nom = nom_assurance$$

CREATE DEFINER=`root`@`%` PROCEDURE `achat_patient` (IN `no_patient` VARCHAR(16))  NO SQL
SELECT * FROM achats
WHERE no_patient = achats.no_patient$$

CREATE DEFINER=`root`@`%` PROCEDURE `chiffre_affaire_distributeur` (IN `id_distributeur` INT, IN `date_debut` DATE, IN `date_fin` DATE)  NO SQL
SELECT SUM(achats.quantite*prix) AS chiffre_affaire_distributeur
FROM achats
INNER JOIN contient ON achats.id_distributeur = contient.id_distributeur AND achats.intitule_med = contient.intitule_med
WHERE achats.id_distributeur = id_distributeur AND achats.date > date_debut AND achats.date < date_fin$$

CREATE DEFINER=`root`@`%` PROCEDURE `chiffre_affaire_distributeur_produit` (IN `id_distributeur` INT, IN `intitule_med` VARCHAR(9), IN `date_debut` DATE, IN `date_fin` DATE)  NO SQL
SELECT achats.intitule_med, SUM(achats.quantite*prix) AS chiffre_affaire_distributeur
FROM achats
INNER JOIN contient ON achats.id_distributeur = contient.id_distributeur AND achats.intitule_med = contient.intitule_med
WHERE achats.intitule_med = intitule_med AND achats.id_distributeur = id_distributeur AND achats.date > date_debut AND achats.date < date_fin
GROUP BY achats.intitule_med$$

CREATE DEFINER=`root`@`%` PROCEDURE `chiffre_affaire_produit` (IN `intule_med` VARCHAR(9), IN `date_debut` DATE, IN `date_fin` DATE)  NO SQL
SELECT achats.intitule_med, SUM(achats.quantite*prix) AS chiffre_affaire
FROM achats
INNER JOIN distributeurs ON achats.id_distributeur = distributeurs.id
INNER JOIN contient ON achats.intitule_med = contient.intitule_med
WHERE achats.intitule_med = intule_med AND achats.date > date_debut AND achats.date < date_fin
GROUP BY achats.intitule_med$$

CREATE DEFINER=`root`@`%` PROCEDURE `chiffre_affaire_societe` (IN `nom_societe` VARCHAR(19), IN `date_debut` DATE, IN `date_fin` DATE)  NO SQL
SELECT SUM(achats.quantite*prix) AS chiffre_affaire_societe
FROM achats
INNER JOIN contient ON achats.id_distributeur = contient.id_distributeur
INNER JOIN distributeurs ON contient.id_distributeur = distributeurs.id AND achats.intitule_med = contient.intitule_med
WHERE achats.date > date_debut AND achats.date < date_fin AND distributeurs.nom_societe = nom_societe$$

CREATE DEFINER=`root`@`%` PROCEDURE `chiffre_affaire_societe_mere` (IN `nom_societe_mere` VARCHAR(13), IN `date_debut` DATE, IN `date_fin` DATE)  NO SQL
SELECT SUM(achats.quantite*prix) AS chiffre_affaire_societe
FROM achats
INNER JOIN contient ON achats.id_distributeur = contient.id_distributeur
AND achats.intitule_med = contient.intitule_med
INNER JOIN distributeurs ON contient.id_distributeur = distributeurs.id
INNER JOIN societes_filles ON distributeurs.nom_societe = societes_filles.nom
WHERE societes_filles.nom_mere = nom_societe_mere AND achats.date > date_debut AND achats.date < date_fin$$

CREATE DEFINER=`root`@`%` PROCEDURE `liste_medecin_assurance` (IN `nom_assurance` VARCHAR(12))  NO SQL
SELECT medecins.prenom, medecins.nom, no_medecin
FROM medecins
INNER JOIN ordonnances ON ordonnances.no_medecin = medecins.no_avs
INNER JOIN patients ON ordonnances.no_patient = patients.no_avs
INNER JOIN assurances on patients.no_assurance = assurances.no
WHERE assurances.nom = nom_assurance
GROUP BY(no_medecin)$$

CREATE DEFINER=`root`@`%` PROCEDURE `ordonnance_medecin` (IN `no_medecin` VARCHAR(16))  NO SQL
SELECT no_medecin, ordonnances.id_ordonnance, no_patient, intitule_med, quantite FROM ordonnances
LEFT JOIN inclut ON ordonnances.id_ordonnance = inclut.id_ordonnance 
WHERE ordonnances.no_medecin = no_medecin$$

CREATE DEFINER=`root`@`%` PROCEDURE `ordonnance_patient` (IN `no_patient` VARCHAR(16))  NO SQL
SELECT * FROM ordonnances
WHERE ordonnances.no_patient = no_patient$$

CREATE DEFINER=`root`@`%` PROCEDURE `restock` (IN `intitule_med` VARCHAR(9), IN `quantite_ajoute` INT, IN `id_distributeur` INT)  NO SQL
UPDATE contient SET quantite = (quantite + quantite_ajoute) WHERE intitule_med = intitule_med AND id_distributeur = id_distributeur$$

CREATE DEFINER=`root`@`%` PROCEDURE `show_stock` (IN `id_distributeur` INT)  NO SQL
SELECT * FROM contient
WHERE contient.id_distributeur = id_distributeur$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `achats`
--

CREATE TABLE `achats` (
  `intitule_med` varchar(9) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `id_distributeur` int NOT NULL,
  `no_patient` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `date` datetime NOT NULL,
  `quantite` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `achats`
--

INSERT INTO `achats` (`intitule_med`, `id_distributeur`, `no_patient`, `date`, `quantite`) VALUES
('Aspirin', 1, '102.0337.1896.04', '2020-06-17 22:38:49', 10),
('Aspirin', 1, '725.4625.1176.35', '2020-06-17 22:38:49', 10),
('Tryptanol', 1, '104.4238.1230.70', '2020-06-17 23:01:03', 5);

--
-- Déclencheurs `achats`
--
DELIMITER $$
CREATE TRIGGER `autorisation_achat` AFTER INSERT ON `achats` FOR EACH ROW BEGIN
DECLARE autorised bit;
SET autorised = (SELECT autorisation 
                 FROM produits
                 INNER JOIN medicaments
                 ON medicaments.DCI = produits.DCI
                 WHERE medicaments.intitule = NEW.intitule_med);

IF NOT EXISTS (SELECT *
FROM ordonnances
LEFT JOIN inclut ON ordonnances.id_ordonnance = inclut.id_ordonnance
WHERE ordonnances.no_patient = NEW.no_patient and inclut.intitule_med = NEW.intitule_med) AND autorised THEN
SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Medicament sous ordonnance';
END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `en_stock` AFTER INSERT ON `achats` FOR EACH ROW BEGIN
  DECLARE stock int;
  SET stock = ( SELECT quantite FROM contient WHERE NEW.id_distributeur = contient.id_distributeur
                    AND NEW.intitule_med = contient.intitule_med);

IF (stock < NEW.quantite OR stock IS NULL) THEN
SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Stock insuffisant';
END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_stock` AFTER INSERT ON `achats` FOR EACH ROW UPDATE contient 
SET quantite = quantite - NEW.quantite
WHERE NEW.id_distributeur = contient.id_distributeur AND
NEW.intitule_med = contient.intitule_med
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `achat_totaux`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `achat_totaux` (
`nom_medicament` varchar(9)
,`total` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Structure de la table `assurances`
--

CREATE TABLE `assurances` (
  `no` int NOT NULL,
  `nom` varchar(12) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `telephone` int DEFAULT NULL,
  `localite` varchar(9) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `email` varchar(17) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `assurances`
--

INSERT INTO `assurances` (`no`, `nom`, `telephone`, `localite`, `email`) VALUES
(8, 'CSS', 582771111, 'Luzern', 'css.info@css.ch'),
(290, 'CONCORDIA', 412280111, 'Luzern', 'info@concordia.ch'),
(1542, 'Assura-Basis', 217214411, 'Pully', 'assura@assura.ch'),
(1555, 'Visana', 313579111, 'Bern', 'info@visana.ch'),
(1562, 'Helsana', 433401111, 'Dübendorf', '');

-- --------------------------------------------------------

--
-- Structure de la table `contient`
--

CREATE TABLE `contient` (
  `intitule_med` varchar(9) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `id_distributeur` int NOT NULL,
  `quantite` int NOT NULL,
  `prix` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `contient`
--

INSERT INTO `contient` (`intitule_med`, `id_distributeur`, `quantite`, `prix`) VALUES
('Aspirin', 1, 60, 3),
('Aspirin', 2, 60, 3),
('Aspirin', 3, 97, 3),
('Concerta', 2, 67, 13),
('Dormicum', 4, 37, 8),
('Focalin', 2, 77, 18),
('Ritalin', 2, 57, 9),
('Tryptanol', 1, 47, 16),
('Tryptanol', 3, 32, 16),
('Xanax', 1, 102, 12);

-- --------------------------------------------------------

--
-- Structure de la table `distributeurs`
--

CREATE TABLE `distributeurs` (
  `id` int NOT NULL,
  `adresse` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `nom_societe` varchar(19) NOT NULL,
  `canton` varchar(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `distributeurs`
--

INSERT INTO `distributeurs` (`id`, `adresse`, `nom_societe`, `canton`) VALUES
(1, 'quais des volontaires 2', 'Amavita', 'GE'),
(2, 'chemin du bois 9', 'Pharmacie Populaire', 'GE'),
(3, 'route de la pierre 32', 'Sunstore', 'GE'),
(4, 'rue benedicte 6', 'Pharmacie Plus', 'NE'),
(5, 'chemin de la faucille 12', 'Coop Vitality', 'VS'),
(6, 'chemin de bellevue 3', 'Amavita', 'VD');

-- --------------------------------------------------------

--
-- Structure de la table `fabrique`
--

CREATE TABLE `fabrique` (
  `no_lot` int NOT NULL,
  `nom_producteur` varchar(13) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `DCI` varchar(15) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `fabrique`
--

INSERT INTO `fabrique` (`no_lot`, `nom_producteur`, `DCI`) VALUES
(1, 'Bayer', 'Aspirine'),
(1, 'Janssen-Cilag', 'Methylphenidate'),
(1, 'Novartis', 'Methylphenidate'),
(1, 'Nycomed', 'Zolpidem'),
(1, 'Obs', 'Amitriptyline'),
(1, 'Pfizer', 'Alprazolam'),
(1, 'Roche', 'Diazepam'),
(1, 'Roche', 'Midazolam'),
(1, 'Sanofi', 'Zolpidem');

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `factures_client`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `factures_client` (
`prenom` varchar(11)
,`nom` varchar(12)
,`no_avs` varchar(16)
,`date` datetime
,`nom_assurance` varchar(12)
,`id_distributeur` int
,`intitule_med` varchar(9)
,`quantite` int
,`prix` int
,`total` bigint
);

-- --------------------------------------------------------

--
-- Structure de la table `inclut`
--

CREATE TABLE `inclut` (
  `id_ordonnance` int NOT NULL,
  `intitule_med` varchar(9) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `quantite` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `inclut`
--

INSERT INTO `inclut` (`id_ordonnance`, `intitule_med`, `quantite`) VALUES
(1, 'Tryptanol', 5),
(1, 'Xanax', 2),
(2, 'Focalin', 3),
(3, 'Concerta', 3),
(3, 'Focalin', 5),
(18, 'Valium', 2),
(19, 'Tryptanol', 5),
(19, 'Valium', 5),
(24, 'Dormicum', 5);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `individus`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `individus` (
`prenom` varchar(11)
,`nom` varchar(12)
,`no_avs` varchar(16)
,`canton` varchar(2)
);

-- --------------------------------------------------------

--
-- Structure de la table `medecins`
--

CREATE TABLE `medecins` (
  `prenom` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `nom` varchar(9) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `no_avs` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `canton` varchar(2) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `specialite` varchar(12) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `autorisation` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `medecins`
--

INSERT INTO `medecins` (`prenom`, `nom`, `no_avs`, `canton`, `specialite`, `autorisation`) VALUES
('Sid', 'Whinney', '037.3205.2348.53', 'NE', 'Interniste', 1),
('Megan', 'Frow', '072.7352.7867.27', 'NE', 'Pneumologue', 1),
('Gerhardine', 'Perrie', '080.6113.2973.54', 'NE', 'Generaliste', 1),
('Borg', 'McCullagh', '187.2108.2768.22', 'NE', 'Cardiologue', 0),
('Marianna', 'Beagles', '248.4121.6513.61', 'VD', 'Cardiologue', 1),
('Phebe', 'Dugood', '256.5437.1392.48', 'VS', 'Generaliste', 1),
('Benjamin', 'Leglise', '489.8137.5484.12', 'VS', 'Dermatologue', 1),
('Rebecca', 'Gillott', '543.4141.0118.64', 'NE', 'Generaliste', 1),
('Tod', 'Mebs', '868.9850.7281.95', 'VS', 'Generaliste', 1);

-- --------------------------------------------------------

--
-- Structure de la table `medicaments`
--

CREATE TABLE `medicaments` (
  `intitule` varchar(9) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `DCI` varchar(15) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `medicaments`
--

INSERT INTO `medicaments` (`intitule`, `DCI`) VALUES
('Xanax', 'Alprazolam'),
('Tryptanol', 'Amitriptyline'),
('Aspirin', 'Aspirine'),
('Valium', 'Diazepam'),
('Concerta', 'Methylphenidate'),
('Focalin', 'Methylphenidate'),
('Ritalin', 'Methylphenidate'),
('Dormicum', 'Midazolam'),
('Ambien', 'Zolpidem'),
('Hypnogen', 'Zolpidem'),
('Stilnox', 'Zolpidem');

-- --------------------------------------------------------

--
-- Structure de la table `ordonnances`
--

CREATE TABLE `ordonnances` (
  `date` date NOT NULL,
  `no_medecin` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `no_patient` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `id_ordonnance` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `ordonnances`
--

INSERT INTO `ordonnances` (`date`, `no_medecin`, `no_patient`, `id_ordonnance`) VALUES
('2020-06-05', '072.7352.7867.27', '104.4238.1230.70', 1),
('2020-06-08', '248.4121.6513.61', '311.6470.2621.49', 2),
('2020-06-05', '248.4121.6513.61', '311.6470.2621.49', 3),
('2020-06-05', '248.4121.6513.61', '311.6470.2621.49', 18),
('2020-06-05', '187.2108.2768.22', '883.5381.5273.68', 19),
('2020-06-05', '080.6113.2973.54', '306.1724.4972.76', 21),
('2020-06-18', '037.3205.2348.53', '311.6470.2621.49', 22),
('2020-06-18', '037.3205.2348.53', '029.6101.4070.60', 23),
('2020-06-18', '037.3205.2348.53', '029.6101.4070.60', 24);

--
-- Déclencheurs `ordonnances`
--
DELIMITER $$
CREATE TRIGGER `insert_autorisation` AFTER INSERT ON `ordonnances` FOR EACH ROW BEGIN
  DECLARE autorised bit;
  SET autorised = ( SELECT autorisation FROM medecins WHERE NEW.no_medecin = medecins.no_avs);

IF autorised = 0 THEN
SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Doctor not allowed';
END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `ordonnances_achat`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `ordonnances_achat` (
`id_ordonnance` int
,`prenom` varchar(11)
,`nom` varchar(12)
,`intitule` varchar(9)
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `ordonnances_medicaments`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `ordonnances_medicaments` (
`no_medecin` varchar(16)
,`no_patient` varchar(16)
,`id_ordonnance` int
,`intitule_med` varchar(9)
,`quantite` int
);

-- --------------------------------------------------------

--
-- Structure de la table `patients`
--

CREATE TABLE `patients` (
  `prenom` varchar(11) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `nom` varchar(12) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `no_avs` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `canton` varchar(2) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `no_assurance` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `patients`
--

INSERT INTO `patients` (`prenom`, `nom`, `no_avs`, `canton`, `no_assurance`) VALUES
('Dionis', 'Ubsdell', '029.6101.4070.60', 'NE', 290),
('Carolyne', 'Weitzel', '102.0337.1896.04', 'GE', 8),
('Shaylyn', 'Showering', '104.4238.1230.70', 'VS', 1542),
('Lianne', 'Gladman', '194.6863.2689.22', 'NE', 1542),
('Basile', 'Asel', '306.1724.4972.76', 'NE', 8),
('Esdras', 'Mac', '311.6470.2621.49', 'GE', 1542),
('Sander', 'Brangan', '389.9134.2102.32', 'VS', 1555),
('Jeth', 'Higginbottam', '392.1440.8718.20', 'VD', 1555),
('Oswell', 'Swinyard', '423.1858.9721.59', 'VS', 290),
('Heindrick', 'Hogbourne', '525.3223.7937.92', 'VS', 1562),
('Janetta', 'Clemendet', '631.7289.4653.07', 'NE', 290),
('Wally', 'Everitt', '682.2994.1156.29', 'NE', 1562),
('Kizzee', 'Halpen', '691.6176.1642.27', 'NE', 1555),
('Tamarra', 'Izard', '725.4625.1176.35', 'NE', 8),
('Ophelie', 'Bonnick', '883.5381.5273.68', 'VS', 8),
('Diann', 'Pilfold', '943.3593.0144.39', 'VD', 290),
('Kristel', 'Manginot', '944.1309.3061.86', 'NE', 1562),
('Archaimbaud', 'Spriggs', '964.7809.5071.13', 'VS', 1542);

-- --------------------------------------------------------

--
-- Structure de la table `producteurs`
--

CREATE TABLE `producteurs` (
  `nom` varchar(13) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `siege_social` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `producteurs`
--

INSERT INTO `producteurs` (`nom`, `siege_social`) VALUES
('Bayer', 'Leverkusen'),
('Janssen-Cilag', 'Zug'),
('Novartis', 'Bale'),
('Nycomed', 'Zurich'),
('Obs', 'Karachi'),
('Pfizer', 'New-York'),
('Roche', 'Bale'),
('Sanofi', 'Paris');

-- --------------------------------------------------------

--
-- Structure de la table `produits`
--

CREATE TABLE `produits` (
  `DCI` varchar(15) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `autorisation` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `produits`
--

INSERT INTO `produits` (`DCI`, `autorisation`) VALUES
('Alprazolam', 1),
('Amitriptyline', 1),
('Aspirine', 0),
('Diazepam', 1),
('Methylphenidate', 1),
('Midazolam', 1),
('Zolpidem', 1);

-- --------------------------------------------------------

--
-- Structure de la table `societes_filles`
--

CREATE TABLE `societes_filles` (
  `nom` varchar(19) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `email` varchar(29) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `nom_mere` varchar(13) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `societes_filles`
--

INSERT INTO `societes_filles` (`nom`, `email`, `nom_mere`) VALUES
('Amavita', 'info@amavita.ch', 'Galenica'),
('Coop Vitality', 'apotheke.ins@coop-vitality.ch', 'Coop'),
('Pharmacie Plus', 'wilson.ge@pharmacieplus.ch', NULL),
('Pharmacie Populaire', 'admin@pharmaciepopulaire.ch', NULL),
('Sunstore', 'sun311cs@sunstore.ch', 'Galenica');

-- --------------------------------------------------------

--
-- Structure de la table `societes_meres`
--

CREATE TABLE `societes_meres` (
  `nom` varchar(13) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `siege_social` varchar(5) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `societes_meres`
--

INSERT INTO `societes_meres` (`nom`, `siege_social`) VALUES
('Coop', 'Bale'),
('Galenica', 'Berne');

-- --------------------------------------------------------

--
-- Structure de la vue `achat_totaux`
--
DROP TABLE IF EXISTS `achat_totaux`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `achat_totaux`  AS  select `achats`.`intitule_med` AS `nom_medicament`,sum(`achats`.`quantite`) AS `total` from `achats` group by `achats`.`intitule_med` ;

-- --------------------------------------------------------

--
-- Structure de la vue `factures_client`
--
DROP TABLE IF EXISTS `factures_client`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `factures_client`  AS  select `patients`.`prenom` AS `prenom`,`patients`.`nom` AS `nom`,`patients`.`no_avs` AS `no_avs`,`achats`.`date` AS `date`,`assurances`.`nom` AS `nom_assurance`,`achats`.`id_distributeur` AS `id_distributeur`,`achats`.`intitule_med` AS `intitule_med`,`achats`.`quantite` AS `quantite`,`contient`.`prix` AS `prix`,(`achats`.`quantite` * `contient`.`prix`) AS `total` from ((((`assurances` join `patients` on((`patients`.`no_assurance` = `assurances`.`no`))) join `achats` on((`achats`.`no_patient` = `patients`.`no_avs`))) join `distributeurs` on((`achats`.`id_distributeur` = `distributeurs`.`id`))) join `contient` on((`distributeurs`.`id` = `contient`.`id_distributeur`))) where (`contient`.`intitule_med` = `achats`.`intitule_med`) ;

-- --------------------------------------------------------

--
-- Structure de la vue `individus`
--
DROP TABLE IF EXISTS `individus`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `individus`  AS  select `patients`.`prenom` AS `prenom`,`patients`.`nom` AS `nom`,`patients`.`no_avs` AS `no_avs`,`patients`.`canton` AS `canton` from `patients` union select `medecins`.`prenom` AS `prenom`,`medecins`.`nom` AS `nom`,`medecins`.`no_avs` AS `no_avs`,`medecins`.`canton` AS `canton` from `medecins` ;

-- --------------------------------------------------------

--
-- Structure de la vue `ordonnances_achat`
--
DROP TABLE IF EXISTS `ordonnances_achat`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `ordonnances_achat`  AS  select distinct `inclut`.`id_ordonnance` AS `id_ordonnance`,`patients`.`prenom` AS `prenom`,`patients`.`nom` AS `nom`,`medicaments`.`intitule` AS `intitule` from ((((`ordonnances` join `inclut` on((`ordonnances`.`id_ordonnance` = `inclut`.`id_ordonnance`))) join `medicaments` on((`medicaments`.`intitule` = `inclut`.`intitule_med`))) join `achats` on((`medicaments`.`intitule` = `achats`.`intitule_med`))) join `patients` on(((`achats`.`no_patient` = `patients`.`no_avs`) and (`patients`.`no_avs` = `ordonnances`.`no_patient`)))) where (`ordonnances`.`date` < `achats`.`date`) ;

-- --------------------------------------------------------

--
-- Structure de la vue `ordonnances_medicaments`
--
DROP TABLE IF EXISTS `ordonnances_medicaments`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `ordonnances_medicaments`  AS  select `ordonnances`.`no_medecin` AS `no_medecin`,`ordonnances`.`no_patient` AS `no_patient`,`ordonnances`.`id_ordonnance` AS `id_ordonnance`,`inclut`.`intitule_med` AS `intitule_med`,`inclut`.`quantite` AS `quantite` from (`ordonnances` join `inclut` on((`ordonnances`.`id_ordonnance` = `inclut`.`id_ordonnance`))) ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `achats`
--
ALTER TABLE `achats`
  ADD PRIMARY KEY (`id_distributeur`,`intitule_med`,`no_patient`,`date`),
  ADD KEY `no_patient` (`no_patient`),
  ADD KEY `intitule_med` (`intitule_med`);

--
-- Index pour la table `assurances`
--
ALTER TABLE `assurances`
  ADD PRIMARY KEY (`no`),
  ADD UNIQUE KEY `nom` (`nom`);

--
-- Index pour la table `contient`
--
ALTER TABLE `contient`
  ADD PRIMARY KEY (`intitule_med`,`id_distributeur`),
  ADD KEY `intitule_med` (`intitule_med`),
  ADD KEY `id_distributeur` (`id_distributeur`);

--
-- Index pour la table `distributeurs`
--
ALTER TABLE `distributeurs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `nom_societe` (`nom_societe`);

--
-- Index pour la table `fabrique`
--
ALTER TABLE `fabrique`
  ADD PRIMARY KEY (`no_lot`,`nom_producteur`,`DCI`),
  ADD KEY `DCI` (`DCI`),
  ADD KEY `nom_producteur` (`nom_producteur`);

--
-- Index pour la table `inclut`
--
ALTER TABLE `inclut`
  ADD PRIMARY KEY (`id_ordonnance`,`intitule_med`),
  ADD KEY `intitule_med` (`intitule_med`);

--
-- Index pour la table `medecins`
--
ALTER TABLE `medecins`
  ADD PRIMARY KEY (`no_avs`);

--
-- Index pour la table `medicaments`
--
ALTER TABLE `medicaments`
  ADD PRIMARY KEY (`intitule`),
  ADD KEY `DCI` (`DCI`);

--
-- Index pour la table `ordonnances`
--
ALTER TABLE `ordonnances`
  ADD PRIMARY KEY (`id_ordonnance`),
  ADD KEY `no_medecin` (`no_medecin`),
  ADD KEY `no_patient` (`no_patient`);

--
-- Index pour la table `patients`
--
ALTER TABLE `patients`
  ADD PRIMARY KEY (`no_avs`),
  ADD KEY `no_assurance` (`no_assurance`);

--
-- Index pour la table `producteurs`
--
ALTER TABLE `producteurs`
  ADD PRIMARY KEY (`nom`);

--
-- Index pour la table `produits`
--
ALTER TABLE `produits`
  ADD PRIMARY KEY (`DCI`);

--
-- Index pour la table `societes_filles`
--
ALTER TABLE `societes_filles`
  ADD PRIMARY KEY (`nom`),
  ADD KEY `nom_mere` (`nom_mere`);

--
-- Index pour la table `societes_meres`
--
ALTER TABLE `societes_meres`
  ADD PRIMARY KEY (`nom`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `ordonnances`
--
ALTER TABLE `ordonnances`
  MODIFY `id_ordonnance` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `achats`
--
ALTER TABLE `achats`
  ADD CONSTRAINT `achats_ibfk_1` FOREIGN KEY (`id_distributeur`) REFERENCES `distributeurs` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `achats_ibfk_4` FOREIGN KEY (`no_patient`) REFERENCES `patients` (`no_avs`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `achats_ibfk_5` FOREIGN KEY (`intitule_med`) REFERENCES `medicaments` (`intitule`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `contient`
--
ALTER TABLE `contient`
  ADD CONSTRAINT `contient_ibfk_2` FOREIGN KEY (`intitule_med`) REFERENCES `medicaments` (`intitule`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `contient_ibfk_3` FOREIGN KEY (`id_distributeur`) REFERENCES `distributeurs` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `distributeurs`
--
ALTER TABLE `distributeurs`
  ADD CONSTRAINT `distributeurs_ibfk_1` FOREIGN KEY (`nom_societe`) REFERENCES `societes_filles` (`nom`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `fabrique`
--
ALTER TABLE `fabrique`
  ADD CONSTRAINT `fabrique_ibfk_1` FOREIGN KEY (`DCI`) REFERENCES `produits` (`DCI`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `fabrique_ibfk_2` FOREIGN KEY (`nom_producteur`) REFERENCES `producteurs` (`nom`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `inclut`
--
ALTER TABLE `inclut`
  ADD CONSTRAINT `inclut_ibfk_1` FOREIGN KEY (`id_ordonnance`) REFERENCES `ordonnances` (`id_ordonnance`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `inclut_ibfk_3` FOREIGN KEY (`intitule_med`) REFERENCES `medicaments` (`intitule`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `medicaments`
--
ALTER TABLE `medicaments`
  ADD CONSTRAINT `medicaments_ibfk_2` FOREIGN KEY (`DCI`) REFERENCES `produits` (`DCI`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `ordonnances`
--
ALTER TABLE `ordonnances`
  ADD CONSTRAINT `ordonnances_ibfk_1` FOREIGN KEY (`no_medecin`) REFERENCES `medecins` (`no_avs`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `ordonnances_ibfk_2` FOREIGN KEY (`no_patient`) REFERENCES `patients` (`no_avs`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `patients`
--
ALTER TABLE `patients`
  ADD CONSTRAINT `patients_ibfk_1` FOREIGN KEY (`no_assurance`) REFERENCES `assurances` (`no`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `societes_filles`
--
ALTER TABLE `societes_filles`
  ADD CONSTRAINT `societes_filles_ibfk_1` FOREIGN KEY (`nom_mere`) REFERENCES `societes_meres` (`nom`) ON DELETE RESTRICT ON UPDATE RESTRICT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
