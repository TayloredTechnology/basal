# Wordpress @ Basal by Taylored Technology
> quest for optimal Containerization

### Will be moved out into separate repository?

## Purpose
Wordpress

## Environmental Variables
Base version of Basal uses the following for configuring CONFD:
- ROOT_DOMAIN ~ dns domain of deployed application
- MAIL_DOMAIN ~ *smtp.mailgun.org:587* for sending e-mails to
- MAIL_USER   ~ *postmaster* login name @ ROOT_DOMAIN
- MAIL_PASSWORD ~ password for username

Additional
- WP_RESET ~ set to anything will enable /resetter to clear PHP caches
