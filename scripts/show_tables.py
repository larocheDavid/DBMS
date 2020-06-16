import mysql.connector

cnx = mysql.connector.connect(user='root', password='test',
                              host='localhost',port='3308', database='distributeur')


mycursor = cnx.cursor(buffered=True)
mycursor.execute("SHOW TABLES")
tables = mycursor.fetchall()
for table in tables:
    print(table)

name = input("Table name:")
mycursor.execute("SELECT * FROM %s" % (name,))
#mycursor.execute("SELECT * FROM achats")
rows = mycursor.fetchall()
for row in rows:
    print(row)
cnx.close()
