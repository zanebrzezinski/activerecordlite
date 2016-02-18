# Insert your SQL file between the single quotes below that SQL_FILE is pointing to, eg:
#   SQL_FILE: File.join(ROOT_FOLDER, 'cats.sql')
# Insert your DB file between the single quotes below that DB_FILE is point to, eg:
#   DB_FILE: File.join(ROOT_FOLDER, 'cats.db')

ROOT_FOLDER = File.join(File.dirname(__FILE__), '..')

DB_INFO = {
  SQL_FILE: File.join(ROOT_FOLDER, 'cats.sql'), #insert SQL_FILE here
  DB_FILE: File.join(ROOT_FOLDER, 'cats.db') #insert DB_FILE here
}
