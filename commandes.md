1. Tous les identifiants d’ordonnances de médicaments contenant du methylphénidate
SELECT id_ordonnance
FROM inclut
INNER JOIN medicaments ON inclut.no_CAS = medicaments.no_CAS AND inclut.intitule_med = medicaments.intitule
WHERE medicaments.DCI = 'Methylphenidate'
GROUP BY id_ordonnance

2. Le nom des médicaments enregistrés contenant du methylphenidate et leur producteur
SELECT intitule, nom_producteur
FROM medicaments
WHERE medicaments.DCI = 'Methylphenidate'

3. Le nom de tous les medecins ayant prescrit du valium et l'identifiant de l'ordonnance en question
SELECT prenom, nom, no_avs, ordonnances.id_ordonnance
FROM medecins
INNER JOIN ordonnances ON ordonnances.no_medecin = medecins.no_avs
INNER JOIN inclut ON ordonnances.id_ordonnance = inclut.id_ordonnance
WHERE inclut.intitule_med = 'Valium'

4. L'adresse des distributeurs contenant de l'aspirine
SELECT adresse
FROM distributeurs
INNER JOIN contient ON distributeurs.id = contient.id_distributeur
WHERE contient.intitule_med = 'Aspirin'

5. Connaître toutes les ventes du distributeur 1 depuis depuis le 1er juin 2020
SELECT *
FROM achats
WHERE achats.id_distributeur = 1 and achats.date >= '2020-06-01'

6. Le chiffre d'affaires de la vente de tryptanol pour l'année 2020
SELECT SUM(achats.quantite*prix) AS chiffre_affaire_tryptanol
FROM achats
INNER JOIN contient ON achats.id_distributeur = contient.id_distributeur AND achats.intitule_med = contient.intitule_med AND achats.no_CAS = contient.no_CAS
WHERE achats.intitule_med = 'Tryptanol' AND achats.date > '2020-01-01' 

6. Le chiffre d'affaires de la vente d'Aspirin du distributeur n°1 pour l'année 2020
SELECT SUM(achats.quantite*prix) AS chiffre_affaire_distributeur
FROM achats
INNER JOIN contient ON achats.id_distributeur = contient.id_distributeur AND achats.intitule_med = contient.intitule_med AND achats.no_CAS = contient.no_CAS
WHERE achats.intitule_med = 'Aspirin' AND achats.id_distributeur = 1 AND achats.date > '2020-01-01' AND achats.date < '2021-01-01'

7. Le chiffre d'affaire de la société Amavita pour l'année 2020
SELECT SUM(achats.quantite*prix) AS chiffre_affaire_societe
FROM achats
INNER JOIN contient ON achats.id_distributeur = contient.id_distributeur
INNER JOIN distributeurs ON contient.id_distributeur = distributeurs.id AND achats.no_CAS = contient.no_CAS AND achats.intitule_med = contient.intitule_med
WHERE achats.date > '2020-01-01' AND achats.date < '2021-01-01' AND distributeurs.nom_societe = 'Amavita'

7. Le chiffre d'affaire de la société mère Galenica pour l'année 2020

SELECT SUM(achats.quantite*prix) AS chiffre_affaire_societe
FROM achats
INNER JOIN contient ON achats.id_distributeur = contient.id_distributeur
INNER JOIN distributeurs ON contient.id_distributeur = distributeurs.id AND achats.no_CAS = contient.no_CAS AND achats.intitule_med = contient.intitule_med
INNER JOIN societes_filles ON distributeurs.nom_societe = societes_filles.nom
WHERE societes_filles.nom_mere = 'Galenica' AND achats.date > '2020-01-01' AND achats.date < '2021-01-01'

8. La quantité achetée totale pour chaque nom de médicament
SELECT intitule_med, SUM(quantite) AS total FROM achats
GROUP BY (intitule_med)

10. La liste de tous les medecins ayant des patients assurés chez Assura
SELECT medecins.prenom, medecins.nom, no_medecin
FROM medecins
INNER JOIN ordonnances ON ordonnances.no_medecin = medecins.no_avs
INNER JOIN patients ON ordonnances.no_patient = patients.no_avs
INNER JOIN assurances on patients.no_assurance = assurances.no
WHERE assurances.nom = 'Assura-Basis'
GROUP BY(no_medecin)

11. Tous les achats des clients assurés chez CSS
SELECT id_distributeur, no_CAS, intitule_med, no_patient, date, quantite FROM achats
INNER JOIN patients ON achats.no_patient = patients.no_avs
INNER JOIN assurances ON assurances.no = patients.no_assurance
WHERE assurances.nom = 'CSS'

12. Tous les distributeurs ayant un stock d'aspirin inférieur à 60
SELECT distributeurs.id, distributeurs.adresse
FROM distributeurs
INNER JOIN contient ON contient.id_distributeur = distributeurs.id
WHERE contient.DCI = 'Aspirine' AND contient.quantite < 60

13. La liste des medecins et leur client ayant prescrit une ordonnance à un client du même canton
SELECT medecins.nom AS nom_medecin, medecins.prenom AS prenom_medecin, medecins.no_avs AS avs_medecin, patients.nom AS nom_patient, patients.prenom AS prenom_patient, patients.no_avs AS avs_patient, patients.canton FROM medecins
INNER JOIN ordonnances ON ordonnances.no_medecin = medecins.no_avs
INNER JOIN patients ON ordonnances.no_patient = patients.no_avs
WHERE patients.canton = medecins.canton

14. La liste des clients ayant effectué des achats hors de leur canton et le canton du distributeur étranger
SELECT DISTINCT prenom, nom, patients.canton AS canton_patient, distributeurs.canton AS distributeur_canton FROM patients
INNER JOIN achats ON achats.no_patient = patients.no_avs
INNER JOIN distributeurs ON distributeurs.id = achats.id_distributeur
WHERE distributeurs.canton <> patients.canton

15. La liste des cardiologues ayant prescrit du valium
SELECT DISTINCT medecins.prenom, medecins.nom, medecins.no_avs
FROM medecins
INNER JOIN ordonnances ON ordonnances.no_medecin = medecins.no_avs
INNER JOIN inclut ON ordonnances.id_ordonnance = inclut.id_ordonnance
WHERE medecins.specialite = 'Cardiologue' AND inclut.intitule_med = 'Valium'


