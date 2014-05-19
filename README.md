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

## Alternate
Use the vagrant box described here:
[https://github.com/gddk/vagrant-cent65-64-puppet](https://github.com/gddk/vagrant-cent65-64-puppet)

It has rvm and ruby 2.1.1 preinstalled and ready to go.  

##  Download the source and prepare
```
cd
mkdir -p repos
cd repos
git clone https://github.com/gddk/pingdom-graphite.git
cd pingdom-graphite
rvm use 2.1.1
sudo -s
rvm use 2.1.1
# Will complain at you about running this as root, but
# it's the only way I could get it to work. vagrant user
# doesn't have permission to add gems
bundle install
exit
```

##  Configure config/config.yml
Self explanatory

## Test the app is working right
Edit spec/pingdom_spec.rb and change 1118385 to your pingdom check id
Then run "rspec --format nested" and the output should look like this:
```
Graphite
  #new
    returns a new graphite object
    has a host
    has a port
    has an open socket
  #report
    reports to graphite without socket error

Pingdom
  #probes
    is a hash
    contains more than 50 probes
  #results
    return more than 30 results for checkid 1118385 for last hour

Finished in 11.01 seconds
8 examples, 0 failures
```

##  Execute app
Change XXXXXXX to your checkid
```
./pingdom-graphite.rb XXXXXXX
```
In it's current form, it will fetch the last 2 days worth of data.
For the first run, you may want to edit pingdom-graphite.rb and make
it more, like 30 or 60 days, to backfill your data.

## Setup to run regularly
```
REM Coming soon, add to crontab
```
