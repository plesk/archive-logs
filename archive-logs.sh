#!/bin/bash -e
### Copyright 1999-2022. Plesk International GmbH. All rights reserved.

# --- start of config.sh parameters ---

# List of log glob patterns to include.
# All glob strings MUST be quoted. Prefer absolute paths.
# See 'Pattern Matching' under 'Pathname Expansion' in bash(1) for glob string syntax.
# Each glob string should cover one or more unrotated log paths and
# all their rotated variants.
# To add to the default list, use the '+=' syntax:
#	LOG_GLOBS+=(
#		"/path/to/file.log*"
#		"/path/to/log/dirs/*/*.log*"
#	)
# To override the entire list use the '=' syntax:
LOG_GLOBS=(
	# Plesk
	"/var/log/plesk/*.log*"
	"/var/log/plesk/httpsd_access_log*"
	"/var/log/plesk/install/*.log*"
	"/var/log/sw-cp-server/error_log*"
	"/var/log/sw-cp-server/sw-engine.log*"
	# Plesk backup/restore
	"/var/log/plesk/PMM/*.log*"
	"/var/log/plesk/PMM/*/*.log"
	# Plesk Migrator extension
	"/usr/local/psa/var/modules/panel-migrator/logs/*.log*"
	"/usr/local/psa/var/modules/panel-migrator/sessions/*/*.log"
	"/usr/local/psa/var/modules/panel-migrator/sessions/*/tasks/*.log"
	# Plesk Site Import extension
	"/usr/local/psa/var/modules/site-import/logs/*.log*"
	"/usr/local/psa/var/modules/site-import/sessions/*/*.log"
	"/usr/local/psa/var/modules/site-import/sessions/*/tasks/*.log"
	# Plesk WordPress Toolkit extension
	"/var/log/plesk/modules/wp-toolkit/action-logs/*/*.log*"
	# MySQL and its variants
	"/var/log/mariadb/*.log*"
	"/var/log/mysql/*.log*"
	# PostgreSQL
	"/var/log/postgresql/*.log*"
	# Apache (server-wide)
	"/var/log/httpd/*_log*"
	"/var/log/apache2/*.log*"
	# nginx (server-wide)
	"/var/log/nginx/*.log*"
	# FTP
	"/var/log/plesk/xferlog"
	"/var/log/plesk/xferlog.processed*"
	#"/var/log/plesk/ftp_tls.log*"	# covered by "/var/log/plesk/*.log*" above
	# Authentication
	"/var/log/secure*"
	#"/var/log/auth.log*"			# covered by "/var/log/*.log*" below
	# System services (xinetd, bind, systemd, etc.)
	"/var/log/messages*"
	"/var/log/syslog*"
	# Mail services
	"/var/log/maillog"
	"/var/log/maillog.processed*"
	# Horde webmail
	"/var/log/psa-horde/*.log*"
	# Roundcube webmail
	"/var/log/plesk-roundcube/*"
	# Mailman
	"/var/log/mailman/*"
	# Premium Antivirus (DrWeb)
	"/var/drweb/log/*.log*"
	# Plesk Watchdog extension
	"/var/log/plesk/modules/monit.log*"
	"/var/log/plesk/modules/wdcollect.log*"
	#"/var/log/rkhunter.log*"		# covered by "/var/log/*.log*" below
	# Fail2Ban
	#"/var/log/fail2ban.log*"		# covered by "/var/log/*.log*" below
	# ModSecurity
	#"/var/log/modsec_audit.log*"	# covered by "/var/log/*.log*" below
	# Passenger
	"/var/log/passenger/*.log*"
	"/var/log/passenger-analytics/*.log*"
	# Plesk PHP-FPM
	"/var/log/plesk-php*-fpm/*log*"
	# Assorted system services
	"/var/log/*.log*"
	"/var/log/apt/*.log*"
	"/var/log/cron*"

	# Plesk domain logs
	# If /var/www/vhosts was relocated using 'transvhosts.pl' utility, either add updated
	# patterns using the config or simply symlink /var/www/vhosts to the new location.
	"/var/www/vhosts/system/*/logs/*access*log"
	"/var/www/vhosts/system/*/logs/*error_log*"
	"/var/www/vhosts/system/*/logs/access_log.processed*"
	"/var/www/vhosts/system/*/logs/access_ssl_log.processed*"
	"/var/www/vhosts/system/*/logs/php-fpm_error.log*"
	"/var/www/vhosts/system/*/logs/xferlog.processed*"
	"/var/www/vhosts/system/*/logs/xferlog_regular.processed*"
)

