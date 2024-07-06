#!/bin/bash

# Setze die Variablen
DOMAIN="ragul.puvaneswaran.users.bbw-it.ch"
DNS_SERVER="ns.users.bbw-it.ch"
NSUPDATE_KEY="/home/ubuntu/bbw.key"
ACME="$HOME/.acme.sh/acme.sh"

# Erzeuge ein neues Zertifikat mit acme.sh und fange den TXT-Eintrag ab
$ACME --issue --dns --yes-I-know-dns-manual-mode-enough-go-ahead-please --renew --force -d $DOMAIN

# Installiere das Zertifikat
$ACME --renew --force --install-cert -d $DOMAIN \
--key-file /home/ubuntu/$DOMAIN.key \
--fullchain-file /home/ubuntu/$DOMAIN.cer

# Benutzer zur Eingabe der benötigten Informationen auffordern
read -p "Geben Sie den Domainnamen ein: " TXT_RECORD
read -p "Geben Sie den TXT-Eintrag ein: " TXT_VALUE

# Temporäre nsupdate-Datei erstellen
NSUPDATE_FILE=$(mktemp)

# Füge nsupdate-Befehle hinzu, um den TXT-Eintrag zu erstellen
cat <<EOF > $NSUPDATE_FILE
server $DNS_SERVER
update add $TXT_RECORD 300 IN TXT "$TXT_VALUE"
send
EOF

# Führe nsupdate aus
nsupdate -k $NSUPDATE_KEY $NSUPDATE_FILE

# Temporäre Datei löschen
rm $NSUPDATE_FILE