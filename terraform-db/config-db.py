import sys
import mysql.connector

# Check if all required command-line arguments are provided
if len(sys.argv) < 3:
    print("Usage: python3 script.py <host> <password> ")
    sys.exit(1)

# Get the connection parameters from command-line arguments
host = sys.argv[1]
password = sys.argv[2]

# Establish the database connection
connection = mysql.connector.connect(
    host=host,
    port=25060,
    user='doadmin',
    password=password,
    database='defaultdb'
)

# Create the table
create_table_query = """
    DROP TABLE IF EXISTS posts;
    CREATE TABLE posts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        title TEXT NOT NULL,
        content TEXT NOT NULL
    );
"""

cursor = connection.cursor()

# Execute each query separately
for query in create_table_query.split(';'):
    if query.strip():
        cursor.execute(query)


# Insert data into the table
insert_query = "INSERT INTO posts (title, content) VALUES (%s, %s)"
data = [
    ('First Post', 'Content for the first post'),
    ('Second Post', 'Content for the second post')
]

for record in data:
    cursor.execute(insert_query, record)  

# Commit the changes
connection.commit()

# Close the connection
cursor.close()
connection.close()