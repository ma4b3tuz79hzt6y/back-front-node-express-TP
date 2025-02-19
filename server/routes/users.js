const express = require('express');
const router = express.Router();
const db = require('../config/db');

// Récupérer tous les utilisateurs
router.get('/', (req, res) => {
    db.query('CALL all_users(@s)', (err, results) => {
        if (err) return res.status(500).json({ message: err.sqlMessage });
        res.json(results[0]);
    });
});

// Ajouter un utilisateur
router.post('/', (req, res) => {
    const { nom, prenom, email, phone } = req.body;
    db.query('CALL Ajouter_user(?, ?, ?, ?)', [nom, prenom, email, phone], (err) => {
        if (err) return res.status(500).json({ message: err.sqlMessage });
        res.json({ message: 'Utilisateur ajouté avec succès' });
    });
});

// Modifier un utilisateur
router.put('/', (req, res) => {
    const { id, nom, prenom, email, phone } = req.body;
    db.query('CALL Modifier_user(?, ?, ?, ?, ?)', [id, nom, prenom, email, phone], (err) => {
        if (err) return res.status(500).json({ message: err.sqlMessage });
        res.json({ message: 'Utilisateur modifié avec succès' });
    });
});

// Supprimer un utilisateur
router.delete('/:id', (req, res) => {
    const userId = req.params.id;
    db.query('CALL Supprimer_user(?)', [userId], (err) => {
        if (err) return res.status(500).json({ message: err.sqlMessage });
        res.json({ message: 'Utilisateur supprimé' });
    });
});

module.exports = router;

