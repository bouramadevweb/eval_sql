import os
import sqlite3
import requests
import pandas as pd
from bs4 import BeautifulSoup
from datetime import datetime
from urllib.request import urlopen, urlretrieve

class FromageETL:
    def __init__(self, url, db_path):
        self.url = url
        self.db_path = db_path

    def extract(self):
        """_summary_

        Returns:
            _type_: _description_
        """
        response = requests.get(self.url)
        if response.status_code == 200:
            return response.text
        else:
            print(f"échec de la récupération de la page. Status code: {response.status_code}")
            return None

    def extract_price(self, url):
        """_summary_

        Args:
            url (_type_): _description_

        Returns:
            _type_: _description_
        """
        data = urlopen(url)
        html_content = data.read()

        soup = BeautifulSoup(html_content, 'html.parser')
        parent_tag = soup.find('p', class_='price')

        prix = None

        if parent_tag:
            price_bdi = parent_tag.find('bdi')
            if price_bdi:
                prix_text = price_bdi.text.strip()
                prix_text = prix_text.replace('€', '').replace('\xa0', '')

                try:
                    prix = float(prix_text)
                except ValueError as e:
                    print(f"Erreur lors de la conversion du prix en float : {e}")

        return prix

    def extract_and_save_image(self, url, save_dir='./images_fromage/'):
        data = urlopen(url)
        html_content = data.read()

        soup = BeautifulSoup(html_content, 'html.parser')
        div_tag = soup.find('div', {'class': 'woocommerce-product-gallery__wrapper'})

        image_filename = None

        if div_tag:
            a_tag = div_tag.find('a')
            if a_tag:
                image_url = a_tag['href']
                image_filename = os.path.basename(image_url)

                os.makedirs(save_dir, exist_ok=True)
                image_filepath = os.path.join(save_dir, image_filename)

                print("Téléchargement de l'image depuis l'URL :", image_url)
                urlretrieve(image_url, image_filepath)

        return image_filename

    def transform(self, html_content):
        """_summary_

        Args:
            html_content (_type_): _description_

        Returns:
            _type_: _description_
        """
        if html_content:
            soup = BeautifulSoup(html_content, 'html.parser')
            data_fromage = []

            table = soup.find('table')

            if table:
                for row in table.find_all('tr')[1:]:
                    columns = row.find_all('td')
                    fromage = columns[0].text.strip()
                    family = columns[1].text.strip()
                    paste = columns[2].text.strip()
                    date = datetime.now().strftime('%Y-%m-%d')
                    link_element = columns[0].find('a')
                    image_url = f'https://www.laboitedufromager.com{link_element["href"]}' if link_element else ''

                    if image_url:
                        price = self.extract_price(image_url)
                        image_filename = self.extract_and_save_image(image_url)

                        data_fromage.append((fromage, family, paste, price, date, image_filename))
                    else:
                        print(f"Erreur: L'URL de l'image est vide pour le fromage {fromage}")

            return data_fromage
        else:
            return []

    def load(self, data):
        """_summary_

        Args:
            data (_type_): _description_
        """
        if data:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()

            cursor.execute('''
                CREATE TABLE IF NOT EXISTS cheese_ods (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    fromage TEXT,
                    family TEXT,
                    paste TEXT,
                    price REAL,
                    date TEXT,
                    image_filename TEXT
                )
            ''')

            cursor.executemany('''
                INSERT INTO cheese_ods (fromage, family, paste, price, date, image_filename)
                VALUES (?, ?, ?, ?, ?, ?)
            ''', data)

            conn.commit()
            conn.close()

    def get_dataframe_from_db(self):
        """_summary_

        Returns:
            _type_: _description_
        """
        conn = sqlite3.connect(self.db_path)
        query = 'SELECT * FROM cheese_ods'
        df = pd.read_sql_query(query, conn)
        conn.close()
        return df

    def group_by_family(self):
        """_summary_

        Returns:
            _type_: _description_
        """
        df = self.get_dataframe_from_db()
        df = df[df['family'] != '']
        counts = df.groupby('family').size().reset_index(name='counts')
        counters_counts = counts.to_string(index=False)
        return counts

    def export_to_csv(self, file_path):
        df = self.get_dataframe_from_db()
        df.to_csv(file_path, index=False, encoding='utf-8-sig')

    def score_fiabilite(self):
        """_summary_
        """
        reference_file = 'fromages.csv'
        df_extracted = self.get_dataframe_from_db()
        df_reference = pd.read_csv(reference_file)

        correct_results = df_extracted[['fromage', 'family', 'paste', 'date']] == df_reference[['fromage', 'family', 'paste', 'date']]
        total_results = len(df_extracted)
        total_correct_results = correct_results.all(axis=1).sum()
        accuracy_rate = total_correct_results / total_results * 100

        print(f"Taux de fiabilité des résultats : {accuracy_rate} %")

    def run_etl(self):
        """_summary_
        """
        html_content = self.extract()
        transformed_data = self.transform(html_content)
        self.load(transformed_data)

url = 'https://www.laboitedufromager.com/liste-des-fromages-par-ordre-alphabetique/'
DB_PATH = 'my_database.db'

etl = FromageETL(url, DB_PATH)
etl.run_etl()
etl.export_to_csv('fromages.csv')
etl.score_fiabilite()

# Lire les données depuis la base de données avec Pandas
# df_from_db = etl.get_dataframe_from_db()

# Afficher le DataFrame
# print(df_from_db)
# counts_by_letter = etl.group_by_letter()
# print(counts_by_letter)
# Utilisation de la nouvelle méthode
counts_by_family = etl.group_by_family()
print(counts_by_family)
# counts_by_first_letter = etl.group_by_first_letter_of_family()
# print(counts_by_first_letter)
