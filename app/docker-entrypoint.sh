#!/bin/bash
set -e

function _parse_true() {
	case "$1" in
		
		true | True | TRUE | 1)
		return 0
		;;
		
		*)
		return 1
		;;

	esac
}

function _parse_false() {
	case "$1" in
		
		false | False | FALSE | 0)
		return 0
		;;
		
		*)
		return 1
		;;

	esac
}

function _print_version {
    if [[ -n "${NGINX_PROXY_VERSION:-}" ]]; then
        echo "Info: running nginx-proxy version ${NGINX_PROXY_VERSION}"
    fi
}

function _check_unix_socket() {
	# Warn if the DOCKER_HOST socket does not exist
	if [[ ${DOCKER_HOST} == unix://* ]]; then
		local SOCKET_FILE="${DOCKER_HOST#unix://}"

		if [[ ! -S ${SOCKET_FILE} ]]; then
			cat >&2 <<-EOT
				ERROR: you need to share your Docker host socket with a volume at ${SOCKET_FILE}
				Typically you should run your nginxproxy/nginx-proxy with: \`-v /var/run/docker.sock:${SOCKET_FILE}:ro\`
				See the documentation at: https://github.com/nginx-proxy/nginx-proxy/#usage
			EOT

			exit 1
		fi
	fi
}

function _resolvers() {
	# Compute the DNS resolvers for use in the templates - if the IP contains ":", it's IPv6 and must be enclosed in []
	RESOLVERS=$(awk '$1 == "nameserver" {print ($2 ~ ":")? "["$2"]": $2}' ORS=' ' /etc/resolv.conf | sed 's/ *$//g'); export RESOLVERS

	SCOPED_IPV6_REGEX='\[fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}\]'

	if [[ -z ${RESOLVERS} ]]; then
		echo 'Warning: unable to determine DNS resolvers for nginx' >&2
		unset RESOLVERS
	elif [[ ${RESOLVERS} =~ ${SCOPED_IPV6_REGEX} ]]; then
		echo -n 'Warning: Scoped IPv6 addresses removed from resolvers: ' >&2
		echo "${RESOLVERS}" | grep -Eo "$SCOPED_IPV6_REGEX" | paste -s -d ' ' >&2
		RESOLVERS=$(echo "${RESOLVERS}" | sed -r "s/${SCOPED_IPV6_REGEX}//g" | xargs echo -n); export RESOLVERS
	fi
}

# Run the init logic if the default CMD was provided
if [[ $* == 'forego start -r' ]]; then
	_print_version
	
	_check_unix_socket

	_resolvers

	if [ -z "${TRUST_DOWNSTREAM_PROXY}" ]; then
		cat >&2 <<-EOT
			Warning: TRUST_DOWNSTREAM_PROXY is not set; defaulting to "true". For security, you should explicitly set TRUST_DOWNSTREAM_PROXY to "false" if there is not a trusted reverse proxy in front of this proxy.
			Warning: The default value of TRUST_DOWNSTREAM_PROXY might change to "false" in a future version of nginx-proxy. If you require TRUST_DOWNSTREAM_PROXY to be enabled, explicitly set it to "true".
		EOT
	fi
fi

exec "$@"
