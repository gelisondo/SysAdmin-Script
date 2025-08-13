#! /bin/bash

#Como Herramientas extras agregamos:
#bat, lsd, fzf , ranger

#Download Hack Fonts
sudo apt install fontconfig
sudo mkdir /usr/share/fonts/Hack
cd  /usr/share/fonts/Hack
sudo wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip
sudo unzip Hack.zip
sudo fc-cache -f

sleep 4
echo "Si no lo logras ver correctamente, es por que estas conectado al servidor de forma remota"
echo "Si es así, debes descargar las fuentes en tu equipo de trabajo y configurar tu emulador de terminal(terminator,termix,) para poder visualizarlas" 


#Instalación de la shell y herramientas 
sudo apt-get install -y  zsh 


#Descargamos Powerlevel10k, Tuning de ZSH
cd
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

#scp systecadmin@164.73.188.18:/home/systecadmin/sistemas-operativos/server/AutoZsh/.p10k.zshr 

#Cosas que agregar a la izquirda
#   status
#    command_execution_time


#Configuramos ZSH por primera vez
echo "#Des pues de configurarla Ejecuta el comando 'exit'"
sleep 3
zsh

sudo mkdir /usr/share/zsh-plugins/
sudo chmod 777 /usr/share/zsh-plugins/
cd /usr/share/zsh-plugins/
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
git clone https://github.com/zsh-users/zsh-autosuggestions

# Plugins
echo "#plugins" >> .zshrc
echo "source /usr/share/zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> $HOME/.zshrc
echo "source /usr/share/zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> $HOME/.zshrc
echo "source /usr/share/zsh-plugins/sudo.plugin.zsh" >> $HOME/.zshrc

cd

#Instalación de Bat Version mejorada de cat:
wget https://github.com/sharkdp/bat/releases/download/v0.20.0/bat_0.20.0_amd64.deb
sudo dpkg -i bat_0.20.0_amd64.deb
echo "#custon Aliases  " >> .zshrc
echo "alias bcat='/bin/batcat'  " >> .zshrc
echo "alias bcatl='batcat --paging=never'  " >> .zshrc


wget https://github.com/Peltoche/lsd/releases/download/0.21.0/lsd-musl_0.21.0_amd64.deb
sudo dpkg -i lsd-musl_0.21.0_amd64.deb
# Manual aliases  " >> .zshrc
echo "" >> .zshrc
echo "alias ll='lsd -lh --group-dirs=first'  " >> .zshrc
echo "alias la='lsd -a --group-dirs=first'  " >> .zshrc
echo "alias l='lsd --group-dirs=first'  " >> .zshrc
echo "alias lla='lsd -lha --group-dirs=first'  " >> .zshrc
echo "alias ls='lsd --group-dirs=first'  " >> .zshrc


#fuzzzy finder
#    Key bindings (CTRL-T, CTRL-R, and ALT-C) (bash, zsh, fish)
#    Fuzzy auto-completion (bash, zsh)

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install



####################################################### root #################################################
#Configuramos ZSH por primera vez
echo "#Des pues de configurarla Ejecuta el comando 'exit'"
sleep 3
su -

#Descargamos P10K para root
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

#Ejecutamos la shell para configurarla 
zsh

#Elimina la configuración del promp para Root
#sudo sed -i '/POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE/d' /root/.p10k.zsh
#Agrega un prom con un Hastach para Root
#sudo echo "typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='#'" >> /root/.p10k.zsh


# Plugins
echo "source /usr/share/zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> /root/.zshrc
echo "source /usr/share/zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> /root/.zshrc

#Con la tecla ESC dos veces te agrega la palabra sudo adelante del comando
echo "source /usr/share/zsh-plugins/zsh-sudo/sudo.plugin.zsh" >> /root/.zshrc

#Alias para root
echo "#custon Aliases  " >> /root/.zshrc
echo "alias bcat='/bin/batcat'  " >> /root/.zshrc
echo "alias bcatl='batcat --paging=never'  " >> /root/.zshrc


# Manual aliases  " >> /root/.zshrc
echo "" >> /root/.zshrc
echo "alias ll='lsd -lh --group-dirs=first'  " >> /root/.zshrc
echo "alias la='lsd -a --group-dirs=first'  " >> /root/.zshrc
echo "alias l='lsd --group-dirs=first'  " >> /root/.zshrc
echo "alias lla='lsd -lha --group-dirs=first'  " >> /root/.zshrc
echo "alias ls='lsd --group-dirs=first'  " >> /root/.zshrc

#fuzzzy finder
#    Key bindings (CTRL-T, CTRL-R, and ALT-C) (bash, zsh, fish)
#    Fuzzy auto-completion (bash, zsh)

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install





####################################################### root #################################################


sudo usermod --shell /usr/bin/zsh systecadmin
sudo usermod --shell /usr/bin/zsh root

Voy aca despues lo sigo!!
https://youtu.be/mHLwfI1nHHY?t=6259
