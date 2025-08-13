#!/bin/bash
TUUSUARIO="himan"

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.6.0/utils/wp-completion.bash
mv  wp-completion.bash /home/$TUUSUARIO/.wp-completion.bash

echo "source /home/$TUUSUARIO/.wp-completion.bash" >> /home/$TUUSUARIO/.bashrc
echo "source /home/$TUUSUARIO/.wp-completion.bash" >> /root/.bashrc
source ~/.bash_profile
