# Warden Commands

## Commands List

`warden project-init` - Initialise project.
This is the first command to run after cloning or setting up any project for the
first time. It will install all the necessary dependencies and set up the project.
You can use this command with the `--clean-install` flag to create a fresh install.


### Additional Commands

- `warden install-magento` - Install Magento.
- `warden install-magerun` - Install n98-magerun.
- `warden install-dev-modules` - Install development modules.
- `warden config-set-developer` - Updates store configuration settings for development environment.
- `warden config-set-store-urls` - Updates store URLs in the database.
- `warden database-backup` - Backup database.
- `warden database-restore` - Restore database.
- `warden clear-static-files` - Clear static files cache.
- `warden check-env-file` - Check if required values exist in .env file.
- `warden create-admin-user` - Create admin user.