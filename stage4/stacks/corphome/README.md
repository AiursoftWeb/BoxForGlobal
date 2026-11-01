# CorpHome contact follow-up

Deploy the CorpHome version containing the ContactEmailFollowUp migrations before applying this configuration. AlertCenter itself requires no code change. The existing `CORPHOME_ALERTCENTER_API_KEY` must belong to the same application as before and have create, query and mitigate incident permissions. Keep its incident history for ReportId deduplication.

Supply these external values using the existing Box substitution mechanism:

| Value | Purpose |
|---|---|
| `CORPHOME_CONTACT_MAIL_ENABLED` | Set to `false` initially. Set to `true` only after the mailbox delivery restrictions and acceptance checks below pass. |
| `CORPHOME_CONTACT_MAIL_USERNAME` | Dedicated Mailcow mailbox receiving employee follow-up copies. |
| `CORPHOME_CONTACT_MAIL_PASSWORD` | Mailbox/application password. Never commit the real value. |

The compose configuration connects to `mail.aiursoft.com:993` with implicit TLS, inspects INBOX, accepts `@aiursoft.com` staff senders and uses a seven-day follow-up window. These are deployment choices; CorpHome supports other IMAPS hosts, mailboxes, sender addresses/domains and windows through its global settings. Configuration overrides the administration UI.

## Mailcow setup

Create a dedicated mailbox and arrange for employee replies copied to the staff group to reach it, or ask staff to copy this mailbox explicitly. Configure mail-server delivery rules so only authenticated internal employee messages can reach the monitored folder. Cover direct delivery to the mailbox and indirect delivery through the staff alias. An allowed From domain alone is not authentication. Do not enable automatic mitigation on an unrestricted mailbox. The mailbox account requires IMAP read access, not Mailcow administrator/API credentials. Retain messages until CorpHome has processed them.

## Acceptance and rollout

1. Set `CORPHOME_CONTACT_MAIL_ENABLED=false`, supply the mailbox credentials and deploy CorpHome with its database migrations.
2. Verify a genuine staff reply to a test customer, copied to the configured group/mailbox, reaches INBOX with the customer in To or CC. Verify external messages, including forged employee From addresses sent directly or through the group, cannot reach the monitored folder.
3. Grant the CorpHome AlertCenter key query and mitigate permissions alongside create permission. Confirm the contact synchronization job succeeds.
4. Use an isolated mailbox and AlertCenter application for initial testing. Submit two recent inquiries for one customer, send one employee reply and enable polling. Both incidents should mitigate after the next jobs complete. A later inquiry needs a new reply. External/automatic emails must not mitigate inquiries. Coordinate any production test because it sends real alerts.
5. Set `CORPHOME_CONTACT_MAIL_ENABLED=true` after validation. Inspect both contact jobs on the Jobs page. To pause automatic mitigation, set it back to `false`; saved evidence and progress remain.

Polling runs every minute, processes at most 1000 envelopes per run and resumes from persisted IMAP UID progress. First use or mailbox UIDVALIDITY changes scan recent history. A matching email must be sent and delivered after the submission and sent within seven days of it. Follow-up evidence survives AlertCenter outages, and failed mitigations retry. Already mitigated/resolved incidents are left in their existing state. Only mitigation is requested; resolution follows AlertCenter policy. CorpHome does not send customer emails or download message bodies.