# List of log glob patterns to exclude.
# All glob strings MUST be quoted.
# Same as in logrotate by default (see 'tabooext' and 'taboopat' in logrotate(8)).
# To add to the default list, use the '+=' syntax:
#	LOG_IGNORE_PATTERNS+=(
#		"*.backup"
#		"/path/to/specific/file"
#	)
# To override the entire list use the '=' syntax:
LOG_IGNORE_PATTERNS=(
	"*,v"
	"*.bak"
	"*.cfsaved"
	"*.disabled"
	"*.dpkg-bak"
	"*.dpkg-del"
	"*.dpkg-dist"
	"*.dpkg-new"
	"*.dpkg-old"
	"*.dpkg-tmp"
	"*.rhn-cfg-tmp-*"
	"*.rpmnew"
	"*.rpmorig"
	"*.rpmsave"
	"*.swp"
	"*.ucf-dist"
	"*.ucf-new"
	"*.ucf-old"
	"*~"
)

# Compress command.
# Same as in logrotate by default (see 'compresscmd' in logrotate(8)).
# Note that using multiple different 'compresscmd' in logrotate configuration will lead
# to bad results (duplicated data) during log archival.
COMPRESS_CMD=(gzip)

# Compressed file extension. Should correspond to the COMPRESS_CMD above.
# Same as in logrotate by default (see 'compressext' in logrotate(8)).
COMPRESS_EXT=".gz"

# List of file extensions recognized as archives.
# By default this is the same as in logrotate source code.
COMPRESSED_EXTENSIONS=(bz2 gz xz Z zip zst)

# Command to use as transport from staging to storage.
# Typical examples: cp, rsync, scp.
# The command should accept two arguments: staging directory and destination (see below).
# The command should account for COPY_STRATEGY (see below).
TRANSPORT_CMD=(cp -arT)

# Transport destination (the storage). Should be understandable by the TRANSPORT_CMD above.
TRANSPORT_DEST="/tmp/cold-storage-example"

# Local staging directory. Logs are collected here before transport command is invoked.
# Ideally this directory should reside on the same partition as all the collected logs.
# That way efficient COPY_STRATEGY="hardlink" (see below) can be safely used.
# Staging directory is cleaned up before the logs archival script ends its work.
STAGING_DIR="/var/cache/archive-logs"

# Strategy used to obtain a "copy" of a log in the staging directory.
# The value should be one of:
# * "hardlink" - hardlink file: efficient, but typically requires the log and the staging
#                directory to be on the same partition, typically very easy to handle for
#                the transport command.
# * "symlink"  - symlink file: efficient, no limitations on use, but typically requires
#                transport command to correctly dereference links (so the transport
#                command might need additional flags).
# * "copy"     - copy file: slow, consumes extra disk space (unless filesystem supports
#                reflinks), but typically very easy to handle for the transport command.
# * "best"     - hardlink if possible, otherwise copy file: ensures that the transport
#                command doesn't need to handle symlinks, even if some logs are on a
#                different partition than the staging directory.
# * "link"     - hardlink if possible, otherwise symlink file: ensures minimum possible
#                space (and time) is used during preparation of staging directory,
#                but the transport command needs to account for possible symlinks.
COPY_STRATEGY="best"

# Default transport implementation. Arguments: directories to transport.
# Override this if TRANSPORT_CMD and TRANSPORT_DEST customization is not sufficient.
transport()
{
	"${TRANSPORT_CMD[@]}" "$@" "$TRANSPORT_DEST"
}

# Default log compression implementation. Arguments: uncompressed path, compressed path.
# Override this if COMPRESS_CMD customization is not sufficient.
compress()
{
	"${COMPRESS_CMD[@]}" <"$1" >"$2"
}

# Default log filter implementation. Arguments: log path.
# Returns 0 if log should be included, non-zero if log should be excluded.
# Override this if LOG_IGNORE_PATTERNS customization is not sufficient.
# E.g. it is possible to exclude all logs that are older than a certain age here.
log_filter()
{
	:
}

# --- end of config.sh parameters ---

# --- service functions required during arguments parsing ---
# These could technically be overridden in config.sh, but SHOULD NOT be.

copy_strategy_hardlink()
{
	debug "Hardlink '$1' to '$2'"
	[ -z "$DRY_RUN" ] || return 0

	mkdir -p "`dirname "$target"`"
	cp -Tl "$@"
}

copy_strategy_symlink()
{
	debug "Symlink  '$1' to '$2'"
	[ -z "$DRY_RUN" ] || return 0

	mkdir -p "`dirname "$target"`"
	cp -Ts "$@"
}

