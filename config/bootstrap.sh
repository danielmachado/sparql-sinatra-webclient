#!/usr/bin/env bash

apt-get update
apt-get install -y rubygems
apt-get install -y git
apt-get install -y curl
#introducir a mano desde la MV. luego hacer vagrant halt y vagrant up
#curl -#L https://get.rvm.io | bash -s stable --autolibs=3 --ruby
#echo "source $HOME/.rvm/scripts/rvm" >> ~/.bash_profile
#una vez arrancada, utilizar rvm para gestionar Ruby
#rvm use 2.0.0
cd /vagrant
#git clone repo.url
