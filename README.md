# Basal by Taylored Technology
> quest for optimal Containerization

## Purpose
Create a suite of containers utilizing the best practices for running & scaling applications in cloud and OS independent ways.

## Approach
This uses a git-tree release strategy, all development work is completed on 'master' and each docker image to be compiled is released into a branch

## Technology
- JustContainers Implementation of Skarnet's S6 Hypervisior Suite
- Fetch for grabbing repo's & releases off GitHub
- SSMTP for Leaner & faster mail
- SQLite3 as a generic system accessible database
- CONFD for generating dynamic configuration files
- ENTR(1) to re-trigger events when files change {powerful when used in conjunction with CONFD}

## Alpine Alternative
(Unavailable) Best suited for situations where server memory is stressed over CPU & packages are available for use
## Clear Linux Alternative
(Unavailable) Fastest Linux in Docker to date, not always the smallest HD footprint but optimal throughput tuned.

## Environmental Variables
Base version of Basal uses the following for configuring CONFD:
- ROOT_DOMAIN ~ dns domain of deployed application
- MAIL_DOMAIN ~ *smtp.mailgun.org:587* for sending e-mails to
- MAIL_USER   ~ *postmaster* login name @ ROOT_DOMAIN
- MAIL_PASSWORD ~ password for username
