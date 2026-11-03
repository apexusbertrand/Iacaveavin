// Flux IA_CAVE_Comptes (CPT-01 à CPT-03, contrat 2.0) : connexion par code
// envoyé par mail et clé de session propre au compte.
// - POST /iacave/compte/code : public, code à 6 chiffres par mail.
// - POST /iacave/compte/session : public, code vérifié, compte et clé.
// - GET /iacave/compte, POST /iacave/compte/deconnexion : signés avec la clé
//   du compte (état, quotas, révocation).
module.exports = (o) => {
  // Les trois chemins rejoignent la même décision (code assemblé une fois).
  const D = "$('Décision compte').first().json";
  const CODE = D;
  const SES = D;
  const ETAT = D;
  const COMPTE_ENTETE = "{{ $('Empreinte compte').first().json.entetes['x-iacav-compte'] || 'aucun' }}";
  const colonnesCompte = ['compte_id', 'email', 'statut', 'cle_session', 'cle_expire_le', 'cree_le', 'derniere_connexion', 'installation'];
  return `import { workflow, node, trigger, ifElse, sticky, expr } from '@n8n/workflow-sdk';

${o.webhook('webhookCode', 'Webhook code', 'POST', 'iacave/compte/code', false)}
${o.lire('configCode', 'Config code', 'config', [], { tout: true })}
${o.lire('codeEnCours', 'Code en cours', 'codes', [['email', o.ex("{{ String($('Webhook code').first().json.body.email || '').trim().toLowerCase() || 'aucun' }}")]])}
${o.code('decision', 'Décision compte', 'compte', "{ action: 'code', decision: 'refus', http: 400, reponse: {} }")}
${o.si('siEnvoiCode', 'Code à envoyer ?', "{{ $json.decision === 'envoi' }}")}
${o.si('siConnecte', 'Session ouverte ?', "{{ $json.decision === 'connecte' }}")}
${o.si('siEchec', 'Mauvais code ?', "{{ $json.decision === 'echec' }}")}
${o.si('siDeconnexion', 'Déconnexion ?', "{{ $json.decision === 'deconnexion' }}")}
${o.si('siSuppression', 'Suppression ?', "{{ $json.decision === 'suppression' }}")}
const mailCode = node({
  type: 'n8n-nodes-base.gmail', version: 2.2,
  config: { name: 'Mail du code', executeOnce: true, onError: 'continueRegularOutput',
    parameters: { resource: 'message', operation: 'send',
      sendTo: ${o.ex(`{{ ${CODE}.mail.a }}`)},
      subject: ${o.ex(`{{ ${CODE}.mail.sujet }}`)},
      emailType: 'text',
      message: ${o.ex(`{{ ${CODE}.mail.texte }}`)},
      options: { appendAttribution: false, senderName: 'IA cave à vin' } },
    credentials: ${o.IDENTIFIANTS.gmail} },
  output: [{ id: 'm1' }]
});
${o.si('siMailParti', 'Mail du code parti ?', '{{ !$json.error }}')}
${o.ecrire('enregistrerCode', 'Enregistrer le code', 'codes', 'upsert', Object.fromEntries(
    ['email', 'code_empreinte', 'expire_le', 'essais', 'envois', 'fenetre_debut'].map((k) => [k, o.ex(`{{ ${CODE}.ligne.${k} }}`)])),
  [['email', o.ex(`{{ ${CODE}.ligne.email }}`)]])}
const repondreCodeEchec = node({
  type: 'n8n-nodes-base.respondToWebhook', version: 1.5,
  config: { name: 'Répondre mail non parti', parameters: { respondWith: 'json',
    responseBody: expr(${o.q(`{{ { version_contrat: '2.0', request_id: ${CODE}.reponse.request_id, statut: 'erreur', erreur: { code: 'interne', message: 'Le mail n\\'est pas parti, réessayez plus tard.', reessayable: true } } }}`)}),
    options: { responseCode: 502 } } }
});
${o.repondre('repondreDecision', 'Répondre', `{{ ${D}.reponse }}`, `{{ ${D}.http }}`)}

${o.webhook('webhookSession', 'Webhook session', 'POST', 'iacave/compte/session', false)}
${o.lire('configSession', 'Config session', 'config', [], { tout: true })}
${o.lire('codeSession', 'Code de session', 'codes', [['email', o.ex("{{ String($('Webhook session').first().json.body.email || '').trim().toLowerCase() || 'aucun' }}")]])}
${o.lire('compteSession', 'Compte de session', 'comptes', [['email', o.ex("{{ String($('Webhook session').first().json.body.email || '').trim().toLowerCase() || 'aucun' }}")]])}
${o.lire('usageSession', 'Usage de session', 'usages', [['compte_id', o.ex("{{ $('Compte de session').first().json.compte_id || 'aucun' }}")], ['mois', o.ex(o.MOIS)]])}
${o.ecrire('enregistrerCompte', 'Enregistrer le compte', 'comptes', 'upsert', Object.fromEntries(
    colonnesCompte.map((k) => [k, o.ex(`{{ ${SES}.compte.${k} }}`)])),
  [['email', o.ex(`{{ ${SES}.compte.email }}`)]])}
${o.ecrire('consommerCode', 'Code consommé', 'codes', 'update',
    { code_empreinte: "''", essais: o.ex(`{{ ${SES}.ligne_code.essais }}`) },
  [['email', o.ex(`{{ ${SES}.ligne_code.email }}`)]])}
${o.ecrire('compterEssai', 'Essai compté', 'codes', 'update',
    { essais: o.ex(`{{ ${SES}.ligne_code.essais }}`) },
  [['email', o.ex(`{{ ${SES}.ligne_code.email }}`)]])}

${o.webhook('webhookEtat', 'Webhook compte', 'GET', 'iacave/compte', true)}
${o.webhook('webhookDeconnexion', 'Webhook déconnexion', 'POST', 'iacave/compte/deconnexion', true)}
${o.webhook('webhookSuppression', 'Webhook suppression', 'POST', 'iacave/compte/suppression', true)}
${o.code('empreinte', 'Empreinte compte', 'empreinte', "{ empreinte: 'x', texteCorps: '{}', requestId: 'x', entetes: {} }")}
${o.lire('configEtat', 'Config compte', 'config', [], { tout: true })}
${o.lire('compteSigne', 'Compte signé', 'comptes', [['compte_id', o.ex(COMPTE_ENTETE)]])}
${o.lire('usageCompte', 'Usage du compte', 'usages', [['compte_id', o.ex(COMPTE_ENTETE)], ['mois', o.ex(o.MOIS)]])}
${o.ecrire('revoquer', 'Révoquer la clé', 'comptes', 'update',
    { cle_session: "''", cle_expire_le: o.ex(`{{ ${ETAT}.compte.cle_expire_le }}`) },
  [['compte_id', o.ex(`{{ ${ETAT}.compte.compte_id }}`)]])}
${o.ecrire('anonymiser', 'Anonymiser le compte', 'comptes', 'update',
    { email: "''", statut: "'supprime'", cle_session: "''", cle_expire_le: o.ex(`{{ ${ETAT}.compte.cle_expire_le }}`) },
  [['compte_id', o.ex(`{{ ${ETAT}.compte.compte_id }}`)]])}

const note = sticky('## IA_CAVE_Comptes\\nComptes de l\\'app IA cave à vin (CPT-01 à CPT-05, docs/06) : code par mail, session, état, déconnexion, suppression. Source : n8n/workflow/src/ et n8n/code/ du dépôt iacaveavin. Ne pas modifier à la main.', [configCode, codeEnCours, decision], { color: 5 });

export default workflow('ia-cave-comptes', 'IA_CAVE_Comptes')
  .add(webhookCode)
  .to(configCode)
  .to(codeEnCours)
  .to(decision)
  .add(webhookSession)
  .to(configSession)
  .to(codeSession)
  .to(compteSession)
  .to(usageSession)
  .to(decision)
  .add(webhookEtat)
  .to(empreinte)
  .to(configEtat)
  .to(compteSigne)
  .to(usageCompte)
  .to(decision)
  .add(webhookDeconnexion)
  .to(empreinte)
  .add(webhookSuppression)
  .to(empreinte)
  .add(decision)
  .to(siEnvoiCode
    .onTrue(mailCode.to(siMailParti
      .onTrue(enregistrerCode.to(repondreDecision))
      .onFalse(repondreCodeEchec)))
    .onFalse(siConnecte
      .onTrue(enregistrerCompte.to(consommerCode).to(repondreDecision))
      .onFalse(siEchec
        .onTrue(compterEssai.to(repondreDecision))
        .onFalse(siDeconnexion
          .onTrue(revoquer.to(repondreDecision))
          .onFalse(siSuppression
            .onTrue(anonymiser.to(repondreDecision))
            .onFalse(repondreDecision))))))
  .add(note);
`;
};
