import mysql.connector
import pandas as pd

def show_distributeur(id_distributeur):
    mycursor.execute("SELECT * FROM contient WHERE contient.id_distributeur = %s", (id_distributeur,))
    myresult = mycursor.fetchall()
    df = pd.DataFrame(myresult, columns = [ 'intitule_med', 'id_distributeur', 'quantite', 'prix'])
    print('\n', df)

cnx = mysql.connector.connect(user='root', password='test',
                              host='127.0.0.1', database='distributeur')


mycursor = cnx.cursor(buffered=True)
mycursor.execute("SELECT * FROM distributeurs")
myresult = mycursor.fetchall()

print("Table distributeurs\n")

df = pd.DataFrame(myresult, columns = ['id_distributeur', 'adresse', 'societe_fille', 'canton'])
print(df)

id = int(input("\nChoose id_distributeur:"))

show_distributeur(id)

intitule_med = input("intitule_med: ")
quantite = int(input("quantite: "))

query = "UPDATE contient SET quantite = (%s + quantite) WHERE intitule_med = %s AND id_distributeur = %s"
val = (quantite,  intitule_med, id)

mycursor.execute(query, val)
cnx.commit()

show_distributeur(id)
cnx.close()
