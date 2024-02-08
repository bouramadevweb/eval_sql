import tkinter as tk
from tkinter import ttk
import oracledb

class Application:
    def __init__(self, root):
        self.root = root
        self.root.title("Analyse de Ventes de Fromages")
        
        self.conn = oracledb.connect(user='system', password="Kungfu83@", dsn="localhost:1521/xe")
        
        self.create_widgets()

    def create_widgets(self):
        # Buttons to display information
        ttk.Button(self.root, text="Top 3 des fromages vendus", command=self.show_top_cheeses).pack(pady=5)
        ttk.Button(self.root, text="Jour avec le plus de chiffre d'affaire", command=self.show_top_day).pack(pady=5)
        ttk.Button(self.root, text="Nombre de fromages par famille", command=self.show_family_counts).pack(pady=5)

        # Treeview for displaying results
        self.tree = ttk.Treeview(self.root)
        self.tree["columns"] = ("1", "2")
        self.tree.column("#0", width=0, stretch=tk.NO)
        self.tree.column("1", anchor=tk.W, width=200)
        self.tree.column("2", anchor=tk.W, width=200)

        self.tree.heading("#0", text="", anchor=tk.W)
        self.tree.heading("1", text="Colonne 1", anchor=tk.W)
        self.tree.heading("2", text="Colonne 2", anchor=tk.W)

        self.tree.pack(pady=10)

    def show_top_cheeses(self):
        top_cheeses = self.get_top_cheeses()
        self.display_results(top_cheeses, ["Fromage", "Total Quantités Vendues"])

    def show_top_day(self):
        top_day = self.get_top_day()
        self.display_results(top_day, ["Date de Vente", "Chiffre d'Affaire Total"])

    def show_family_counts(self):
        family_counts = self.get_family_counts()
        self.display_results(family_counts, ["Famille", "Nombre de Fromages"])

    def get_top_cheeses(self):
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT
                c.fromage,
                SUM(v.quantites) AS total_quantites_vendues
            FROM
                ventes v
            JOIN
                cheesess c ON v.cheeses = c.family
            GROUP BY
                c.fromage
            ORDER BY
                total_quantites_vendues DESC
        """)
        top_cheeses = cursor.fetchmany(3)
        cursor.close()
        return top_cheeses

    def get_top_day(self):
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT
                v.vente_date,
                SUM(TO_NUMBER(v.quantites, '999999999.99') * TO_NUMBER(c.prix, '999999999.99')) AS chiffre_affaires_total
            FROM
                ventes v
            JOIN
                cheesess c ON v.cheeses = c.family
            GROUP BY
                v.vente_date
            ORDER BY
                chiffre_affaires_total DESC
        """)
        top_day = cursor.fetchone()
        cursor.close()
        return top_day

    def get_family_counts(self):
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT
                c.family,
                COUNT(c.fromage) AS nombre_de_fromages
            FROM
                cheesess c
            GROUP BY
                c.family
        """)
        family_counts = cursor.fetchall()
        cursor.close()
        return family_counts

    def display_results(self, results, column_names):
        # Clear existing items in the Treeview
        for item in self.tree.get_children():
            self.tree.delete(item)

        # Insert new data into the Treeview
        self.tree["columns"] = column_names
        self.tree.column("#0", width=0, stretch=tk.NO)
        for col in column_names:
            self.tree.column(col, anchor=tk.W, width=200)
            self.tree.heading(col, text=col, anchor=tk.W)

        for row in results:
            self.tree.insert("", tk.END, values=row)

    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    root = tk.Tk()
    app = Application(root)
    app.run()
