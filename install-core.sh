#!/bin/bash
set -e

echo "sleeping for 10s..."
sleep 10

cd /app

echo "installing wp core if necessary..."
wp core is-installed --allow-root || wp core install --url="$WORDPRESS_BLOGURL" --title="$WORDPRESS_BLOGNAME" --admin_user="$WORDPRESS_USERNAME" --admin_password="$WORDPRESS_PASSWORD" --admin_email="$WORDPRESS_EMAIL" --allow-root

sleep 1

echo "updating wp core database if necessary..."
wp core update-db --allow-root

sleep 1

echo "verifying wp core checksums..."
wp core verify-checksums --allow-root