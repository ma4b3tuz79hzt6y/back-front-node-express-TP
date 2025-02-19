// Importation des modules
const express = require('express');
const cors = require('cors');
const db = require('./config/db');
const userRoutes = require('./routes/users');
const commandeRoutes = require('./routes/commandes');

// Configuration de l'application
const app = express();
app.use(express.json());
app.use(cors());

//---------------------------------------------------------------------------------------
// Routes charger vos Routes ici
app.use('/utilisateurs', userRoutes);
app.use('/commandes', commandeRoutes);
//---------------------------------------------------------------------------------------

// Démarrer le serveur
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Serveur en écoute sur http://localhost:${PORT}`);
});

