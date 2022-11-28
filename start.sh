#!/bin/bash

# Validate Redirect Type
# REDIRECT : HTTP Redirect using redirection http status code (ex. 301)
# REWRITE : URL Rewrite
echo "REDIRECT, REWRITE" | grep -qw ${REDIRECT_TYPE}
if [[ $? -ne 0 ]]; then
	echo -e "Invalid REDIRECT_TYPE(${REDIRECT_TYPE}).\nUse REDIRECT for HTTP Redirect.\nUse REWRITE for URL Rewrite."
	exit 1
fi

# Check if REDIRECT_TARGET is set
if [ -z "${REDIRECT_TARGET}" ]; then
	echo "(REDIRECT_TARGET) variable not set"
	exit 1
else
	# Add http it not set
	if ! [[ ${REDIRECT_TARGET} =~ ^https?:// ]]; then
		REDIRECT_TARGET="http://${REDIRECT_TARGET}"
	fi

	# Add trailing slash it not set
	if [[ ${REDIRECT_TARGET:length-1:1} != "/" ]]; then
		REDIRECT_TARGET="${REDIRECT_TARGET}/"
	fi
fi

# Default to 80
LISTEN="80"
# VIRTUAL_PORT is a variable defined in nginxproxy/nginx-proxy docker image
if [ -n "${VIRTUAL_PORT}" ]; then
	LISTEN="${VIRTUAL_PORT}"
fi

##
# HTTP Redirect 
##
if [ "${REDIRECT_TYPE}" = "REDIRECT" ]; then
	# Default to 302 (Temporary Redirect)
	if [ -z "${REDIRECT_CODE}" ]; then
		REDIRECT_CODE="302"
	fi

	# Validate HTTP Redirect Code
	# 301 : Permanent / GET when request to redirected location
	# 308 : Permanent / Same HTTP method
	# 302 : Temporary / Originally same as 307, but most browsers only use GET
	# 303 : Temporary / GET
	# 307 : Temporary / Same HTTP method
	echo "301, 302, 303, 307, 308" | grep -qw ${REDIRECT_CODE}
	if [[ $? -ne 0 ]]; then
		echo -e "Invalid REDIRECT_CODE(${REDIRECT_CODE}).\nUse 301, 308 for Permanent Redirects.\nUse 302, 303, 307 for Temporary Redirects."
		exit 1
	fi

	cat <<EOF > /etc/nginx/conf.d/default.conf
		server {
			listen ${LISTEN};
			return ${REDIRECT_CODE} ${REDIRECT_TARGET};
		}
EOF

	echo "Listening to ${LISTEN}, Redirecting HTTP requests to ${REDIRECT_TARGET} (${REDIRECT_CODE})"
else
	##
	# URL Rewrite
	##

	# Default to redirect
	if [ -z "${REWRITE_FLAG}" ]; then
		REWRITE_FLAG="redirect"
	fi

	# Validate Rewrite Flag
	# permanent (same as 301)
	# redirect (same as 302)
	# break (Not Implemented)
	# last (Not Implemented)
	echo "permanent, redirect" | grep -qw ${REWRITE_FLAG}
	if [[ $? -ne 0 ]]; then
		echo -e "Invalid REWRITE_FLAG(${REWRITE_FLAG}).\nUse permanent for Permanent Rewrite.\nUse redirect for Temporary Rewrite."
		exit 1
	fi

	cat <<EOF > /etc/nginx/conf.d/default.conf
		server {
			listen ${LISTEN};
			rewrite ^/(.*)$ ${REDIRECT_TARGET}\$1 ${REWRITE_FLAG};
		}
EOF

	echo "Listening to ${LISTEN}, Rewriting URL to ${REDIRECT_TARGET} (${REWRITE_FLAG})"
fi

exec nginx -g "daemon off;"
