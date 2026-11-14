// CPT-04, CPT-05 (contrat 2.1) : état, déconnexion et suppression du compte,
// signés avec la clé du compte. Remplace decisionEtatCompte de comptes.js dans
// le seul flux IA_CAVE_Comptes : comptes.js reste tel quel, car il est aussi
// inclus dans les contrôles d'entrée et le suivi de l'Agent (T131).
if (typeof require !== 'undefined' && typeof comptePublic === 'undefined') Object.assign(globalThis, require('./comptes.js'));

const VERSION_CONTRAT_COMPTE_21 = '2.1';
const CHEMINS_COMPTE_21 = { ...CHEMINS_COMPTE, suppression: '/webhook/iacave/compte/suppression' };

/**
 * action : etat (GET), deconnexion ou suppression (POST). La suppression
 * anonymise le compte : adresse et clé effacées, statut supprime. Usages et
 * vins traités gardent l'identifiant pseudonyme, qui ne mène plus à personne.
 */
function decisionCompteSigne({ action, entetes, empreinte, config, compte, ligneUsage, maintenant, schemaReponse }) {
  const methode = action === 'etat' ? 'GET' : 'POST';
  const configCompte = configPourCompte(config, compte, maintenant);
  if (!compteActif(compte, maintenant)) {
    return { decision: 'refus', ...erreurCompte('auth_invalide', 'Session expirée ou inconnue : reconnectez-vous.', null, false) };
  }
  const auth = verifierRequete({
    entetes, methode, chemin: CHEMINS_COMPTE_21[action], corps: empreinte, cle: configCompte.cle_app,
    maintenant: Math.floor(maintenant / 1000), fenetre: parseInt(config.fenetre_secondes, 10) || 300,
  });
  if (!auth.ok) return { decision: 'refus', ...erreurCompte(auth.code, auth.message, null) };
  const reponse = action === 'suppression'
    ? { version_contrat: VERSION_CONTRAT_COMPTE_21, request_id: UUID_NUL, statut: 'supprime' }
    : {
      version_contrat: VERSION_CONTRAT_COMPTE_21,
      request_id: UUID_NUL,
      statut: action === 'deconnexion' ? 'deconnecte' : 'ok',
      compte: comptePublic(compte, config, ligneUsage && ligneUsage.compte_id === compte.compte_id ? ligneUsage : null),
    };
  const verif = validateSchema(schemaReponse, reponse);
  if (verif.length) throw new Error('Réponse hors contrat : ' + verif.join(' ; '));
  const r = { decision: action, http: 200, reponse };
  const fin = new Date(maintenant).toISOString();
  if (action === 'deconnexion') r.compte = { compte_id: compte.compte_id, cle_session: '', cle_expire_le: fin };
  if (action === 'suppression') r.compte = { compte_id: compte.compte_id, email: '', statut: 'supprime', cle_session: '', cle_expire_le: fin };
  return r;
}

/**
 * Q13 : compte de revue Google Play. Pour l'adresse `revue_email` de la
 * config, le code fixe dont l'empreinte (empreinteCode) est
 * `revue_code_empreinte` remplace le code envoyé par mail. Mêmes limites
 * qu'un code ordinaire : un code doit avoir été demandé juste avant (ligne en
 * cours), 5 essais, 10 minutes, code consommé après usage. Sans ces deux clés
 * de config, rien ne change. Ni l'adresse ni le code ne sont dans le dépôt.
 */
function ligneCodeRevue(config, texteCorps, ligneCode) {
  const empreinte = String((config && config.revue_code_empreinte) || '').trim();
  const revue = normaliserEmail(config && config.revue_email);
  if (!empreinte || !revue || !ligneCode || !ligneCode.code_empreinte) return ligneCode;
  let corps = texteCorps;
  if (typeof corps === 'string') {
    try {
      corps = JSON.parse(corps);
    } catch (e) {
      return ligneCode;
    }
  }
  if (!corps || normaliserEmail(corps.email) !== revue) return ligneCode;
  return { ...ligneCode, code_empreinte: empreinte };
}

if (typeof module !== 'undefined') module.exports = { VERSION_CONTRAT_COMPTE_21, CHEMINS_COMPTE_21, decisionCompteSigne, ligneCodeRevue };
