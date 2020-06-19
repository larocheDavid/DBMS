import mysql.connector
cnx = mysql.connector.connect(user='root', password='test',
                              host='127.0.0.1', database='distributeur')
print(cnx)

mycursor = cnx.cursor()
mycursor.execute("SELECT * FROM patients")
myresult = mycursor.fetchall()

for row in myresult:
    print(row)
cnx.close()
