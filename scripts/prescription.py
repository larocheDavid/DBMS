import mysql.connector
import pandas as pd
from datetime import date

def show_meds():
    print("\n Table medicaments")
    mycursor.execute("SELECT no_CAS, intitule, DCI FROM medicaments")
    myresult = mycursor.fetchall()
    df = pd.DataFrame(myresult, columns = ['no_CAS', 'intitule', 'DCI'])
    print(df)

def show_ordonnance(id_ordonnance):
    print("\n Ordonnance n°", id_ordonnance)
    mycursor.execute("SELECT no_medecin, no_patient, no_CAS, intitule_med, quantite FROM ordonnances INNER JOIN inclut WHERE ordonnances.id_ordonnance = inclut.id_ordonnance AND inclut.id_ordonnance = %s", (id_ordonnance,))
    myresult = mycursor.fetchall()
    df = pd.DataFrame(myresult, columns = ['no_medecin', 'no_patient', 'no_CAS', 'intitule_med', 'quantite'])
    print(df)

cnx = mysql.connector.connect(user='root', password='test',
                              host='localhost',port='3308', database='distributeur')


mycursor = cnx.cursor(buffered=True)
print("Table medecins:")
mycursor.execute("SELECT * FROM medecins")
myresult = mycursor.fetchall()
df = pd.DataFrame(myresult, columns = ['prenom', 'nom', 'no_avs', 'canton', 'specialite', 'autorisation'])
print(df)

no_medecin = input("Choose no_avs of doctor:")

print("\nTable patients:")
mycursor.execute("SELECT * FROM patients")
myresult = mycursor.fetchall()
df = pd.DataFrame(myresult, columns = ['prenom', 'nom', 'no_avs', 'canton', 'no_assurance'])
print(df)

no_patient = input("Choose no_avs of patient:")
mycursor.execute("SELECT MAX(id_ordonnance) FROM ordonnances")
id_ordonnance = mycursor.fetchall()
id_ordonnance = id_ordonnance[0][0] + 1

query = "INSERT INTO ordonnances (date, no_medecin, no_patient, id_ordonnance) VALUES (%s, %s, %s, %s)"
val = (date.today(), no_medecin, no_patient, id_ordonnance)
mycursor.execute(query, val)
cnx.commit()
print("Ordonnance n°", id_ordonnance, "created")

show_meds()

finished = 0
while finished != 'y':
    no_CAS = input("no_CAS: ")
    intitule_med = input("intitule_med: ")
    quantite = int(input("quantite: "))
    query = "INSERT INTO inclut (id_ordonnance, no_CAS, intitule_med, quantite) VALUES (%s, %s, %s, %s)"
    val = (id_ordonnance, no_CAS, intitule_med, quantite)
    mycursor.execute(query, val)
    finished = input("Finished? (y/n)")

cnx.commit()
show_ordonnance(id_ordonnance)
cnx.close()
