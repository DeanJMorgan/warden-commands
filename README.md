# Warden Commands

This repository is a collection of commands that can be used with the Warden CLI tool. The commands are designed to help with the setup and distribution of Magento 2 projects between developers. There are three scenarios that the commands are designed to help with:

1. Adding additional commands to the Warden CLI for Magento 2 projects already using Warden.
2. Adding Warden to a pre-existing Magento 2 project.
3. Creating a new Magento 2 project with the Warden CLI tool.


## Requirements

- [Docker](https://www.docker.com/)
- [Warden](https://docs.warden.dev/)


## Installation

### Clone this repository

To install the commands, clone this repository into the `.warden/commands` in your project directory.

```bash
git clone https://github.com/DeanJMorgan/warden-commands.git .warden/commands
```

You can also add the repository as a submodule.

```bash
git submodule add https://github.com/DeanJMorgan/warden-commands.git .warden/commands
```


### Configure Warden

> [!WARNING]
> If your project is already using Warden then you can skip this part.

If you haven't already configured Warden for this project, you can do so by running the following command.

```bash
warden env-init exampleproject magento2
```

This will create a `.env` file in the root of your project directory.


### Add required values to the `.env` file

Update the `.env` file with the following values.

```bash
ADMIN_PATH=backend # Admin path

MAGENTO_PACKAGE=magento/project-community-edition # Magento package to install
MAGENTO_VERSION=2.4.7 # Magento version to install
MAGENTO_PUBLIC_KEY=[public_key_here] # Your Magento Marketplace public key
MAGENTO_PRIVATE_KEY=[private_key_here] # Your Magento Marketplace private key

# The following value is the base64 encoded value of the Magento encryption key.
# You can find the encryption key in the `app/etc/env.php` file in the `crypt` section.
# Example: 'key' => 'base64fFfjc1n+SIxmOcb9x+iVmuAfMziC0OrO4nU/sTt6gbE='
MAGENTO_CRYPT_KEY=base64fFfjc1n+SIxmOcb9x+iVmuAfMziC0OrO4nU/sTt6gbE=

# If you want to install hyva-theme, you need to add the following values
HYVA_LICENSE_KEY=[license_key_here] # Your Hyva license key
HYVA_PROJECT_NAME=[project_name_here] # Your Hyva project name
```


## Initialise Project

> [!WARNING]
> If your project is already using Warden, you may want to skip this part. You can run most of the commands individually. See the list below for the available commands.

This command will perform the following actions:

1. Sets up SSL certificates for the project.
2. Installs Magento 2 (Clean Install Only).
3. Checks for `env.php` and creates one if it doesn't exist.
4. Imports the database (if one exists).
5. Installs n98-magerun.
6. Runs composer install.
7. Updates store configuration settings for development environment.
8. Updates store URLs in the database.
9. Installs development modules.
10. Runs the `setup:upgrade` command.
11. Runs the `indexer:reindex` command.
12. Creates an admin user.

> [!CAUTION]
> If we are not doing a clean install, we are going to be importing a database. It's important to make sure that a database dump is available in the `.warden/database` directory. The database dump should be named `exampleproject.db.sql.gz`.

Before initialising the project, you must first ensure that Warden is running. You can start Warden by running the following command.

```bash
warden env up
```

### Pre-existing Magento 2 Project

If you have a pre-existing Magento 2 project, you can add the Warden commands to the project by running the following command.

```bash
warden project-init
```


### New Magento 2 Project

If you are creating a new Magento 2 project, you can use the Warden CLI tool to create the project and add the Warden commands at the same time.

```bash
warden project-init --clean-install
```


## Commands

To use the commands, run the `warden` command followed by the command you want to run.

```bash
warden project-init
```


### Available Commands

- `install-magento` - Install Magento.
- `install-magerun` - Install n98-magerun.
- `install-dev-modules` - Install development modules.
- `install-hyva-theme` - Install Hyva theme and modules.
- `config-set-developer` - Updates store configuration settings for development environment.
- `config-set-store-urls` - Updates store URLs in the database.
- `database-backup` - Backup database.
- `database-restore` - Restore database.
- `clear-static-files` - Clear static files cache.
- `check-env-file` - Check if required values exist in .env file.
- `create-admin-user` - Create admin user.
