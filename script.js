const API_URL = 'http://localhost:3000/utilisateurs'; // Adresse du backend

// Charger les utilisateurs
async function loadUsers() {
    const response = await fetch(API_URL);
    const users = await response.json();
    
    const tableBody = document.getElementById('userTableBody');
    tableBody.innerHTML = ''; // Vider la table avant de la remplir

    users.forEach(user => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${user.id}</td>
            <td>${user.nom}</td>
            <td>${user.prenom}</td>
            <td>${user.phone}</td>
            <td>${user.email}</td>
            <td><button onclick="deleteUser(${user.id})">Supprimer</button></td>
            <td><button onclick="updateUser(${user.id})">Modifier</button></td>
        `;
        tableBody.appendChild(row);
    });
}

// Ajouter un utilisateur
document.getElementById('addUserForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const name = document.getElementById('name').value;
    const prenom = document.getElementById('prenom').value;
    const phone = document.getElementById('phone').value;
    const email = document.getElementById('email').value;

    await fetch(API_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ nom: name, email: email,prenom : prenom,phone:phone })
    });

    loadUsers(); // Recharger la liste après ajout
});

// Supprimer un utilisateur
async function deleteUser(userId) {
    await fetch(`${API_URL}/${userId}`, { method: 'DELETE' });
    loadUsers(); // Recharger la liste après suppression
}

// Charger les utilisateurs au démarrage
document.addEventListener('DOMContentLoaded', loadUsers);

