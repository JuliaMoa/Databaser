from sqlalchemy import create_engine, text

# connection to the database

connection_url = (
    "mssql+pyodbc://BookStoreUser:PizzaParty321!@localhost\\SQLEXPRESS/BookStoreDB"
    "?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes"
)

engine = create_engine(connection_url)

# function for free text search for title

def search_books(search_term: str):

    # search for books and show amount per store
    # sql-code as string in Python, SQLAlchemy sends it to SQL Server
    # SQLAlchemy använder : param 
    query = text("""

        SELECT
                 b.Title AS title,
                 s.StoreName AS store_name,
                 sq.QuantityInStock AS quantity
            FROM Books b 
            JOIN StockQuantity sq ON b.ISBN13 = sq.ISBN13
            JOIN Stores s ON sq.StoreId = s.StoreID
            WHERE b.Title LIKE :search_term 
            ORDER BY b.Title, s.StoreName; 
            """
                
    )

    # context manager to close connection automatically
    with engine.connect() as conn:
        result = conn.execute(query, {"search_term": f"%{search_term}%"})

        # iterate over result
        for row in result:
            print(f"{row.title} - {row.store_name}: {row.quantity} exemplar")

# test run

if __name__ == "__main__":
    user_input = input("Sök boktitel: ")
    search_books(user_input)