copy_strategy_copy()
{
	debug "Copy     '$1' to '$2'"
	[ -z "$DRY_RUN" ] || return 0

	mkdir -p "`dirname "$target"`"
	cp -Ta --reflink=auto "$@"
}

copy_strategy_best()
{
	[ -z "$DRY_RUN" ] || { debug "Hard/Cp  '$1' to '$2'"; return 0; }

	mkdir -p "`dirname "$target"`"
	cp -Tl "$@" && debug "Hardlink '$1' to '$2'" ||
		copy_strategy_copy "$@"
}

copy_strategy_link()
{
	[ -z "$DRY_RUN" ] || { debug "Hard/Sym '$1' to '$2'"; return 0; }

	mkdir -p "`dirname "$target"`"
	cp -Tl "$@" && debug "Hardlink '$1' to '$2'" ||
		copy_strategy_symlink "$@"
}

usage()
{
	if [ -n "$*" ]; then
		echo "archive-logs: $*" >&2
		exit 2
	fi

	cat <<-EOT
	Usage: archive-logs [OPTIONS]
	Collect and transfer logs for long-term storage.

	  -c, --config CONFIG           Use this config (default: 'config.sh' in the directory
	                                of the script). Config defines where to upload logs,
	                                how to do it, which additional logs to include, and
	                                some other settings. Use '--show-config-sample' to
	                                obtain a sample. Do not make the config world-writable.
	  -l, --log-level LEVEL         Set logging level, one of: 'ERROR', 'WARNING', 'INFO',
	                                'DEBUG' (default: 'WARNING'). Logs are written to
	                                stdout, additional error output from children and
	                                the script errors may appear on stderr.
	  -n, --dry-run                 Simulate operation, don't create or transfer files

	  -s, --show-config-sample      Print config.sh sample and exit
	  -h, --help                    Display this help and exit
	
	With default config this will simply copy all logs to '$TRANSPORT_DEST'.
	EOT
	exit 2
}

# --- parse arguments ---

TEMP=`getopt -o c:l:nsh --long config:,log-level:,dry-run,show-config-sample,help \
	-n archive-logs -- "$@"` || exit 2
eval set -- "$TEMP"

# Defaults
CONFIG="`dirname "$0"`/config.sh"
LOG_LEVEL=1
DRY_RUN=
SHOW_CONFIG_SAMPLE=

while [ "$#" -gt 0 ]; do
	case "$1" in
		-c|--config)
			[ -f "$2" ] || usage "config file '$2' doesn't exist"
			CONFIG="$2"
			shift 2
			;;
		-l|--log-level)
			case "${2^^}" in
				ERROR)      LOG_LEVEL=0 ;;
				WARNING)    LOG_LEVEL=1 ;;
				INFO)       LOG_LEVEL=2 ;;
				DEBUG)      LOG_LEVEL=3 ;;
				*) usage "invalid log level '$2'" ;;
			esac
			shift 2
			;;
		-n|--dry-run)
			DRY_RUN="debug"
			shift
			;;
		-s|--show-config-sample)
			SHOW_CONFIG_SAMPLE="yes"
			shift
			;;
		-h|--help)
			usage
			;;
		--)
			shift
			break
			;;
		*)
			usage "unhandled argument '$1'"
			;;
	esac
done

[ -z "$*" ] || usage "unexpected positional arguments '$*'"

# --- load configuration ---

[ ! -f "$CONFIG" ] || . "$CONFIG"

LOG_IGNORE_PATTERN="!(`IFS='|'; echo "${LOG_IGNORE_PATTERNS[*]}"`)"
COMPRESSED_EXTENSIONS_PATTERN="*.@(`IFS='|'; echo "${COMPRESSED_EXTENSIONS[*]}"`)"

COPY_STRATEGY_FUNC="copy_strategy_$COPY_STRATEGY"

[ "`type -t "$COPY_STRATEGY_FUNC"`" = "function" ] ||
	usage "invalid COPY_STRATEGY '$COPY_STRATEGY' in config"

# --- other service functions ---

log_level_name()
{
	case "$1" in
		0) echo "ERROR" ;;
		1) echo "WARN " ;;
		2) echo "INFO " ;;
		3) echo "DEBUG" ;;
	esac
}

log()
{
	local level="$1"
	shift

	[ "$level" -gt "$LOG_LEVEL" ] ||
		echo "`date --rfc-3339=seconds` `log_level_name "$level"`: $*"
}

error()
{
	log 0 "$@"
}

warn()
{
	log 1 "$@"
}

info()
{
	log 2 "$@"
}

debug()
{
	log 3 "$@"
}

