import sys
from PyQt6.QtWidgets import (
    QApplication, QWidget, QLabel, QLineEdit, QPushButton, QGridLayout, QMessageBox, QVBoxLayout, QScrollArea
)
import oracledb as db
import cx_Oracle 
import hashlib
from bcrypt import hashpw, gensalt
import os

# Spécifie manuellement le chemin vers Instant Client
os.environ["PATH"] = r"C:\oracle\instantclient_19_12;" + os.environ["PATH"]

class DatabaseConnectionApp(QWidget):
    def __init__(self):
        super().__init__()
        self.initUI()

    def initUI(self):
        self.setWindowTitle("Connexion à la base Oracle et affichage des données")
        self.resize(600, 400)

        # Layout principal
        self.main_layout = QVBoxLayout(self)

        # Formulaire pour les informations de connexion
        self.form_layout = QGridLayout()
        self.form_layout.addWidget(QLabel("Nom d'utilisateur:"), 0, 0)
        self.username_input = QLineEdit("Entreprise_admin")
        self.form_layout.addWidget(self.username_input, 0, 1)

        self.form_layout.addWidget(QLabel("Mot de passe:"), 1, 0)
        self.password_input = QLineEdit()

        self.form_layout.addWidget(self.password_input, 1, 1)

        self.form_layout.addWidget(QLabel("Hôte:"), 2, 0)
        self.host_input = QLineEdit("localhost")
        self.form_layout.addWidget(self.host_input, 2, 1)

        self.form_layout.addWidget(QLabel("Port:"), 3, 0)
        self.port_input = QLineEdit("1521")
        self.form_layout.addWidget(self.port_input, 3, 1)

        self.form_layout.addWidget(QLabel("Nom du service:"), 4, 0)
        self.service_name_input = QLineEdit("Entreprise_db")
        self.form_layout.addWidget(self.service_name_input, 4, 1)

        # Bouton de connexion
        self.connect_button = QPushButton("Se connecter")
        self.connect_button.clicked.connect(self.connect_to_database)
        self.form_layout.addWidget(self.connect_button, 5, 0, 1, 2)
        # Ajouter un champ de recherche (vulnérable)
        self.form_layout.addWidget(QLabel("Recherche par nom (non vulnérable) :"), 6, 0)
        self.search_input = QLineEdit()
        self.form_layout.addWidget(self.search_input, 6, 1)
        self.search_button = QPushButton("Rechercher")
        self.search_button.clicked.connect(self.search_vulnerable)
        self.form_layout.addWidget(self.search_button, 7, 0, 1, 2)

        # Ajouter le formulaire au layout principal
        self.main_layout.addLayout(self.form_layout)

        # Scroll area pour afficher les résultats
        self.scroll_area = QScrollArea()
        self.scroll_area_widget = QWidget()
        self.scroll_area_layout = QGridLayout()
        self.scroll_area_widget.setLayout(self.scroll_area_layout)
        self.scroll_area.setWidget(self.scroll_area_widget)
        self.scroll_area.setWidgetResizable(True)
        self.main_layout.addWidget(self.scroll_area)

        self.setLayout(self.main_layout)
    
    def hash_password(self, password):
            # Utiliser hashlib pour hacher le mot de passe avec SHA-256
        sha256_hash = hashlib.sha256()  # Crée une instance de l'algorithme SHA-256
        sha256_hash.update(password.encode('utf-8'))  # Convertir le mot de passe en bytes et le hacher
        return sha256_hash.hexdigest()  # Retourne le hachage en format hexadécimal

    def connect_to_database(self):
        # Récupérer les valeurs saisies
        username = self.username_input.text()
        password = self.password_input.text()
        host = self.host_input.text()
        port = self.port_input.text()
        service_name = self.service_name_input.text()
        
       

        try:
            # Création du DSN et connexion
            dsn = db.makedsn(host, port, service_name=service_name)
            connection = db.connect(user=username, password=password, dsn=dsn)

            # Exécuter une requête (remplacez par une table existante)
            cursor = connection.cursor()
            cursor.execute("SELECT * FROM departements FETCH FIRST 10 ROWS ONLY")  # Exemple avec hr.employees
            data = cursor.fetchall()
            columns = [desc[0] for desc in cursor.description]  # Noms des colonnes
            print(f"Colonnes disponibles : {columns}")

            
              # Appliquer le hachage sur la colonne "Localisation"
            hashed_data = []
            for row in data:
                row = list(row)  # Convertir le tuple en liste pour modification
                if "LOCALISATION" in columns:  # Vérifie si la colonne existe
                    print("Localisation existe")
                    loc_index = columns.index("LOCALISATION")  # Récupère l'index de la colonne
                    row[loc_index] = self.hash_password(row[loc_index]) if row[loc_index] else None  # Hache la localisation si elle existe
                hashed_data.append(tuple(row))  # Reconvertir en tuple pour consistance

            # Afficher les données dans le QGridLayout
            self.display_data(columns, hashed_data)

            # Fermer la connexion
            cursor.close()
            connection.close()
        except db.DatabaseError as e:
            error, = e.args
            QMessageBox.critical(self, "Erreur", f"Erreur de connexion : {error}")

    def display_data(self, columns, data):
        # Effacer les données précédentes
        for i in reversed(range(self.scroll_area_layout.count())):
            widget = self.scroll_area_layout.itemAt(i).widget()
            if widget:
                widget.deleteLater()

        # Afficher les noms des colonnes
        for col_index, col_name in enumerate(columns):
            self.scroll_area_layout.addWidget(QLabel(f"<b>{col_name}</b>"), 0, col_index)

        # Afficher les lignes
        for row_index, row in enumerate(data, start=1):
            for col_index, cell in enumerate(row):
                self.scroll_area_layout.addWidget(QLabel(str(cell)), row_index, col_index)

    def search_vulnerable(self):
        search_term = self.search_input.text()
        print(f"Clicked, {search_term}  " )
         # Création du DSN et connexion
        # Récupérer les valeurs saisies
        username = self.username_input.text()
        password = self.password_input.text()
        host = self.host_input.text()
        port = self.port_input.text()
        service_name = self.service_name_input.text()

        try:
            # Récupérer la connexion à la base de données
            dsn = db.makedsn(host, port, service_name=service_name)
            connection = db.connect(user=username, password=password, dsn=dsn)
            cursor = connection.cursor()
            # Requête sécurisée avec des paramètres liés
            query = "SELECT * FROM departements WHERE NOM_DEPARTEMENT LIKE :search_term"
            print(f'{search_term}')
            cursor.execute(query, {'search_term': f'%{search_term}%'})
            print(query)
            data = cursor.fetchall()
            columns = [desc[0] for desc in cursor.description]  # Obtenir les noms de colonnes
            
               # Appliquer le hachage sur la colonne "Localisation"
            hashed_data = []
            for row in data:
                row = list(row)  # Convertir le tuple en liste pour modification
                if "LOCALISATION" in columns:  # Vérifie si la colonne existe
                    print("Localisation existe")
                    loc_index = columns.index("LOCALISATION")  # Récupère l'index de la colonne
                    row[loc_index] = self.hash_password(row[loc_index]) if row[loc_index] else None  # Hache la localisation si elle existe
                hashed_data.append(tuple(row))  # Reconvertir en tuple pour consistance

            
            # Afficher les résultats de la recherche
            self.display_data(columns, hashed_data)
            # Fermer la connexion
            cursor.close()
            connection.close()
        except db.DatabaseError as e:
            error, = e.args
            QMessageBox.critical(self, "Erreur", f"Erreur de recherche : {error}")

# Application principale
if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = DatabaseConnectionApp()
    window.show()
    sys.exit(app.exec())