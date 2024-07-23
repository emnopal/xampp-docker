#!/bin/bash

# TODO: check this again

# Define default configuration paths
DEFAULT_APACHE_CONF="/etc/apache2/sites-enabled"
DEFAULT_PHP_CONF="/etc/php/${PHP_VERSION}/cli"

# Copy Apache configuration if present, otherwise use default
if [ -d /config/apache ]; then
    echo "Applying user-defined Apache configurations..."
    cp -r /config/apache/* ${DEFAULT_APACHE_CONF}/
else
    echo "No user-defined Apache configurations found. Using defaults."
    # Ensure default configuration is in place (no action needed if default is already in place)
    # You can include default configuration setup here if needed
fi

# Copy PHP configuration if present, otherwise use default
if [ -d /config/php ]; then
    echo "Applying user-defined PHP configurations..."
    cp -r /config/php/* ${DEFAULT_PHP_CONF}/
else
    echo "No user-defined PHP configurations found. Using defaults."
    # Ensure default configuration is in place (no action needed if default is already in place)
    # You can include default configuration setup here if needed
fi

# Start Apache in the foreground
exec apache2ctl -D FOREGROUND
