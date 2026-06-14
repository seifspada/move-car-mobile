const String GET_MISSIONS_FOR_CARDS = '''
  query MissionsForCards {
    missionsForCards {
      id
      statut
      typeVehicule
      typeCarburant
      villeDepart
      villeArrivee
      distanceKm
      fraisPeage
      montantTotal
      dateDebut
      dateDepartMax
      isFavori
    }
  }
''';

const String TOGGLE_FAVORI = '''
  mutation ToggleFavori(\$missionId: String!) {
    toggleFavori(missionId: \$missionId)  
  }
''';

const String SEARCH_MISSIONS = '''
  query SearchMissions(\$search: String, \$page: Int, \$pageSize: Int) {
    searchMissions(search: \$search, page: \$page, pageSize: \$pageSize) {
      missions {
        id
        statut
        typeVehicule
        typeCarburant
        villeDepart
        villeArrivee
        distanceKm
        fraisPeage
        montantTotal
        dateDebut
        dateDepartMax
      }
      total
      page
      pageSize
      totalPages
    }
  }
''';

const String SEARCH_MISSIONS_BY_POSITION = '''
  query SearchMissionsByPosition(
    \$filters: SearchByPositionInput!
    \$page: Int
    \$pageSize: Int
  ) {
    searchMissionsByPosition(
      filters: \$filters
      page: \$page
      pageSize: \$pageSize
    ) {
      missions {
        id
        statut
        typeVehicule
        typeCarburant
        villeDepart
        villeArrivee
        distanceKm
        fraisPeage
        montantTotal
        dateDebut
        dateDepartMax
      }
      total
      page
      pageSize
      totalPages
    }
  }
''';

const String SEARCH_MISSIONS_BY_TRAJET = '''
  query SearchMissionsByTrajet(
    \$filters: SearchByTrajetInput!
    \$page: Int
    \$pageSize: Int
  ) {
    searchMissionsByTrajet(
      filters: \$filters
      page: \$page
      pageSize: \$pageSize
    ) {
      missions {
        id
        statut
        typeVehicule
        typeCarburant
        villeDepart
        villeArrivee
        distanceKm
        fraisPeage
        montantTotal
        dateDebut
        dateDepartMax
      }
      total
      page
      pageSize
      totalPages
    }
  }
''';


// ==========================================
// 🔔 ALERTES - MUTATIONS
// ==========================================
 
const String CREATE_ALERTE_GEOGRAPHIQUE = '''
  mutation CreateAlerteGeographique(\$input: CreateAlerteGeographiqueInput!) {
    createAlerteGeographique(input: \$input) {
      id
      type
      actif
      dateCreation
    }
  }
''';
 
const String CREATE_ALERTE_TRAJET = '''
  mutation CreateAlerteTrajet(\$input: CreateAlerteTrajetInput!) {
    createAlerteTrajet(input: \$input) {
      id
      type
      actif
      dateCreation
    }
  }
''';
 
const String UPDATE_FCM_TOKEN = '''
  mutation UpdateFcmToken(\$fcmToken: String!) {
    updateFcmToken(fcmToken: \$fcmToken)
  }
''';
 
const String DESACTIVER_ALERTE = '''
  mutation DesactiverAlerte(\$id: ID!) {
    desactiverAlerte(id: \$id) {
      id
      actif
    }
  }
''';
 
const String ACTIVER_ALERTE = '''
  mutation ActiverAlerte(\$id: ID!) {
    activerAlerte(id: \$id) {
      id
      actif
    }
  }
''';
 
const String SUPPRIMER_ALERTE = '''
  mutation SupprimerAlerte(\$id: ID!) {
    supprimerAlerte(id: \$id)
  }
''';
 
const String MODIFIER_RAYON = '''
  mutation ModifierRayon(\$id: ID!, \$rayon: Int!) {
    modifierRayon(id: \$id, rayon: \$rayon) {
      id
      rayon
    }
  }
''';
 
// ==========================================
// 🔔 ALERTES - QUERIES
// ==========================================
 
const String GET_MY_ALERTES = '''
  query {
    getMyAlertes {
      id
      type
      actif
      emailActif
      pushActif
      rayon
      villeNom
      latitude
      longitude
      villeDepartNom
      latitudeDepart
      longitudeDepart
      villeArriveeNom
      latitudeArrivee
      longitudeArrivee
      dateDepart
      dateDepartMax
      dateCreation
    }
  }
''';
 
const String GET_MY_ALERTES_WITH_TOKENS = '''
  query {
    getMyAlertesByUserWithTokens {
      id
      type
      actif
      emailActif
      pushActif
      fcmToken
      rayon
      villeNom
      latitude
      longitude
      villeDepartNom
      latitudeDepart
      longitudeDepart
      villeArriveeNom
      latitudeArrivee
      longitudeArrivee
      dateDepart
      dateDepartMax
      dateCreation
    }
  }
''';
const String getMissionByIdQuery = r'''
  query GetMissionById($id: String!) {
    getMissionById(id: $id) {
      id
      statut
      commentaire
      dateCreation
      partenaire {
        id
        entiteGroupe
      }
      agent {
        id
        nom
        prenom
        email
        telephone
        photo
      }
      vehicule {
        id
        typeVehicule
        typeCarburant
        marqueModele
        immatriculation
        nombrePlaces
        boiteVitesse
      }
      adresseDepart {
        id
        villeNom
        adresseComplete
        typeLieu
        nomLieu
        latitude
        longitude
      }
      adresseArrivee {
        id
        villeNom
        adresseComplete
        typeLieu
        nomLieu
        latitude
        longitude
      }
      disponibilite {
        id
        dateDebut
        dateFin
        dateDepartMax
      }
      calculs {
        id
        distanceKm
        fraisPeage
        montantTotal
      }
      notifications {
        id
        typeNotification
        actif
        nomContact
        telephoneContact
      }
      contrat {
        prixParKm
        depassementKilometrage
        retardSansAvertissement
        restitutionAutreEndroit
      }
    }
  }
''';
// ─── Mutation créer une réservation ──────────────────────────────────────────
 
const String createReservationMutation = r'''
  mutation CreateReservation($input: CreateReservationInput!) {
    createReservation(input: $input) {
      success
      message
      code
      reservation {
        id
        missionId
        numeroReservation
        statut
        dateDepart
        heureDepart
        dateArrivee
        heureArrivee
        dureeEstimee
        montantTotal
        fraisPeage
        distanceKm
      }
    }
  }
''';