prepare_staging_dir()
{
	info "Preparing staging directory: $STAGING_DIR"
	[ -z "$DRY_RUN" ] || return 0

	rm -rf "$STAGING_DIR"
	mkdir -p "$STAGING_DIR"
}

cleanup_staging_dir()
{
	# This also gets rid of log hardlinks, which could prevent log rotation
	info "Removing staging directory: $STAGING_DIR"
	[ -z "$DRY_RUN" ] || return 0

	rm -rf "$STAGING_DIR"
}

archive_extension()
{
	local path="$1"
	for ext in "${COMPRESSED_EXTENSIONS[@]}"; do
		if [[ $path == *.$ext ]]; then
			echo ".$ext"
			return 0
		fi
	done
}

mangle_path()
{
	local prefix="$1"
	local source="$2"

	local ext=
	local stamp=
	if [ "$prefix" != "$source" ]; then
		ext="`archive_extension "$source"`"
		stamp="`date --utc --reference "$source" +.%Y%m%dT%H%M%SZ`"
	fi

	echo "$prefix$stamp$ext"
}

copy_to_staging()
{
	local prefix="$1"
	local source="$2"
	local target="$STAGING_DIR`mangle_path "$prefix" "$source"`"

	if [ -f "$target" ]; then
		warn "Skip     '$source': target '$target' already exists (same mtime or intersecting globs?)"
		return 0
	fi

	"$COPY_STRATEGY_FUNC" "$source" "$target"
}

compress_to_staging()
{
	local prefix="$1"
	local source="$2"
	local target="$STAGING_DIR`mangle_path "$prefix" "$source"`$COMPRESS_EXT"

	if [ -f "$target" ]; then
		warn "Skip     '$source': target '$target' already exists (same mtime or intersecting globs?)"
		return 0
	fi

	debug "Compress '$source' to '$target'"
	[ -z "$DRY_RUN" ] || return 0

	mkdir -p "`dirname "$target"`"
	compress "$source" "$target"

	chown --reference "$source" "$target"
	chmod --reference "$source" "$target"
	touch --reference "$source" "$target"
}

is_compressed()
{
	local path="$1"
	[[ $path == $COMPRESSED_EXTENSIONS_PATTERN ]]
}

is_processable_log_path()
{
	local path="$1"

	[ -f "$path" ] || {
		debug "Ignore   '$path': not a file"
		return 1
	}
	[[ $path == $LOG_IGNORE_PATTERN ]] || {
		debug "Ignore   '$path': matches an ignore pattern"
		return 1
	}
	log_filter "$path" || {
		debug "Ignore   '$path': rejected by log_filter()"
		return 1
	}

	return 0
}

process_glob()
{
	local glob="$1"
	local path_prefix=

	info "Processing glob: $glob"
	for path in $glob; do
		path="`readlink -m "$path"`"
		is_processable_log_path "$path" || continue

		# 'path_prefix' is the base log path before rotation
		[[ -n $path_prefix && $path == $path_prefix* ]] || path_prefix="$path"

		if ! is_compressed "$path" && [ "$path" != "$path_prefix" ]; then
			compress_to_staging "$path_prefix" "$path"
		else
			copy_to_staging "$path_prefix" "$path"
		fi
	done
}

show_config_sample()
{
	echo "## Configuration for the archive-logs tool. Bash syntax."
	cat "$0" |
		# Take the script part between the markers (empty regexp // reuses last matched one)
		sed -ne "
			/^# --- start of config\.sh parameters ---/,\
			/^# --- end of config\.sh parameters ---/ {
				//! p
			}" |
		# Replace vertical array contents with "# ..." for brevity
		sed -e '
			/^[^#]\+=($/,/^)$/ {
				//! d; /($/ a \\t# ...
			}' |
		# Turn all non-empty lines into comments
		sed -e 's/^.\+/#\0/'
}

# --- main logic ---

if [ -n "$SHOW_CONFIG_SAMPLE" ]; then
	show_config_sample
	exit 0
fi

info "Running from: `readlink -m "$0"`"
[ ! -f "$CONFIG" ] || info "Config in use: `readlink -m "$CONFIG"`"

prepare_staging_dir
trap -- 'cleanup_staging_dir' EXIT

for glob in "${LOG_GLOBS[@]}"; do
	process_glob "$glob"
done

info "Transferring `find -L "$STAGING_DIR" -type f | wc -l` logs from '$STAGING_DIR' to storage"
[ -n "$DRY_RUN" ] || transport "$STAGING_DIR"
info "Transfer to storage finished"

# vim: set ts=4 sts=4 sw=4 noet ai:
