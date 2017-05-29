#!/usr/bin/execlineb -P
# -P is used exclusively when script does not require arguments to be passed into the script

define cenv /var/run/s6/container_environment
with-contenv

foreground {
	if -n { s6-test -f /app/core-domain-salts }
	# STDIN  0
	# STDOUT 1
	# STDERR 2
	redirfd -x -n 1 /app/core-domain-salts curl -s https://api.wordpress.org/secret-key/1.1/salt/
}

ifthenelse { s6-test -z $ROOT_DOMAIN }
{
	define SALTY_KEY default
}
{
	define SALTY_KEY $ROOT_DOMAIN
}

foreground {
	forbacktickx -d"'" maybeSalty { redirfd -r -n 0 /app/core-domain-salts cat }
  import -u maybeSalty
  # foreground { echo maybeSalty: ${maybeSalty} }
  backtick -n almostNameSalty { pipeline { s6-echo $maybeSalty } s6-grep -F "_" }
  import almostNameSalty
  backtick -n lenSalty { pipeline { s6-echo ${maybeSalty} } wc -m }
  import -u lenSalty
  backtick -n nameSalty {
  	if { s6-test -n $almostNameSalty }
    if -n { s6-test $lenSalty = "65" }
    foreground { echo ${almostNameSalty} }
  }
  importas nameSalty nameSalty
  ifthenelse { s6-test -z $nameSalty }
  {
  	backtick -n keySalty { redirfd -r -n 0 ${cenv}/tmp cat }
    import -u keySalty
    if { s6-test $lenSalty = "65" }
    redirfd -x -n 1 ${cenv}/${keySalty} s6-echo -n ${maybeSalty}
  }
  {
	  # foreground { echo { saltyness: ${nameSalty} } }
    redirfd -w -n 1 ${cenv}/tmp s6-echo -n $nameSalty
  }
}
s6-rmrf ${cenv}/tmp
