// Flux IA_CAVE_Remontee (RET-01, contrat 1.3) : POST /iacave/remontee,
// requête signée comme les autres. Contrôles et composition du mail dans
// n8n/code/noeuds/remontee.js ; envoi par l'identifiant Gmail de l'app,
// à apexus.claude@gmail.com, copie et réponse au contact.
module.exports = (o) => {
  const CTL = "$('Contrôles remontée').first().json";
  const gmail = (variable, nom, avecPiece) => `const ${variable} = node({
  type: 'n8n-nodes-base.gmail', version: 2.2,
  config: { name: ${o.q(nom)}, executeOnce: true, onError: 'continueRegularOutput',
    parameters: { resource: 'message', operation: 'send',
      sendTo: ${o.ex(`{{ ${CTL}.mail.a }}`)},
      subject: ${o.ex(`{{ ${CTL}.mail.sujet }}`)},
      emailType: 'text',
      message: ${o.ex(`{{ ${CTL}.mail.texte }}`)},
      options: { appendAttribution: false,
        ccList: ${o.ex(`{{ ${CTL}.mail.cc }}`)},
        replyTo: ${o.ex(`{{ ${CTL}.mail.repondreA }}`)},
        senderName: ${o.ex(`{{ ${CTL}.mail.nomExpediteur }}`)}${avecPiece ? `,
        attachmentsUi: { attachmentsBinary: [{ property: 'piece_jointe' }] }` : ''} } },
    credentials: ${o.IDENTIFIANTS.gmail} },
  output: [{ id: 'm1' }]
});`;
  return `import { workflow, node, trigger, ifElse, sticky, expr } from '@n8n/workflow-sdk';

${o.webhook('webhookRemontee', 'Webhook remontée', 'POST', 'iacave/remontee', true)}
${o.code('empreinte', 'Empreinte remontée', 'empreinte', "{ empreinte: 'x', texteCorps: '{}', requestId: 'x', entetes: {} }")}
${o.lire('config', 'Config remontée', 'config', [], { tout: true })}
${o.lire('duJour', 'Remontées du jour', 'remontees', [['jour', o.ex("{{ $now.setZone('Europe/Paris').toFormat('yyyy-MM-dd') }}")]], { tout: true })}
${o.code('controles', 'Contrôles remontée', 'remontee', "{ decision: 'refus', http: 401, reponse: {}, avec_piece: false }")}
${o.si('siEnvoi', 'Remontée acceptée ?', "{{ $json.decision === 'envoi' }}")}
${o.si('siPiece', 'Pièce jointe ?', '{{ $json.avec_piece }}')}
${gmail('mailPiece', 'Mail avec pièce jointe', true)}
${gmail('mailSimple', 'Mail sans pièce jointe', false)}
${o.si('siParti', 'Mail parti ?', '{{ !$json.error }}')}
${o.ecrire('journal', 'Journal remontée', 'remontees', 'insert', Object.fromEntries(
    ['request_id', 'installation', 'jour', 'titre', 'email_contact', 'piece_jointe']
      .map((k) => [k, o.ex(`{{ ${CTL}.ligne.${k} }}`)])))}
${o.repondre('repondreEnvoye', 'Répondre envoyée', `{{ ${CTL}.reponse }}`, '{{ 200 }}')}
${o.repondre('repondreEchec', "Répondre échec d'envoi", `{{ ${CTL}.reponse_echec }}`, '{{ 502 }}')}
${o.repondre('repondreRefus', 'Répondre refus', `{{ ${CTL}.reponse }}`, `{{ ${CTL}.http }}`)}

const note = sticky('## IA_CAVE_Remontee\\nRemontée d\\'information de l\\'app par mail (RET-01, docs/06). Source : n8n/workflow/src/ et n8n/code/ du dépôt iacaveavin. Ne pas modifier à la main.', [empreinte, config, duJour, controles], { color: 5 });

export default workflow('ia-cave-remontee', 'IA_CAVE_Remontee')
  .add(webhookRemontee)
  .to(empreinte)
  .to(config)
  .to(duJour)
  .to(controles)
  .to(siEnvoi
    .onTrue(siPiece
      .onTrue(mailPiece.to(siParti.onTrue(journal.to(repondreEnvoye)).onFalse(repondreEchec)))
      .onFalse(mailSimple.to(siParti)))
    .onFalse(repondreRefus))
  .add(note);
`;
};
