import mysql.connector
import pandas as pd
import time

host = 'localhost'
port = '3307'
db_name = 'DE1'
user = 'root'
password = '1'
url = 'jdbc:mysql://' + host + ':' + port + '/' + db_name
driver = "com.mysql.cj.jdbc.Driver"
cnx = mysql.connector.connect(user=user, password=password,
                                         host=host,
                                         port=port,
                                      database=db_name)
query = """select count(*) as total_events from events"""

while True:
    mysql_data = pd.read_sql(query,cnx)
    print(mysql_data)
    time.sleep(10)