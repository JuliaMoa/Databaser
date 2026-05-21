from sqlalchemy import create_engine, text

# create engine object

# fill in when database is done
connection_url =(

)

engine = create_engine(connection_url)

# function for free text search for title

def search_books(search_term: str):

    # search for books and show amount per store

    query = text(

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