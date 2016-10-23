#!/bin/bash
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.custom
. /opt/farm/scripts/functions.install


if [ "$1" = "" ]; then
	echo "usage: $0 <role>"
	exit
fi

role=$1


if [ -f $base/packages/$role ]; then
	for p in `cat $base/packages/$role`; do
		if [ "$OSTYPE" = "debian" ]; then
			install_deb $p
		elif [ "$OSTYPE" = "redhat" ]; then
			install_rpm $p
		elif [ "$OSTYPE" = "suse" ]; then
			install_suse $p
		elif [ "$OSTYPE" = "netbsd" ]; then
			install_pkgin $p
		elif [ "$OSTYPE" = "freebsd" ]; then
			install_pkg $p
		fi
	done
fi

if [ -f $base/packages/$role.purge ]; then
	for p in `cat $base/packages/$role.purge`; do
		if [ "$OSTYPE" = "debian" ]; then
			uninstall_deb $p
		elif [ "$OSTYPE" = "redhat" ] || [ "$OSTYPE" = "suse" ]; then
			uninstall_rpm $p
		elif [ "$OSTYPE" = "netbsd" ]; then
			uninstall_pkgin $p
		elif [ "$OSTYPE" = "freebsd" ]; then
			uninstall_pkg $p
		fi
	done
fi

if [ -f $base/packages/$role.cpan ]; then
	for p in `cat $base/packages/$role.cpan`; do
		install_cpan $p
	done
fi

if [ ${role:0:3} = "sf-" ]; then
	ext=${role:3}
	if [ ! -d /opt/farm/ext/$ext ]; then
		git clone "`extension_repository`/$role" /opt/farm/ext/$ext
	elif [ ! -d /opt/farm/ext/$ext/.git ] && [ ! -d /opt/farm/ext/$ext/.svn ]; then
		echo "directory /opt/farm/ext/$ext busy, skipping extension $role installation"
	fi
	if [ -x /opt/farm/ext/$ext/setup.sh ]; then
		/opt/farm/ext/$ext/setup.sh
	fi
fi
