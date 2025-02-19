const express = require('express');
const router = express.Router();
const db = require('../config/db');

// Récupérer tous les Commandes
router.get('/', (req, res) => {
    db.query('CALL all_commandes(@s)', (err, results) => {
        if (err) return res.status(500).json({ message: 'Erreur serveur' });

        // Récupérer le statut
        db.query('SELECT @s AS status', (err, statusResult) => {
            if (err) return res.status(500).json({ message: 'Erreur lors de la récupération du statut' });

            const status = statusResult[0].status;
            if (status === 0) {
                return res.json({ message: 'Aucune commande trouvée' });
            }  
            res.json(results[0]); 
        });
        
    });
});


// Ajouter une Commandes
router.post('/', (req, res) => {
    const { user_id, date_cmd, tva } = req.body;
    db.query('CALL Ajouter_commande( ?, ?, ?)', [ user_id, date_cmd, tva], (err) => {
        if (err) return res.status(500).json({ message: err.sqlMessage });
        res.json({ message: 'Commande ajoutée avec succès' });
    });
});

// Modifier une Commandes
router.put('/', (req, res) => {
    const { id, user_id, date_cmd, tva } = req.body;
    db.query('CALL Modifier_commande(?, ?, ?, ?)', [id, user_id, date_cmd, tva], (err) => {
        if (err) return res.status(500).json({ message: err.sqlMessage });
        res.json({ message: 'Commande modifiée avec succès' });
    });
});

// Supprimer une Commandes
router.delete('/:id', (req, res) => {
    const commandeId = req.params.id;
    db.query('CALL Supprimer_commande(?)', [commandeId], (err) => {
        if (err) return res.status(500).json({ message: err.sqlMessage });
        res.json({ message: 'Commande supprimé' });
    });
});

module.exports = router;

