# Dirty passenger build system for Debian
This creates passenger builds for Nginx that can be used on Debian managed Nginx packages.

It should be triggered for every Nginx, Debian or Passenger update.

## Install
- Create amd64 and arm64 packages using the `build.sh` script
- Install the packages `passenger_<arch>.deb` and `libnginx-mod-http-passenger_*.deb`
- Create the default passenger config file at `/etc/nginx/conf.d/mod-http-passenger.conf`
```
passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;
passenger_ruby /usr/bin/passenger_free_ruby;
```
