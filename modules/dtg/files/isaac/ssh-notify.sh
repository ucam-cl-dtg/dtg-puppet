#!/bin/sh

# See http://sandrinodimattia.net/posting-successful-ssh-logins-to-slack/
#
# Ensure that the correct WebHook URL is on a single line in the file:
#     /local/data/webhook-url

if ( [ -e /local/data/webhook-url ] && [ "$PAM_USER" != "munin-async" ] && [ "$PAM_USER" != "isaac" ] && [ "$PAM_USER" != "jenkins" ]); then

    # Slack configuration:
    url=$(cat /local/data/webhook-url)
    channel="#compsci-ssh"

    # Info about the machine:
    timestamp="$(TZ=Europe/London date +'%-d %B %Y at %l:%M%p %Z')"
    host="$(hostname)"
    ip_addresses="$(ip addr list net0)"

    # Info about the trigger:
    if ([ "$PAM_TYPE" = "open_session" ]); then
        action="login"
    elif ([ "$PAM_TYPE" = "close_session" ]); then
        action="logout"
    else
        action="connection"
    fi

    # Colour to highlight message:
    if (echo "$ip_addresses" | grep -q '128.232.21.250'); then
        colour="#bb2828"
    elif (echo "$host" | grep -q 'analysis'); then
        colour="#509e2e"
    else
        colour="#fea100"
    fi

    # Content of the message:
    content="\"attachments\": [ { \"mrkdwn_in\": [\"text\", \"fallback\"], \"fallback\": \"SSH $action: $PAM_USER at \`$host\`\", \"text\": \"SSH $action at \`$host\`\", \"fields\": [ { \"title\": \"User\", \"value\": \"$PAM_USER\", \"short\": true }, { \"title\": \"IP Address\", \"value\": \"$PAM_RHOST\", \"short\": true }, { \"title\": \"Time\", \"value\": \"$timestamp\", \"short\": true },{ \"title\": \"Action\", \"value\": \"$action\", \"short\": true } ], \"color\": \"$colour\" } ]"

    curl -X POST --data-urlencode "payload={\"channel\": \"$channel\", \"mrkdwn\": true, \"username\": \"ssh-bot\", $content, \"icon_emoji\": \":computer:\"}" "$url"

fi
