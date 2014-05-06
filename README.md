pingdom-graphite
================

Get raw test results for a specified check in pingdom and jam into graphite

# Why
Very quick demonstration of something you can do with the Pindom API

# Dependencies

ruby 2.1.1 on CentOS 6.5 x86-64 used in the making.  May or may not work with other versions.

# What do do

## Install rvm and ruby 2.1.1
```
sudo -s
curl -L get.rvm.io | bash -s stable
rvm reload
rvm install 2.1.1
rvm list rubies
rvm use 2.1.1 --default
exit
```

##  Download the source and prepare
```
cd
mkdir -p repos
cd repos
git clone https://github.com/gddk/pingdom-graphite.git
cd pingdom-graphite
rvm use 2.1.1
sudo -s
bundle install
exit
```

##  Configure config/config.yml
Self explanatory

##  Execute app
```
REM Coming soon
```

## Setup to run regularly
```
REM Coming soon
```