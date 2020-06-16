import mysql.connector
cnx = mysql.connector.connect(user='root', password='test',
                              host='localhost',port='3308', database='distributeur')
print(cnx)

mycursor = cnx.cursor()
mycursor.execute("SELECT * FROM patients")
myresult = mycursor.fetchall()

for row in myresult:
    print(row)
cnx.close()
